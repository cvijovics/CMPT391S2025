-- refresh to avoid compiling issues
-- EXEC sp_refreshsqlmodule 'dbo.ValidateStudentRegistration';
-- GO
-- USE CMPT391S2025;

USE CMPT391S2025;
GO

PRINT '--- Data and Object Verification ---';

-- Check row counts for key tables
SELECT 'department' AS [Table], COUNT(*) AS [RowCount] FROM dbo.department
UNION ALL
SELECT 'student', COUNT(*) FROM dbo.student
UNION ALL
SELECT 'instructor', COUNT(*) FROM dbo.instructor
UNION ALL
SELECT 'course', COUNT(*) FROM dbo.course
UNION ALL
SELECT 'course_instance', COUNT(*) FROM dbo.course_instance
UNION ALL
SELECT 'registration', COUNT(*) FROM dbo.registration
UNION ALL
SELECT 'ShoppingCart', COUNT(*) FROM dbo.ShoppingCart;
GO

-- Verify the materialized view exists and check its row count
IF EXISTS (SELECT * FROM sys.views WHERE name = 'view_student_registration' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Materialized view dbo.view_student_registration exists.';
    SELECT COUNT(*) AS ViewRowCount FROM dbo.view_student_registration;
END
ELSE
BEGIN
    PRINT 'Materialized view dbo.view_student_registration does NOT exist.';
END
GO

-- Optionally, show a few sample rows from each table for additional verification
PRINT '--- Sample Data from Key Tables ---';
SELECT TOP 5 * FROM dbo.department;
SELECT TOP 5 * FROM dbo.student;
SELECT TOP 5 * FROM dbo.instructor;
SELECT TOP 5 * FROM dbo.course;
SELECT TOP 5 * FROM dbo.course_instance;
SELECT TOP 5 * FROM dbo.registration;
SELECT TOP 5 * FROM dbo.ShoppingCart;
GO

PRINT '--- Data Verification Complete ---';
GO

-- Make sure the materialized view exists
SELECT * 
FROM sys.views 
WHERE name = 'view_student_registration';
GO

-- Clear data from previous tests (if needed)
DELETE FROM registration
WHERE student_id = 1 AND course_instance_id = 11;
GO

DELETE FROM ShoppingCart
WHERE StudentID = 1 AND CourseInstanceID = 11;
GO

-- Call the validation procedure
PRINT '--- Running Validation Procedure ---';
EXEC dbo.ValidateStudentRegistration @StudentID = 1, @CourseInstanceID = 11;
GO

-- Check what's been loaded into the ShoppingCart table
SELECT *
FROM dbo.ShoppingCart
WHERE StudentID = 1;
GO

-- Now, assuming the shopping cart in the WinForms app, when ready ?
-- call the confirmation procedure to finalize the registration.
PRINT '--- Running Confirmation Procedure ---';
EXEC dbo.ConfirmStudentRegistration @StudentID = 1, @CourseInstanceID = 11;
GO

-- View final registration results
SELECT *
FROM registration
WHERE student_id = 1 AND course_instance_id = 11;
GO

-- Also, check the updated course_instance occupancy
SELECT current_occupancy, max_occupancy
FROM course_instance
WHERE course_instance_id = 11;
GO