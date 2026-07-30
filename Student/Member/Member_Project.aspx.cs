using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Collections.Generic;

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
                LoadMemberProjects();
            }
        }

        private void LoadMemberProjects()
        {
            int userId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();

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

                    string projSql = "SELECT * FROM Projects WHERE GroupId = @GroupId ORDER BY SubmittedAt DESC";
                    using (SqlCommand pCmd = new SqlCommand(projSql, conn))
                    {
                        pCmd.Parameters.AddWithValue("@GroupId", groupId);
                        using (SqlDataAdapter da = new SqlDataAdapter(pCmd))
                        {
                            DataTable dtProjects = new DataTable();
                            da.Fill(dtProjects);

                            if (dtProjects.Rows.Count > 0)
                            {
                                pnlProjectDetails.Visible = true;
                                pnlNoProject.Visible = false;

                                dtProjects.Columns.Add("Keywords", typeof(string));

                                foreach (DataRow row in dtProjects.Rows)
                                {
                                    int projId = Convert.ToInt32(row["ProjectId"]);
                                    string kwQuery = "SELECT Keyword FROM ProjectKeywords WHERE ProjectId = @ProjectId";
                                    using (SqlCommand kwCmd = new SqlCommand(kwQuery, conn))
                                    {
                                        kwCmd.Parameters.AddWithValue("@ProjectId", projId);
                                        List<string> kwList = new List<string>();
                                        using (SqlDataReader rdr = kwCmd.ExecuteReader())
                                        {
                                            while (rdr.Read())
                                            {
                                                kwList.Add(rdr["Keyword"].ToString());
                                            }
                                        }
                                        row["Keywords"] = string.Join(", ", kwList);
                                    }
                                }

                                rptMemberProposals.DataSource = dtProjects;
                                rptMemberProposals.DataBind();
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
