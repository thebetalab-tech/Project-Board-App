using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Student.Member
{
    public partial class Member_TaskManagement : Page
    {
        protected string UserInitials { get; set; } = "M";
        protected string UserName { get; set; } = "Student Member";
        protected string UserEmail { get; set; } = "member@example.com";

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
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadMemberTasks();
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
                    cmd.Parameters.AddWithValue("@Action", "BY_ASSIGNED_TO");
                    cmd.Parameters.AddWithValue("@UserId", memberId);

                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }
            }

            TotalTasks = dt.Rows.Count;
            PendingCount = 0;
            InProgressCount = 0;
            CompletedCount = 0;

            foreach (DataRow row in dt.Rows)
            {
                string st = row["Status"].ToString();
                if (st == "Pending") PendingCount++;
                else if (st == "In Progress") InProgressCount++;
                else if (st == "Completed") CompletedCount++;
            }

            rptMemberTasks.DataSource = dt;
            rptMemberTasks.DataBind();

            lblNoTasks.Visible = dt.Rows.Count == 0;
        }

        protected void rptMemberTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int taskId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ReportToLeader")
            {
                hfReportTaskId.Value = taskId.ToString();

                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    using (SqlCommand cmd = new SqlCommand("sp_select_tasks", conn))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Action", "BY_ID");
                        cmd.Parameters.AddWithValue("@TaskId", taskId);

                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblModalTaskTitle.Text = reader["TaskTitle"].ToString();
                                lblModalLeaderName.Text = reader["AssignedByName"].ToString();
                                ddlUpdateStatus.SelectedValue = reader["Status"].ToString();
                                txtMemberReportText.Text = reader["ReportText"] != DBNull.Value ? reader["ReportText"].ToString() : "";
                            }
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "OpenReportModal", "openModal('reportModal');", true);
            }
        }

        protected void btnSubmitReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfReportTaskId.Value)) return;

            int taskId = Convert.ToInt32(hfReportTaskId.Value);
            string status = ddlUpdateStatus.SelectedValue;
            string reportText = txtMemberReportText.Text.Trim();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_tasks", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "SUBMIT_REPORT");
                    cmd.Parameters.AddWithValue("@TaskId", taskId);
                    cmd.Parameters.AddWithValue("@Status", status);
                    cmd.Parameters.AddWithValue("@ReportText", reportText);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            lblMessage.Text = "Report and status successfully updated for your Leader!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            LoadMemberTasks();
        }
    }
}