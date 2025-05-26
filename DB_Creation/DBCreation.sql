----------------------------------------------------------------
-- Experimenting with Automating Data Pop - Can ignore
-- Set your database path manually first HERE (if using SQLCMD to automate data pop, otherwise comment this out)
----------------------------------------------------------------

-- :setvar ScriptPath "C:\Users\crazy\Documents\School\Spring-Summer 2025\CMPT 391\Project 1\CMPT391S2025\DB_Creation" -- eg. C:\Users\USER\Documents\School\Spring-Summer 2025\CMPT 391\Project 1\CMPT391S2025\DB_Creation
-- Right-click "DB Creation" folder in Explorer (if using VS Code) and select "copy path", then replace path above

----------------------------------------------------------------
-- Full Database Creation, Seeding, and Materialized View Setup
----------------------------------------------------------------

USE CMPT391S2025;
GO

----------------------------------------
-- 1. Drop dependent objects first
----------------------------------------

-- Drop the materialized view if it exists
IF OBJECT_ID('dbo.view_student_registration', 'V') IS NOT NULL
    DROP VIEW dbo.view_student_registration;
GO

-- Drop foreign key constraints that might block table drops
IF OBJECT_ID('fk_department_head', 'F') IS NOT NULL 
BEGIN
    ALTER TABLE department DROP CONSTRAINT fk_department_head;
END
GO

----------------------------------------
-- 2. Drop tables in proper order
----------------------------------------
IF OBJECT_ID('registration', 'U') IS NOT NULL DROP TABLE registration;
GO
IF OBJECT_ID('course_instance', 'U') IS NOT NULL DROP TABLE course_instance;
GO
IF OBJECT_ID('prerequisite', 'U') IS NOT NULL DROP TABLE prerequisite;
GO
IF OBJECT_ID('course', 'U') IS NOT NULL DROP TABLE course;
GO
IF OBJECT_ID('student', 'U') IS NOT NULL DROP TABLE student;
GO
IF OBJECT_ID('instructor', 'U') IS NOT NULL DROP TABLE instructor;
GO
IF OBJECT_ID('department', 'U') IS NOT NULL DROP TABLE department;
GO

----------------------------------------
-- 3. Re-create tables
----------------------------------------

CREATE TABLE department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_head_id INT  -- FK will be added later
);
GO

CREATE TABLE instructor (
    instructor_id INT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) 
        REFERENCES department(department_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
GO

ALTER TABLE department
ADD CONSTRAINT fk_department_head
    FOREIGN KEY (department_head_id)
        REFERENCES instructor(instructor_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION;
GO

CREATE TABLE student (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL
);
GO

CREATE TABLE course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
);
GO

CREATE TABLE course_instance
(
    course_instance_id INT PRIMARY KEY,
    course_id INT,
    instructor_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    days_of_week VARCHAR(3) NOT NULL,
    max_occupancy INT NOT NULL, 
    current_occupancy INT NOT NULL,
    FOREIGN KEY (course_id) 
        REFERENCES course(course_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (instructor_id) 
        REFERENCES instructor(instructor_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
GO

CREATE TABLE registration (
    course_instance_id INT,
    student_id INT,
    registration_date DATE NOT NULL,
    course_completed BIT NOT NULL,
    FOREIGN KEY (course_instance_id) 
        REFERENCES course_instance(course_instance_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (student_id)
        REFERENCES student(student_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
GO

CREATE TABLE prerequisite (
    course_id INT,
    prerequisite_course_id INT,
    FOREIGN KEY (course_id) 
        REFERENCES course(course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (prerequisite_course_id) 
        REFERENCES course(course_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

IF OBJECT_ID('dbo.ShoppingCart', 'U') IS NOT NULL DROP TABLE dbo.ShoppingCart;
GO

CREATE TABLE dbo.ShoppingCart (
    ShoppingCartID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    CourseInstanceID INT NOT NULL,
    CourseID INT NOT NULL,
    AddedDate DATETIME NOT NULL
);
GO

----------------------------------------
-- More Automation Experimentation
-- 4. Insert sample data automatically
----------------------------------------

-- -- Insert prerequisite data (`SQLCMD = On` required - otherwise comment out these commands and run the insert scripts, in this order:
-- -- department, student, instructor, course, instance

-- :r "$(ScriptPath)\Department_Insert.sql"
-- :r "$(ScriptPath)\Student_Insert.sql"
-- :r "$(ScriptPath)\Instructor_Insert.sql"
-- :r "$(ScriptPath)\Course_Insert.sql"
-- :r "$(ScriptPath)\Instance_Insert.sql"

----------------------------------------
-- 5. Create & execute the materialized view procedure
----------------------------------------

-- -- Ensure you're in the correct database context
-- USE CMPT391S2025;
-- GO

-- -- Drop the view if it exists
-- IF OBJECT_ID('dbo.view_student_registration', 'V') IS NOT NULL
--     DROP VIEW dbo.view_student_registration;
-- GO

-- -- Create the materialized view with schemabinding
-- CREATE VIEW dbo.view_student_registration
-- WITH SCHEMABINDING
-- AS
--     SELECT
--         s.student_id,
--         r.course_instance_id, 
--         c.course_id, 
--         r.course_completed,
--         c.course_name, 
--         i.start_date, 
--         i.end_date, 
--         i.start_time, 
--         i.end_time,
--         i.days_of_week
--     FROM dbo.student s
--     JOIN dbo.registration r ON s.student_id = r.student_id
--     JOIN dbo.course_instance i ON r.course_instance_id = i.course_instance_id
--     JOIN dbo.course c ON i.course_id = c.course_id;
-- GO

-- -- Create a unique clustered index on the view to materialize it
-- CREATE UNIQUE CLUSTERED INDEX idx_student_registration
-- ON dbo.view_student_registration(student_id);
-- GO

-- PRINT 'Materialized view and index created successfully.';
-- GO

----------------------------------------
-- 6. Potentially Automate Stored Procedures Here, once we've determined all that are necessary
----------------------------------------