<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_GroupsManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_GroupsManagement" MasterPageFile="~/Admin/Admin.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Dashboard — Groups
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="dashboard-container">
            <div class="view-section active">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Groups</h1>
                        <p>View all student groups, members, and faculty mentors.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Group Details (Aggregated)</h2>
                        <div style="display:flex; gap: 10px; align-items:center;">
                            <asp:DropDownList ID="ddlReportFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReportFilter_SelectedIndexChanged" CssClass="form-select" style="padding: 0.5rem; border: 1px solid var(--c-border); border-radius: 4px; background: var(--c-surface); color: var(--c-text);">
                                <asp:ListItem Text="All Groups" Value="All"></asp:ListItem>
                                <asp:ListItem Text="Active Only" Value="Active"></asp:ListItem>
                                <asp:ListItem Text="Inactive Only" Value="Inactive"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:LinkButton ID="btnExportReport" runat="server" CssClass="btn-secondary" OnClick="btnExportReport_Click">
                                <i class="fa-solid fa-file-export"></i> Export Report
                            </asp:LinkButton>
                            <div class="search-bar" style="width: 250px;">
                                <i class="fa-solid fa-search"></i>
                                <input type="text" id="searchGroups" placeholder="Filter groups...">
                            </div>
                        </div>
                    </div>
                    <table id="groupsTable">
                        <thead>
                            <tr>
                                <th>Group Name</th>
                                <th>Leader</th>
                                <th>Members</th>
                                <th>Faculty Mentor</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptGroups" runat="server" OnItemCommand="rptGroups_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("GroupName") %></strong></td>
                                        <td><%# Eval("LeaderName") %></td>
                                        <td><%# string.IsNullOrEmpty(Convert.ToString(Eval("Members"))) ? "<span style='color:var(--c-text-muted)'>None</span>" : Eval("Members") %></td>
                                        <td><%# Eval("MentorName") != DBNull.Value ? Eval("MentorName") : "<span style='color:var(--c-text-muted)'>Not Assigned</span>" %></td>
                                        <td>
                                            <span class='badge status-<%# Eval("Status").ToString().ToLower() %>'><%# Eval("Status") %></span>
                                        </td>
                                        <td>
                                            <div class="table-actions">
                                                <button type="button" class="icon-btn edit" onclick="openEditGroupModal('<%# Eval("GroupId") %>', '<%# Eval("Status") %>')" style="color:var(--c-primary); background:none; border:none; cursor:pointer;" title="Edit Group">
                                                    <i class="fa-solid fa-edit"></i>
                                                </button>
                                                <a href='<%# ResolveUrl("~/Admin/Details/Group_Details.aspx?GroupId=" + Eval("GroupId")) %>' class="icon-btn" title="View Details">
                                                    <i class="fa-solid fa-eye" style="color: var(--c-primary);"></i>
                                                </a>
                                                <asp:LinkButton ID="btnToggleStatus" runat="server" CssClass="icon-btn" CommandName="ToggleGroupStatus" CommandArgument='<%# Eval("GroupId") %>' OnClientClick="return confirm('Are you sure you want to deactivate this group? Deactivated groups will not be visible for new join requests.');">
                                                    <i class='fa-solid fa-ban' style='color: var(--c-red);'></i>
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
        
    <!-- Edit Group Modal -->
    <div class="modal-overlay" id="editGroupModal">
        <div class="modal-content" style="max-width: 400px;">
            <h2 style="margin-bottom: 1.5rem; font-family: var(--f-display);">Edit Group Status</h2>
            <asp:HiddenField ID="hdnEditGroupId" runat="server" />
            <div id="editGroupForm">
                <div class="form-group">
                    <label>Status</label>
                    <asp:DropDownList ID="ddlEditGroupStatus" runat="server" CssClass="form-control">
                        <asp:ListItem Value="Forming">Forming</asp:ListItem>
                        <asp:ListItem Value="Pending">Pending</asp:ListItem>
                        <asp:ListItem Value="Active">Active</asp:ListItem>
                        <asp:ListItem Value="Rejected">Rejected</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <asp:Label ID="lblEditMessage" runat="server" ForeColor="#ff4d4d" EnableViewState="false" style="display:block;margin-bottom:10px; margin-top: 10px;"></asp:Label>
                
                <div class="form-actions" style="margin-top: 1.5rem; text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('editGroupModal')">Cancel</button>
                    <asp:Button ID="btnUpdateGroup" runat="server" Text="Save Changes" CssClass="btn-primary" OnClick="btnUpdateGroup_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchGroups', 'groupsTable');
        });
        function openEditGroupModal(id, status) {
            document.getElementById('<%= hdnEditGroupId.ClientID %>').value = id;
            document.getElementById('<%= ddlEditGroupStatus.ClientID %>').value = status;
            openModal('editGroupModal');
        }
    </script>
</asp:Content>

