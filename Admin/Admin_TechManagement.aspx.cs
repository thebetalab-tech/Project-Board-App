using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_TechManagement : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["role"] == null || Session["role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Fetch user information from session
                string userName = Session["FullName"]?.ToString() ?? "Guest";
                string userEmail = Session["Email"]?.ToString() ?? "No email provided";
                string intial = userName.Substring(0, 1).ToUpper();
                userNameLabel.Text = userName;
                userEmailLabel.Text = userEmail;
                userintial.Text = intial;

                LoadTechnologies();
                LoadDropdowns();
                LoadFacultyTech();
            }
        }

        private void LoadTechnologies()
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT TechId, TechName FROM Technologies ORDER BY TechName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    try
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            rptTechs.DataSource = reader;
                            rptTechs.DataBind();
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine(ex.Message);
                    }
                }
            }
        }

        protected void btnAddTech_Click(object sender, EventArgs e)
        {
            string techName = txtNewTech.Text.Trim();
            if (string.IsNullOrEmpty(techName))
            {
                lblMessage.ForeColor = System.Drawing.Color.Red;
                lblMessage.Text = "Technology name cannot be empty.";
                return;
            }

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string checkQuery = "SELECT COUNT(1) FROM Technologies WHERE TechName = @TechName";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@TechName", techName);
                    try
                    {
                        conn.Open();
                        int count = (int)checkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            lblMessage.ForeColor = System.Drawing.Color.Red;
                            lblMessage.Text = "This technology already exists.";
                            return;
                        }

                        string insertQuery = "INSERT INTO Technologies (TechName) VALUES (@TechName)";
                        using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                        {
                            insertCmd.Parameters.AddWithValue("@TechName", techName);
                            insertCmd.ExecuteNonQuery();
                            
                            txtNewTech.Text = string.Empty;
                            lblMessage.ForeColor = System.Drawing.Color.Green;
                            lblMessage.Text = "Technology added successfully.";
                            
                            LoadTechnologies();
                        }
                    }
                    catch (Exception ex)
                    {
                        lblMessage.ForeColor = System.Drawing.Color.Red;
                        lblMessage.Text = "Error: " + ex.Message;
                    }
                }
            }
        }

        protected void rptTechs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteTech")
            {
                int techId = Convert.ToInt32(e.CommandArgument);
                
                // NOTE: Cannot perform a hard delete if this technology is already linked to Faculty or Groups.
                // We'll catch the SqlException and inform the user.
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Technologies WHERE TechId = @TechId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@TechId", techId);
                        try
                        {
                            conn.Open();
                            cmd.ExecuteNonQuery();
                            lblMessage.ForeColor = System.Drawing.Color.Green;
                            lblMessage.Text = "Technology deleted successfully.";
                            LoadTechnologies();
                        }
                        catch (SqlException sqlEx)
                        {
                            // FK constraint violation typically has error number 547
                            if (sqlEx.Number == 547)
                            {
                                lblMessage.ForeColor = System.Drawing.Color.Red;
                                lblMessage.Text = "Cannot delete this technology because it is currently assigned to a Faculty member or Group.";
                            }
                            else
                            {
                                lblMessage.ForeColor = System.Drawing.Color.Red;
                                lblMessage.Text = "Database Error: " + sqlEx.Message;
                            }
                        }
                        catch (Exception ex)
                        {
                            lblMessage.ForeColor = System.Drawing.Color.Red;
                            lblMessage.Text = "Error: " + ex.Message;
                        }
                    }
                }
            }
            else if (e.CommandName == "DeleteAssignment")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                int facultyId = Convert.ToInt32(args[0]);
                int techId = Convert.ToInt32(args[1]);

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "DELETE FROM Faculty WHERE FacultyId = @FacultyId AND TechId = @TechId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                        cmd.Parameters.AddWithValue("@TechId", techId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                        
                        lblAssignMessage.ForeColor = System.Drawing.Color.Green;
                        lblAssignMessage.Text = "Assignment removed successfully.";
                        LoadFacultyTech();
                    }
                }
            }
        }

        private void LoadDropdowns()
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Load Faculty
                string qFaculty = "SELECT UserId, FullName FROM Users WHERE Role = 'Faculty' AND IsActive = 1 ORDER BY FullName";
                using (SqlCommand cmd = new SqlCommand(qFaculty, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ddlFaculty.DataSource = reader;
                        ddlFaculty.DataTextField = "FullName";
                        ddlFaculty.DataValueField = "UserId";
                        ddlFaculty.DataBind();
                    }
                    ddlFaculty.Items.Insert(0, new ListItem("Select Faculty", ""));
                }

                // Load Technologies
                string qTech = "SELECT TechId, TechName FROM Technologies ORDER BY TechName";
                using (SqlCommand cmd = new SqlCommand(qTech, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ddlTech.DataSource = reader;
                        ddlTech.DataTextField = "TechName";
                        ddlTech.DataValueField = "TechId";
                        ddlTech.DataBind();
                    }
                    ddlTech.Items.Insert(0, new ListItem("Select Technology", ""));
                }
            }
        }

        private void LoadFacultyTech()
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT F.FacultyId, F.TechId, U.FullName AS FacultyName, T.TechName 
                    FROM Faculty F
                    INNER JOIN Users U ON F.FacultyId = U.UserId
                    INNER JOIN Technologies T ON F.TechId = T.TechId
                    ORDER BY U.FullName, T.TechName";
                
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        rptFacultyTech.DataSource = reader;
                        rptFacultyTech.DataBind();
                    }
                }
            }
        }

        protected void btnAssign_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlFaculty.SelectedValue) || string.IsNullOrEmpty(ddlTech.SelectedValue))
            {
                lblAssignMessage.ForeColor = System.Drawing.Color.Red;
                lblAssignMessage.Text = "Please select both a faculty member and a technology.";
                return;
            }

            int facultyId = Convert.ToInt32(ddlFaculty.SelectedValue);
            int techId = Convert.ToInt32(ddlTech.SelectedValue);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                try
                {
                    string insertQuery = "INSERT INTO Faculty (FacultyId, TechId) VALUES (@FacultyId, @TechId)";
                    using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@FacultyId", facultyId);
                        insertCmd.Parameters.AddWithValue("@TechId", techId);
                        conn.Open();
                        insertCmd.ExecuteNonQuery();
                        
                        lblAssignMessage.ForeColor = System.Drawing.Color.Green;
                        lblAssignMessage.Text = "Technology assigned successfully.";
                        
                        LoadFacultyTech();
                    }
                }
                catch (SqlException ex) when (ex.Number == 2627 || ex.Number == 2601)
                {
                    lblAssignMessage.ForeColor = System.Drawing.Color.Red;
                    lblAssignMessage.Text = "This faculty member is already assigned to this technology.";
                }
                catch (Exception ex)
                {
                    lblAssignMessage.ForeColor = System.Drawing.Color.Red;
                    lblAssignMessage.Text = "Error: " + ex.Message;
                }
            }
        }
    }
}