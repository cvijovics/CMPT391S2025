--Checks if the database exists, if not, creates it
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DummyDB')
BEGIN
    CREATE DATABASE DummyDB;
END
GO
USE DummyDB;
GO

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
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    FOREIGN KEY (instructor_id) REFERENCES instructor(instructor_id)
)

CREATE TABLE registration (
    course_instance_id INT,
    student_id INT,
    FOREIGN KEY (course_instance_id) REFERENCES course_instance(course_instance_id),
    FOREIGN KEY (student_id) REFERENCES student(student_id)
)

CREATE TABLE prerequisite (
    course_id INT,
    prerequisite_course_id INT,
    FOREIGN KEY (course_id) REFERENCES course(course_id),
    FOREIGN KEY (prerequisite_course_id) REFERENCES course(course_id)
)

