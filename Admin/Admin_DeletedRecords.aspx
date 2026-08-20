<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_DeletedRecords.aspx.cs" Inherits="Project_Board.Admin.Admin_DeletedRecords" MasterPageFile="~/Admin/Admin.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Deleted Records — Audit Log
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="dashboard-container">
  <div class="view-section active">

    <!-- Page Header -->
    <div class="page-header">
      <div class="page-title">
        <h1><i class="fa-solid fa-trash-can-arrow-up" style="color:var(--c-accent);margin-right:.5rem;"></i>Deleted Records</h1>
        <p>Complete audit trail of all deletions across the system. This log is read-only.</p>
      </div>
    </div>

    <!-- Stats Row -->
    <div class="stats-grid" id="deletionStatsGrid" runat="server">
      <div class="stat-card">
        <div class="stat-header">
          <div class="stat-icon" style="background:rgba(239,68,68,.12);color:#ef4444;">
            <i class="fa-solid fa-trash"></i>
          </div>
        </div>
        <div class="stat-value"><asp:Label ID="lblTotalDeleted" runat="server" Text="0" /></div>
        <div class="stat-label">Total Deleted Records</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div class="stat-icon" style="background:rgba(99,102,241,.12);color:#6366f1;">
            <i class="fa-solid fa-users"></i>
          </div>
        </div>
        <div class="stat-value"><asp:Label ID="lblDeletedUsers" runat="server" Text="0" /></div>
        <div class="stat-label">Deleted Users</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div class="stat-icon" style="background:rgba(16,185,129,.12);color:#10b981;">
            <i class="fa-solid fa-user-group"></i>
          </div>
        </div>
        <div class="stat-value"><asp:Label ID="lblDeletedGroups" runat="server" Text="0" /></div>
        <div class="stat-label">Deleted Groups</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div class="stat-icon" style="background:rgba(245,158,11,.12);color:#f59e0b;">
            <i class="fa-solid fa-folder-open"></i>
          </div>
        </div>
        <div class="stat-value"><asp:Label ID="lblDeletedProjects" runat="server" Text="0" /></div>
        <div class="stat-label">Deleted Projects</div>
      </div>
      <div class="stat-card">
        <div class="stat-header">
          <div class="stat-icon" style="background:rgba(139,92,246,.12);color:#8b5cf6;">
            <i class="fa-solid fa-list-check"></i>
          </div>
        </div>
        <div class="stat-value"><asp:Label ID="lblDeletedTasks" runat="server" Text="0" /></div>
        <div class="stat-label">Deleted Tasks</div>
      </div>
    </div>

    <!-- Filters Bar -->
    <div class="stat-card" style="margin-top:1.5rem;padding:1.2rem 1.5rem;">
      <div style="display:flex;flex-wrap:wrap;gap:1rem;align-items:flex-end;">
        
        <!-- Entity Type Filter -->
        <div style="display:flex;flex-direction:column;gap:.4rem;min-width:160px;">
          <label style="font-size:.78rem;font-weight:600;color:var(--c-text-muted);text-transform:uppercase;letter-spacing:.05em;">Entity Type</label>
          <asp:DropDownList ID="ddlTypeFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTypeFilter_SelectedIndexChanged">
            <asp:ListItem Value="All" Text="All Types" />
            <asp:ListItem Value="User" Text="Users" />
            <asp:ListItem Value="Group" Text="Groups" />
            <asp:ListItem Value="Project" Text="Projects" />
            <asp:ListItem Value="Task" Text="Tasks" />
            <asp:ListItem Value="Technology" Text="Technologies" />
          </asp:DropDownList>
        </div>

        <!-- Search -->
        <div style="display:flex;flex-direction:column;gap:.4rem;flex:1;min-width:200px;">
          <label style="font-size:.78rem;font-weight:600;color:var(--c-text-muted);text-transform:uppercase;letter-spacing:.05em;">Search</label>
          <asp:TextBox ID="txtSearch" runat="server" CssClass="form-input" placeholder="Search by name, details, or deleted by..." />
        </div>

        <!-- Date From -->
        <div style="display:flex;flex-direction:column;gap:.4rem;min-width:150px;">
          <label style="font-size:.78rem;font-weight:600;color:var(--c-text-muted);text-transform:uppercase;letter-spacing:.05em;">From Date</label>
          <asp:TextBox ID="txtDateFrom" runat="server" CssClass="form-input" TextMode="Date" />
        </div>

        <!-- Date To -->
        <div style="display:flex;flex-direction:column;gap:.4rem;min-width:150px;">
          <label style="font-size:.78rem;font-weight:600;color:var(--c-text-muted);text-transform:uppercase;letter-spacing:.05em;">To Date</label>
          <asp:TextBox ID="txtDateTo" runat="server" CssClass="form-input" TextMode="Date" />
        </div>

        <!-- Search Button -->
        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" style="min-width:100px;" />
        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline" OnClick="btnClear_Click" style="min-width:80px;" />
      </div>
    </div>

    <!-- Results Count -->
    <div style="margin:1rem 0 .5rem;display:flex;align-items:center;justify-content:space-between;">
      <p style="color:var(--c-text-muted);font-size:.875rem;">
        Showing <strong><asp:Label ID="lblResultCount" runat="server" Text="0" /></strong> records
        <asp:Label ID="lblFilterDesc" runat="server" Text="" />
      </p>
      <div style="display:flex;gap:.5rem;align-items:center;">
        <asp:Label ID="lblPageInfo" runat="server" Text="Page 1 of 1" style="font-size:.8rem;color:var(--c-text-muted);" />
        <asp:Button ID="btnPrevPage" runat="server" Text="← Prev" CssClass="btn btn-outline" OnClick="btnPrevPage_Click" style="font-size:.8rem;padding:.3rem .7rem;" />
        <asp:Button ID="btnNextPage" runat="server" Text="Next →" CssClass="btn btn-outline" OnClick="btnNextPage_Click" style="font-size:.8rem;padding:.3rem .7rem;" />
      </div>
    </div>

    <!-- Records Table -->
    <div class="stat-card" style="padding:0;overflow:hidden;">
      <asp:Repeater ID="rptDeletedRecords" runat="server" OnItemCommand="rptDeletedRecords_ItemCommand">
        <HeaderTemplate>
          <table class="data-table" style="width:100%;border-collapse:collapse;">
            <thead>
              <tr>
                <th style="width:130px;">Type</th>
                <th>Name / Title</th>
                <th style="width:150px;">Deleted By</th>
                <th style="width:160px;">Deleted At</th>
                <th style="width:80px;">Details</th>
              </tr>
            </thead>
            <tbody>
        </HeaderTemplate>
        <ItemTemplate>
          <tr class="del-record-row" style="<%# Convert.ToString(Eval("ParentDeleteId")) != "" ? "opacity:.7;background:var(--c-sidebar);" : "" %>">
            <td>
              <span class="badge <%# GetTypeBadgeClass(Convert.ToString(Eval("EntityType"))) %>">
                <i class="<%# GetTypeIcon(Convert.ToString(Eval("EntityType"))) %>"></i>
                <%# Eval("EntityType") %>
              </span>
            </td>
            <td>
              <div style="font-weight:600;color:var(--c-text);"><%# System.Web.HttpUtility.HtmlEncode(Convert.ToString(Eval("EntityName"))) %></div>
              <div style="font-size:.78rem;color:var(--c-text-muted);margin-top:.2rem;">ID: <%# Eval("EntityId") %><%# Convert.ToString(Eval("ParentDeleteId")) != "" ? " · Cascade deletion" : "" %></div>
            </td>
            <td>
              <div style="font-weight:500;"><%# System.Web.HttpUtility.HtmlEncode(Convert.ToString(Eval("DeletedByName"))) %></div>
            </td>
            <td>
              <div style="font-size:.875rem;"><%# Eval("DeletedAt") != null ? Convert.ToDateTime(Eval("DeletedAt")).ToString("dd MMM yyyy") : "" %></div>
              <div style="font-size:.75rem;color:var(--c-text-muted);"><%# Eval("DeletedAt") != null ? Convert.ToDateTime(Eval("DeletedAt")).ToString("hh:mm tt") : "" %></div>
            </td>
            <td>
              <asp:LinkButton ID="lnkViewDetails" runat="server" 
                CommandName="ViewDetails" 
                CommandArgument='<%# Eval("DeleteId") %>'
                CssClass="btn btn-outline" style="font-size:.75rem;padding:.25rem .6rem;">
                <i class="fa-solid fa-eye"></i>
              </asp:LinkButton>
            </td>
          </tr>
        </ItemTemplate>
        <FooterTemplate>
            </tbody>
          </table>
        </FooterTemplate>
      </asp:Repeater>

      <!-- Empty State -->
      <asp:Panel ID="pnlEmpty" runat="server" Visible="false" style="text-align:center;padding:3rem 1rem;">
        <i class="fa-solid fa-trash-can" style="font-size:3rem;color:var(--c-text-muted);opacity:.4;"></i>
        <p style="margin-top:1rem;color:var(--c-text-muted);font-size:1rem;">No deleted records found.</p>
        <p style="color:var(--c-text-muted);font-size:.875rem;">Try changing the filter or clearing the search.</p>
      </asp:Panel>
    </div>

  </div>
</div>

<!-- Detail Modal -->
<div id="detailModal" class="modal-overlay" style="display:none;" onclick="if(event.target===this)closeModal('detailModal')">
  <div class="modal-box" style="max-width:600px;max-height:80vh;overflow-y:auto;">
    <div class="modal-header" style="display:flex;align-items:center;justify-content:space-between;margin-bottom:1.5rem;">
      <h2 style="margin:0;font-size:1.25rem;">Deletion Details</h2>
      <button class="btn btn-outline" onclick="closeModal('detailModal')" style="padding:.3rem .7rem;">✕</button>
    </div>
    <div id="detailContent">
      <div style="display:grid;gap:.75rem;">
        <div class="detail-row"><span class="detail-label">Entity Type</span><span id="dEntityType" class="detail-val"></span></div>
        <div class="detail-row"><span class="detail-label">Entity ID</span><span id="dEntityId" class="detail-val"></span></div>
        <div class="detail-row"><span class="detail-label">Name / Title</span><span id="dEntityName" class="detail-val"></span></div>
        <div class="detail-row"><span class="detail-label">Deleted By</span><span id="dDeletedBy" class="detail-val"></span></div>
        <div class="detail-row"><span class="detail-label">Deleted At</span><span id="dDeletedAt" class="detail-val"></span></div>
        <div class="detail-row"><span class="detail-label">Reason</span><span id="dReason" class="detail-val"></span></div>
        <div class="detail-row"><span class="detail-label">Cascade From</span><span id="dParent" class="detail-val"></span></div>
      </div>
      <div style="margin-top:1.25rem;">
        <div class="detail-label" style="margin-bottom:.5rem;">Full Snapshot</div>
        <pre id="dDetails" style="background:var(--c-sidebar);border:1px solid var(--c-border);border-radius:.5rem;padding:1rem;font-size:.8rem;color:var(--c-text);overflow-x:auto;white-space:pre-wrap;word-break:break-word;"></pre>
      </div>
    </div>
  </div>
</div>

<!-- Hidden fields for modal data -->
<asp:HiddenField ID="hdnModalEntityType" runat="server" />
<asp:HiddenField ID="hdnModalEntityId" runat="server" />
<asp:HiddenField ID="hdnModalEntityName" runat="server" />
<asp:HiddenField ID="hdnModalDeletedBy" runat="server" />
<asp:HiddenField ID="hdnModalDeletedAt" runat="server" />
<asp:HiddenField ID="hdnModalReason" runat="server" />
<asp:HiddenField ID="hdnModalParent" runat="server" />
<asp:HiddenField ID="hdnModalDetails" runat="server" />
<asp:HiddenField ID="hdnShowModal" runat="server" Value="0" />
<asp:HiddenField ID="hdnCurrentPage" runat="server" Value="1" />

<style>
.del-record-row:hover { background: var(--c-sidebar-hover, rgba(255,255,255,.03)) !important; }
.detail-row { display:flex; gap:1rem; padding:.5rem 0; border-bottom:1px solid var(--c-border); }
.detail-row:last-child { border-bottom:none; }
.detail-label { font-size:.78rem; font-weight:700; color:var(--c-text-muted); text-transform:uppercase; letter-spacing:.05em; min-width:110px; padding-top:.1rem; }
.detail-val { font-size:.9rem; color:var(--c-text); }
.badge { display:inline-flex; align-items:center; gap:.35rem; padding:.25rem .65rem; border-radius:.375rem; font-size:.75rem; font-weight:700; text-transform:uppercase; letter-spacing:.05em; }
.badge-user    { background:rgba(99,102,241,.15); color:#818cf8; }
.badge-group   { background:rgba(16,185,129,.15); color:#34d399; }
.badge-project { background:rgba(245,158,11,.15); color:#fbbf24; }
.badge-task    { background:rgba(139,92,246,.15); color:#a78bfa; }
.badge-tech    { background:rgba(14,165,233,.15); color:#38bdf8; }
.badge-other   { background:rgba(107,114,128,.15); color:#9ca3af; }
</style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
<script>
  // Populate and open detail modal on server postback signal
  window.addEventListener('DOMContentLoaded', function () {
    var show = document.getElementById('<%= hdnShowModal.ClientID %>').value;
    if (show === '1') {
      document.getElementById('dEntityType').textContent  = document.getElementById('<%= hdnModalEntityType.ClientID %>').value;
      document.getElementById('dEntityId').textContent    = document.getElementById('<%= hdnModalEntityId.ClientID %>').value;
      document.getElementById('dEntityName').textContent  = document.getElementById('<%= hdnModalEntityName.ClientID %>').value;
      document.getElementById('dDeletedBy').textContent   = document.getElementById('<%= hdnModalDeletedBy.ClientID %>').value;
      document.getElementById('dDeletedAt').textContent   = document.getElementById('<%= hdnModalDeletedAt.ClientID %>').value;
      document.getElementById('dReason').textContent      = document.getElementById('<%= hdnModalReason.ClientID %>').value || 'N/A';
      document.getElementById('dParent').textContent      = document.getElementById('<%= hdnModalParent.ClientID %>').value || 'None (top-level deletion)';
      document.getElementById('dDetails').textContent     = document.getElementById('<%= hdnModalDetails.ClientID %>').value || 'No snapshot stored.';
      openModal('detailModal');
      document.getElementById('<%= hdnShowModal.ClientID %>').value = '0';
    }
  });
</script>
</asp:Content>
