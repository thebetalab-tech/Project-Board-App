<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Student.Leader.Dashboard" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader Dashboard — Overview</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../../Admin/admin.css?v=639200793428857004" />
    <style>
        .status-badge-container {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            background: var(--c-bg-elevated);
            padding: 0.5rem 1rem;
            border-radius: 20px;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            display: inline-block;
            background: var(--c-blue);
        }

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

        .members-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .members-table th, .members-table td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid var(--c-border);
        }

        .members-table th {
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
                    <a href='<%= ResolveUrl("~/Student/Leader/Dashboard.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Members.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Project.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-open"></i> Project Management
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <a href='<%= ResolveUrl("~/Student/Leader/Leader_TaskManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-list-check"></i> Tasks
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
                    <div class="avatar">
                        <%= UserInitials %>
                    </div>
                    <div class="user-info">
                        <h4>
                            <%= Session["FullName"] ?? "Student Leader" %>
                        </h4>
                        <p>
                            <%= Session["Email"] ?? "leader@example.com" %>
                        </p>
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
                    <div class="status-badge-container">
                        <span class="status-dot" style='<%= MemberNeeded ? "" : "background: var(--c-green);" %>'></span>
                        <%= MemberNeeded ? "Team Forming" : "Team Completed" %>
                    </div>
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1><%= GroupName %></h1>
                        <p>Technology Domain: <%= TechName %></p>
                    </div>
                </div>

                <!-- MENTOR STATUS PROFILE CARD -->
                <div class="mentor-card">
                    <div class="mentor-avatar">
                        <%= IsMentorAssigned ? MentorInitials : "<i class='fa-solid fa-user-tie'></i>" %>
                    </div>
                    <div class="mentor-details" style="flex:1;">
                        <% if (IsMentorAssigned) { %>
                            <h4><i class="fa-solid fa-award" style="color:#6366f1; margin-right:0.4rem;"></i> Assigned Faculty Mentor: <%= MentorName %></h4>
                            <p><i class="fa-solid fa-envelope" style="margin-right:0.3rem;"></i> <%= MentorEmail %></p>
                        <% } else if (GroupStatus.Equals("Pending Faculty Approval", StringComparison.OrdinalIgnoreCase)) { %>
                            <h4><i class="fa-solid fa-clock" style="color:#eab308; margin-right:0.4rem;"></i> Mentor Request Pending Approval</h4>
                            <p>Requested: <%= MentorName %> — Waiting for faculty acceptance.</p>
                        <% } else { %>
                            <h4><i class="fa-solid fa-triangle-exclamation" style="color:#ef4444; margin-right:0.4rem;"></i> No Faculty Mentor Assigned</h4>
                            <p>Go to <a href='<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>' style="color:var(--c-accent); text-decoration:underline;">Mentor Request</a> to select a mentor.</p>
                        <% } %>
                    </div>
                    <div>
                        <span class="badge-status <%= IsMentorAssigned ? "badge-success" : (GroupStatus.Equals("Pending Faculty Approval", StringComparison.OrdinalIgnoreCase) ? "badge-warning" : "badge-danger") %>">
                            <%= IsMentorAssigned ? "Assigned" : (GroupStatus.Equals("Pending Faculty Approval", StringComparison.OrdinalIgnoreCase) ? "Pending" : "Unassigned") %>
                        </span>
                    </div>
                </div>

                <!-- TASK PROGRESS OVERVIEW GRID -->
                <div class="stats-grid" style="grid-template-columns: repeat(5, 1fr); margin-bottom: 1.5rem;">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: rgba(234, 179, 8, 0.12); color: #eab308;"><i class="fa-solid fa-clock"></i></div>
                        </div>
                        <div class="stat-value"><%= PendingTasks %></div>
                        <div class="stat-label">Pending Tasks</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: rgba(59, 130, 246, 0.12); color: #3b82f6;"><i class="fa-solid fa-spinner"></i></div>
                        </div>
                        <div class="stat-value"><%= InProgressTasks %></div>
                        <div class="stat-label">In Progress</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: rgba(34, 197, 94, 0.12); color: #22c55e;"><i class="fa-solid fa-check-circle"></i></div>
                        </div>
                        <div class="stat-value"><%= CompletedTasks %></div>
                        <div class="stat-label">Completed</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: rgba(239, 68, 68, 0.12); color: #ef4444;"><i class="fa-solid fa-calendar-xmark"></i></div>
                        </div>
                        <div class="stat-value"><%= OverdueTasks %></div>
                        <div class="stat-label">Overdue</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon" style="background: rgba(168, 85, 247, 0.12); color: #a855f7;"><i class="fa-solid fa-flag"></i></div>
                        </div>
                        <div class="stat-value"><%= AppealedTasks %></div>
                        <div class="stat-label">Appealed</div>
                    </div>
                </div>

                <!-- TEAM MEMBERS LIST -->
                <div class="stat-card" style="margin-top: 1.5rem;">
                    <h3><i class="fa-solid fa-users" style="color:var(--c-accent); margin-right:0.5rem;"></i> Group Members (<%= TotalMembers %>)</h3>
                    <table class="members-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Enrollment No</th>
                                <th>Email</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptMembers" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("FullName") %></strong></td>
                                        <td><%# Eval("EnrollmentNo") != DBNull.Value ? Eval("EnrollmentNo") : "N/A" %></td>
                                        <td><%# Eval("Email") %></td>
                                        <td>
                                            <span class='badge-status <%# Eval("JoinStatus").ToString() == "Accepted" ? "badge-success" : "badge-warning" %>'>
                                                <%# Eval("JoinStatus") %>
                                            </span>
                                        </td>
                                    </tr>   
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js") %>'></script>
</body>

</html>