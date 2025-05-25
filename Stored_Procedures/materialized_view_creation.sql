USE CMPT391S2025;
GO
-- Drop the procedure if it exists
IF OBJECT_ID(N'dbo.createMaterializedView', N'P') IS NOT NULL
    DROP PROCEDURE dbo.createMaterializedView;
GO

CREATE PROCEDURE dbo.createMaterializedView

AS
BEGIN
        -- Check if the materialized view already exists
        EXEC sp_executesql N'
            IF OBJECT_ID(N''dbo.view_student_registration'', N''V'') IS NOT NULL
                DROP VIEW dbo.view_student_registration;
        ';
        -- Create the materialized view
        EXEC sp_executesql N'
        CREATE VIEW dbo.view_student_registration
            WITH SCHEMABINDING
            AS
            SELECT 
                s.student_id, 
                r.course_instance_id, 
                c.course_id, 
                r.course_completed,
                c.course_name, 
                i.start_date, 
                i.end_date, 
                i.start_time, 
                i.end_time,
                i.days_of_week
            FROM dbo.student as s
            JOIN dbo.registration as r ON s.student_id = r.student_id
            JOIN dbo.course_instance as i ON r.course_instance_id = i.course_instance_id
            JOIN dbo.course as c ON i.course_id = c.course_id;
        ';
        -- Create the clustered index on the materialized view
        EXEC sp_executesql N'
                CREATE UNIQUE CLUSTERED INDEX idx_student_registration
                ON dbo.view_student_registration(student_id);
        ';     
END;


