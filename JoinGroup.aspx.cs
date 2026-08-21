using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board
{
    public partial class JoinGroup : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "SM";
        protected string SuccessMessage { get; set; } = "";
        protected string ErrorMessage { get; set; } = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Student")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Student Member";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }

                // Ensure IsActive column exists
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
                if (!string.IsNullOrEmpty(connString))
                {
                    using (SqlConnection conn = new SqlConnection(connString))
                    {
                        conn.Open();
                        string sql = @"
                            IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Groups]') AND name = 'IsActive')
                            BEGIN
                                ALTER TABLE [dbo].[Groups] ADD IsActive BIT NOT NULL DEFAULT 1;
                            END";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                LoadTechnologies();
                LoadAvailableGroups();
            }
            else
            {
                // Removed because it runs before ItemCommand. Messages are now shown directly.
            }
        }

        private void LoadTechnologies()
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT TechId, TechName FROM Technologies ORDER BY TechName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    ddlTechnology.DataSource = cmd.ExecuteReader();
                    ddlTechnology.DataTextField = "TechName";
                    ddlTechnology.DataValueField = "TechId";
                    ddlTechnology.DataBind();
                    ddlTechnology.Items.Insert(0, new ListItem("All Technologies", "0"));
                }
            }
        }

        private void LoadAvailableGroups(int techId = 0)
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT g.GroupId, g.GroupName, t.TechName, l.FullName AS LeaderName,
                           (SELECT COUNT(1) FROM GroupMembers WHERE GroupId = g.GroupId AND UserId = @UserId AND JoinStatus = 'Requested') AS HasRequested,
                           g.MemberNeeded
                    FROM Groups g
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    JOIN Users l ON g.LeaderId = l.UserId";

                if (techId > 0)
                {
                    query += " WHERE g.TechId = @TechId AND g.MemberNeeded = 1 AND g.IsActive = 1";
                }
                else
                {
                    query += " WHERE g.MemberNeeded = 1 AND g.IsActive = 1";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    if (techId > 0)
                    {
                        cmd.Parameters.AddWithValue("@TechId", techId);
                    }
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptAvailableGroups.DataSource = dt;
                        rptAvailableGroups.DataBind();
                    }
                }
            }
        }

        protected void ddlTechnology_SelectedIndexChanged(object sender, EventArgs e)
        {
            int techId = Convert.ToInt32(ddlTechnology.SelectedValue);
            LoadAvailableGroups(techId);
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            ddlTechnology.SelectedIndex = 0;
            LoadAvailableGroups(0);
        }

        protected void rptAvailableGroups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "RequestJoin")
            {
                int groupId = Convert.ToInt32(e.CommandArgument);
                int userId = Convert.ToInt32(Session["UserId"]);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Check if user already has a pending request
                    string checkActiveRequestSql = "SELECT COUNT(1) FROM GroupMembers WHERE UserId = @UserId AND JoinStatus IN ('Pending', 'Requested')";
                    using (SqlCommand checkCmd = new SqlCommand(checkActiveRequestSql, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@UserId", userId);
                        int count = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (count > 0)
                        {
                            ShowMessage("You already have a pending group join request. Please wait for the leader's response.", false);
                            LoadAvailableGroups(ddlTechnology.SelectedValue != "0" ? Convert.ToInt32(ddlTechnology.SelectedValue) : 0);
                            return;
                        }
                    }

                    // Check if already requested or invited for this group
                    string checkSql = "SELECT COUNT(1) FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count == 0)
                        {
                            string insertSql = "INSERT INTO GroupMembers (GroupId, UserId, JoinStatus, RequestedAt) VALUES (@GroupId, @UserId, 'Requested', GETDATE())";
                            using (SqlCommand insCmd = new SqlCommand(insertSql, conn))
                            {
                                insCmd.Parameters.AddWithValue("@GroupId", groupId);
                                insCmd.Parameters.AddWithValue("@UserId", userId);
                                insCmd.ExecuteNonQuery();
                            }

                            // Send notification to group leader
                            string leaderSql = "SELECT l.UserId, l.FullName, g.GroupName FROM Groups g JOIN Users l ON g.LeaderId = l.UserId WHERE g.GroupId = @GroupId";
                            using (SqlCommand leaderCmd = new SqlCommand(leaderSql, conn))
                            {
                                leaderCmd.Parameters.AddWithValue("@GroupId", groupId);
                                using (SqlDataReader rdr = leaderCmd.ExecuteReader())
                                {
                                    if (rdr.Read())
                                    {
                                        int leaderId = Convert.ToInt32(rdr["UserId"]);
                                        string leaderName = rdr["FullName"].ToString();
                                        string groupName = rdr["GroupName"].ToString();

                                        // Insert notification for leader
                                        string notifySql = "INSERT INTO Notifications (UserId, Message, Link) VALUES (@UserId, @Message, @Link)";
                                        using (SqlCommand notifyCmd = new SqlCommand(notifySql, conn))
                                        {
                                            notifyCmd.Parameters.AddWithValue("@UserId", leaderId);
                                            notifyCmd.Parameters.AddWithValue("@Message", "New group join request from " + Session["FullName"]);
                                            notifyCmd.Parameters.AddWithValue("@Link", "~/Student/Leader/InvitationManager.aspx");
                                            notifyCmd.ExecuteNonQuery();
                                        }
                                    }
                                }
                            }

                            ShowMessage("Your request to join the group has been submitted successfully. You will be notified when the leader responds.", true);
                        }
                        else
                        {
                            ShowMessage("You have already requested to join this group.", false);
                        }
                    }
                }
                LoadAvailableGroups(ddlTechnology.SelectedValue != "0" ? Convert.ToInt32(ddlTechnology.SelectedValue) : 0);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "alert alert-success" : "alert alert-danger";

            string icon = isSuccess ? "<i class='fa-solid fa-check-circle' style='margin-right:0.5rem;'></i>" : "<i class='fa-solid fa-exclamation-circle' style='margin-right:0.5rem;'></i>";
            string bgColor = isSuccess ? "rgba(34,197,94,0.15)" : "rgba(239,68,68,0.15)";
            string color = isSuccess ? "#22c55e" : "#ef4444";

            pnlMessage.Style["background"] = bgColor;
            pnlMessage.Style["color"] = color;
            pnlMessage.Style["border"] = "1px solid " + color;
            pnlMessage.Style["display"] = "block";

            litMessage.Text = icon + message;
        }
    }
}
