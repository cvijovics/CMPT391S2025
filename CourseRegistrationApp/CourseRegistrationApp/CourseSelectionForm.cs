using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace CourseRegistrationApp
{
    public partial class selectionForm : Form
    {
        private string studentID;
        private Form previousForm;
        public selectionForm(string studentID, Form previousForm)
        {
            InitializeComponent();
            this.studentID = studentID;
            this.previousForm = previousForm;
            textBox1.Text = studentID;
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            LoadCourseData();
        }

        private void LoadCourseData()
        {
            dataGridView1.Rows.Clear();

            string connStr = "Server=localhost;Database=CMPT391S2025;Trusted_Connection=True;";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("GetShoppingCartContents", conn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@StudentID", studentID);

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

        private void label3_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void btnRegister_Click(object sender, EventArgs e)
        {
            string connStr = "Server=localhost;Database=CMPT391S2025;Trusted_Connection=True;";
            bool success = true;
            StringBuilder errorMessages = new StringBuilder();

            if (string.IsNullOrWhiteSpace(textBox1.Text))
            {
                MessageBox.Show("Student ID is required.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            int studentId;
            if (!int.TryParse(textBox1.Text, out studentId))
            {
                MessageBox.Show("Student ID must be a valid number.", "Validation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                foreach (DataGridViewRow row in dataGridView1.Rows)
                {
                    if (Convert.ToBoolean(row.Cells["colSelect"].Value) == true)
                    {
                        try
                        {
                            int courseInstanceId = Convert.ToInt32(row.Cells[7].Value);

                            SqlCommand cmd = new SqlCommand("ConfirmStudentRegistration", conn);
                            cmd.CommandType = CommandType.StoredProcedure;

                            cmd.Parameters.AddWithValue("@StudentID", studentId);
                            cmd.Parameters.AddWithValue("@CourseInstanceID", courseInstanceId);

                            SqlParameter outputParam = new SqlParameter("@result", SqlDbType.VarChar, 100);
                            outputParam.Direction = ParameterDirection.Output;
                            //cmd.Parameters.Add(outputParam);

                            cmd.ExecuteNonQuery();

                            string result = outputParam.Value?.ToString();
                            if (result != null && result.StartsWith("Error", StringComparison.OrdinalIgnoreCase))
                            {
                                success = false;
                                errorMessages.AppendLine($"Course ID {courseInstanceId}: {result}");
                            }
                        }
                        catch (Exception ex)
                        {
                            success = false;
                            errorMessages.AppendLine($"Unexpected error for selected course: {ex.Message}");
                        }
                    }

                    if (success)
                    {
                        MessageBox.Show("Registration Successful", "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        LoadCourseData();
                    }
                    else
                    {
                        MessageBox.Show("Registration failed:\n" + errorMessages.ToString(), "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        LoadCourseData();

                    }
                }
            }
        }

        private void btnBack_Click(object sender, EventArgs e)
        {
            this.Close();
            previousForm.Show();
        }
    }
}
