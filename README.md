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
 
 ## 🗄️ Database Setup – Foreign Keys and Constraints

```sql
-- Create Database---
CREATE DATABASE library_project_2;
USE library_project_2;

-- Add Foreign Keys to issued_status
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

-- Adjust column type for issued_emp_id
ALTER TABLE issued_status
ALTER COLUMN issued_emp_id NVARCHAR(10);

-- Add Foreign Key to employees
ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

-- Adjust column type for branch_id
ALTER TABLE employees
ALTER COLUMN branch_id NVARCHAR(50);

-- Add Foreign Key to return_status
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

-- Validation Query Example
SELECT issued_id
FROM issued_status
WHERE issued_id NOT IN (SELECT issued_id FROM issued_status);

-- Re-add Foreign Key (if needed)
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);
```

## 2. CRUD Operations
- Create: Inserted sample records into the books table.
- Read: Retrieved and displayed data from various tables.
- Update: Updated records in the employees table.
- Delete: Removed records from the members table as needed.

## 📚 Library Management Project Tasks

### 🗄️ SQL Queries

--========================Project Task================================
# 📚 Library Management System – SQL Tasks

## 🗄️ Task 1: Create a New Book Record
```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

## 🗄️ Task 2: Update an Existing Member's Address
```sql
UPDATE members
SET member_address = '123 Main state'
WHERE member_id = 'C101';
```

## 🗄️ Task 3: Delete a Record from Issued Status
```sql
DELETE FROM issued_status
WHERE issued_id = 'IS111';
```

## 🗄️ Task 4: Retrieve All Books Issued by a Specific Employee
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```

## 🗄️ Task 5: List Members Who Have Issued More Than One Book
```sql
SELECT issued_emp_id, COUNT(*) AS total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;
```

## 🗄️ Task 6: Create Summary Table of Issued Books
```sql
WITH book_issued_cnt AS (
    SELECT ist.issued_book_isbn, b.book_title, b.category,
           COUNT(ist.issued_id) AS issued_count
    FROM issued_status AS ist
    JOIN books AS b ON ist.issued_book_isbn = b.isbn
    GROUP BY ist.issued_book_isbn, b.book_title, b.category
)
SELECT * FROM book_issued_cnt;
```

## 🗄️ Task 7: Retrieve All Books in a Specific Category
```sql
SELECT * FROM books
WHERE category = 'Classic';
```

## 🗄️ Task 8: Find Total Rental Income by Category
```sql
SELECT b.category, SUM(b.rental_price) AS Total_rental_income, COUNT(*)
FROM books AS b
JOIN issued_status AS ist ON b.isbn = ist.issued_book_isbn
GROUP BY b.category;
```

## 🗄️ Task 9: List Members Who Registered in the Last 180 Days
```sql
SELECT * FROM members
WHERE reg_date >= DATEADD(DAY, -180, GETDATE());
```

## 🗄️ Task 10: List Employees with Their Branch Manager's Name
```sql
SELECT e.emp_id, e.emp_name, e.position, e.salary, e.branch_id,
       b.manager_id, b.branch_address, b.contact_no, e2.emp_name AS manager_name
FROM employees AS e
JOIN branch AS b ON e.branch_id = b.branch_id
JOIN employees AS e2 ON b.manager_id = e2.emp_id;
```

## 🗄️ Task 11: Books with Rental Price Above Threshold
```sql
WITH expensive_book AS (
    SELECT * FROM books WHERE rental_price >= 7.00
)
SELECT * FROM expensive_book;
```

## 🗄️ Task 12: Retrieve Books Not Yet Returned
```sql
SELECT * 
FROM issued_status AS ist
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

## 🗄️ Task 13: Identify Members with Overdue Books
```sql
SELECT ist.issued_member_id, mb.member_name, bk.book_title,
       ist.issued_date, rs.return_date,
       DATEDIFF(DAY, ist.issued_date, GETDATE()) AS over_dues_days
FROM issued_status AS ist
JOIN members AS mb ON ist.issued_member_id = mb.member_id
JOIN books AS bk ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
  AND DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30
ORDER BY ist.issued_member_id;
```

## 🗄️ Task 14: Stored Procedure – Update Book Status on Return
```sql
CREATE PROCEDURE add_return_record
    @p_return_id VARCHAR(10),
    @p_issued_id VARCHAR(10),
    @p_book_quality VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_isbn VARCHAR(50);
    DECLARE @v_book_name VARCHAR(50);

    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (@p_return_id, @p_issued_id, CAST(GETDATE() AS DATE), @p_book_quality);

    SELECT @v_book_name = issued_book_name,
           @v_isbn = issued_book_isbn
    FROM issued_status
    WHERE issued_id = @p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbn = @v_isbn;

    PRINT 'Thank you for returning the book: ' + @v_book_name;
END;
GO

EXEC add_return_record 'rs121', 'IS101', 'good';
```

## 🗄️ Task 15: Branch Performance Report
```sql
WITH Branch_report AS (
    SELECT br.branch_id, br.manager_id,
           COUNT(ist.issued_id) AS Nr_book_issued,
           COUNT(rs.return_id) AS NR_book_returned,
           SUM(bk.rental_price) AS Total_revenue
    FROM issued_status AS ist
    JOIN employees AS em ON ist.issued_emp_id = em.emp_id
    JOIN branch AS br ON em.branch_id = br.branch_id
    LEFT JOIN return_status AS rs ON rs.issued_id = ist.issued_id
    JOIN books AS bk ON ist.issued_book_isbn = bk.isbn
    GROUP BY br.branch_id, br.manager_id
)
SELECT * FROM Branch_report;
```
```

---

✨ This layout keeps **all tasks on one page** with clear headings and SQL code blocks. You can copy-paste this directly into your GitHub README, and it will render beautifully with syntax highlighting.  

Would you like me to also add a **Table of Contents** at the top so readers can jump directly to each task?
