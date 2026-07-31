using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace Project_Board.Student.Member
{
    public partial class Member_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "SM";
        protected string UserName { get; set; } = "Student Member";
        protected string UserEmail { get; set; } = "member@example.com";
        protected int MemberTasksCompleted { get; set; } = 0;
        protected int TotalMemberTasks { get; set; } = 0;

        protected int TotalTasks { get; set; } = 0;
        protected int PendingCount { get; set; } = 0;
        protected int InProgressCount { get; set; } = 0;
        protected int CompletedCount { get; set; } = 0;

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Member";
            UserEmail = Session["Email"]?.ToString() ?? "member@example.com";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadMemberTasks();
                LoadGroupMentorTasks();
            }
        }

        private void LoadMemberTasks()
        {
            int memberId = Convert.ToInt32(Session["UserId"]);
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "MEMBER_ASSIGNED_TASKS");
                    cmd.Parameters.AddWithValue("@UserId", memberId);

                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            TotalMemberTasks = dt.Rows.Count;
            TotalTasks = dt.Rows.Count;
            MemberTasksCompleted = 0;
            PendingCount = 0;
            InProgressCount = 0;
            CompletedCount = 0;

            foreach (DataRow row in dt.Rows)
            {
                string st = row["Status"] != DBNull.Value ? row["Status"].ToString() : "";
                if (st == "Completed")
                {
                    MemberTasksCompleted++;
                    CompletedCount++;
                }
                else if (st == "Appealed" || st == "In Progress" || st == "Working")
                {
                    InProgressCount++;
                }
                else
                {
                    PendingCount++;
                }
            }

            rptMemberTasks.DataSource = dt;
            rptMemberTasks.DataBind();
            lblNoTasks.Visible = dt.Rows.Count == 0;
        }

        private void LoadGroupMentorTasks()
        {
            int memberId = Convert.ToInt32(Session["UserId"]);
            int groupId = 0;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string groupSql = @"
                    SELECT TOP 1 g.GroupId 
                    FROM Groups g
                    LEFT JOIN GroupMembers gm ON g.GroupId = gm.GroupId AND gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted')
                    WHERE g.LeaderId = @UserId OR (gm.UserId = @UserId AND (gm.JoinStatus = 'Accepted' OR gm.JoinStatus = 'accepted'))
                    ORDER BY CASE WHEN g.LeaderId = @UserId THEN 0 ELSE 1 END;";

                using (SqlCommand cmd = new SqlCommand(groupSql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", memberId);
                    object res = cmd.ExecuteScalar();
                    if (res != null) groupId = Convert.ToInt32(res);
                }

                if (groupId > 0)
                {
                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "MENTOR_LEADER_TASKS");
                        cmd.Parameters.AddWithValue("@GroupId", groupId);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            da.Fill(dt);
                        }
                    }

                    rptGroupMentorTasks.DataSource = dt;
                    rptGroupMentorTasks.DataBind();
                    lblNoGroupMentorTasks.Visible = dt.Rows.Count == 0;
                }
                else
                {
                    lblNoGroupMentorTasks.Visible = true;
                }
            }
        }

        protected void rptMemberTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ReportToLeader")
            {
                int taskId = Convert.ToInt32(e.CommandArgument);
                Response.Redirect($"~/Student/Appeal.aspx?TaskId={taskId}");
            }
        }

    }
}