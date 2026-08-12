<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Student.Member.Dashboard" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard - Overview</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../../Admin/admin.css?v=latest_v3" />
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
</head>

<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2>Project Board</h2>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href='<%= ResolveUrl("~/Student/Member/Dashboard.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_Team.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Team & Mentor
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_Project.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-open"></i> Project Details
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Member/Member_TaskManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-list-check"></i> My Tasks
                    </a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href='<%= ResolveUrl("~/Logout.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                    </a>
                </div>
            </nav>
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="avatar"><%= UserInitials %></div>
                    <div class="user-info">
                        <h4><%= UserName %></h4>
                        <p><%= UserEmail %></p>
                    </div>
                </div>
            </div>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <div class="topbar">
                <div class="search-bar" style="visibility: hidden;">
                    <i class="fa-solid fa-search"></i>
                    <input type="text" placeholder="Search...">
                </div>
                                    <div class="topbar-actions">
                        <a href="<%= ResolveUrl("~/User/Notifications.aspx") %>" class="notification-btn" title="Notifications">
                            <i class="fa-regular fa-bell"></i>
                            <span class="notification-badge"><%= Project_Board.Utils.NotificationHelper.GetUnreadCount(Session["UserId"]) %></span>
                        </a>
                        <div class="profile-menu-container">
                            <div class="profile-trigger">
                                <div class="avatar"><%= Session["FullName"] != null ? Session["FullName"].ToString().Substring(0,1).ToUpper() : "U" %></div>
                                <div class="profile-greeting">
                                    <span>Hi,</span> <%= Session["FullName"] ?? "User" %>
                                </div>
                                <i class="fa-solid fa-chevron-down profile-arrow"></i>
                            </div>
                            <div class="profile-dropdown">
                                <a href="<%= ResolveUrl("~/User/Profile.aspx") %>"><i class="fa-regular fa-user"></i> My Profile</a>
                                <a href="<%= ResolveUrl("~/User/Profile.aspx") %>"><i class="fa-solid fa-key"></i> Change Password</a>
                                <a href="<%= ResolveUrl("~/Logout.aspx") %>"><i class="fa-solid fa-lock"></i> Log Out</a>
                            </div>
                        </div>
                    </div>
            </div>

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
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>

</html>
