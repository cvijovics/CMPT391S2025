# CMPT391S2025 Project

**Group 1 • Spring 2025**

This repository contains the SQL scripts needed to set up the CMPT391S2025 database for our project, along with sample data for testing.

[![Project Preview](https://www.pngall.com/wp-content/uploads/13/Figma-Logo-PNG-Image.png)](https://www.figma.com/files/team/1503817106759156462/project/383188732/Team-project?fuid=1108639375161038790)

---

## Prerequisites

- **SQL Server / SQL Server Express:** Ensure it is installed on your machine
- **Visual Studio Code:** Download from [VS Code](https://code.visualstudio.com/).
- **mssql VS Code Extension:** Install via the [mssql extension](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql).

---

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/cvijovics/CMPT391S2025.git

2. **Open in VS Code**

   Open the cloned folder in Visual Studio Code.

3. **Connect to SQL Server**

   - Press **F1** to open the Command Palette.
   - Type `MS SQL: Connect` and press Enter.
   - Enter your connection details:
     - **Server:** `localhost` or `localhost\SQLEXPRESS` (depending on your installation)
     - **Authentication:** Choose Windows Authentication (or SQL Server Authentication if needed)
     - **Database:** For initial setup, connect to the `master` database. Once your setup, you can then use `CMPT391S2025`

4. **Create the Database**

   - Open the `DBCreation.sql` file.
   - Ensure the file is active (click inside the editor) and sql server is running before running the script.
   - You should be able to switch to the database now (from master).
     
   - **Note:** If batch separators (like `GO`) cause issues, run each command individually.

5. **Insert test data**
   - Run insert data in this order:
   - department, student, instructor, course, instance

6. **Insert Materialized View/Stored Procedures**

   Although these groups don't need to be run in any particular order, the scripts listed within do 
   (dependancies):
   (This is incomplete)

   - Creating Registration Flow:
      - 1. `Create_Materialized_View.sql`
      - 2. `Validate_Student_Registration.sql`
      - 3. `Confirm_Student_Registration.sql`
   
   - Front-End Queries:
      - 1. `GetAvailableCourseInstances.sq1`

7. **Test Your Setup**

   - Create a new SQL file (for example, `test.sql`) and run:
     
     ```sql
     SELECT student_id, first_name, last_name FROM student;
     SELECT department_id, department_name FROM department;
     ```
     
   - You should see query results with headers and the inserted data.

   - Testing scripts included under `Test_Queries`

---

## Troubleshooting

- **Active SQL Editor:**  
  Ensure the SQL file you're executing is in focus (click inside the editor) before running commands.

- **Execute Scripts in the Correct Order**
  Important!
  - department, student, instructor, course, instance

- **Output Panel:**  
  Open **View > Output** in VS Code and select the "MSSQL" channel for error messages and logs.

- **Reload VS Code:**  
  If problems persist, try reloading VS Code with `Developer: Reload Window` from the Command Palette.

- ### To Start From Scratch:
   - Run `DeleteDB.sql`
   - Start from beginning
