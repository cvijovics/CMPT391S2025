USE CMPT391S2025;
GO


EXEC createMaterializedView;
SELECT * FROM dbo.view_student_registration;
SELECT * FROM dbo.view_student_registration WHERE student_id = 9002;
