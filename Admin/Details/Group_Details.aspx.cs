using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Admin.Details
{
    public partial class Group_Details : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "AD";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Administrator";
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

            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string queryDetails = @"
                    SELECT g.GroupName, g.Status, t.TechName, u.FullName AS LeaderName
                    FROM Groups g
                    INNER JOIN Technologies t ON g.TechId = t.TechId
                    INNER JOIN Users u ON g.LeaderId = u.UserId
                    WHERE g.GroupId = @GroupId";

                using (SqlCommand cmd = new SqlCommand(queryDetails, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    
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
                            ShowError("Group not found.");
                            return;
                        }
                    }
                }

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
