using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CourseRegistrationApp
{
    public partial class RegistrationForm : Form
    {
        public RegistrationForm()
        {
            InitializeComponent();
        }

        private void RegistrationForm_Load(object sender, EventArgs e)
        {
            LoadCourseData();
        }

        private void LoadCourseData()
        {
            dataGridView1.Rows.Clear();

            string connStr = "Server=localhost;Database=CMPT391S2025;Trusted_Connection=True;";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("GetAvailableCourseInstances", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    string courseName = reader["course_name"].ToString();

                    string timeSlot = $"{reader["days_of_week"]} {reader["start_time"]}–{reader["end_time"]}";
                    string seats = $"{reader["current_occupancy"]}/{reader["max_occupancy"]}";
                    string instructor = reader["instructor_name"].ToString();
                    string title = reader["department_name"].ToString(); 
                    string courseId = reader["course_id"].ToString();
                    string instanceId = reader["course_instance_id"].ToString();

                    dataGridView1.Rows.Add(
                        false,        // colSelect
                        courseName,   // colCourseCode
                        title,        // colTitle
                        instructor,   // colInstructor
                        timeSlot,     // colTime
                        seats,        // colSeats
                        courseId,     // colCourseId
                        instanceId  // colInstanceId
                    );
                }

                reader.Close();
            }
        }


        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void btnBack_Click(object sender, EventArgs e)
        {
            // Navigate back
            this.Hide(); // Hide the current form
            selectionForm courseForm = new selectionForm();
            courseForm.FormClosed += (s, args) => this.Close(); // Close this form when the other is closed
            courseForm.Show();
        }

        private void btnRegister_Click(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
        {

        }

        private void add_course_Click(object sender, EventArgs e)
        {
            DataGridViewRow selectedRow = dataGridView1.CurrentRow;
            TextBox idBox = textBox1;

            if (selectedRow != null && idBox != null)
            {
                string studentId = idBox.Text.Trim();
                string courseInstanceId = selectedRow.Cells["colInstanceId"].Value.ToString();
                string courseId = selectedRow.Cells["colCourseId"].Value.ToString();
                DateTime addedTime = DateTime.Now;
                addToShoppingCart(studentId, courseInstanceId);



            }

        
        }

        private void addToShoppingCart(string studentId, string courseInstanceId)
        {
            string connStr = "Server=localhost;Database=CMPT391S2025;Trusted_Connection=True;";

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("ValidateStudentRegistration", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    // Add parameters to the command
                    cmd.Parameters.AddWithValue("@studentId", studentId);
                    cmd.Parameters.AddWithValue("@courseInstanceId", courseInstanceId);

                    try
                    {
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        MessageBox.Show("Course added to shopping cart successfully.");
                    }
                    catch (SqlException ex)
                    {
                        MessageBox.Show("Error adding course to shopping cart: " + ex.Message);
                    }
                }
            }
        }
    }
}
