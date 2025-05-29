USE CMPT391S2025;

-- Retrieve all students
SELECT student_id, first_name, last_name
FROM student;

-- Retrieve all departments
SELECT department_id, department_name
FROM department;

-- -- execute the procedure to create the materialized view if you didn't run it during creation:
-- EXEC createMaterializedView;

-- confirm data population
--SELECT student_id, first_name, last_name FROM student;
--SELECT department_id, department_name FROM department;
--SELECT COUNT(*) AS StudentCount FROM dbo.student;
--SELECT COUNT(*) AS CourseInstanceCount FROM dbo.course_instance;

-- retrieve all students and their registration information from the materialized view
--SELECT * FROM view_student_registration;
EXEC dbo.GetAvailableCourseInstances;


