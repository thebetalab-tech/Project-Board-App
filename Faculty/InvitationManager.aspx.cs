using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board.Faculty
{
    public partial class InvitationManager : System.Web.UI.Page
    {
        protected global::System.Web.UI.WebControls.Repeater rptRequests;
        protected global::System.Web.UI.WebControls.Label lblMessage;
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
                LoadRequests();
            }
        }

        private void LoadRequests()
        {
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT g.GroupId, g.GroupName, u.FullName AS LeaderName, t.TechName 
                    FROM Groups g
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    INNER JOIN Technologies t ON g.TechId = t.TechId
                    WHERE g.MentorId = @FacultyId AND g.Status = 'Pending Faculty Approval'";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptRequests.DataSource = dt;
                        rptRequests.DataBind();
                    }
                }
            }
        }

        protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int groupId = Convert.ToInt32(e.CommandArgument);
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                if (e.CommandName == "Accept")
                {
                    string update = "UPDATE Groups SET Status = 'Active' WHERE GroupId = @GroupId";
                    using (SqlCommand cmd = new SqlCommand(update, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Mentor request accepted successfully.", true);
                }
                else if (e.CommandName == "Reject")
                {
                    string update = "UPDATE Groups SET MentorId = NULL, Status = 'Forming' WHERE GroupId = @GroupId";
                    using (SqlCommand cmd = new SqlCommand(update, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.ExecuteNonQuery();
                    }

                    // Log rejection
                    string reject = "INSERT INTO GroupMentorRejections (GroupId, FacultyId) VALUES (@GroupId, @FacultyId)";
                    using (SqlCommand cmd = new SqlCommand(reject, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Mentor request rejected.", false);
                }
            }
            LoadRequests();
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "form-message success" : "form-message error";
            lblMessage.Visible = true;
        }
    }
}
