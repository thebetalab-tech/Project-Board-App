<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Dashboard.aspx.cs" Inherits="Project_Board.Admin.Admin_Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Overview</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="admin.css">
</head>
<body>
    <form id="form1" runat="server">

    <!-- SIDEBAR -->
    <aside class="sidebar">
        <div class="sidebar-header">
            <div class="logo-icon">P</div>
            <h2>Project Board</h2>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href="Admin_Dashboard.aspx" class="nav-link active">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href="Admin_UserManagement.aspx" class="nav-link">
                    <i class="fa-solid fa-users"></i> Users Management
                </a>
                <a href="Admin_GroupsManagement.aspx" class="nav-link">
                    <i class="fa-solid fa-user-group"></i> Groups
                </a>
                <a href="Admin_ProjectsManagement.aspx" class="nav-link">
                    <i class="fa-solid fa-folder-open"></i> Projects
                </a>
                <a href="Admin_TechManagement.aspx" class="nav-link">
                    <i class="fa-solid fa-microchip"></i> Technologies
                </a>
            </div>

            <div class="nav-section">
                <div class="nav-section-title">Preferences</div>
                <a href="#settings" class="nav-link">
                    <i class="fa-solid fa-gear"></i> Settings
                </a>
                <a href="../Logout.aspx" class="nav-link">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                </a>
            </div>
        </nav>

        <div class="sidebar-footer">
            <div class="user-profile">
                <div class="avatar">AD</div>
                <div class="user-info">
                    <h4>System Admin</h4>
                    <p>admin@university.edu</p>
                </div>
            </div>
        </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <header class="topbar">
            <div class="search-bar">
                <i class="fa-solid fa-search"></i>
                <input type="text" placeholder="Search overview...">
            </div>
            
            <div class="topbar-actions">
                <button class="action-btn">
                    <i class="fa-regular fa-bell"></i>
                    <span class="notification-badge"></span>
                </button>
            </div>
        </header>

        <div class="dashboard-container">
            <div class="view-section active">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Dashboard Overview</h1>
                        <p>Welcome back, Admin. Here is what's happening today.</p>
                    </div>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users"><i class="fa-solid fa-users"></i></div>
                            <div class="stat-trend positive"><i class="fa-solid fa-arrow-up"></i> 12%</div>
                        </div>
                        <div class="stat-value">1,248</div>
                        <div class="stat-label">Total Active Users</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon groups"><i class="fa-solid fa-user-group"></i></div>
                            <div class="stat-trend positive"><i class="fa-solid fa-arrow-up"></i> 5%</div>
                        </div>
                        <div class="stat-value">156</div>
                        <div class="stat-label">Total Groups</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects"><i class="fa-solid fa-folder-open"></i></div>
                            <div class="stat-trend negative"><i class="fa-solid fa-arrow-down"></i> 2%</div>
                        </div>
                        <div class="stat-value">84</div>
                        <div class="stat-label">Pending Projects</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-microchip"></i></div>
                        </div>
                        <div class="stat-value">32</div>
                        <div class="stat-label">Registered Technologies</div>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Recent Project Submissions</h2>
                        <div class="section-actions">
                            <a href="Admin_ProjectsManagement.aspx" class="btn-secondary" style="text-decoration:none; display:inline-block;">View All</a>
                        </div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Project Title</th>
                                <th>Group</th>
                                <th>Type</th>
                                <th>Status</th>
                                <th>Submitted Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>AI-Powered Health Assistant</td>
                                <td>Group Alpha</td>
                                <td>UDP</td>
                                <td><span class="badge status-pending">Pending</span></td>
                                <td>Today, 10:45 AM</td>
                            </tr>
                            <tr>
                                <td>Blockchain Voting System</td>
                                <td>CyberKnights</td>
                                <td>IDP</td>
                                <td><span class="badge status-active">Approved</span></td>
                                <td>Yesterday, 02:30 PM</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
    <script src="admin.js"></script>
    </form>
</body>
</html>

