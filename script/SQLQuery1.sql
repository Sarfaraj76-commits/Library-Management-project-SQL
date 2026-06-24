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








