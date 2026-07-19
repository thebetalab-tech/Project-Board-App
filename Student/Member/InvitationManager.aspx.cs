using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Member
{
    public partial class InvitationManager : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "SM";
        
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
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
                LoadInvitations();
            }
        }

        private void LoadInvitations()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT g.GroupId, g.GroupName, t.TechName, l.FullName AS LeaderName 
                    FROM GroupMembers gm
                    INNER JOIN Groups g ON gm.GroupId = g.GroupId
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    INNER JOIN Users l ON g.LeaderId = l.UserId
                    WHERE gm.UserId = @UserId AND gm.JoinStatus = 'Pending'
                ";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptInvitations.DataSource = dt;
                        rptInvitations.DataBind();
                        pnlEmptyState.Visible = dt.Rows.Count == 0;
                        pnlInvitations.Visible = dt.Rows.Count > 0;
                    }
                }
            }
        }

        protected void rptInvitations_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int groupId = Convert.ToInt32(e.CommandArgument);
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                if (e.CommandName == "Accept")
                {
                    // Update this invite to Accepted
                    string acceptSql = "UPDATE GroupMembers SET JoinStatus = 'Accepted' WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Pending'";
                    using (SqlCommand cmd = new SqlCommand(acceptSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.ExecuteNonQuery();
                    }

                    // Delete other invites/requests
                    string deleteOthersSql = "DELETE FROM GroupMembers WHERE UserId = @UserId AND JoinStatus != 'Accepted'";
                    using (SqlCommand cmd = new SqlCommand(deleteOthersSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else if (e.CommandName == "Reject")
                {
                    string rejectSql = "DELETE FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId AND JoinStatus = 'Pending'";
                    using (SqlCommand cmd = new SqlCommand(rejectSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            LoadInvitations();
        }
    }
}