USE CMPT391S2025;
GO


SELECT s.first_name, s.last_name, c.course_name, r.course_completed
FROM dbo.registration r
JOIN dbo.student s ON r.student_id = s.student_id
JOIN dbo.course_instance ci ON r.course_instance_id = ci.course_instance_id
JOIN dbo.course c ON ci.course_id = c.course_id
ORDER BY s.last_name, c.course_id;

-- retrieves all registration records from student Christiano Ronaldo (student_id = 9002)
SELECT * FROM view_student_registration WHERE student_id = 9002; 
