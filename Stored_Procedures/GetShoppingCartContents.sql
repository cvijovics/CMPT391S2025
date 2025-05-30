USE CMPT391S2025;
GO

IF OBJECT_ID('dbo.GetShoppingCartContents', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetShoppingCartContents;
GO

CREATE PROCEDURE dbo.GetShoppingCartContents
    @StudentID INT
AS
BEGIN TRANSACTION
    BEGIN TRY
        SET NOCOUNT ON;

        SELECT
            sc.course_instance_id,
            sc.course_id,
            c.course_name,
            ci.start_date,
            ci.end_date,
            ci.start_time,
            ci.end_time,
            ci.days_of_week,
            ci.current_occupancy,
            ci.max_occupancy,
            i.first_name + ' ' + i.last_name AS instructor_name,
            d.department_name
        FROM dbo.shopping_cart sc  -- ✅ correct case
        JOIN course_instance ci ON sc.course_instance_id = ci.course_instance_id
        JOIN course c ON sc.course_id = c.course_id
        JOIN instructor i ON ci.instructor_id = i.instructor_id
        JOIN department d ON i.department_id = d.department_id
        WHERE sc.student_id = @StudentID
        ORDER BY c.course_name, ci.start_date;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000);
        SET @ErrorMessage = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
GO
