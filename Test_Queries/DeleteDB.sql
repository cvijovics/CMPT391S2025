----------------------------------------------------------
-- !!**Use this script with caution - will delete entire db**!!
-- Will take a few seconds
----------------------------------------------------------

-- switch to master to delete
USE master;
GO

-- Check if the database exists, then drop it if it does
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'CMPT391S2025')
BEGIN
    ALTER DATABASE CMPT391S2025 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CMPT391S2025;
END;
GO

-- Create the database again
CREATE DATABASE CMPT391S2025;
GO

-- Switch to the newly recreated database
USE CMPT391S2025;
GO

