# Library-Management-project-SQL

## Project Overview
Project Title: Library Management System
Database: library_db

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives
1.  Set up the Library Management System Database: Create and populate the database with tables for branches, employees,      members, books, issued status, and return status.
2. CRUD Operations: Perform Create, Read, Update, and Delete operations on the data.
3. CTAS (Create Table As Select): Utilize CTAS to create new tables based on query results.
4. Advanced SQL Queries: Develop complex queries to analyze and retrieve specific data.

## Project Structure
- **Database Creation :** Created a database named library_db.
- **Table Creation:** Created tables for branches, employees, members, books, issued status, and return status. Each table  includes relevant columns and relationships.
- **Database setup :**
 <img width="524" height="338" alt="image" src="https://github.com/user-attachments/assets/2af2dee4-c8fa-4e70-bcdd-68dc112d7525" />
 
 create database library_project_2
use library_project_2


-------- foreign key----
alter table issued_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issued_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issued_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

ALTER TABLE issued_status
ALTER COLUMN issued_emp_id nvarchar(10);


alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

ALTER TABLE employees
ALTER COLUMN branch_id nvarchar(50);

alter table return_status
add constraint fk_issued_status
foreign key (issued_id)
references issued_status(issued_id);


SELECT issued_id
FROM issued_status
WHERE issued_id NOT IN (SELECT issued_id FROM issued_status);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);


## 2. CRUD Operations
- **Create:** Inserted sample records into the books table.
- **Read:** Retrieved and displayed data from various tables.
- **Update:** Updated records in the employees table.
- **Delete:** Removed records from the members table as needed.

--========================Project Task===============================--
/* Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')" */

insert into books(isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

/* Task 2: Update an Existing Member's Address */

select * from members;
update members
set member_address='123 Main state'
where member_id='C101'

/* Delete a Record from the Issued Status Table */
select * from issued_status;
delete from issued_status
where issued_id='IS111'

/* Task 4: Retrieve All Books Issued by a Specific Employee -- 
Objective: Select all books issued by the employee with emp_id = 'E101'.*/

select * from issued_status
where issued_emp_id='E101'

/* Task 5: List Members Who Have Issued More Than One Book --
Objective: Use GROUP BY to find members who have issued more than one book.*/

SELECT 
    issued_emp_id,
    COUNT(*) AS total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;

/*Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - 
each book and total book_issued_cnt* */



WITH book_issued_cnt AS (
    SELECT
        ist.issued_book_isbn,
        b.book_title,
        b.category,
        COUNT(ist.issued_id) AS issued_count
    FROM issued_status AS ist
    JOIN books AS b
        ON ist.issued_book_isbn = b.isbn
    GROUP BY 
        ist.issued_book_isbn,
        b.book_title,
        b.category
)
SELECT * 
FROM book_issued_cnt;


-- Task 7. Retrieve All Books in a Specific Category: --
Select * from books
where category='Classic'

--- Task 8: Find Total Rental Income by Category:---

Select 
b.category,
sum(b.rental_price) as Total_rental_income,
COUNT(*)

 from books as b
join issued_status as ist
on b.isbn=ist.issued_book_isbn
group by b.category;

-- List Members Who Registered in the Last 180 Days:--
-- List Members Who Registered in the Last 180 Days
SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, 180, GETDATE());

--- List Employees with Their Branch Manager's Name and their branch details: ---
select 
e.emp_id,
e.emp_name,
e.position,
e.salary,
e.branch_id,
b.manager_id,
b.branch_address,
b.contact_no,
e2.emp_name
from employees as e
join branch as b
on e.branch_id=b.branch_id
join employees as e2
on b.manager_id=e2.emp_id

--- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold: ----

with expensive_book as (
	select 
	*
	 from books
	 where rental_price>=7.00
	)
	select * from expensive_book


	-- Task 12: Retrieve the List of Books Not Yet Returned ---
	SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

/* Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue. */

-- List overdue books (more than 30 days)
SELECT
    ist.issued_member_id,
    mb.member_name,
    bk.book_title,
    ist.issued_date,
    rs.return_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE()) AS over_dues_days
FROM issued_status AS ist
JOIN members AS mb
    ON ist.issued_member_id = mb.member_id
JOIN books AS bk
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
  AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
ORDER BY ist.issued_member_id;



/* Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" 
when they are returned (based on entries in the return_status table). */

-----Create store procedure-----
create procedure add_return_record
@p_return_id varchar(10),
@p_issued_id varchar(10),
@p_book_quality varchar(10)

as
 SET NOCOUNT ON;
begin
	declare @v_isbn varchar(50);
	declare @v_book_name varchar(50);

	
----insert into return status---
insert into return_status(return_id,issued_id,return_date,book_quality)
					values(@p_return_id,@p_issued_id,cast(GETDATE() as date),@p_book_quality);
	  -- Get book details from issued_status--
	  select
	  @v_book_name=issued_book_name,
	  @v_isbn=issued_book_isbn
	from issued_status
	where issued_id=@p_issued_id;

	 -- Update book status--
	 update books
	 set status='yes'
	 where isbn=@v_isbn;

	  -- Print message
    PRINT 'Thank you for returning the book: ' + @v_book_name;
end;
go

exec add_return_record ('rs121','IS101','good');

exec add_return_record ('rs121','IS101','good');


select * from return_status

-- Positional parameters (no parentheses)
EXEC add_return_record 'rs121', 'IS101', 'good';

-- Or with named parameters
EXEC add_return_record 
    @p_return_id = 'rs121',
    @p_issued_id = 'IS101',
    @p_book_quality = 'good';

ALTER TABLE return_status
ALTER COLUMN return_book_name VARCHAR(50) NULL;

ALTER TABLE return_status
ALTER COLUMN return_book_isbn VARCHAR(50) NULL;

select * from return_status

exec add_return_record 'rs122','is1022','goog'


/* Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, 
showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.*/

WITH Branch_report AS (
    SELECT 
        br.branch_id,
        br.manager_id,
        COUNT(ist.issued_id) AS Nr_book_issued,
        COUNT(rs.return_id) AS NR_book_returned,
        SUM(bk.rental_price) AS Total_revenue
    FROM issued_status AS ist
    JOIN employees AS em
        ON ist.issued_emp_id = em.emp_id
    JOIN branch AS br
        ON em.branch_id = br.branch_id
    LEFT JOIN return_status AS rs
        ON rs.issued_id = ist.issued_id
    JOIN books AS bk
        ON ist.issued_book_isbn = bk.isbn
    GROUP BY br.branch_id, br.manager_id
)
SELECT * FROM Branch_report;

## 📝 Task 2: Update an Existing Member's Address

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';



