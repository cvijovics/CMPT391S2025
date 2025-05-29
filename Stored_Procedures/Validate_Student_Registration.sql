-- Validate student registration

USE CMPT391S2025;
GO
IF OBJECT_ID('dbo.ValidateStudentRegistration', 'P') IS NOT NULL
    DROP PROCEDURE dbo.ValidateStudentRegistration;
GO

CREATE PROCEDURE dbo.ValidateStudentRegistration
    @StudentID INT,
    @CourseInstanceID INT
AS
BEGIN TRANSACTION
    SET NOCOUNT ON;

    DECLARE @CourseID INT,
            @TargetDays VARCHAR(3),
            @TargetStart TIME,
            @TargetEnd TIME;
    
	BEGIN TRY


		-- Retrieve course and schedule info from course_instance.
		SELECT 
			@CourseID = course_id,
			@TargetDays = days_of_week,
			@TargetStart = start_time,
			@TargetEnd = end_time
		FROM course_instance
		WHERE course_instance_id = @CourseInstanceID;
    
		IF @CourseID IS NULL
		BEGIN
			RAISERROR('Invalid course instance.', 16, 1);
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
			RETURN;
		END

		------------------------------------------------------------------------
		-- 2. Check for schedule conflicts using the materialized view.
		IF EXISTS (
			SELECT 1
			FROM dbo.view_student_registration vsr
			WHERE vsr.student_id = @StudentID
			  AND vsr.course_completed = 0
			  AND (
					vsr.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 1, 1) + '%'
				 OR vsr.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 2, 1) + '%'
				 OR vsr.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 3, 1) + '%'
			  )
			  AND (vsr.start_time < @TargetEnd AND vsr.end_time > @TargetStart)
			
			  UNION

			-- Also check the shopping cart for conflicts
			  SELECT 1
			  FROM dbo.shopping_cart sc
			  JOIN dbo.course_instance ci ON sc.course_instance_id = ci.course_instance_id
			  WHERE sc.student_id = @StudentID
			    AND (
					ci.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 1, 1) + '%'
				 OR ci.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 2, 1) + '%'
				 OR ci.days_of_week LIKE '%' + SUBSTRING(@TargetDays, 3, 1) + '%'
			  	)
			    AND (ci.start_time < @TargetEnd AND ci.end_time > @TargetStart)


		)
		BEGIN
			RAISERROR('Schedule conflict detected.', 16, 1);
			RETURN;
		END

		------------------------------------------------------------------------
		-- 3. Check if same instance exists in shopping cart.
		IF EXISTS (
			SELECT 1
			FROM shopping_cart
			WHERE student_id = @StudentID
			  AND course_id = @CourseID
		)
		BEGIN
			RAISERROR('This course is already in your shopping cart.', 16, 1);
			RETURN;
		END

		------------------------------------------------------------------------
		-- If all checks pass, load data into the "shopping cart" for further review.
		INSERT INTO shopping_cart (student_id, course_instance_id, course_id, added_date)
		VALUES (@StudentID, @CourseInstanceID, @CourseID, GETDATE());


		PRINT 'Validation successful. Data loaded into shopping cart.';
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH


