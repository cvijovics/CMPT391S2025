USE CMPT391S2025;
GO

/* === Demo Courses === */
INSERT INTO dbo.course (course_id, course_name)
VALUES 
  (291, 'CMPT 291: Introduction to Database Systems'),
  (391, 'CMPT 391: Intermediate Database Systems'),
  (491, 'CMPT 491: Advanced Database Systems');

/* === Prerequisites === */
INSERT INTO dbo.Prerequisite (course_id, prerequisite_course_id)
VALUES
  (391, 291),  -- CMPT 391 requires 291
  (491, 391);  -- CMPT 491 requires 391

/* === Demo Instructor === */
INSERT INTO dbo.instructor (instructor_id, first_name, last_name, department_id)
VALUES
  (1001, 'Mohamad', 'El-Hajj', 1);

/* === Demo Course Instances === */
INSERT INTO dbo.course_instance 
    (course_instance_id, course_id, instructor_id, start_date, end_date, start_time, end_time, days_of_week, max_occupancy, current_occupancy)
VALUES
  (2001, 291, 1001, '2025-01-15', '2025-04-30', '09:00', '10:30', 'MWF', 30, 0),
  (2002, 391, 1001, '2025-05-05', '2025-08-20', '10:00', '11:30', 'TT', 25, 0),
  (2003, 491, 1001, '2025-09-05', '2025-12-15', '09:30', '11:00', 'MWF', 20, 0);

/* === Demo Students === */
INSERT INTO dbo.student (student_id, first_name, last_name)
VALUES
  (9001, 'Lionel', 'Messi'),
  (9002, 'Cristiano', 'Ronaldo');

/* === Registrations for Demo Students === */
-- Lionel Messi: Completed 291, current registration in 391 (in progress)
INSERT INTO dbo.registration (course_instance_id, student_id, registration_date, course_completed)
VALUES
  (2001, 9001, GETDATE(), 1),  -- Completed CMPT 291
  (2002, 9001, GETDATE(), 0);  -- In-progress in CMPT 391

-- Cristiano Ronaldo: Completed 291 and 391, now registering for 491
INSERT INTO dbo.registration (course_instance_id, student_id, registration_date, course_completed)
VALUES
  (2001, 9002, GETDATE(), 1),  -- Completed CMPT 291
  (2002, 9002, GETDATE(), 1);  -- Completed CMPT 391
  --(2003, 9002, GETDATE(), 0);  -- Registered for CMPT 491 (in progress)

