using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board.Student.Leader
{
    public partial class Leader_Mentor : Page
    {
        protected global::System.Web.UI.WebControls.DropDownList ddlMentors;
        protected global::System.Web.UI.WebControls.Button btnRequest;
        protected global::System.Web.UI.WebControls.Button btnWithdraw;
        protected global::System.Web.UI.WebControls.Label lblStatus;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl divRequestForm;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl divCurrentRequest;

        protected string UserInitials { get; set; } = "TL";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            string fullName = Session["FullName"]?.ToString() ?? "Student Leader";
            if (!string.IsNullOrEmpty(fullName))
            {
                UserInitials = fullName.Substring(0, 1).ToUpper();
            }

            if (!IsPostBack)
            {
                LoadMentorData();
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

        private void LoadMentorData()
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                // Check group status, mentor, and tech
                string qGroup = "SELECT MentorId, Status, TechId FROM Groups WHERE GroupId = @GroupId";
                int? mentorId = null;
                string status = "";
                int? techId = null;

                using (SqlCommand cmd = new SqlCommand(qGroup, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            mentorId = reader["MentorId"] as int?;
                            status = reader["Status"].ToString();
                            techId = reader["TechId"] as int?;
                        }
                    }
                }

                if (mentorId.HasValue)
                {
                    // Fetch mentor name and email
                    string mentorName = "Faculty Mentor";
                    string mentorEmail = "";
                    string qMentor = "SELECT FullName, Email FROM Users WHERE UserId = @UserId";
                    using (SqlCommand cmd2 = new SqlCommand(qMentor, conn))
                    {
                        cmd2.Parameters.AddWithValue("@UserId", mentorId.Value);
                        using (SqlDataReader mRdr = cmd2.ExecuteReader())
                        {
                            if (mRdr.Read())
                            {
                                mentorName = mRdr["FullName"].ToString();
                                mentorEmail = mRdr["Email"].ToString();
                            }
                        }
                    }

                    string initials = !string.IsNullOrEmpty(mentorName) ? mentorName.Substring(0, 1).ToUpper() : "F";

                    if (status.Equals("Assigned Mentor", StringComparison.OrdinalIgnoreCase) ||
                        status.Equals("Accepted", StringComparison.OrdinalIgnoreCase) ||
                        status.Equals("Active", StringComparison.OrdinalIgnoreCase))
                    {
                        // Accepted / Assigned State: Hide request form and withdraw button completely
                        divRequestForm.Visible = false;
                        divCurrentRequest.Visible = true;
                        btnWithdraw.Visible = false;

                        lblStatus.Text = $@"
                            <div style='display:flex; align-items:center; gap:1.25rem; padding:0.5rem;'>
                                <div style='width:52px; height:52px; border-radius:50%; background:linear-gradient(135deg, #6366f1, #8b5cf6); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:1.3rem;'>
                                    {initials}
                                </div>
                                <div style='flex:1;'>
                                    <h3 style='margin:0 0 0.3rem 0; color:var(--c-text); font-size:1.15rem;'>
                                        <i class='fa-solid fa-award' style='color:#6366f1; margin-right:0.4rem;'></i> Assigned Faculty Mentor: {mentorName}
                                    </h3>
                                    <p style='margin:0; font-size:0.875rem; color:var(--c-text-muted);'>
                                        <i class='fa-solid fa-envelope' style='margin-right:0.3rem;'></i> {mentorEmail}
                                    </p>
                                </div>
                                <span class='badge' style='background:rgba(34,197,94,0.15); color:#22c55e; border:1px solid rgba(34,197,94,0.3); padding:0.4rem 0.8rem; border-radius:20px; font-weight:600;'>
                                    Assigned Mentor
                                </span>
                            </div>";
                    }
                    else
                    {
                        // Pending State: Allow withdrawal
                        divRequestForm.Visible = false;
                        divCurrentRequest.Visible = true;
                        btnWithdraw.Visible = true;

                        lblStatus.Text = $@"
                            <div style='padding:0.5rem;'>
                                <h4 style='margin:0 0 0.4rem 0; color:#eab308; display:flex; align-items:center; gap:0.5rem;'>
                                    <i class='fa-solid fa-clock'></i> Mentor Request Pending Approval
                                </h4>
                                <p style='margin:0; font-size:0.9rem; color:var(--c-text);'>
                                    Requested Professor: <strong>{mentorName}</strong> ({mentorEmail})
                                </p>
                            </div>";
                    }
                }
                else
                {
                    if (!techId.HasValue) 
                    {
                        // No technology selected yet, cannot pick mentor
                        divRequestForm.Visible = false;
                        divCurrentRequest.Visible = true;
                        btnWithdraw.Visible = false;
                        lblStatus.Text = "<strong>Error:</strong> Your group has not selected a Technology domain yet. Please select a technology on the Dashboard first.";
                        return;
                    }

                    // No mentor request, show dropdown
                    divRequestForm.Visible = true;
                    divCurrentRequest.Visible = false;

                    // Load faculty list if not already loaded
                    if (ddlMentors.Items.Count == 1) // Only 'Select a Professor' is there
                    {
                        string qFaculty = @"
                            SELECT U.UserId, U.FullName 
                            FROM Users U
                            INNER JOIN Faculty F ON U.UserId = F.FacultyId
                            WHERE U.Role = 'Faculty' 
                              AND U.IsActive = 1
                              AND F.TechId = @TechId
                              AND U.UserId NOT IN (
                                  SELECT FacultyId FROM GroupMentorRejections WHERE GroupId = @GroupId
                              )
                            ORDER BY U.FullName";
                        
                        using (SqlCommand cmd3 = new SqlCommand(qFaculty, conn))
                        {
                            cmd3.Parameters.AddWithValue("@TechId", techId.Value);
                            cmd3.Parameters.AddWithValue("@GroupId", groupId);
                            using (SqlDataReader reader3 = cmd3.ExecuteReader())
                            {
                                while (reader3.Read())
                                {
                                    ddlMentors.Items.Add(new ListItem(reader3["FullName"].ToString(), reader3["UserId"].ToString()));
                                }
                            }
                        }
                    }
                }
            }
        }

        protected void btnRequest_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlMentors.SelectedValue)) return;
            
            int selectedMentorId = Convert.ToInt32(ddlMentors.SelectedValue);
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                string updateSql = "UPDATE Groups SET MentorId = @MentorId, Status = 'Pending Faculty Approval' WHERE GroupId = @GroupId";
                using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@MentorId", selectedMentorId);
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.ExecuteNonQuery();
                }
            }
            LoadMentorData();
        }

        protected void btnWithdraw_Click(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int groupId = GetGroupId(conn);
                if (groupId == 0) return;

                // Only allow withdrawal if not yet finalized (e.g. still Pending)
                string updateSql = "UPDATE Groups SET MentorId = NULL, Status = 'Forming' WHERE GroupId = @GroupId AND Status = 'Pending Faculty Approval'";
                using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.ExecuteNonQuery();
                }
            }
            LoadMentorData();
        }
    }
}
