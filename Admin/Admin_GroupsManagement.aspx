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
                            <asp:Repeater ID="rptGroups" runat="server">
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
                                                <a href='<%# ResolveUrl("~/Admin/Details/Group_Details.aspx?GroupId=" + Eval("GroupId")) %>' class="icon-btn" title="View Details">
                                                    <i class="fa-solid fa-eye" style="color: var(--c-primary);"></i>
                                                </a>
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
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchGroups', 'groupsTable');
        });
    </script>
</asp:Content>

