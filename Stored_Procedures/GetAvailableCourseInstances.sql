USE CMPT391S2025;
GO

IF OBJECT_ID('dbo.GetAvailableCourseInstances', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetAvailableCourseInstances;
GO

CREATE PROCEDURE GetAvailableCourseInstances
AS
BEGIN TRANSACTION
    BEGIN TRY 
        SET NOCOUNT ON;
        SELECT
            ci.course_instance_id,
            c.course_id,
            c.course_name,
            ci.start_date,
            ci.end_date,
            ci.start_time,
            ci.end_time,
            ci.days_of_week,
            ci.max_occupancy,
            ci.current_occupancy,
            (ci.max_occupancy - ci.current_occupancy) AS available_seats,
            i.first_name + ' ' + i.last_name AS instructor_name,
            d.department_name AS department_name
        FROM course_instance ci
        JOIN course c ON ci.course_id = c.course_id
        JOIN instructor i ON ci.instructor_id = i.instructor_id
        JOIN department d ON i.department_id = d.department_id
        WHERE ci.current_occupancy < ci.max_occupancy
        ORDER BY c.course_name, ci.start_date;
	    
COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH

	



