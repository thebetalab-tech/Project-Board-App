using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.Linq;
using Project_Board.Admin;
using Project_Board.Services;

namespace Project_Board.Student.Leader
{
    public partial class Leader_Project : Page
    {
        protected string UserInitials { get; set; } = "TL";
        protected string UserName { get; set; } = "Student Leader";
        protected string UserEmail { get; set; } = "leader@example.com";
        protected int CurrentGroupId { get; set; } = 0;
        protected string CurrentGroupStatus { get; set; } = "";

        private string ConnString => ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            UserName = Session["FullName"]?.ToString() ?? "Student Leader";
            UserEmail = Session["Email"]?.ToString() ?? "";
            if (!string.IsNullOrEmpty(UserName))
            {
                UserInitials = UserName.Substring(0, 1).ToUpper();
            }

            LoadGroupInfo();

            if (!IsPostBack)
            {
                LoadProposals();
            }
        }

        private void LoadGroupInfo()
        {
            int leaderId = Convert.ToInt32(Session["UserId"]);
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                string query = "SELECT GroupId, Status FROM Groups WHERE LeaderId = @LeaderId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            CurrentGroupId = Convert.ToInt32(rdr["GroupId"]);
                            CurrentGroupStatus = rdr["Status"].ToString();
                        }
                    }
                }
            }

            if (CurrentGroupId == 0 || CurrentGroupStatus != "Assigned Mentor")
            {
                pnlSubmissionForm.Visible = false;
                if (CurrentGroupId != 0 && CurrentGroupStatus != "Assigned Mentor")
                {
                    lblMessage.Text = "Notice: You can only submit a project proposal after your mentor request has been accepted.";
                    lblMessage.CssClass = "alert-warning-box";
                    lblMessage.Visible = true;
                }
            }
            else
            {
                pnlSubmissionForm.Visible = true;
            }
        }

        private void LoadProposals()
        {
            if (CurrentGroupId == 0) return;

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string query = "SELECT * FROM Projects WHERE GroupId = @GroupId ORDER BY SubmittedAt DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dtProjects = new DataTable();
                        da.Fill(dtProjects);

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

                        rptProposals.DataSource = dtProjects;
                        rptProposals.DataBind();
                    }
                }
            }
        }

        protected void txtProjectTitle_TextChanged(object sender, EventArgs e)
        {
            CheckTitleSimilarity(txtProjectTitle.Text.Trim());
        }

        private bool CheckTitleSimilarity(string title)
        {
            if (string.IsNullOrWhiteSpace(title) || title.Length < 3)
            {
                pnlWarning.Visible = false;
                return false;
            }

            string normInput = title.ToLower().Trim();
            var inputTokens = normInput.Split(new[] { ' ', '-', '_', ',', '.' }, StringSplitOptions.RemoveEmptyEntries)
                                      .Where(w => w.Length >= 3)
                                      .ToList();

            List<string> matches = new List<string>();

            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string sql = "SELECT ProjectTitle, Status FROM Projects";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string pTitle = rdr["ProjectTitle"].ToString();
                            string pStatus = rdr["Status"].ToString();
                            string normPTitle = pTitle.ToLower().Trim();

                            if (normPTitle.Contains(normInput) || normInput.Contains(normPTitle))
                            {
                                matches.Add($"\"{pTitle}\" ({pStatus})");
                                continue;
                            }

                            var pTokens = normPTitle.Split(new[] { ' ', '-', '_', ',', '.' }, StringSplitOptions.RemoveEmptyEntries)
                                                   .Where(w => w.Length >= 3)
                                                   .ToList();
                            int sharedCount = inputTokens.Count(t => pTokens.Contains(t));
                            if (sharedCount > 0 && (sharedCount >= 2 || (inputTokens.Count <= 2 && sharedCount >= 1)))
                            {
                                matches.Add($"\"{pTitle}\" ({pStatus})");
                            }
                        }
                    }
                }
            }

            if (matches.Count > 0)
            {
                lblWarningMessage.Text = "<strong>Warning: Similar project title(s) already exist in the system:</strong><br/>" +
                                        string.Join("<br/>", matches.Distinct()) +
                                        "<br/><em>Please make sure your project proposal is distinct and unique.</em>";
                pnlWarning.Visible = true;
                return true;
            }
            else
            {
                pnlWarning.Visible = false;
                return false;
            }
        }

        protected void btnSubmitProject_Click(object sender, EventArgs e)
        {
            if (CurrentGroupId == 0)
            {
                lblMessage.Text = "Error: You are not assigned as Leader of any group.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            if (CurrentGroupStatus != "Assigned Mentor")
            {
                lblMessage.Text = "Error: You cannot submit a project proposal until a mentor has accepted your group's request.";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            string title = txtProjectTitle.Text.Trim();
            string type = ddlProjectType.SelectedValue;
            string keywordsInput = txtKeywords.Text.Trim();
            string functionality = txtFunctionality.Text.Trim();

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(functionality))
            {
                lblMessage.Text = "Please fill in all required project fields (Title and Overview).";
                lblMessage.CssClass = "alert alert-danger";
                lblMessage.Visible = true;
                return;
            }

            bool hasSimilar = CheckTitleSimilarity(title);

            string normalizedTitle = title.ToLower().Trim();

            int newProjectId = 0;
            using (SqlConnection conn = new SqlConnection(ConnString))
            {
                conn.Open();
                string insertSql = @"
                    INSERT INTO Projects (GroupId, ProjectType, ProjectTitle, NormalizedTitle, Functionality, Status, SubmittedAt)
                    OUTPUT INSERTED.ProjectId
                    VALUES (@GroupId, @Type, @Title, @NormTitle, @Func, 'Pending', GETDATE())";

                using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    cmd.Parameters.AddWithValue("@Type", type);
                    cmd.Parameters.AddWithValue("@Title", title);
                    cmd.Parameters.AddWithValue("@NormTitle", normalizedTitle);
                    cmd.Parameters.AddWithValue("@Func", functionality);

                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        newProjectId = Convert.ToInt32(res);
                    }
                }

                if (newProjectId > 0 && !string.IsNullOrWhiteSpace(keywordsInput))
                {
                    string[] keywords = keywordsInput.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
                    foreach (string kw in keywords)
                    {
                        string cleanKw = kw.Trim();
                        if (!string.IsNullOrEmpty(cleanKw))
                        {
                            string kwInsert = "INSERT INTO ProjectKeywords (ProjectId, Keyword) VALUES (@ProjectId, @Keyword)";
                            using (SqlCommand kwCmd = new SqlCommand(kwInsert, conn))
                            {
                                kwCmd.Parameters.AddWithValue("@ProjectId", newProjectId);
                                kwCmd.Parameters.AddWithValue("@Keyword", cleanKw.Length > 30 ? cleanKw.Substring(0, 30) : cleanKw);
                                kwCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }

                string facultyQuery = @"
                    SELECT u.Email, u.FullName, g.GroupName
                    FROM Groups g
                    INNER JOIN Users u ON g.MentorId = u.UserId
                    WHERE g.GroupId = @GroupId";

                using (SqlCommand fCmd = new SqlCommand(facultyQuery, conn))
                {
                    fCmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                    using (SqlDataReader fRdr = fCmd.ExecuteReader())
                    {
                        if (fRdr.Read())
                        {
                            string facultyEmail = fRdr["Email"].ToString();
                            string facultyName = fRdr["FullName"].ToString();
                            string groupName = fRdr["GroupName"].ToString();

                            EmailService.SendProjectProposalToFaculty(
                                facultyEmail,
                                facultyName,
                                UserName,
                                groupName,
                                title,
                                type,
                                keywordsInput,
                                functionality
                            );
                        }
                    }
                }
            }

            lblMessage.Text = hasSimilar 
                ? "Project proposal submitted successfully for Faculty review (Note: Similar project title warning noted)."
                : "Project proposal submitted successfully for Faculty review!";
            lblMessage.CssClass = "alert alert-success";
            lblMessage.Visible = true;

            txtProjectTitle.Text = "";
            txtKeywords.Text = "";
            txtFunctionality.Text = "";

            LoadProposals();
        }

        protected void rptProposals_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DeleteProposal")
            {
                int projectId = Convert.ToInt32(e.CommandArgument);
                int leaderId = Convert.ToInt32(Session["UserId"]);
                string leaderName = Session["FullName"]?.ToString() ?? "Leader";

                using (SqlConnection conn = new SqlConnection(ConnString))
                {
                    conn.Open();

                    // ── AUDIT: Snapshot project details before deletion ────────────
                    string snapshotSql = @"
                        SELECT p.ProjectTitle, p.ProjectType, p.Functionality, p.Status, p.SubmittedAt,
                               STUFF((
                                   SELECT ', ' + pk.Keyword
                                   FROM ProjectKeywords pk WHERE pk.ProjectId = p.ProjectId
                                   FOR XML PATH('')
                               ), 1, 2, '') AS Keywords
                        FROM Projects p
                        WHERE p.ProjectId = @ProjectId";

                    string projectTitle = $"Project #{projectId}";
                    string projectDetails = "";

                    using (SqlCommand snapCmd = new SqlCommand(snapshotSql, conn))
                    {
                        snapCmd.Parameters.AddWithValue("@ProjectId", projectId);
                        using (SqlDataReader rdr = snapCmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                projectTitle = rdr["ProjectTitle"]?.ToString() ?? projectTitle;
                                string submittedAt = rdr["SubmittedAt"] != DBNull.Value
                                    ? Convert.ToDateTime(rdr["SubmittedAt"]).ToString("dd MMM yyyy")
                                    : "N/A";
                                projectDetails = $"{{Title: {projectTitle}, Type: {rdr["ProjectType"]}, Status: {rdr["Status"]}, SubmittedAt: {submittedAt}, Functionality: {rdr["Functionality"]?.ToString()?.Substring(0, Math.Min(200, rdr["Functionality"]?.ToString()?.Length ?? 0))}, Keywords: {rdr["Keywords"]}}}";
                            }
                        }
                    }

                    Admin_DeletedRecords.LogDeletion(conn, "Project", projectId, projectTitle, projectDetails,
                        leaderId > 0 ? (int?)leaderId : null, leaderName, reason: "Project proposal withdrawn by leader");

                    // ── HARD DELETE ───────────────────────────────────────────────
                    string delKw = "DELETE FROM ProjectKeywords WHERE ProjectId = @ProjectId";
                    using (SqlCommand kwCmd = new SqlCommand(delKw, conn))
                    {
                        kwCmd.Parameters.AddWithValue("@ProjectId", projectId);
                        kwCmd.ExecuteNonQuery();
                    }

                    string delProj = "DELETE FROM Projects WHERE ProjectId = @ProjectId AND GroupId = @GroupId AND Status = 'Pending'";
                    using (SqlCommand pCmd = new SqlCommand(delProj, conn))
                    {
                        pCmd.Parameters.AddWithValue("@ProjectId", projectId);
                        pCmd.Parameters.AddWithValue("@GroupId", CurrentGroupId);
                        pCmd.ExecuteNonQuery();
                    }
                }

                lblMessage.Text = "Project proposal withdrawn successfully.";
                lblMessage.CssClass = "alert alert-success";
                lblMessage.Visible = true;

                LoadProposals();
            }
        }
    }
}
