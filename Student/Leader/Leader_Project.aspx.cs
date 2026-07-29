using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Leader
{
    public partial class Leader_Project : Page
    {
        protected string UserInitials { get; set; } = "TL";
        protected string UserName { get; set; } = "Student Leader";
        protected string UserEmail { get; set; } = "leader@example.com";
        protected int CurrentGroupId { get; set; } = 0;

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Leader";
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            LoadGroupInfo();

            if (!IsPostBack)
            {
                LoadProjectDetails();
            }
        }

        private void LoadGroupInfo()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        CurrentGroupId = Convert.ToInt32(res);
                    }
                }
            }
        }

        private void LoadProjectDetails()
        {
            if (CurrentGroupId == 0) return;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT * FROM Projects WHERE GroupId = @GroupId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            pnlExistingProject.Visible = true;
                            lblProjectTitle.Text = rdr["ProjectTitle"].ToString();
                            lblProjectType.Text = rdr["ProjectType"].ToString();
                            lblProjectStatus.Text = rdr["Status"].ToString();
                            lblFunctionality.Text = rdr["Functionality"].ToString();
                            lblSubmittedAt.Text = Convert.ToDateTime(rdr["SubmittedAt"]).ToString("MMM dd, yyyy hh:mm tt");

                            // Prefill form for editing
                            txtProjectTitle.Text = rdr["ProjectTitle"].ToString();
                            if (ddlProjectType.Items.FindByValue(rdr["ProjectType"].ToString()) != null)
                            {
                                ddlProjectType.SelectedValue = rdr["ProjectType"].ToString();
                            }
                            txtFunctionality.Text = rdr["Functionality"].ToString();
                            btnSubmitProject.Text = "Update Project Proposal";
                        }
                        else
                        {
                            pnlExistingProject.Visible = false;
                        }
                    }
                }
            }
        }

        protected void btnSubmitProject_Click(object sender, EventArgs e)
        {
            if (CurrentGroupId == 0)
            {
                lblMessage.Text = "Error: You are not assigned as Leader of any group.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            string title = txtProjectTitle.Text.Trim();
            string type = ddlProjectType.SelectedValue;
            string functionality = txtFunctionality.Text.Trim();

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(functionality))
            {
                lblMessage.Text = "Please fill in all project fields.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            string normalizedTitle = title.ToLower().Trim();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                // Check if project exists for group
                string checkSql = "SELECT ProjectId FROM Projects WHERE GroupId = @GroupId";
                int existingProjectId = 0;
                using (SqlCommand checkCmd = new SqlCommand(checkSql, conn))
                {
                    checkCmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    object res = checkCmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value) existingProjectId = Convert.ToInt32(res);
                }

                if (existingProjectId > 0)
                {
                    // Update existing
                    string updateSql = @"
                        UPDATE Projects 
                        SET ProjectTitle = @Title, NormalizedTitle = @NormTitle, ProjectType = @Type, Functionality = @Func, SubmittedAt = GETDATE()
                        WHERE ProjectId = @ProjectId";
                    using (SqlCommand uCmd = new SqlCommand(updateSql, conn))
                    {
                        uCmd.Parameters.AddWithValue("@Title", title);
                        uCmd.Parameters.AddWithValue("@NormTitle", normalizedTitle);
                        uCmd.Parameters.AddWithValue("@Type", type);
                        uCmd.Parameters.AddWithValue("@Func", functionality);
                        uCmd.Parameters.AddWithValue("@ProjectId", existingProjectId);
                        uCmd.ExecuteNonQuery();
                    }
                    lblMessage.Text = "Project proposal updated successfully!";
                }
                else
                {
                    // Insert new
                    string insertSql = @"
                        INSERT INTO Projects (GroupId, ProjectType, ProjectTitle, NormalizedTitle, Functionality, Status, SubmittedAt)
                        VALUES (@GroupId, @Type, @Title, @NormTitle, @Func, 'Pending', GETDATE())";
                    using (SqlCommand iCmd = new SqlCommand(insertSql, conn))
                    {
                        iCmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                        iCmd.Parameters.AddWithValue("@Type", type);
                        iCmd.Parameters.AddWithValue("@Title", title);
                        iCmd.Parameters.AddWithValue("@NormTitle", normalizedTitle);
                        iCmd.Parameters.AddWithValue("@Func", functionality);
                        iCmd.ExecuteNonQuery();
                    }
                    lblMessage.Text = "Project proposal submitted successfully for Faculty review!";
                }
            }

            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadProjectDetails();
        }
    }
}
