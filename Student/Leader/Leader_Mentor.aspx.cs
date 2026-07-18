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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
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
                    // Already has a mentor request
                    divRequestForm.Visible = false;
                    divCurrentRequest.Visible = true;
                    btnWithdraw.Visible = true; // Show withdraw if there is a mentor request
                    
                    // Fetch mentor name
                    string mentorName = "Unknown";
                    string qMentor = "SELECT FullName FROM Users WHERE UserId = @UserId";
                    using (SqlCommand cmd2 = new SqlCommand(qMentor, conn))
                    {
                        cmd2.Parameters.AddWithValue("@UserId", mentorId.Value);
                        object result = cmd2.ExecuteScalar();
                        if (result != null) mentorName = result.ToString();
                    }

                    lblStatus.Text = $"Requested Mentor: <strong>{mentorName}</strong><br/>Status: <strong>{status}</strong>";
                }
                else
                {
                    if (!techId.HasValue) 
                    {
                        // No technology selected yet, cannot pick mentor
                        divRequestForm.Visible = false;
                        divCurrentRequest.Visible = true;
                        btnWithdraw.Visible = false; // Hide withdraw because nothing to withdraw
                        lblStatus.Text = "<strong>Error:</strong> Your group has not selected a Technology yet. Please select a technology on the Dashboard first.";
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
