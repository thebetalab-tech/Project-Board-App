using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Project_Board.Admin
{
    public partial class Admin_DeletedRecords : System.Web.UI.Page
    {
        private string connString = ConfigurationManager.ConnectionStrings["ProjectBoardDB"]?.ConnectionString
            ?? ConfigurationManager.ConnectionStrings["Project_BoardConnectionString"]?.ConnectionString;

        private const int PageSize = 10000;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadStats();
                LoadRecords();
            }
        }

        // -----------------------------------------------------------------------
        //  STATS
        // -----------------------------------------------------------------------
        private void LoadStats()
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_deleted_records", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "STATS");

                    try
                    {
                        conn.Open();
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            // Per-type counts
                            var typeCounts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
                            while (rdr.Read())
                            {
                                typeCounts[rdr["EntityType"].ToString()] = Convert.ToInt32(rdr["TotalDeleted"]);
                            }

                            // Grand total
                            int grandTotal = 0;
                            if (rdr.NextResult() && rdr.Read())
                            {
                                grandTotal = Convert.ToInt32(rdr["GrandTotal"]);
                            }

                            lblTotalDeleted.Text = grandTotal.ToString();
                            lblDeletedUsers.Text    = typeCounts.ContainsKey("User")        ? typeCounts["User"].ToString()        : "0";
                            lblDeletedGroups.Text   = typeCounts.ContainsKey("Group")       ? typeCounts["Group"].ToString()       : "0";
                            lblDeletedProjects.Text = typeCounts.ContainsKey("Project")     ? typeCounts["Project"].ToString()     : "0";
                            lblDeletedTasks.Text    = typeCounts.ContainsKey("Task")        ? typeCounts["Task"].ToString()        : "0";
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("DeletedRecords Stats Error: " + ex.Message);
                    }
                }
            }
        }

        // -----------------------------------------------------------------------
        //  LOAD / FILTER RECORDS
        // -----------------------------------------------------------------------
        private void LoadRecords()
        {
            if (string.IsNullOrEmpty(connString)) return;

            // No server-side filters anymore. Fetch all records.
            string action = "ALL";

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_deleted_records", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action",       action);
                    cmd.Parameters.AddWithValue("@EntityType",   DBNull.Value);
                    cmd.Parameters.AddWithValue("@SearchKeyword", DBNull.Value);
                    cmd.Parameters.AddWithValue("@DateFrom",     DBNull.Value);
                    cmd.Parameters.AddWithValue("@DateTo",       DBNull.Value);
                    cmd.Parameters.AddWithValue("@PageNumber",   1);
                    cmd.Parameters.AddWithValue("@PageSize",     PageSize);

                    try
                    {
                        conn.Open();
                        DataTable dt = new DataTable();
                        int totalRows = 0;

                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            dt.Load(rdr);
                            if (rdr.NextResult() && rdr.Read())
                            {
                                totalRows = Convert.ToInt32(rdr["TotalRows"]);
                            }
                        }

                        rptDeletedRecords.DataSource = dt;
                        rptDeletedRecords.DataBind();

                        pnlEmpty.Visible = dt.Rows.Count == 0;

                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("DeletedRecords Load Error: " + ex.Message);
                        pnlEmpty.Visible = true;
                    }
                }
            }
        }

        // -----------------------------------------------------------------------
        //  EVENTS
        // -----------------------------------------------------------------------
        // No server-side pagination events anymore

        protected void rptDeletedRecords_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ViewDetails")
            {
                int deleteId = Convert.ToInt32(e.CommandArgument);
                PopulateDetailModal(deleteId);
            }
        }

        // -----------------------------------------------------------------------
        //  DETAIL MODAL
        // -----------------------------------------------------------------------
        private void PopulateDetailModal(int deleteId)
        {
            if (string.IsNullOrEmpty(connString)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string sql = "SELECT * FROM DeletedRecords WHERE DeleteId = @DeleteId";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@DeleteId", deleteId);
                    try
                    {
                        conn.Open();
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                hdnModalEntityType.Value = rdr["EntityType"]?.ToString() ?? "";
                                hdnModalEntityId.Value   = rdr["EntityId"]?.ToString()   ?? "";
                                hdnModalEntityName.Value = rdr["EntityName"]?.ToString()  ?? "";
                                hdnModalDeletedBy.Value  = rdr["DeletedByName"]?.ToString() ?? "System";
                                hdnModalDeletedAt.Value  = rdr["DeletedAt"] != DBNull.Value
                                    ? Convert.ToDateTime(rdr["DeletedAt"]).ToString("dd MMM yyyy, hh:mm tt")
                                    : "";
                                hdnModalReason.Value     = rdr["Reason"]?.ToString()      ?? "";
                                hdnModalParent.Value     = rdr["ParentDeleteId"] != DBNull.Value
                                    ? $"Delete #{rdr["ParentDeleteId"]}"
                                    : "";
                                hdnModalDetails.Value    = FormatDetailsJson(rdr["EntityDetails"]?.ToString() ?? "");
                                hdnShowModal.Value       = "1";
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("DeletedRecords Detail Error: " + ex.Message);
                    }
                }
            }

            // Re-load to keep the list visible
            LoadStats();
            LoadRecords();
        }

        // -----------------------------------------------------------------------
        //  HELPERS — used from ASPX
        // -----------------------------------------------------------------------
        protected string GetTypeBadgeClass(string entityType)
        {
            switch ((entityType ?? "").ToLower())
            {
                case "user":        return "badge-user";
                case "group":       return "badge-group";
                case "project":     return "badge-project";
                case "task":        return "badge-task";
                case "technology":  return "badge-tech";
                default:            return "badge-other";
            }
        }

        protected string GetTypeIcon(string entityType)
        {
            switch ((entityType ?? "").ToLower())
            {
                case "user":        return "fa-solid fa-user";
                case "group":       return "fa-solid fa-user-group";
                case "project":     return "fa-solid fa-folder-open";
                case "task":        return "fa-solid fa-list-check";
                case "technology":  return "fa-solid fa-microchip";
                default:            return "fa-solid fa-circle-question";
            }
        }

        /// <summary>
        /// Pretty-prints the stored details string; if it's JSON-like, formats it; otherwise returns as-is.
        /// </summary>
        private string FormatDetailsJson(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return "";
            // Simple line-break formatting for our key:value format
            return raw.Replace(", ", "\n").Replace("{", "").Replace("}", "").Trim();
        }

        // -----------------------------------------------------------------------
        //  STATIC HELPER — called from other admin pages to log a deletion
        // -----------------------------------------------------------------------
        /// <summary>
        /// Inserts a deletion audit record. Call this BEFORE performing the actual delete.
        /// Returns the new DeleteId (useful as ParentDeleteId for cascade children).
        /// </summary>
        public static int LogDeletion(
            SqlConnection conn,
            string entityType,
            int entityId,
            string entityName,
            string entityDetails,
            int? deletedBy,
            string deletedByName,
            string reason = null,
            int? parentDeleteId = null)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_deleted_records", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action",         "INSERT");
                    cmd.Parameters.AddWithValue("@EntityType",     entityType);
                    cmd.Parameters.AddWithValue("@EntityId",       entityId);
                    cmd.Parameters.AddWithValue("@EntityName",     entityName ?? "Unknown");
                    cmd.Parameters.AddWithValue("@EntityDetails",  (object)entityDetails ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@DeletedBy",      deletedBy.HasValue ? (object)deletedBy.Value : DBNull.Value);
                    cmd.Parameters.AddWithValue("@DeletedByName",  deletedByName ?? "System");
                    cmd.Parameters.AddWithValue("@Reason",         (object)reason ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ParentDeleteId", parentDeleteId.HasValue ? (object)parentDeleteId.Value : DBNull.Value);

                    object result = cmd.ExecuteScalar();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LogDeletion Error: " + ex.Message);
                return 0;
            }
        }

        // -----------------------------------------------------------------------
        //  REPORT GENERATION
        // -----------------------------------------------------------------------
        protected void btnGetReport_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(connString)) return;

            // Build report data
            var reportData = GetReportData();

            if (reportData == null || reportData.Count == 0)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "notify", "alert('No data available to generate report.');", true);
                return;
            }

            // Generate CSV
            string csv = GenerateCsv(reportData);

            // Export
            Response.Clear();
            Response.ContentType = "text/csv";
            Response.AddHeader("Content-Disposition", "attachment; filename=Deleted_Records_Report_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".csv");
            Response.ContentEncoding = Encoding.UTF8;
            Response.Write(csv);
            Response.End();
        }

        private List<DeletedRecordDto> GetReportData()
        {
            var records = new List<DeletedRecordDto>();

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("sp_crud_deleted_records", conn))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Action", "ALL");

                    try
                    {
                        conn.Open();
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read())
                            {
                                records.Add(new DeletedRecordDto
                                {
                                    DeleteId = Convert.ToInt32(rdr["DeleteId"]),
                                    EntityType = rdr["EntityType"]?.ToString() ?? "",
                                    EntityId = Convert.ToInt32(rdr["EntityId"]),
                                    EntityName = rdr["EntityName"]?.ToString() ?? "",
                                    EntityDetails = rdr["EntityDetails"]?.ToString() ?? "",
                                    DeletedBy = rdr["DeletedBy"] != DBNull.Value ? Convert.ToInt32(rdr["DeletedBy"]) : (int?)null,
                                    DeletedByName = rdr["DeletedByName"]?.ToString() ?? "",
                                    DeletedAt = rdr["DeletedAt"] != DBNull.Value ? Convert.ToDateTime(rdr["DeletedAt"]) : (DateTime?)null,
                                    Reason = rdr["Reason"]?.ToString() ?? "",
                                    ParentDeleteId = rdr["ParentDeleteId"] != DBNull.Value ? Convert.ToInt32(rdr["ParentDeleteId"]) : (int?)null
                                });
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine("GetReportData Error: " + ex.Message);
                    }
                }
            }

            return records;
        }

        private string GenerateCsv(List<DeletedRecordDto> records)
        {
            var sb = new System.Text.StringBuilder();

            // Header
            sb.AppendLine("DeleteId,EntityType,EntityId,EntityName,EntityDetails,DeletedBy,DeletedByName,DeletedAt,Reason,ParentDeleteId");

            // Rows
            foreach (var rec in records)
            {
                sb.AppendLine(string.Format("{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}",
                    rec.DeleteId,
                    EscapeCsv(rec.EntityType),
                    rec.EntityId,
                    EscapeCsv(rec.EntityName),
                    EscapeCsv(rec.EntityDetails),
                    rec.DeletedBy?.ToString() ?? "",
                    EscapeCsv(rec.DeletedByName ?? ""),
                    rec.DeletedAt?.ToString("yyyy-MM-dd HH:mm:ss") ?? "",
                    EscapeCsv(rec.Reason ?? ""),
                    rec.ParentDeleteId?.ToString() ?? ""
                ));
            }

            return sb.ToString();
        }

        private string EscapeCsv(string value)
        {
            if (string.IsNullOrEmpty(value)) return "";
            // Escape quotes and wrap in quotes if contains comma, quote, or newline
            if (value.Contains(",") || value.Contains("\"") || value.Contains("\n"))
            {
                return "\"" + value.Replace("\"", "\"\"") + "\"";
            }
            return value;
        }
    }

    // DTO class for report data
    public class DeletedRecordDto
    {
        public int DeleteId { get; set; }
        public string EntityType { get; set; }
        public int EntityId { get; set; }
        public string EntityName { get; set; }
        public string EntityDetails { get; set; }
        public int? DeletedBy { get; set; }
        public string DeletedByName { get; set; }
        public DateTime? DeletedAt { get; set; }
        public string Reason { get; set; }
        public int? ParentDeleteId { get; set; }
    }
}
