-- Confirm Student Registration

IF OBJECT_ID('dbo.ConfirmStudentRegistration', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ConfirmStudentRegistration;
GO

CREATE PROCEDURE dbo.ConfirmStudentRegistration
    @StudentID INT,
    @CourseInstanceID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @CurrentOcc INT,
            @MaxOcc INT;
    
    -- Retrieve capacity info.
    SELECT @CurrentOcc = current_occupancy,
           @MaxOcc = max_occupancy
    FROM course_instance
    WHERE course_instance_id = @CourseInstanceID;
    
    IF (@CurrentOcc >= @MaxOcc)
    BEGIN
        RAISERROR('No available seats for this course instance.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    ------------------------------------------------------------------------
    -- Insert the registration record.
    INSERT INTO registration (course_instance_id, student_id, registration_date, course_completed)
    VALUES (@CourseInstanceID, @StudentID, GETDATE(), 0);

    ------------------------------------------------------------------------
    -- Update the course instance's current occupancy.
    UPDATE course_instance
    SET current_occupancy = current_occupancy + 1
    WHERE course_instance_id = @CourseInstanceID;

    COMMIT TRANSACTION;
    PRINT 'Registration successful.';
END;
GO
