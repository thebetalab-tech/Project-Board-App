using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Project_Board
{
    public partial class JoinGroup : System.Web.UI.Page
    {
        protected string UserInitials { get; set; } = "SM";

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
                LoadAvailableGroups();
            }
        }

        private void LoadAvailableGroups()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT g.GroupId, g.GroupName, t.TechName, l.FullName AS LeaderName,
                           (SELECT COUNT(1) FROM GroupMembers WHERE GroupId = g.GroupId AND UserId = @UserId AND JoinStatus = 'Requested') AS HasRequested
                    FROM Groups g
                    LEFT JOIN Technologies t ON g.TechId = t.TechId
                    JOIN Users l ON g.LeaderId = l.UserId
                    WHERE g.MemberNeeded = 1;
                ";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
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
                    // Check if already requested or invited
                    string checkSql = "SELECT COUNT(1) FROM GroupMembers WHERE GroupId = @GroupId AND UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(checkSql, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count == 0)
                        {
                            string insertSql = "INSERT INTO GroupMembers (GroupId, UserId, JoinStatus) VALUES (@GroupId, @UserId, 'Requested')";
                            using (SqlCommand insCmd = new SqlCommand(insertSql, conn))
                            {
                                insCmd.Parameters.AddWithValue("@GroupId", groupId);
                                insCmd.Parameters.AddWithValue("@UserId", userId);
                                insCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
                LoadAvailableGroups(); // Refresh UI
            }
        }
    }
}