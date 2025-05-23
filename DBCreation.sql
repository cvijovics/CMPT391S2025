-- was having trouble with 'GO' methods

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'CMPT391S2025')
BEGIN
    CREATE DATABASE CMPT391S2025;
END
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
)

CREATE TABLE instructor (
    instructor_id INT PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES department(department_id)
)

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
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id)
)

-- Table to track student registrations for course instances, if they've taken the course before, and if they are currently enrolled
CREATE TABLE registration (
    course_instance_id INT,
    student_id INT,
    registration_date DATE NOT NULL,
    is_currently_enrolled BIT NOT NULL, -- 1 for true, 0 for false
    FOREIGN KEY (course_instance_id) REFERENCES course_instance(course_instance_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id)
)

-- Table to track prerequisites for courses
CREATE TABLE prerequisite (
    course_id INT,
    prerequisite_course_id INT,
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    FOREIGN KEY (prerequisite_course_id) REFERENCES course(course_id)
)