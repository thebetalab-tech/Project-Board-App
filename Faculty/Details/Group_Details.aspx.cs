using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Faculty.Details
{
    public partial class Group_Details : System.Web.UI.Page
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

                if (Request.QueryString["GroupId"] != null)
                {
                    LoadGroupDetails(Request.QueryString["GroupId"]);
                }
                else
                {
                    ShowError("Group ID is missing.");
                }
            }
        }

        private void LoadGroupDetails(string groupIdStr)
        {
            if (!int.TryParse(groupIdStr, out int groupId))
            {
                ShowError("Invalid Group ID.");
                return;
            }

            int facultyId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Verify the group belongs to this mentor and get details
                string queryDetails = @"
                    SELECT g.GroupName, g.Status, t.TechName, u.FullName AS LeaderName
                    FROM (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g
                    INNER JOIN Technologies t ON g.TechId = t.TechId
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    WHERE g.GroupId = @GroupId AND g.MentorId = @FacultyId";

                using (SqlCommand cmd = new SqlCommand(queryDetails, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.Parameters.AddWithValue("@FacultyId", facultyId);
                    
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litGroupName.Text = reader["GroupName"].ToString();
                            litTechnology.Text = reader["TechName"].ToString();
                            litStatus.Text = reader["Status"].ToString();
                            litLeaderName.Text = reader["LeaderName"].ToString();
                        }
                        else
                        {
                            ShowError("Group not found or you do not have permission to view it.");
                            return;
                        }
                    }
                }

                // Get members
                string queryMembers = @"
                    SELECT u.FullName, u.Email, u.EnrollmentNo, u.IsLeader
                    FROM GroupMembers gm
                    INNER JOIN Users u ON gm.UserId = u.UserId
                    WHERE gm.GroupId = @GroupId AND gm.JoinStatus = 'Accepted'
                    ORDER BY u.IsLeader DESC, u.FullName ASC";

                using (SqlCommand cmdMembers = new SqlCommand(queryMembers, conn))
                {
                    cmdMembers.Parameters.AddWithValue("@GroupId", groupId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmdMembers))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptMembers.DataSource = dt;
                        rptMembers.DataBind();
                    }
                }
            }
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "form-message error";
            lblMessage.Visible = true;
            DetailsContainer.Visible = false;
        }
    }
}