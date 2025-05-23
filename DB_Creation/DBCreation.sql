-- DB Creation Script

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CMPT391S2025')
BEGIN
    CREATE DATABASE CMPT391S2025;
END
GO
-- Test - if row shows server name, server is set up
-- SELECT name FROM sys.databases WHERE name = 'CMPT391S2025';

-- SELECT COLUMN_NAME 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'student';

-- SELECT COLUMN_NAME 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'department';

USE CMPT391S2025;

-- Drop existing tables if they exist
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_department_head')
BEGIN
    ALTER TABLE department DROP CONSTRAINT fk_department_head;
END

IF OBJECT_ID('registration', 'U') IS NOT NULL DROP TABLE registration;
IF OBJECT_ID('course_instance', 'U') IS NOT NULL DROP TABLE course_instance;
IF OBJECT_ID('prerequisite', 'U') IS NOT NULL DROP TABLE prerequisite;
IF OBJECT_ID('course', 'U') IS NOT NULL DROP TABLE course;
IF OBJECT_ID('student', 'U') IS NOT NULL DROP TABLE student;
IF OBJECT_ID('instructor', 'U') IS NOT NULL DROP TABLE instructor;
IF OBJECT_ID('department', 'U') IS NOT NULL DROP TABLE department;

CREATE TABLE department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
	department_head_id INT -- FK added later
)

CREATE TABLE instructor (
    instructor_id INT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) 
		REFERENCES department(department_id)
		ON DELETE SET NULL
		ON UPDATE CASCADE
)

 -- Handling circular FK reference
 -- Need to manually delete/update department head on instructor update/deletion
 ALTER TABLE department
 ADD CONSTRAINT fk_department_head
 FOREIGN KEY (department_head_id)
 	REFERENCES instructor(instructor_id)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION;

CREATE TABLE student (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL
)

CREATE TABLE course (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL
)

-- Table to track course instances, including the instructor, start and end dates, times, days of the week, and occupancy
CREATE TABLE course_instance
(
    course_instance_id INT PRIMARY KEY,
    course_id INT,
    instructor_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    days_of_week VARCHAR(3) NOT NULL, -- e.g., 'MWF' for Monday, Wednesday, Friday, 'TT' for Tuesday, Thursday
    max_occupancy INT NOT NULL, 
    current_occupancy INT NOT NULL,
    FOREIGN KEY (course_id) 
		REFERENCES course(course_id)
		ON DELETE CASCADE -- Delete course_instance if course is deleted
		ON UPDATE CASCADE,
    FOREIGN KEY (instructor_id) 
		REFERENCES instructor(instructor_id)
		ON DELETE SET NULL -- Keep course_instance if instructor is deleted
		ON UPDATE CASCADE
)

-- Table to track student registrations for course instances, if they've taken the course before, and if they are currently enrolled
CREATE TABLE registration (
    course_instance_id INT,
    student_id INT,
    registration_date DATE NOT NULL,
    course_completed BIT NOT NULL, -- 1 for true, 0 for false
    FOREIGN KEY (course_instance_id) 
		REFERENCES course_instance(course_instance_id)
		ON DELETE SET NULL -- Keep registration records for deprecated courses.
		ON UPDATE CASCADE,
    FOREIGN KEY (student_id)
		REFERENCES student(student_id)
		ON DELETE CASCADE -- Delete registration records for students that aren't in the system
		ON UPDATE CASCADE
)


-- Table to track prerequisites for courses
CREATE TABLE prerequisite (
    course_id INT,
    prerequisite_course_id INT,
    FOREIGN KEY (course_id) 
		REFERENCES course(course_id)
		ON DELETE NO ACTION -- Need to manually delete or update prerequisite when a course_id is changed
		ON UPDATE NO ACTION,
    FOREIGN KEY (prerequisite_course_id) 
		REFERENCES course(course_id)
		ON DELETE NO ACTION -- Need to manually delete or update prerequisite when a course_id is changed
		ON UPDATE NO ACTION
)