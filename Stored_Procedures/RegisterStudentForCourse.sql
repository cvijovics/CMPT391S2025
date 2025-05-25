-- drop it if you run this script again, first:
IF OBJECT_ID('dbo.RegisterStudentForCourse', 'P') IS NOT NULL
    DROP PROCEDURE dbo.RegisterStudentForCourse;
GO

-- create procedures for materialized views
CREATE PROCEDURE dbo.RegisterStudentForCourse
    @StudentID INT,
    @CourseInstanceID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    
    DECLARE @CourseID INT,
            @CurrentOcc INT,
            @MaxOcc INT,
            @TargetDays VARCHAR(3),
            @TargetStart TIME,
            @TargetEnd TIME;
    
    -- Retrieve course and schedule info from the course_instance table.
    SELECT 
        @CourseID = course_id,
        @TargetDays = days_of_week,
        @TargetStart = start_time,
        @TargetEnd = end_time,
        @CurrentOcc = current_occupancy,
        @MaxOcc = max_occupancy
    FROM course_instance
    WHERE course_instance_id = @CourseInstanceID;
    
    IF @CourseID IS NULL
    BEGIN
        RAISERROR('Invalid course instance.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 1. Check that all prerequisites have been met using the materialized view.
    IF EXISTS (
        SELECT *
        FROM prerequisite p
        WHERE p.course_id = @CourseID
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.view_student_registration vsr
              WHERE vsr.student_id = @StudentID 
                AND vsr.course_id = p.prerequisite_course_id
                AND vsr.course_completed = 1
          )
    )
    BEGIN
        RAISERROR('Prerequisites not met.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 2. Check for schedule conflicts using the materialized view.
    IF EXISTS (
        SELECT 1
        FROM dbo.view_student_registration vsr
        WHERE vsr.student_id = @StudentID
        AND (
                vsr.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 1, 1) + '%' OR
                vsr.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 2, 1) + '%' OR
                vsr.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 3, 1) + '%'
            )
        AND (
            vsr.start_time < @TargetEnd
            AND vsr.end_time > @TargetStart
            )
    )
    BEGIN
        RAISERROR('Schedule conflict detected.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 3. Check for available capacity in the course instance.
    IF (@CurrentOcc >= @MaxOcc)
    BEGIN
        RAISERROR('No available seats for this course instance.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 4. Insert the registration record.
    INSERT INTO registration (course_instance_id, student_id, registration_date, course_completed)
    VALUES (@CourseInstanceID, @StudentID, GETDATE(), 0);

    -- 5. Update the course instance's current occupancy.
    UPDATE course_instance
    SET current_occupancy = current_occupancy + 1
    WHERE course_instance_id = @CourseInstanceID;

    COMMIT TRANSACTION;
    PRINT 'Registration successful.';
END;
GO