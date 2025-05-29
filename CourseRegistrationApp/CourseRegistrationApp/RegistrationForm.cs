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
            comboBox1.Items.AddRange(new string[] { "Winter", "Spring", "Summer", "Fall" });

            comboBox2.Items.AddRange(new string[] { "2025", "2026" });
            LoadCourseData();
        }

        private void LoadCourseData()
        {
            dataGridView1.Rows.Clear();

            string selectedTerm = comboBox1.Text; 
            string selectedYear = comboBox2.Text; 

            string connStr = "Server=localhost;Database=CMPT391S2025;Trusted_Connection=True;";
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                SqlCommand cmd = new SqlCommand("GetAvailableCourseInstances", conn);
                cmd.CommandType = CommandType.StoredProcedure;

                conn.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                while (reader.Read())
                {
                    // Get and parse start date
                    DateTime startDate = Convert.ToDateTime(reader["start_date"]);
                    int month = startDate.Month;
                    int year = startDate.Year;

                    string term;
                    if (month >= 1 && month <= 4) term = "Winter";
                    else if (month >= 5 && month <= 6) term = "Spring";
                    else if (month >= 7 && month <= 8) term = "Summer";
                    else term = "Fall";

                    string enrollmentTerm = $"{term} {year}";

                    if (!string.IsNullOrWhiteSpace(selectedTerm) && term != selectedTerm)
                        continue;

                    if (!string.IsNullOrWhiteSpace(selectedYear) && year.ToString() != selectedYear)
                        continue;


                    string courseName = reader["course_name"].ToString();
                    string timeSlot = $"{reader["days_of_week"]} {reader["start_time"]}–{reader["end_time"]}";
                    string seats = $"{reader["current_occupancy"]}/{reader["max_occupancy"]}";
                    string waitlist = "0/10"; // Placeholder
                    string prereqsMet = "Yes"; // Placeholder
                    string timeConflict = "No"; // Placeholder
                    string instructor = reader["instructor_name"].ToString();
                    string title = reader["department_name"].ToString(); 
                    string action = "-";

                    dataGridView1.Rows.Add(
                        false,        // colSelect
                        courseName,   // colCourseCode
                        title,        // colTitle
                        instructor,   // colInstructor
                        timeSlot,     // colTime
                        seats,        // colSeats
                        waitlist,     // colWaitlist
                        prereqsMet,   // colPrereqs
                        timeConflict, // colConflict
                        action        // colAction
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

        private void comboBox2_SelectedIndexChanged(object sender, EventArgs e)
        {
           LoadCourseData();

        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCourseData();
        }
    }
}
