<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Student.Member.Dashboard" MasterPageFile="~/Student/Member/Member.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Member Dashboard - Overview
</asp:Content>
<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .mentor-card {
            background: var(--c-bg-card);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.25rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .mentor-avatar {
            width: 52px;
            height: 52px;
            border-radius: 50%;
            background: linear-gradient(135deg, #6366f1, #8b5cf6);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.25rem;
        }

        .mentor-details h4 {
            margin: 0;
            font-size: 1.1rem;
            color: var(--c-text);
        }

        .mentor-details p {
            margin: 0.2rem 0 0 0;
            font-size: 0.875rem;
            color: var(--c-text-dim);
        }

        .badge-status {
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-success { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
        .badge-warning { background: rgba(234, 179, 8, 0.15); color: #eab308; }
        .badge-danger { background: rgba(239, 68, 68, 0.15); color: #ef4444; }
        .badge-info { background: rgba(59, 130, 246, 0.15); color: #3b82f6; }
        .badge-purple { background: rgba(168, 85, 247, 0.15); color: #a855f7; }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .data-table th, .data-table td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid var(--c-border);
        }

        .data-table th {
            color: var(--c-text-dim);
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1><%= IsAssigned ? GroupName : "Not in a Team" %></h1>
                        <p>Technology Domain: <%= TechName %></p>
                    </div>
                </div>

                <% if (!IsAssigned) { %>
                    <div class="stat-card" style="padding:2rem; text-align:center;">
                        <i class="fa-solid fa-users-slash" style="font-size:3rem; color:var(--c-text-dim); margin-bottom:1rem; display:block;"></i>
                        <h2 style="margin-bottom:0.5rem;">You haven't joined a team yet</h2>
                        <p style="color:var(--c-text-dim);">Check your <a href='<%= ResolveUrl("~/Student/Member/InvitationManager.aspx") %>' style="color:var(--c-accent); text-decoration:underline;">Invitations</a> or request to join a team to see team details and tasks.</p>
                    </div>
                <% } else { %>

                    <!-- ASSIGNED FACULTY MENTOR PROFILE CARD -->
                    <div class="mentor-card">
                        <div class="mentor-avatar">
                            <%= IsMentorAssigned ? MentorInitials : (IsMentorPending ? "<i class='fa-solid fa-clock'></i>" : "<i class='fa-solid fa-user-tie'></i>") %>
                        </div>
                        <div class="mentor-details" style="flex:1;">
                            <% if (IsMentorAssigned) { %>
                                <h4><i class="fa-solid fa-award" style="color:#6366f1; margin-right:0.4rem;"></i> Assigned Faculty Mentor: <%= MentorName %></h4>
                                <p><i class="fa-solid fa-envelope" style="margin-right:0.3rem;"></i> <%= MentorEmail %></p>
                            <% } else if (IsMentorPending) { %>
                                <h4><i class="fa-solid fa-clock" style="color:#eab308; margin-right:0.4rem;"></i> Mentor Request Pending Approval</h4>
                                <p>Requested: <strong><%= MentorName %></strong> — Waiting for faculty acceptance.</p>
                            <% } else { %>
                                <h4><i class="fa-solid fa-triangle-exclamation" style="color:#ef4444; margin-right:0.4rem;"></i> Faculty Mentor Not Assigned</h4>
                                <p>Your team leader hasn't requested a faculty mentor yet.</p>
                            <% } %>
                        </div>
                        <div>
                            <span class="badge-status <%= IsMentorAssigned ? "badge-success" : (IsMentorPending ? "badge-warning" : "badge-danger") %>">
                                <%= IsMentorAssigned ? "Assigned" : (IsMentorPending ? "Pending" : "Unassigned") %>
                            </span>
                        </div>
                    </div>

                    <!-- STRICTLY MY ASSIGNED TASKS SECTION -->
                    <div class="stat-card" style="margin-bottom: 1.5rem;">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <h3><i class="fa-solid fa-list-check" style="color:var(--c-accent); margin-right:0.5rem;"></i> My Assigned Tasks</h3>
                            <a href='<%= ResolveUrl("~/Student/Member/Member_TaskManagement.aspx") %>' class="btn-primary" style="padding:0.4rem 0.8rem; font-size:0.8rem; text-decoration:none;">View All Tasks</a>
                        </div>

                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Task Title</th>
                                    <th>Assigned By</th>
                                    <th>Due Date</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptAssignedTasks" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("TaskTitle") %></strong></td>
                                            <td><%# Eval("AssignedByName") %></td>
                                            <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No Due Date" %></td>
                                            <td>
                                                <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-success" : (Eval("Status").ToString() == "Appealed" ? "badge-purple" : "badge-info") %>'>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>

                    <!-- GROUP MEMBERS LIST -->
                    <div class="stat-card">
                        <h3><i class="fa-solid fa-users" style="color:var(--c-accent); margin-right:0.5rem;"></i> Team Members</h3>
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Role</th>
                                    <th>Enrollment No</th>
                                    <th>Email</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptMembers" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("FullName") %></strong></td>
                                            <td><%# Eval("Role").ToString() == "Leader" ? "<span class='badge-status badge-purple'>Leader</span>" : "<span class='badge-status badge-info'>Member</span>" %></td>
                                            <td><%# Eval("EnrollmentNo") != DBNull.Value ? Eval("EnrollmentNo") : "N/A" %></td>
                                            <td><%# Eval("Email") %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>

                <% } %>
            </div>
            </div>
</asp:Content>
