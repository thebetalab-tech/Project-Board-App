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
            // Check if the user is a leader or not
            if (Session["IsLeader"] == null || !(bool)Session["IsLeader"])
            {
                Response.Redirect("OnBoarding.aspx");
            }

            if (!IsPostBack)
            {
                // Populate the dropdown list with technology domains from the database
                LoadTechnologies();
            }
        }

        private void LoadTechnologies()
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
            Response.Redirect("MentorSelection.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}