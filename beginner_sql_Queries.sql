-- Task 1.Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

INSERT INTO books 
VALUES( '978-1-60129-456-2', 
		'To Kill a Mockingbird', 
        'Classic', 
         6.00, 
        'yes', 
        'Harper Lee', 
        'J.B. Lippincott & Co.')
;
SELECT 
    *
FROM
    books
WHERE
    isbn = '978-1-60129-456-2';
    
    
-- Task 2.Update an Existing Member's Address

UPDATE members 
SET 
    member_address = 'L-124, mysore'
WHERE
    member_address = '123 Main St';


-- Task 3.Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

SELECT 
    *
FROM
    issued_status
WHERE
    issued_id = 'IS121';
    
DELETE
FROM
    issued_status
WHERE
    issued_id = 'IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT 
    *
FROM
    issued_status 
WHERE
    issued_emp_id = 'E101';
    
    
-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id , count(*) no_book_issued
from issued_status
group by issued_emp_id
having count(*)>1
;

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table books_issued_cnt 
as
SELECT 
    b.isbn, b.book_title, COUNT(ist.issued_id)
FROM
    books b
        JOIN
    issued_status ist ON b.isbn = ist.issued_book_isbn
GROUP BY 1 , 2
;

select * from books_issued_cnt;


-- DATA ANALYSIS FINDINGS
-- Task 7: Retrieve All Books in a Specific Category:
SELECT 
    *
FROM
    books
WHERE
    category = 'classic';


-- Task 8: Find Total Rental Income by Category:
SELECT 
    b.category, SUM(b.rental_price) total_rentals,COUNT(*) total_count
FROM
    books b
        JOIN
        
    issued_status ist ON b.isbn = ist.issued_book_isbn
GROUP BY 1 ;


-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT 
    *
FROM
    members
WHERE
    reg_date >= CURDATE() - 180;

insert into members value ('C120','Kushal Babu','25/1 bangalore','2025-03-25');

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.*,
    br.manager_id,
    e2.emp_name as manager
FROM
    employees e1
        JOIN
    branch br ON  br.branch_id = e1.branch_id 
		JOIN
	employees e2 ON br.manager_id = e2.emp_id 	
    ;


-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE above_certain_price
AS
SELECT 
    *
FROM
    books
WHERE
    rental_price > 7;
    

SELECT 
    *
FROM
    above_certain_price;



-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
    ist.issued_book_name
FROM
    issued_status ist
        LEFT JOIN
    return_status rst ON ist.issued_id = rst.issued_id
WHERE
    rst.return_id IS NULL;














