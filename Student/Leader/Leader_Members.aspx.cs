using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Student.Leader
{
    public partial class Leader_Members : Page
    {
        protected global::System.Web.UI.WebControls.Repeater rptGroups;
        protected global::System.Web.UI.WebControls.Repeater rptPending;
        protected global::System.Web.UI.WebControls.TextBox txtInviteEmail;
        protected global::System.Web.UI.WebControls.Button btnInvite;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadMembers();
            }
        }

        private int GetGroupId(SqlConnection conn)
        {
            string query = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@LeaderId", Session["UserId"]);
                object result = cmd.ExecuteScalar();
                return result != null ? Convert.ToInt32(result) : 0;
            }
        }

        private void LoadMembers()
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                string query = @"
                    SELECT u.UserId, u.FullName, u.Email, u.EnrollmentNo, gm.JoinStatus, u.Role
                    FROM GroupMembers gm 
                    INNER JOIN Users u ON gm.UserId = u.UserId 
                    WHERE gm.GroupId = @GroupId AND u.IsActive = 1";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        DataView dvAccepted = new DataView(dt);
                        dvAccepted.RowFilter = "JoinStatus = 'Accepted'";
                        rptGroups.DataSource = dvAccepted;
                        rptGroups.DataBind();

                        DataView dvPending = new DataView(dt);
                        dvPending.RowFilter = "JoinStatus = 'Pending'";
                        rptPending.DataSource = dvPending;
                        rptPending.DataBind();
                    }
                }
            }
        }

        protected void btnInvite_Click(object sender, EventArgs e)
        {
            string inviteValue = txtInviteEmail.Text.Trim();
            if (string.IsNullOrEmpty(inviteValue)) return;

            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                // Find user
                string findUser = "SELECT UserId FROM Users WHERE (Email = @Val OR EnrollmentNo = @Val) AND IsActive = 1";
                int targetUserId = 0;
                using (SqlCommand cmd = new SqlCommand(findUser, conn))
                {
                    cmd.Parameters.AddWithValue("@Val", inviteValue);
                    object result = cmd.ExecuteScalar();
                    if (result != null) targetUserId = Convert.ToInt32(result);
                }

                if (targetUserId > 0)
                {
                    // Check if already invited
                    string checkSql = "SELECT COUNT(1) FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", targetUserId);
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count == 0)
                        {
                            string insertSql = "INSERT INTO GroupMembers (GroupId, UserId, JoinStatus) VALUES (@GroupId, @UserId, 'Pending')";
                            using (SqlCommand insCmd = new SqlCommand(insertSql, conn))
                            {
                                insCmd.Parameters.AddWithValue("@GroupId", groupId);
                                insCmd.Parameters.AddWithValue("@UserId", targetUserId);
                                insCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }
            txtInviteEmail.Text = "";
            LoadMembers();
        }

        protected void rptPending_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Cancel")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    int groupId = GetGroupId(conn);
                    if (groupId > 0)
                    {
                        string delSql = "DELETE FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Pending'";
                        using (SqlCommand cmd = new SqlCommand(delSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@GroupId", groupId);
                            cmd.Parameters.AddWithValue("@UserId", targetUserId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                LoadMembers();
            }
        }
    }
}