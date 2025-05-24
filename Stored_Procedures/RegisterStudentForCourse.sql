-- check if a student is eligible to register for a course—by verifying prerequisites (stored procedure)

CREATE PROCEDURE RegisterStudentForCourse
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
    
    -- Get the course ID and schedule info from the course_instance.
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
    -- 1. Check that all prerequisites have been met.
    -- For every prerequisite of this course, verify the student has a
    -- registration record in a course_instance for the required course with course_completed = 1.
    IF EXISTS (
        SELECT *
        FROM prerequisite p
        WHERE p.course_id = @CourseID
          AND NOT EXISTS (
              SELECT 1
              FROM registration r
              JOIN course_instance ci ON r.course_instance_id = ci.course_instance_id
              WHERE r.student_id = @StudentID 
                AND ci.course_id = p.prerequisite_course_id
                AND r.course_completed = 1
          )
    )
    BEGIN
        RAISERROR('Prerequisites not met.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 2. Check for schedule conflicts.
    -- Compare the target course instance schedule with any the student is already registered for.
    IF EXISTS (
        SELECT 1
        FROM registration r
        JOIN course_instance ci ON r.course_instance_id = ci.course_instance_id
        WHERE r.student_id = @StudentID
          AND (
                -- (Simplified - may need to improve):
                -- Check if any day in the target schedule appears in the registered course's schedule.
                ci.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 1, 1) + '%' OR
                ci.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 2, 1) + '%' OR
                ci.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 3, 1) + '%'
              )
          AND (
                -- Check if times overlap.
                (ci.start_time < @TargetEnd AND ci.end_time > @TargetStart)
              )
    )
    BEGIN
        RAISERROR('Schedule conflict detected.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    ------------------------------------------------------------------------
    -- 3. Check if there is available capacity in the course instance.
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

