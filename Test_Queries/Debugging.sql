-- -- Debugging:
-- EXEC sp_refreshsqlmodule 'dbo.RegisterStudentForCourse';
-- GO

-- USE CMPT391S2025;
-- GO

-- IF OBJECT_ID('dbo.view_student_registration', 'V') IS NOT NULL
--     DROP VIEW dbo.view_student_registration;
-- GO

-- CREATE VIEW dbo.view_student_registration
-- WITH SCHEMABINDING
-- AS
-- SELECT 
--     s.student_id, 
--     r.course_instance_id, 
--     c.course_id, 
--     r.course_completed,
--     c.course_name, 
--     i.start_date, 
--     i.end_date, 
--     i.start_time, 
--     i.end_time,
--     i.days_of_week
-- FROM dbo.student AS s
-- JOIN dbo.registration AS r ON s.student_id = r.student_id
-- JOIN dbo.course_instance AS i ON r.course_instance_id = i.course_instance_id
-- JOIN dbo.course AS c ON i.course_id = c.course_id;
-- GO

-- CREATE UNIQUE CLUSTERED INDEX idx_student_registration
-- ON dbo.view_student_registration(student_id);
-- GO

-- -- view
-- SELECT name FROM sys.views WHERE name = 'view_student_registration';
-- GO

-- Check for duplicates
-- PRINT '--- Checking for duplicate registrations ---';
-- SELECT 
--     student_id,
--     course_instance_id,
--     COUNT(*) AS DuplicateCount
-- FROM dbo.registration
-- GROUP BY student_id, course_instance_id
-- HAVING COUNT(*) > 1;
-- GO

-- -- Remove Duplicates
WITH Duplicates AS (
    SELECT 
        student_id, 
        course_instance_id,
        ROW_NUMBER() OVER (PARTITION BY student_id, course_instance_id ORDER BY (SELECT NULL)) AS rn
    FROM dbo.registration
)
DELETE FROM Duplicates
WHERE rn > 1;
GO
