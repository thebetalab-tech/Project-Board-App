using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace Project_Board.Student.Member
{
    public partial class Member_Team : Page
    {
        protected string UserInitials { get; set; } = "SM";
        protected bool IsAssigned { get; set; } = false;

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
                LoadTeamMembers();
            }
        }

        private void LoadTeamMembers()
        {
            int userId = Convert.ToInt32(Session["UserId"]);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                
                string groupSql = "SELECT GroupId FROM GroupMembers WHERE UserId = @UserId AND JoinStatus = 'Accepted'";
                int groupId = 0;
                using (SqlCommand cmd = new SqlCommand(groupSql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        groupId = Convert.ToInt32(result);
                        IsAssigned = true;
                    }
                }

                if (groupId > 0)
                {
                    pnlAssigned.Visible = true;
                    pnlUnassigned.Visible = false;

                    string query = @"
                        SELECT u.UserId, u.FullName, u.Email, u.EnrollmentNo, 'Leader' AS Role
                        FROM Users u
                        JOIN Groups g ON u.UserId = g.LeaderId
                        WHERE g.GroupId = @GroupId
                        UNION
                        SELECT u.UserId, u.FullName, u.Email, u.EnrollmentNo, 'Member' AS Role
                        FROM Users u
                        JOIN GroupMembers gm ON u.UserId = gm.UserId
                        WHERE gm.GroupId = @GroupId AND gm.JoinStatus = 'Accepted'
                        ORDER BY Role DESC, u.FullName ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);
                            rptRoster.DataSource = dt;
                            rptRoster.DataBind();
                        }
                    }
                }
                else
                {
                    pnlAssigned.Visible = false;
                    pnlUnassigned.Visible = true;
                }
            }
        }
        
        protected string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "U";
            return name.Substring(0, 1).ToUpper();
        }
    }
}
