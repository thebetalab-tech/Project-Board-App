using System;
using System.Web.UI;

namespace Project_Board.Student.Leader
{
    public partial class LeaderMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] != null)
            {
                string role = Session["Role"]?.ToString() ?? "";
                string isLeaderStr = Session["IsLeader"]?.ToString();
                bool isLeader = !string.IsNullOrEmpty(isLeaderStr) && (isLeaderStr.Equals("True", StringComparison.OrdinalIgnoreCase) || isLeaderStr == "1");

                if (role == "Student" && !isLeader)
                {
                    Response.Redirect("~/Student/Member/Dashboard.aspx");
                    return;
                }
                else if (role == "Faculty")
                {
                    Response.Redirect("~/Faculty/Dashboard.aspx");
                    return;
                }

                // Check for Lockdown
                bool isLockedDown = false;
                string connString = System.Configuration.ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
                if (!string.IsNullOrEmpty(connString))
                {
                    using (System.Data.SqlClient.SqlConnection conn = new System.Data.SqlClient.SqlConnection(connString))
                    {
                        conn.Open();
                        string sql = @"
                            SELECT 1 FROM Groups g WHERE g.LeaderId = @UserId AND g.IsActive = 0
                            UNION
                            SELECT 1 FROM Groups g INNER JOIN GroupMembers gm ON g.GroupId = gm.GroupId WHERE gm.UserId = @UserId AND gm.JoinStatus = 'Accepted' AND g.IsActive = 0";
                        using (System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", Session["UserId"]);
                            object result = cmd.ExecuteScalar();
                            if (result != null)
                            {
                                isLockedDown = true;
                            }
                        }
                    }
                }

                if (isLockedDown)
                {
                    Response.Redirect("~/Student/Lockdown.aspx");
                }
            }
            else
            {
                Response.Redirect("~/Default.aspx");
            }
        }
    }
}
