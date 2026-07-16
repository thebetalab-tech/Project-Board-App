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
        }
    }
}