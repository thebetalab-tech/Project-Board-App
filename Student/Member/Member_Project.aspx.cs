using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;

namespace Project_Board.Student.Member
{
    public partial class Member_Project : Page
    {
        protected string UserInitials { get; set; } = "SM";
        protected string UserName { get; set; } = "Student Member";
        protected string UserEmail { get; set; } = "member@example.com";

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Member";
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadMemberProject();
            }
        }

        private void LoadMemberProject()
        {
            int userId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

                // Identify Group
                string groupSql = @"
                    SELECT TOP 1 g.GroupId, g.GroupName 
                    FROM Groups g
                    LEFT JOIN GroupMembers gm ON g.GroupId = gm.GroupId AND gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted')
                    WHERE g.LeaderId = @UserId OR (gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted'))
                    ORDER BY CASE WHEN g.LeaderId = @UserId THEN 0 ELSE 1 END;";

                int groupId = 0;
                string groupName = "";

                using (SqlCommand gCmd = new SqlCommand(groupSql, conn))
                {
                    gCmd.Parameters.AddWithValue("@UserId", userId);
                    using (SqlDataReader gRdr = gCmd.ExecuteReader())
                    {
                        if (gRdr.Read())
                        {
                            groupId = Convert.ToInt32(gRdr["GroupId"]);
                            groupName = gRdr["GroupName"].ToString();
                        }
                    }
                }

                if (groupId > 0)
                {
                    lblGroupName.Text = groupName;

                    string projSql = "SELECT * FROM Projects WHERE GroupId = @GroupId";
                    using (SqlCommand pCmd = new SqlCommand(projSql, conn))
                    {
                        pCmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataReader pRdr = pCmd.ExecuteReader())
                        {
                            if (pRdr.Read())
                            {
                                pnlProjectDetails.Visible = true;
                                pnlNoProject.Visible = false;

                                lblProjectTitle.Text = pRdr["ProjectTitle"].ToString();
                                lblProjectType.Text = pRdr["ProjectType"].ToString();
                                lblProjectStatus.Text = pRdr["Status"].ToString();
                                lblFunctionality.Text = pRdr["Functionality"].ToString();
                                lblSubmittedAt.Text = Convert.ToDateTime(pRdr["SubmittedAt"]).ToString("MMM dd, yyyy hh:mm tt");
                            }
                            else
                            {
                                pnlProjectDetails.Visible = false;
                                pnlNoProject.Visible = true;
                            }
                        }
                    }
                }
                else
                {
                    pnlProjectDetails.Visible = false;
                    pnlNoProject.Visible = true;
                }
            }
        }
    }
}
