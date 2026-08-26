using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Leader
{
    public partial class InvitationManager : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "TL";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["FullName"]?.ToString() ?? "Student Leader";
                if (!string.IsNullOrEmpty(fullName))
                {
                    UserInitials = fullName.Substring(0, 1).ToUpper();
                }
                LoadInvitations();
            }
        }

        private int GetGroupId(SqlConnection conn)
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string sql = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@LeaderId", userId);
                object result = cmd.ExecuteScalar();
                if (result != null) return Convert.ToInt32(result);
            }
            return 0;
        }

        private void LoadInvitations()
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                string query = @"
                    SELECT u.UserId, u.FullName, u.Email, u.EnrollmentNo, gm.JoinStatus
                    FROM GroupMembers gm 
                    INNER JOIN Users u ON gm.UserId = u.UserId 
                    WHERE gm.GroupId = @GroupId AND u.IsActive = 1 AND gm.JoinStatus IN ('Pending', 'Requested')";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataView dvRequested = new DataView(dt);
                        dvRequested.RowFilter = "JoinStatus = 'Requested'";
                        rptRequests.DataSource = dvRequested;
                        rptRequests.DataBind();
                        pnlRequests.Visible = dvRequested.Count > 0;

                        DataView dvPending = new DataView(dt);
                        dvPending.RowFilter = "JoinStatus = 'Pending'";
                        rptPending.DataSource = dvPending;
                        rptPending.DataBind();
                        pnlPending.Visible = dvPending.Count > 0;
                        
                        pnlEmptyState.Visible = dvRequested.Count == 0 && dvPending.Count == 0;
                    }
                }
            }
        }

        protected void rptRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int targetUserId = Convert.ToInt32(e.CommandArgument);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                if (e.CommandName == "Accept")
                {
                    string acceptSql = "UPDATE GroupMembers SET JoinStatus = 'Accepted' WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Requested'";
                    using (SqlCommand cmd = new SqlCommand(acceptSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        cmd.ExecuteNonQuery();
                    }

                    string deleteOthersSql = "DELETE FROM GroupMembers WHERE UserId = @UserId AND JoinStatus != 'Accepted'";
                    using (SqlCommand cmd = new SqlCommand(deleteOthersSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else if (e.CommandName == "Reject")
                {
                    // Get user info for notification
                    string memberName = "";
                    string memberEmail = "";
                    string userInfoSql = "SELECT u.FullName, u.Email FROM Users u WHERE u.UserId = @UserId";
                    using (SqlCommand infoCmd = new SqlCommand(userInfoSql, conn))
                    {
                        infoCmd.Parameters.AddWithValue("@UserId", targetUserId);
                        using (SqlDataReader rdr = infoCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                memberName = rdr["FullName"].ToString();
                                memberEmail = rdr["Email"].ToString();
                            }
                        }
                    }

                    if (!string.IsNullOrEmpty(memberEmail))
                    {
                        // Update status to 'Rejected' instead of deleting
                        string rejectSql = "UPDATE GroupMembers SET JoinStatus = 'Rejected' WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Requested'";
                        using (SqlCommand rejectCmd = new SqlCommand(rejectSql, conn))
                        {
                            rejectCmd.Parameters.AddWithValue("@GroupId", groupId);
                            rejectCmd.Parameters.AddWithValue("@UserId", targetUserId);
                            rejectCmd.ExecuteNonQuery();
                        }

                        // Send rejection notification to user
                        string notificationSql = "INSERT INTO Notifications (UserId, Message, Link) VALUES (@UserId, @Message, @Link)";
                        using (SqlCommand notifyCmd = new SqlCommand(notificationSql, conn))
                        {
                            notifyCmd.Parameters.AddWithValue("@UserId", targetUserId);
                            notifyCmd.Parameters.AddWithValue("@Message", "Your request to join group has been rejected by " + Session["FullName"]);
                            notifyCmd.Parameters.AddWithValue("@Link", "~/Student/Member/MyRequests.aspx");
                            notifyCmd.ExecuteNonQuery();
                        }
                        
                        // Send Email
                        string groupNameSql = "SELECT GroupName FROM Groups WHERE GroupId = @GroupId";
                        using (SqlCommand grpCmd = new SqlCommand(groupNameSql, conn))
                        {
                            grpCmd.Parameters.AddWithValue("@GroupId", groupId);
                            string groupName = grpCmd.ExecuteScalar()?.ToString() ?? "Group";
                            Project_Board.Services.EmailService.SendMemberJoinRequestRejectedNotification(
                                memberEmail,
                                memberName,
                                Session["FullName"]?.ToString() ?? "Leader",
                                groupName
                            );
                        }
                    }
                }

                // Send email notification (Scenario 9)
                try
                {
                    if (e.CommandName == "Accept")
                    {
                        string infoSql = @"
                            SELECT u.FullName AS MemberName, g.GroupName, l.FullName AS LeaderName, l.Email AS LeaderEmail
                            FROM Users u, (SELECT * FROM Groups WHERE IsActive = 1 OR IsActive IS NULL) g, Users l
                            WHERE u.UserId = @UserId AND g.GroupId = @GroupId AND g.LeaderId = l.UserId";
                        using (SqlCommand infoCmd = new SqlCommand(infoSql, conn))
                        {
                            infoCmd.Parameters.AddWithValue("@UserId", targetUserId);
                            infoCmd.Parameters.AddWithValue("@GroupId", groupId);
                            using (SqlDataReader rdr = infoCmd.ExecuteReader())
                            {
                                if (rdr.Read())
                                {
                                    string memberName = rdr["MemberName"].ToString();
                                    string groupName = rdr["GroupName"].ToString();
                                    string leaderName = rdr["LeaderName"].ToString();
                                    string leaderEmail = rdr["LeaderEmail"].ToString();

                                    Project_Board.Services.EmailService.SendMemberJoinedNotification(
                                        leaderEmail,
                                        leaderName,
                                        memberName,
                                        groupName
                                    );
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(ex.Message);
                }
            }
            LoadInvitations();
        }

        protected void rptPending_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Revoke")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    int groupId = GetGroupId(conn);
                    if (groupId == 0) return;

                    string deleteSql = "DELETE FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Pending'";
                    using (SqlCommand cmd = new SqlCommand(deleteSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadInvitations();
            }
        }
    }
}