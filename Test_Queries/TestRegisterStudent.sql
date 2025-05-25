-- make sure view exists
SELECT * 
FROM sys.views 
WHERE name = 'view_student_registration';
GO

-- -- if any of these return errors, likely problem
-- USE CMPT391S2025;
-- GO
-- SELECT * FROM dbo.student;
-- SELECT * FROM dbo.registration;
-- SELECT * FROM dbo.course_instance;
-- SELECT * FROM dbo.course;
-- GO

-- clear from previous testing
DELETE FROM registration
WHERE student_id = 1 AND course_instance_id = 11;
GO

-- try a dummy registration (FILM 230, student '1')
EXEC dbo.RegisterStudentForCourse @StudentID = 1, @CourseInstanceID = 11;

-- view results:
SELECT *
FROM dbo.view_student_registration
WHERE student_id = 1;
GO


