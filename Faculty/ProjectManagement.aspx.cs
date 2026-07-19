using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board.Faculty
{
    public partial class ProjectManagement : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "FM";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Faculty")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Faculty Member";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }
                LoadProjects();
            }
        }

        private void LoadProjects()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT p.ProjectId, p.ProjectTitle, p.ProjectType, p.Status, p.SubmittedAt, g.GroupName 
                    FROM Projects p
                    INNER JOIN Groups g ON p.GroupId = g.GroupId
                    WHERE g.MentorId = @FacultyId
                    ORDER BY p.SubmittedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptProjects.DataSource = dt;
                        rptProjects.DataBind();
                    }
                }
            }
        }

        protected void rptProjects_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int projectId = Convert.ToInt32(e.CommandArgument);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                string newStatus = e.CommandName == "Approve" ? "Approved" : "Rejected";
                
                string update = "UPDATE Projects SET Status = @Status WHERE ProjectId = @ProjectId";
                using (SqlCommand cmd = new SqlCommand(update, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@ProjectId", projectId);
                    cmd.ExecuteNonQuery();
                }
                
                ShowMessage($"Project {newStatus.ToLower()} successfully.", e.CommandName == "Approve");
            }
            LoadProjects();
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "form-message success" : "form-message error";
            lblMessage.Visible = true;
        }
    }
}
