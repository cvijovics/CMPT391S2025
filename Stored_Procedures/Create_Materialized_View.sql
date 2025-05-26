USE CMPT391S2025;
GO

IF OBJECT_ID(N'dbo.createMaterializedView', N'P') IS NOT NULL
    DROP PROCEDURE dbo.createMaterializedView;
GO

CREATE PROCEDURE dbo.createMaterializedView
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Step 1: Drop the view if it exists.
    BEGIN TRY
        PRINT 'Step 1: Dropping view if exists.';
        EXEC sp_executesql N'
            IF OBJECT_ID(N''dbo.view_student_registration'', N''V'') IS NOT NULL
                DROP VIEW dbo.view_student_registration;
        ';
        PRINT 'Step 1 completed successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error in Step 1 (drop view): ' + ERROR_MESSAGE();
    END CATCH;

    -- Step 2: Create the view with schemabinding.
    BEGIN TRY
        PRINT 'Step 2: Creating view.';
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
                FROM dbo.student AS s
                JOIN dbo.registration AS r
                    ON s.student_id = r.student_id
                JOIN dbo.course_instance AS i
                    ON r.course_instance_id = i.course_instance_id
                JOIN dbo.course AS c
                    ON i.course_id = c.course_id;
        ';
        PRINT 'Step 2 completed successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error in Step 2 (create view): ' + ERROR_MESSAGE();
    END CATCH;
    
    -- Step 3: Create the clustered index using a composite key as per E-R diagram
    BEGIN TRY
        PRINT 'Step 3: Creating clustered index.';
        EXEC sp_executesql N'
            CREATE UNIQUE CLUSTERED INDEX idx_student_registration
            ON dbo.view_student_registration(student_id, course_instance_id);
        ';
        PRINT 'Step 3 completed successfully.';
    END TRY
    BEGIN CATCH
        PRINT 'Error in Step 3 (create index): ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

PRINT 'Executing dbo.createMaterializedView...';
EXEC dbo.createMaterializedView;
GO