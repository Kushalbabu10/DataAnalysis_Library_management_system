

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  


This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/Kushalbabu10/DataAnalysis_Library_management_system/blob/main/Library_DataAnalysis_ERD.png)
- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
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
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members 
SET 
    member_address = 'L-124, mysore'
WHERE
    member_address = '123 Main St';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
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
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT 
    *
FROM
    issued_status 
WHERE
    issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
    issued_emp_id, COUNT(*) no_book_issued
FROM
    issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
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
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT 
    *
FROM
    books
WHERE
    category = 'classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category, SUM(b.rental_price) total_rentals,COUNT(*) total_count
FROM
    books b
        JOIN
        
    issued_status ist ON b.isbn = ist.issued_book_isbn
GROUP BY 1 ;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT 
    *
FROM
    members
WHERE
    reg_date >= CURDATE() - 180;

insert into members value ('C120','Kushal Babu','25/1 bangalore','2025-03-25');
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
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
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
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
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
    ist.issued_book_name
FROM
    issued_status ist
        LEFT JOIN
    return_status rst ON ist.issued_id = rst.issued_id
WHERE
    rst.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
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
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

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
```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```


**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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



-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;
CALL issue_book('IS155', 'C120', '978-0-06-112008-4', 'E110');
CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

```




## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


