
CREATE PROCEDURE createMaterializedView
AS
BEGIN
        -- Create the materialized view
        EXEC sp_executesql N'
            IF OBJECT_ID(N''CMPT391S2025.view_student_registration'', N''V'') IS NOT NULL
                DROP VIEW CMPT391S2025.view_student_registration;
        ';
        EXEC sp_executesql N'
        CREATE VIEW CMPT391S2025.view_student_registration
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
            FROM CMPT391S2025.student as s
            JOIN CMPT391S2025.registration as r ON s.student_id = r.student_id
            JOIN CMPT391S2025.course_instance as i ON r.course_instance_id = i.course_instance_id
            JOIN CMPT391S2025.course as c ON i.course_id = c.course_id;
        ';
        EXEC sp_executesql'
                CREATE UNIQUE CLUSTERED INDEX idx_student_registration
                ON CMPT391S2025.view_student_registration(student_id);
        ';     
END;


