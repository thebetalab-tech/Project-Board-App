<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Student.Leader.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader Dashboard — Overview</title>
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
                    <a href="Leader_Members.aspx" class="nav-link">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href="Leader_Mentor.aspx" class="nav-link">
                        <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                    </a>
                    <a href="../Member/Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-user-group"></i> View as Member
                    </a>
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
                    <div class="avatar">TL</div>
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
                        <span class="status-dot"></span> Team Forming
                    </div>
                    <a href="../../User/Profile.aspx" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Beta Lab Core Team</h1>
                        <p>Technology Domain: Web Development (Full Stack)</p>
                    </div>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users"><i class="fa-solid fa-users"></i></div>
                        </div>
                        <div class="stat-value">2</div>
                        <div class="stat-label">Total Members</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon groups"><i class="fa-solid fa-envelope"></i></div>
                        </div>
                        <div class="stat-value">2</div>
                        <div class="stat-label">Total Invited</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects"><i class="fa-solid fa-clock-rotate-left"></i></div>
                        </div>
                        <div class="stat-value">2</div>
                        <div class="stat-label">Pending Invites</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-check"></i></div>
                        </div>
                        <div class="stat-value">0</div>
                        <div class="stat-label">Accepted Invites</div>
                    </div>
                </div>
                
                <div class="data-section">
                    <div class="section-header">
                        <h2>Project Overview</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <p style="color: var(--c-text-muted); margin-bottom: 1.5rem;">Core specifications and technology alignment details submitted for the academic project board.</p>
                        <div style="display: grid; gap: 1.25rem;">
                            <div>
                                <label style="font-size: 0.75rem; color: var(--c-text-muted); text-transform: uppercase; font-weight: 600;">Project Title</label>
                                <p style="font-weight: 700; font-size: 1.1rem; color: var(--c-accent);">Project Board App</p>
                            </div>
                            <div>
                                <label style="font-size: 0.75rem; color: var(--c-text-muted); text-transform: uppercase; font-weight: 600;">Domain Alignment</label>
                                <p style="font-weight: 500;">Web Development (Full Stack)</p>
                            </div>
                            <div>
                                <label style="font-size: 0.75rem; color: var(--c-text-muted); text-transform: uppercase; font-weight: 600;">Functional Scope</label>
                                <p style="font-weight: 400;">Creating a collaborative dashboard workspace. The application supports team tracking, mentor selection, proposal approval workflows, and task boards for agile project development.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
