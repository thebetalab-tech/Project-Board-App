using System;
using System.Configuration;
using System.Data.SqlClient;

namespace Project_Board.Faculty
{
    public partial class RejectionForm : System.Web.UI.Page
    {
        protected global::System.Web.UI.HtmlControls.HtmlForm form1;
        protected global::System.Web.UI.WebControls.Literal litType;
        protected global::System.Web.UI.WebControls.Label lblError;
        protected global::System.Web.UI.WebControls.TextBox txtReason;
        protected global::System.Web.UI.WebControls.LinkButton btnCancel;
        protected global::System.Web.UI.WebControls.Button btnSubmit;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Faculty")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string type = Request.QueryString["type"];
                if (string.IsNullOrEmpty(type) || string.IsNullOrEmpty(Request.QueryString["id"]))
                {
                    Response.Redirect("Dashboard.aspx");
                    return;
                }
                litType.Text = type;
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            string type = Request.QueryString["type"];
            if (type == "Project") Response.Redirect("ProjectManagement.aspx");
            else if (type == "Task" || type == "Appeal") Response.Redirect("TaskManagement.aspx");
            else if (type == "Group") Response.Redirect("InvitationManager.aspx");
            else Response.Redirect("Dashboard.aspx");
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string reason = txtReason.Text.Trim();
            if (string.IsNullOrEmpty(reason))
            {
                lblError.Text = "Please enter a reason.";
                lblError.Visible = true;
                return;
            }

            string type = Request.QueryString["type"];
            int id = Convert.ToInt32(Request.QueryString["id"]);
            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // 1. Log Rejection
                using (SqlCommand cmd = new SqlCommand("sp_crud_rejectionlogs", conn))
                {
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "INSERT");
                    cmd.Parameters.AddWithValue("@EntityType", type);
                    cmd.Parameters.AddWithValue("@EntityId", id);
                    cmd.Parameters.AddWithValue("@RejectedBy", facultyId);
                    cmd.Parameters.AddWithValue("@Reason", reason);
                    cmd.ExecuteNonQuery();
                }

                int studentUserId = 0;
                string notificationMsg = $"Your {type} was rejected by your mentor. Reason: {reason}";
                string redirectUrl = "Dashboard.aspx";

                // 2. Update Entity Status & Find Student to Notify
                if (type == "Project")
                {
                    // Update Project Status
                    using (SqlCommand cmd = new SqlCommand("UPDATE Projects SET Status = 'Rejected' WHERE ProjectId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        cmd.ExecuteNonQuery();
                    }
                    // Find Leader
                    using (SqlCommand cmd = new SqlCommand("SELECT g.LeaderId FROM Projects p JOIN Groups g ON p.GroupId = g.GroupId WHERE p.ProjectId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        object result = cmd.ExecuteScalar();
                        if (result != null) studentUserId = Convert.ToInt32(result);
                    }
                    redirectUrl = "ProjectManagement.aspx";
                }
                else if (type == "Task")
                {
                    // Update Task Status
                    using (SqlCommand cmd = new SqlCommand("UPDATE Task SET Status = 'Revision Needed' WHERE TaskId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        cmd.ExecuteNonQuery();
                    }
                    // Find AssignedTo
                    using (SqlCommand cmd = new SqlCommand("SELECT AssignedTo FROM Task WHERE TaskId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        object result = cmd.ExecuteScalar();
                        if (result != null) studentUserId = Convert.ToInt32(result);
                    }
                    redirectUrl = "TaskDetails.aspx?id=" + id;
                }
                else if (type == "Appeal")
                {
                    // Reject Appeal is basically marking the Task as Revision Needed
                    using (SqlCommand cmd = new SqlCommand("UPDATE Task SET Status = 'Revision Needed' WHERE TaskId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        cmd.ExecuteNonQuery();
                    }
                    using (SqlCommand cmd = new SqlCommand("SELECT AssignedTo FROM Task WHERE TaskId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        object result = cmd.ExecuteScalar();
                        if (result != null) studentUserId = Convert.ToInt32(result);
                    }
                    redirectUrl = "TaskDetails.aspx?id=" + id;
                }
                else if (type == "Group")
                {
                    // Mentor rejects group assignment
                    using (SqlCommand cmd = new SqlCommand("UPDATE Groups SET Status = 'Forming', MentorId = NULL WHERE GroupId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        cmd.ExecuteNonQuery();
                    }
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO GroupMentorRejections (GroupId, FacultyId, RejectedAt) VALUES (@GroupId, @FacultyId, GETDATE())", conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", id);
                        cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                        cmd.ExecuteNonQuery();
                    }
                    using (SqlCommand cmd = new SqlCommand("SELECT LeaderId FROM Groups WHERE GroupId = @Id", conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", id);
                        object result = cmd.ExecuteScalar();
                        if (result != null) studentUserId = Convert.ToInt32(result);
                    }
                    notificationMsg = $"Your mentor request was declined. Reason: {reason}";
                    redirectUrl = "InvitationManager.aspx";
                }

                // 3. Send Notification
                if (studentUserId > 0)
                {
                    using (SqlCommand cmd = new SqlCommand("sp_crud_notifications", conn))
                    {
                        cmd.CommandType = System.Data.CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "INSERT");
                        cmd.Parameters.AddWithValue("@UserId", studentUserId);
                        cmd.Parameters.AddWithValue("@Message", notificationMsg);
                        cmd.Parameters.AddWithValue("@Link", DBNull.Value);
                        cmd.ExecuteNonQuery();
                    }
                }

                Response.Redirect(redirectUrl);
            }
        }
    }
}
