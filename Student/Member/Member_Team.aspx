<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Member_Team.aspx.cs" Inherits="Project_Board.Student.Member.Member_Team" MasterPageFile="~/Student/Member/Member.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Member Dashboard - Team & Mentor
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Team & Mentor</h1>
                        <p>View your roster members and mentor request status.</p>
                    </div>
                </div>

                <!-- FACULTY MENTOR STATUS SECTION -->
                <div class="data-section">
                    <div class="section-header">
                        <h2>Faculty Mentor Status</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <p style="color: var(--c-text-muted); margin-bottom: 1.5rem; font-size: 0.875rem;">
                            Current status of your team's faculty mentor request. Only the Team Leader has permissions to select or change mentors.
                        </p>

                        <!-- ASSIGNED MENTOR PANEL -->
                        <asp:Panel ID="pnlMentorAssigned" runat="server" Visible="false">
                            <div style="background: var(--c-bg-elevated); border: 1px solid var(--c-border); padding: 1.5rem; border-radius: 8px; display:flex; align-items:center; gap:1.25rem;">
                                <div style="width:48px; height:48px; border-radius:50%; background:linear-gradient(135deg, #6366f1, #8b5cf6); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:1.2rem;">
                                    <%= MentorInitials %>
                                </div>
                                <div style="flex:1;">
                                    <h4 style="color: var(--c-text); margin-bottom: 0.25rem;">
                                        <i class="fa-solid fa-award" style="color:#6366f1;"></i> <%= MentorName %>
                                    </h4>
                                    <p style="font-size: 0.85rem; color: var(--c-text-muted); margin:0;">
                                        <i class="fa-solid fa-envelope"></i> <%= MentorEmail %> | Domain: <%= TechName %>
                                    </p>
                                </div>
                                <span class="badge" style="background:rgba(34,197,94,0.15); color:#22c55e; border:1px solid rgba(34,197,94,0.3); padding:0.35rem 0.75rem; border-radius:20px; font-weight:600;">
                                    Assigned Mentor
                                </span>
                            </div>
                        </asp:Panel>

                        <!-- PENDING MENTOR PANEL -->
                        <asp:Panel ID="pnlMentorPending" runat="server" Visible="false">
                            <div style="background: var(--c-bg-elevated); border: 1px solid var(--c-border); padding: 1.5rem; border-radius: 8px; display:flex; align-items:center; gap:1.25rem;">
                                <div style="width:48px; height:48px; border-radius:50%; background:rgba(234,179,8,0.15); color:#eab308; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:1.2rem;">
                                    <i class="fa-solid fa-clock"></i>
                                </div>
                                <div style="flex:1;">
                                    <h4 style="color: var(--c-text); margin-bottom: 0.25rem;">
                                        Mentor Request Pending Approval
                                    </h4>
                                    <p style="font-size: 0.85rem; color: var(--c-text-muted); margin:0;">
                                        Requested: <strong><%= MentorName %></strong> — Awaiting faculty review and acceptance.
                                    </p>
                                </div>
                                <span class="badge" style="background:rgba(234,179,8,0.15); color:#eab308; border:1px solid rgba(234,179,8,0.3); padding:0.35rem 0.75rem; border-radius:20px; font-weight:600;">
                                    Pending Approval
                                </span>
                            </div>
                        </asp:Panel>

                        <!-- NO MENTOR REQUESTED PANEL -->
                        <asp:Panel ID="pnlMentorNone" runat="server" Visible="false">
                            <div style="background: var(--c-bg-elevated); border: 1px solid var(--c-border); padding: 1.5rem; border-radius: 8px;">
                                <h4 style="color: var(--c-text-muted); margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.5rem;">
                                    <i class="fa-solid fa-user-slash"></i> No Mentor Requested
                                </h4>
                                <p style="font-size: 0.85rem; color: var(--c-text-muted);">
                                    Your team leader hasn't submitted a faculty mentor request yet. Once submitted, status updates will show here.
                                </p>
                            </div>
                        </asp:Panel>
                    </div>
                </div>

                <!-- ROSTER MEMBERS SECTION -->
                <div class="data-section">
                    <div class="section-header" style="display:flex; justify-content:space-between; align-items:center;">
                        <h2>Roster Members</h2>
                        <div class="search-bar" style="width: 250px;">
                            <i class="fa-solid fa-search"></i>
                            <input type="text" id="searchRoster" placeholder="Filter team members...">
                        </div>
                    </div>
                    <div class="table-responsive">
                        <asp:Panel ID="pnlUnassigned" runat="server">
                            <div style="background: var(--c-bg-elevated); border: 1px solid var(--c-border); padding: 1.5rem; border-radius: 8px;">
                                <h4 style="color: var(--c-text-muted); margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.5rem;">
                                    <i class="fa-solid fa-users-slash"></i> Not in a Team
                                </h4>
                                <p style="font-size: 0.85rem; color: var(--c-text-muted);">
                                    You haven't joined a team yet. Once you join a team, your roster members will appear here.
                                </p>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlAssigned" runat="server">
                            <table id="rosterTable">
                                <thead>
                                    <tr>
                                        <th>Member Name</th>
                                        <th style="text-align: right;">Role</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptRoster" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <div class="user-cell">
                                                        <div class="user-cell-avatar">
                                                            <%# GetInitials(Eval("FullName").ToString()) %>
                                                        </div>
                                                        <div class="user-cell-info">
                                                            <h4><%# Eval("FullName") %></h4>
                                                            <p><%# Eval("EnrollmentNo") != DBNull.Value ? Eval("EnrollmentNo") : Eval("Email") %></p>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td style="text-align: right;">
                                                    <span class='<%# Eval("Role").ToString() == "Leader" ? "badge admin" : "badge student" %>'>
                                                        <%# Eval("Role") %>
                                                    </span>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </asp:Panel>
                    </div>
                </div>
            </div>
            </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchRoster', 'rosterTable');
        });
    </script>
</asp:Content>