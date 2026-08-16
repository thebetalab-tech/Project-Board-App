<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_ProjectsManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_ProjectsManagement" MasterPageFile="~/Admin/Admin.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Dashboard — Projects
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="dashboard-container">
            <div class="view-section active">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Projects Directory</h1>
                        <p>Track all UDP/IDP projects and their approval status.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>All Projects</h2>
                        <div class="section-actions" style="display:flex; gap: 10px; align-items:center;">
                            <asp:DropDownList ID="ddlReportFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReportFilter_SelectedIndexChanged" CssClass="form-control" style="width:auto; padding: 0.5rem; background: var(--c-surface); color: var(--c-text);">
                                <asp:ListItem Text="All Status" Value="All"></asp:ListItem>
                                <asp:ListItem Text="Pending" Value="Pending"></asp:ListItem>
                                <asp:ListItem Text="Approved" Value="Approved"></asp:ListItem>
                                <asp:ListItem Text="Rejected" Value="Rejected"></asp:ListItem>
                            </asp:DropDownList>
                            <a href="javascript:void(0)" class="btn-secondary" onclick="openModal('reportModal')">
                                <i class="fa-solid fa-file-export"></i> Export Report
                            </a>
                            <div class="search-bar" style="width: 250px;">
                                <i class="fa-solid fa-search"></i>
                                <input type="text" id="searchProjects" placeholder="Filter projects...">
                            </div>
                        </div>
                    </div>
                    <table id="projectsTable">
                        <thead>
                            <tr>
                                <th>Title & Functionality</th>
                                <th>Group</th>
                                <th>Keywords</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptProjects" runat="server" OnItemCommand="rptProjects_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div style="max-width: 300px;">
                                                <strong><%# Eval("ProjectTitle") %></strong>
                                                <p style="font-size:0.75rem; color:var(--c-text-muted); margin-top:0.25rem;">
                                                    <%# Eval("Functionality") %>
                                                </p>
                                            </div>
                                        </td>
                                        <td><%# Eval("GroupName") %></td>
                                        <td>
                                            <%# HttpUtility.HtmlDecode(Convert.ToString(Eval("KeywordHtml"))) %>
                                        </td>
                                        <td><span class='badge status-<%# Eval("Status").ToString().ToLower() %>'><%# Eval("Status") %></span></td>
                                        <td>
                                            <div class="table-actions">
                                                <button type="button" class="icon-btn edit" onclick="openEditProjectModal('<%# Eval("ProjectId") %>', '<%# HttpUtility.JavaScriptStringEncode(Eval("ProjectTitle").ToString()) %>', '<%# HttpUtility.JavaScriptStringEncode(Eval("Functionality").ToString()) %>', '<%# Eval("Status") %>')" style="color:var(--c-primary); background:none; border:none; cursor:pointer;" title="Edit Project">
                                                    <i class="fa-solid fa-edit"></i>
                                                </button>
                                                <asp:LinkButton ID="btnApprove" runat="server" CssClass="icon-btn" style="color:var(--c-green)" ToolTip="Approve" CommandName="Approve" CommandArgument='<%# Eval("ProjectId") %>' Visible='<%# Eval("Status").ToString() == "Pending" %>'>
                                                    <i class="fa-solid fa-check"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnReject" runat="server" CssClass="icon-btn" style="color:var(--c-red)" ToolTip="Reject" CommandName="Reject" CommandArgument='<%# Eval("ProjectId") %>' Visible='<%# Eval("Status").ToString() == "Pending" %>'>
                                                    <i class="fa-solid fa-xmark"></i>
                                                </asp:LinkButton>
                                                <a href='<%# ResolveUrl("~/Admin/Details/Project_Details.aspx?ProjectId=" + Eval("ProjectId")) %>' class="icon-btn" title="View Details">
                                                    <i class="fa-solid fa-eye" style="color: var(--c-primary);"></i>
                                                </a>
                                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="icon-btn delete" CommandName="DeleteProject" CommandArgument='<%# Eval("ProjectId") %>' OnClientClick="return confirm('Are you sure you want to delete this project?');">
                                                    <i class="fa-solid fa-trash"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    
    <!-- Edit Project Modal -->
    <div class="modal-overlay" id="editProjectModal">
        <div class="modal-content">
            <h2 style="margin-bottom: 1.5rem; font-family: var(--f-display);">Edit Project</h2>
            <asp:HiddenField ID="hdnEditProjectId" runat="server" />
            <div id="editProjectForm">
                <div class="form-group">
                    <label>Project Title</label>
                    <asp:TextBox ID="txtEditProjectTitle" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label>Functionality</label>
                    <asp:TextBox ID="txtEditFunctionality" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label>Status</label>
                    <asp:DropDownList ID="ddlEditProjectStatus" runat="server" CssClass="form-control">
                        <asp:ListItem Value="Pending">Pending</asp:ListItem>
                        <asp:ListItem Value="Approved">Approved</asp:ListItem>
                        <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                        <asp:ListItem Value="Completed">Completed</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <asp:Label ID="lblEditMessage" runat="server" ForeColor="#ff4d4d" EnableViewState="false" style="display:block;margin-bottom:10px;"></asp:Label>
                
                <div class="form-actions" style="margin-top: 1.5rem; text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('editProjectModal')">Cancel</button>
                    <asp:Button ID="btnUpdateProject" runat="server" Text="Save Changes" CssClass="btn-primary" OnClick="btnUpdateProject_Click" />
                </div>
            </div>
        </div>
    </div>
    
    <!-- REPORT EXPORT MODAL -->
    <div id="reportModal" class="modal-overlay">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h2>Export Projects Report</h2>
                <button type="button" class="close-btn" onclick="closeModal('reportModal')"><i class="fa-solid fa-times"></i></button>
            </div>
            <div style="padding: 1.5rem;">
                <p style="margin-bottom: 1rem; color: var(--c-text-dim);">Select the columns you want to include in the PDF report:</p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr)); gap: 0.5rem; margin-bottom: 1.5rem;">
                    <label><asp:CheckBox ID="chkColProjectTitle" runat="server" Checked="true" /> Project Title</label>
                    <label><asp:CheckBox ID="chkColFunctionality" runat="server" Checked="true" /> Functionality</label>
                    <label><asp:CheckBox ID="chkColGroupName" runat="server" Checked="true" /> Group Name</label>
                    <label><asp:CheckBox ID="chkColKeywords" runat="server" Checked="true" /> Keywords</label>
                    <label><asp:CheckBox ID="chkColProjectType" runat="server" Checked="true" /> Project Type</label>
                    <label><asp:CheckBox ID="chkColStatus" runat="server" Checked="true" /> Status</label>
                </div>
                <div style="text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('reportModal')">Cancel</button>
                    <asp:Button ID="btnGeneratePdf" runat="server" Text="Generate PDF" CssClass="btn-primary" OnClick="btnGeneratePdf_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchProjects', 'projectsTable');
        });
        function openEditProjectModal(id, title, func, status) {
            document.getElementById('<%= hdnEditProjectId.ClientID %>').value = id;
            document.getElementById('<%= txtEditProjectTitle.ClientID %>').value = title;
            document.getElementById('<%= txtEditFunctionality.ClientID %>').value = func;
            document.getElementById('<%= ddlEditProjectStatus.ClientID %>').value = status;
            openModal('editProjectModal');
        }
    </script>
</asp:Content>

