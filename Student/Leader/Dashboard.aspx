<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Student.Leader.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader Dashboard — Overview</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200793428857004" />
    <style>
        .status-badge-container { display: flex; align-items: center; gap: 0.5rem; font-weight: 500; font-size: 0.875rem; background: var(--c-bg-elevated); padding: 0.5rem 1rem; border-radius: 20px;}
        .status-dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; background: var(--c-blue); }
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
                    <a href="<%= ResolveUrl("~/Student/Leader/Dashboard.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Leader/Leader_Members.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Leader/InvitationManager.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <a href="<%= ResolveUrl("~/Student/Member/Dashboard.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-user-group"></i> View as Member
                    </a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href="<%= ResolveUrl("~/Logout.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                    </a>
                </div>
            </nav>
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="avatar"><%= UserInitials %></div>
                    <div class="user-info">
                        <h4><%= Session["FullName"] ?? "Student Leader" %></h4>
                        <p><%= Session["Email"] ?? "leader@example.com" %></p>
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
                        <span class="status-dot" style='<%= MemberNeeded ? "" : "background: var(--c-green);" %>'></span> <%= MemberNeeded ? "Team Forming" : "Team Completed" %>
                    </div>
                    <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="action-btn" title="Profile">
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

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users"><i class="fa-solid fa-users"></i></div>
                        </div>
                        <div class="stat-value"><%= TotalMembers %></div>
                        <div class="stat-label">Total Members</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects"><i class="fa-solid fa-clock-rotate-left"></i></div>
                        </div>
                        <div class="stat-value"><%= PendingInvites %></div>
                        <div class="stat-label">Pending Invites</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-check"></i></div>
                        </div>
                        <div class="stat-value"><%= AcceptedInvites %></div>
                        <div class="stat-label">Accepted Invites</div>
                    </div>
                </div>
            </div>
        </main>
    </form>
	<script src="<%= ResolveUrl("~/Admin/admin.js") %>"></script>
</body>
</html>


