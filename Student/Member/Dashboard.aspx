<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Student.Member.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard — Overview</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../../Admin/admin.css">
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
                    <a href="Dashboard.aspx" class="nav-link active">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="Member_Team.aspx" class="nav-link">
                        <i class="fa-solid fa-users"></i> Team & Mentor
                    </a>
                    <a href="InvitationManager.aspx" class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Invitations
                    </a>
                    <% if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Leader") { %>
                    <a href="../Leader/Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-user-tie"></i> Leader Panel
                    </a>
                    <% } %>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href="../../User/Profile.aspx" class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href="../../Logout.aspx" class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                    </a>
                </div>
            </nav>
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="avatar"><%= UserInitials %></div>
                    <div class="user-info">
                        <h4><%= Session["FullName"] ?? "Student Member" %></h4>
                        <p><%= Session["Email"] ?? "member@example.com" %></p>
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
                    <a href="../../User/Profile.aspx" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1><%= IsAssigned ? GroupName : "Welcome, " + Session["FullName"] %></h1>
                        <p><%= IsAssigned ? "Technology Domain: " + TechName : "You need to join a group to see project details." %></p>
                    </div>
                </div>

                <% if (IsAssigned) { %>
                <div class="data-section">
                    <div class="section-header">
                        <h2>Team Leader</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <div class="user-cell" style="margin-bottom: 1rem;">
                            <div class="user-cell-avatar" style="width: 48px; height: 48px; font-size: 1.25rem;"><%= LeaderInitials %></div>
                            <div class="user-cell-info">
                                <h4 style="font-size: 1.1rem; margin-bottom: 4px;"><%= LeaderName %></h4>
                                <p style="color: var(--c-accent); font-weight: 500;">Team Leader</p>
                            </div>
                        </div>
                        <div style="display: grid; gap: 0.75rem;">
                            <div>
                                <label style="font-size: 0.75rem; color: var(--c-text-muted); text-transform: uppercase;">Enrollment Number</label>
                                <p style="font-weight: 500;"><%= LeaderEnrollment %></p>
                            </div>
                            <div>
                                <label style="font-size: 0.75rem; color: var(--c-text-muted); text-transform: uppercase;">Email</label>
                                <p style="font-weight: 500;"><%= LeaderEmail %></p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="data-section">
                    <div class="section-header">
                        <h2>Project Specifications</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <p style="color: var(--c-text-muted); margin-bottom: 1.5rem; font-size: 0.875rem;">Core specifications and technology alignment details submitted for the academic project board.</p>
                        <div style="display: grid; gap: 1.25rem;">
                            <div>
                                <label style="font-size: 0.75rem; color: var(--c-text-muted); text-transform: uppercase; font-weight: 600;">Project Title</label>
                                <p style="font-weight: 700; font-size: 1.1rem; color: var(--c-accent);"><%= GroupName %></p>
                            </div>
                            <div>
                                <label style="font-size: 0.75rem; color: var(--c-text-muted); text-transform: uppercase; font-weight: 600;">Domain Alignment</label>
                                <p style="font-weight: 500;"><%= TechName %></p>
                            </div>
                        </div>
                    </div>
                </div>
                <% } else { %>
                <div class="data-section" style="text-align: center; padding: 4rem 2rem;">
                    <i class="fa-solid fa-users-slash" style="font-size: 3rem; color: var(--c-text-muted); margin-bottom: 1rem;"></i>
                    <h2 style="font-size: 1.5rem; margin-bottom: 0.5rem;">You are not in a group yet</h2>
                    <p style="color: var(--c-text-muted); margin-bottom: 2rem;">Browse available groups that are looking for members and send a request to join.</p>
                    <a href="../../JoinGroup.aspx" class="btn-primary" style="display: inline-block; padding: 0.75rem 1.5rem; text-decoration: none; border-radius: 8px;">Browse &amp; Join Groups</a>
                </div>
                <% } %>
            </div>
        </main>
    </form>
</body>
</html>
