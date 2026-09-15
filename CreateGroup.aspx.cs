using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board
{
    public partial class CreateGroup : System.Web.UI.Page
    {
        // Define connection string at the class level
        private readonly string connString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null || Session["Role"]?.ToString() != "Student")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            // Check if the user is a leader or not
            bool isLeader = false;
            if (Session["IsLeader"] != null)
            {
                if (Session["IsLeader"] is bool)
                {
                    isLeader = (bool)Session["IsLeader"];
                }
                else
                {
                    bool.TryParse(Session["IsLeader"].ToString(), out isLeader);
                }
            }

            if (!isLeader)
            {
                Response.Redirect("~/OnBoarding.aspx", true);
                return;
            }

            if (!IsPostBack)
            {
                try
                {
                    // Check for Lockdown
                    bool isLockedDown = false;
                    string connectionString = ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;
                    if (!string.IsNullOrEmpty(connectionString))
                    {
                        using (SqlConnection conn = new SqlConnection(connectionString))
                        {
                            conn.Open();
                            string sqlLockdown = @"
                            SELECT 1 FROM Groups g WHERE g.LeaderId = @UserId AND g.IsActive = 0
                            UNION
                            SELECT 1 FROM Groups g INNER JOIN GroupMembers gm ON g.GroupId = gm.GroupId WHERE gm.UserId = @UserId AND gm.JoinStatus = 'Accepted' AND g.IsActive = 0";
                            using (SqlCommand cmd = new SqlCommand(sqlLockdown, conn))
                            {
                                cmd.Parameters.AddWithValue("@UserId", Session["UserId"]);
                                object result = cmd.ExecuteScalar();
                                isLockedDown = result != null;
                            }
                        }
                    }

                    if (isLockedDown)
                    {
                        Response.Redirect("~/Student/Lockdown.aspx");
                        return;
                    }

                    // Populate the dropdown list with technology domains from the database
                    LoadTechnologies();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("CreateGroup initialization failed: {0}", ex);
                    lblMessage.Text = "Unable to load the group form right now. Please try again later.";
                    lblMessage.CssClass = "error-message";
                }
            }
        }

        private void LoadTechnologies()
        {
            try
            {
            using (SqlConnection connection = new SqlConnection(connString))
            {
                // Fetch all the tech to show in the dropdown list
                using (SqlCommand command = new SqlCommand("sp_select_technologies", connection))
                {
                    // Use CommandType.StoredProcedure instead of "call" for SQL Server
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Action", "ALL");

                    connection.Open();
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        ddlTechDomain.DataSource = reader;
                        ddlTechDomain.DataTextField = "TechName"; // Column from Technologies table
                        ddlTechDomain.DataValueField = "TechId";  // Column from Technologies table 
                        ddlTechDomain.DataBind();
                    }
                }
            }

            // Insert a default placeholder item at the top of the dropdown
            ddlTechDomain.Items.Insert(0, new ListItem("Select primary technology", ""));
            ddlTechDomain.Items[0].Attributes["disabled"] = "disabled";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("CreateGroup.LoadTechnologies failed: " + ex);
                lblMessage.Text = "Unable to load technologies right now. Please try again.";
                lblMessage.CssClass = "form-message form-message--error";
            }
        }

        // This event fires automatically when the user clicks off the text box (Requires AutoPostBack="true" in ASPX)
        protected void txtGroupName_TextChanged(object sender, EventArgs e)
        {
            string groupName = txtGroupName.Text.Trim();

            // If they cleared the box, hide the message
            if (string.IsNullOrEmpty(groupName))
            {
                lblNameStatus.Text = string.Empty;
                return;
            }

            try
            {
            // Check if the group name exists
            using (SqlConnection connection = new SqlConnection(connString))
            {
                string query = "SELECT COUNT(*) FROM Groups WHERE GroupName = @GroupName";
                
                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@GroupName", groupName);
                    
                    connection.Open();
                    int count = (int)command.ExecuteScalar();
                    
                    if (count > 0)
                    {
                        lblNameStatus.Text = "Warning: A group with this name already exists.";
                        lblNameStatus.ForeColor = System.Drawing.ColorTranslator.FromHtml("#d93025"); // Red
                    }
                    else
                    {
                        lblNameStatus.Text = "Group name is available!";
                        lblNameStatus.ForeColor = System.Drawing.ColorTranslator.FromHtml("#188038"); // Green
                    }
                }
            }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("CreateGroup group-name check failed: " + ex);
                lblNameStatus.Text = "Unable to check the group name right now.";
                lblNameStatus.ForeColor = System.Drawing.ColorTranslator.FromHtml("#d93025");
            }
        }

        // Event for when the user submits the form
        protected void btnCreateGroup_Click(object sender, EventArgs e)
        {
            lblMessage.Text = string.Empty;
            string groupName = txtGroupName.Text.Trim();
            string selectedTechDomain = ddlTechDomain.SelectedValue;

            if (string.IsNullOrWhiteSpace(groupName) || string.IsNullOrWhiteSpace(selectedTechDomain))
            {
                lblMessage.Text = "Please provide a group name and select a technology.";
                lblMessage.CssClass = "form-message form-message--error";
                return;
            }

            try
            {
            // Insert the new group using your sp_crud_groups stored procedure
            using (SqlConnection connection = new SqlConnection(connString))
            {
                using (SqlCommand command = new SqlCommand("sp_crud_groups", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    
                    // Parameters based on your database schema
                    command.Parameters.AddWithValue("@Action", "INSERT");
                    command.Parameters.AddWithValue("@GroupName", groupName);
                    command.Parameters.AddWithValue("@LeaderId", Session["UserId"]); // Assuming you store UserId in session
                    command.Parameters.AddWithValue("@TechId", selectedTechDomain);

                    connection.Open();
                    command.ExecuteNonQuery();
                }
            }

            // Redirect on success
            Response.Redirect("~/MentorSelection.aspx", true);
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("CreateGroup.btnCreateGroup_Click failed: " + ex);
                lblMessage.Text = "Unable to create the group right now. Please try again.";
                lblMessage.CssClass = "form-message form-message--error";
            }
        }
    }
}
