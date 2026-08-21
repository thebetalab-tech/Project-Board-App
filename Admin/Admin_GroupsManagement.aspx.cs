using System.Collections.Generic;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_GroupsManagement : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadGroups();
            }
        }

        private void LoadGroups()
        {
            if (string.IsNullOrEmpty(connString)) return;
            string filter = ddlReportFilter.SelectedValue;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT
                        g.GroupId,
                        g.GroupName,
                        g.Status,
                        l.FullName AS LeaderName,
                        m.FullName AS MentorName,
                        STUFF((SELECT ', ' + u.FullName
                            FROM GroupMembers gm
                            JOIN Users u ON gm.UserId = u.UserId
                            WHERE gm.GroupId = g.GroupId AND gm.JoinStatus = 'Accepted'
                            FOR XML PATH('')), 1, 2, '') AS Members
                    FROM Groups g
                    JOIN Users l ON g.LeaderId = l.UserId
                    LEFT JOIN Users m ON g.MentorId = m.UserId";

                query += " ORDER BY g.GroupId DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        rptGroups.DataSource = rdr;
                        rptGroups.DataBind();
                    }
                }
            }
        }

        protected void ddlReportFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadGroups();
        }

        protected void rptGroups_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ToggleGroupStatus")
            {
                // This will work once the database migration adds the IsActive column
                int groupId = Convert.ToInt32(e.CommandArgument);
                if (string.IsNullOrEmpty(connString)) return;

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Check if IsActive column exists (check table schema)
                    string checkColumnSql = "SELECT COUNT(1) FROM sys.columns WHERE object_id = OBJECT_ID('Groups') AND name = 'IsActive'";
                    bool hasColumn = false;

                    using (SqlCommand checkCmd = new SqlCommand(checkColumnSql, conn))
                    {
                        object result = checkCmd.ExecuteScalar();
                        if (result != null && Convert.ToInt32(result) > 0)
                        {
                            hasColumn = true;
                        }
                    }

                    if (hasColumn)
                    {
                        // Get current status
                        string currentStatusSql = "SELECT IsActive FROM Groups WHERE GroupId = @GroupId";
                        bool currentStatus = true;

                        using (SqlCommand statusCmd = new SqlCommand(currentStatusSql, conn))
                        {
                            statusCmd.Parameters.AddWithValue("@GroupId", groupId);
                            object result = statusCmd.ExecuteScalar();
                            if (result != null)
                            {
                                currentStatus = Convert.ToBoolean(result);
                            }
                        }

                        // Toggle the status (Active -> Inactive, Inactive -> Active)
                        string updateSql = "UPDATE Groups SET IsActive = @IsActive WHERE GroupId = @GroupId";
                        using (SqlCommand updateCmd = new SqlCommand(updateSql, conn))
                        {
                            updateCmd.Parameters.AddWithValue("@IsActive", !currentStatus);
                            updateCmd.Parameters.AddWithValue("@GroupId", groupId);
                            updateCmd.ExecuteNonQuery();
                        }
                    }

                    LoadGroups();
                }
            }
            else if (e.CommandName == "DeleteGroup")
            {
                // Legacy - for backward compatibility
                int groupId = Convert.ToInt32(e.CommandArgument);
                Page.ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Please use the toggle button to deactivate groups instead of deleting.');", true);
            }
        }

        protected void btnExportReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"
                    SELECT
                        g.GroupId,
                        g.GroupName,
                        g.Status,
                        l.FullName AS LeaderName,
                        m.FullName AS MentorName,
                        STUFF((SELECT ', ' + u.FullName
                            FROM GroupMembers gm
                            JOIN Users u ON gm.UserId = u.UserId
                            WHERE gm.GroupId = g.GroupId AND gm.JoinStatus = 'Accepted'
                            FOR XML PATH('')), 1, 2, '') AS Members
                    FROM Groups g
                    JOIN Users l ON g.LeaderId = l.UserId
                    LEFT JOIN Users m ON g.MentorId = m.UserId
                    ORDER BY g.GroupId DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Export to CSV
                        string csv = ExportToCsv(dt);
                        Response.Clear();
                        Response.ContentType = "text/csv";
                        Response.AddHeader("Content-Disposition", "attachment; filename=Groups_Report.csv");
                        Response.Write(csv);
                        Response.End();
                    }
                }
            }
        }

        private string ExportToCsv(DataTable dt)
        {
            var result = new System.Text.StringBuilder();
            result.AppendLine(string.Join(",", dt.Columns.Cast<DataColumn>().Select(c => $"\"{c.ColumnName}\"")));

            foreach (DataRow row in dt.Rows)
            {
                result.AppendLine(string.Join(",", row.ItemArray.Select(o => $"\"{o.ToString().Replace("\"", "\"\"")}\"")));
            }

            return result.ToString();
        }

        protected void btnUpdateGroup_Click(object sender, EventArgs e)
        {
            int groupId = Convert.ToInt32(hdnEditGroupId.Value);
            string newStatus = ddlEditGroupStatus.SelectedValue;

            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                string updateSql = "UPDATE Groups SET Status = @Status WHERE GroupId = @GroupId";
                using (SqlCommand cmd = new SqlCommand(updateSql, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@GroupId", groupId);
                    cmd.ExecuteNonQuery();
                }

                LoadGroups();
                ClientScript.RegisterStartupScript(this.GetType(), "closeModal", "closeModal('editGroupModal');", true);
            }
        }
    }
}
