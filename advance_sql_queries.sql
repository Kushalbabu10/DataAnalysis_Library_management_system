-- ADVANCE DATA ANALYSIS QUERIES	
/*
-- Task 13: Identify Members with Overdue Books
	 Write a query to identify members who have overdue books (assume a 30-day return period).
	 Display the member's_id, member's name, book title, issue date, and days overdue.
*/
SELECT 
    ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    CURRENT_DATE() - ist.issued_date AS overdue_days
FROM
    issued_status ist
        JOIN
    members m ON ist.issued_member_id = m.member_id
        JOIN
    books b ON ist.issued_book_isbn = b.isbn
        LEFT JOIN
    return_status rst ON ist.issued_id = rst.issued_id
WHERE
    rst.return_date IS NULL
        AND CURDATE() - ist.issued_date > 30
ORDER BY 1;

/*
-- Task 14: Update Book Status on Return
	 Write a query to update the status of books in the books table to "Yes" when they are returned 
	 (based on entries in the return_status table).
*/

-- doing the updation manually
-- in books table
SELECT 
    *
FROM
    books
WHERE
    isbn = '978-0-451-52994-2';
-- manually updating the status to 'NO'
UPDATE books 
SET 
    `status` = 'no'
WHERE
    isbn = '978-0-375-50167-0';
-- manually updating the status to 'YES'
UPDATE books 
SET 
    `status` = 'yes'
WHERE
    isbn = '978-0-451-52994-2';

-- manually getting the issued_id from the isbn
SELECT 
    *
FROM
    issued_status
WHERE
    issued_book_isbn = '978-0-451-52994-2';

-- checking the return_status of the book using issued_id
SELECT 
    *
FROM
    return_status
WHERE
    issued_id = 'IS130';
-- inserting the return records manually in the return_status table
insert into return_status
values ('RS119','IS130','Moby Dick',curdate(),'978-0-451-52994-2','Good');

-- Doing it using STORED PROCEDURE
DELIMITER $$

CREATE PROCEDURE adding_return_records(
    IN p_return_id VARCHAR(15), 
    IN p_issued_id VARCHAR(15), 
    IN p_book_quality VARCHAR(15)
)
BEGIN
    DECLARE d_isbn VARCHAR(25);
    DECLARE d_book_name VARCHAR(75);

    -- Insert into return_status
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURDATE(), p_book_quality);

    -- Get ISBN and book name from issued_status
    SELECT issued_book_isbn, issued_book_name
    INTO d_isbn, d_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status in books table
    UPDATE books 
    SET `status` = 'yes'
    WHERE isbn = d_isbn;

    -- Display a message (MySQL doesn't support RAISE NOTICE like PostgreSQL)
    SELECT CONCAT('Thank you for returning the book: ', d_book_name) AS Message;
END $$

DELIMITER ;

-- calling the stored procedure for the book having issued id IS153
CALL adding_return_records('RS120', 'IS153', 'Good');

SELECT 
    *
FROM
    books
WHERE
    isbn = '978-0-14-143951-8';
    
-- calling the stored procedure for the book having issued id IS154
SELECT 
    *
FROM
    return_status
WHERE
    issued_id = 'IS154';
-- its not returned yet

-- geting the isbn using issued_id from the issued_status table
SELECT 
    *
FROM
    issued_status
WHERE
    issued_id = 'IS154';
    
-- checking the status of the book with 978-0-375-50167-0 in books table 
SELECT 
    *
FROM
    books
WHERE
    isbn = '978-0-375-50167-0';
-- its shows NO
-- calling the stored procedure
CALL adding_return_records('RS121', 'IS154', 'Good');

/*
-- Task 15: Branch Performance Report 
	 Create a query that generates a performance report for each branch,
	 showing the number of books issued, 
	 the number of books returned, 
	 and the total revenue generated from book rentals.
*/
CREATE TABLE revenue_per_branch AS 
	(
		SELECT br.branch_id,
		br.manager_id,
		COUNT(ist.issued_id) AS nof_book_issued,
		COUNT(rst.return_id) AS nof_book_return,
		SUM(b.rental_price) AS total_revenue 
        FROM
		issued_status AS ist
			JOIN
		employees e ON ist.issued_emp_id = e.emp_id
			JOIN
		branch br ON e.branch_id = br.branch_id
			LEFT JOIN
		return_status rst ON ist.issued_id = rst.issued_id
			JOIN
		books b ON ist.issued_book_isbn = b.isbn
		GROUP BY br.branch_id , br.manager_id
    )
;

SELECT 
    *
FROM
    revenue_per_branch;
    
/*
-- Task 16: CTAS: Create a Table of Active Members
	 Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
	 containing members who have issued at least one book in the last 2 months.
*/ 
CREATE TABLE active_users AS 
	(
		SELECT 
			* 
        FROM
			members
		WHERE
			member_id IN 
        (
			SELECT DISTINCT
				issued_member_id
			FROM
				issued_status
			WHERE
				issued_date >= CURDATE() - INTERVAL 6 MONTH
		)
	)
;

SELECT 
	* 
FROM			
	active_users;
    
    
/*
-- Task 17: Find Employees with the Most Book Issues Processed
	 Write a query to find the top 3 employees who have processed the most book issues.
	 Display the employee name, number of books processed, and their branch.
 */
SELECT 
    e.emp_name,
    br.*,
    COUNT(ist.issued_id) AS nof_books_issued
FROM
    issued_status ist
        JOIN
    employees e ON ist.issued_emp_id = e.emp_id
		JOIN
	branch br ON e.branch_id = br.branch_id
GROUP BY 1,2
ORDER BY 6 DESC;



/*
Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
	Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
	The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
	The procedure should first check if the book is available (status = 'yes'). 
	If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
	If the book is not available (status = 'no'), 
	the procedure should return an error message indicating that the book is currently not available.
*/

DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(15),
    IN p_issued_member_id VARCHAR(15),
    IN p_issued_book_isbn VARCHAR(25),
    IN p_issued_emp_id VARCHAR(15)
)
BEGIN
    DECLARE d_status VARCHAR(15);

    -- Check book availability
    SELECT `status` INTO d_status 
    FROM books 
    WHERE isbn = p_issued_book_isbn;

    IF d_status = 'yes' THEN
        -- Insert into issued_status
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);

        -- Update book status
        UPDATE books 
        SET `status` = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Success message
        SELECT CONCAT('Book record added for ISBN: ', p_issued_book_isbn) AS Message;
    ELSE
        -- Book unavailable message
        SELECT CONCAT('The book you are requesting is currently unavailable. ISBN: ', p_issued_book_isbn) AS Message;
    END IF;
END $$

DELIMITER ;

CALL issue_book('IS155', 'C120', '978-0-06-112008-4', 'E110');




















 
 