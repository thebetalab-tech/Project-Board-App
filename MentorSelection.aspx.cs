using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Project_Board
{
    public partial class MentorSelection : Page
    {
        protected string SelectedTechName { get; set; } = "Technology";

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

        private void LoadMentorData()
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                int leaderId = Convert.ToInt32(Session["UserId"]);
                
                // Get Group details
                string qGroup = @"
                    SELECT G.GroupId, G.GroupName, G.MentorId, G.Status, G.TechId, T.TechName 
                    FROM Groups G
                    LEFT JOIN Technologies T ON G.TechId = T.TechId
                    WHERE G.LeaderId = @LeaderId";

                int groupId = 0;
                string groupName = "";
                int? mentorId = null;
                string status = "";
                int? techId = null;
                string techName = "Not Selected";

                using (SqlCommand cmd = new SqlCommand(qGroup, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            groupId = Convert.ToInt32(reader["GroupId"]);
                            groupName = reader["GroupName"].ToString();
                            mentorId = reader["MentorId"] as int?;
                            status = reader["Status"].ToString();
                            techId = reader["TechId"] as int?;
                            techName = reader["TechName"] != DBNull.Value ? reader["TechName"].ToString() : "Not Selected";
                        }
                    }
                }

                if (groupId == 0)
                {
                    // User has not created a group yet, redirect to OnBoarding.aspx
                    Response.Redirect("OnBoarding.aspx");
                    return;
                }

                lblGroupName.Text = groupName;
                lblTechName.Text = techName;
                SelectedTechName = techName;

                if (mentorId.HasValue)
                {
                    // Has an active request or is already approved
                    pnlCurrentRequest.Visible = true;
                    pnlSelectionForm.Visible = false;

                    // Get Mentor Name
                    string mentorName = "Professor";
                    string qMentor = "SELECT FullName FROM Users WHERE UserId = @UserId";
                    using (SqlCommand cmd2 = new SqlCommand(qMentor, conn))
                    {
                        cmd2.Parameters.AddWithValue("@UserId", mentorId.Value);
                        object result = cmd2.ExecuteScalar();
                        if (result != null) mentorName = result.ToString();
                    }

                    lblMentorName.Text = mentorName;
                    lblStatusText.Text = status;

                    // Only allow withdraw if still pending approval
                    if (status.Equals("Pending Faculty Approval", StringComparison.OrdinalIgnoreCase))
                    {
                        btnWithdraw.Visible = true;
                    }
                    else
                    {
                        btnWithdraw.Visible = false;
                    }
                }
                else
                {
                    pnlCurrentRequest.Visible = false;
                    pnlSelectionForm.Visible = true;

                    if (!techId.HasValue)
                    {
                        lblMessage.Text = "Error: Your group does not have a technology domain selected.";
                        lblMessage.ForeColor = System.Drawing.ColorTranslator.FromHtml("#ef4444");
                        rptFaculty.Visible = false;
                        phEmptyState.Visible = true;
                        return;
                    }

                    // Load available faculty cards
                    string qFaculty = @"
                        SELECT U.UserId, U.FullName, U.Email 
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
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd3))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptFaculty.DataSource = dt;
                                rptFaculty.DataBind();
                                rptFaculty.Visible = true;
                                phEmptyState.Visible = false;
                            }
                            else
                            {
                                rptFaculty.Visible = false;
                                phEmptyState.Visible = true;
                            }
                        }
                    }
                }
            }
        }

        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName)) return "F";
            
            string[] parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 0) return "F";

            if (parts.Length == 1)
            {
                return parts[0].Substring(0, Math.Min(2, parts[0].Length));
            }

            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        protected void rptFaculty_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectMentor")
            {
                int selectedMentorId = Convert.ToInt32(e.CommandArgument);
                string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
                
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();
                    
                    // Get GroupId
                    int leaderId = Convert.ToInt32(Session["UserId"]);
                    string qGroupId = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
                    int groupId = 0;
                    using (SqlCommand cmd = new SqlCommand(qGroupId, conn))
                    {
                        cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                        object res = cmd.ExecuteScalar();
                        if (res != null) groupId = Convert.ToInt32(res);
                    }

                    if (groupId == 0) return;

                    // Update Group with Mentor request
                    string updateSql = "UPDATE Groups SET MentorId = @MentorId, Status = 'Pending Faculty Approval' WHERE GroupId = @GroupId";
                    using (SqlCommand cmdUpdate = new SqlCommand(updateSql, conn))
                    {
                        cmdUpdate.Parameters.AddWithValue("@MentorId", selectedMentorId);
                        cmdUpdate.Parameters.AddWithValue("@GroupId", groupId);
                        cmdUpdate.ExecuteNonQuery();
                    }
                }

                LoadMentorData();
            }
        }

        protected void btnWithdraw_Click(object sender, EventArgs e)
        {
            string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                
                // Get GroupId
                int leaderId = Convert.ToInt32(Session["UserId"]);
                string qGroupId = "SELECT GroupId FROM Groups WHERE LeaderId = @LeaderId";
                int groupId = 0;
                using (SqlCommand cmd = new SqlCommand(qGroupId, conn))
                {
                    cmd.Parameters.AddWithValue("@LeaderId", leaderId);
                    object res = cmd.ExecuteScalar();
                    if (res != null) groupId = Convert.ToInt32(res);
                }

                if (groupId == 0) return;

                // Withdraw request (reset MentorId and Status to forming)
                string updateSql = "UPDATE Groups SET MentorId = NULL, Status = 'Forming' WHERE GroupId = @GroupId AND Status = 'Pending Faculty Approval'";
                using (SqlCommand cmdUpdate = new SqlCommand(updateSql, conn))
                {
                    cmdUpdate.Parameters.AddWithValue("@GroupId", groupId);
                    cmdUpdate.ExecuteNonQuery();
                }
            }

            LoadMentorData();
        }
    }
}
