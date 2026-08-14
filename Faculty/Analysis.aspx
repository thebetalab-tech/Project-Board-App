<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Analysis.aspx.cs" Inherits="Project_Board.Faculty.Analysis" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faculty Dashboard — Analysis</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <style>
        .analysis-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        .chart-container {
            background: white;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--c-border);
        }
        .chart-container h3 {
            margin-top: 0;
            margin-bottom: 1.5rem;
            color: var(--c-text);
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo-icon"><i class="fa-solid fa-graduation-cap" style="color: white;"></i></div>
                <h2 class="sidebar-title">Project Board</h2>
                <button type="button" id="sidebarToggle" class="sidebar-toggle-btn" title="Toggle Sidebar">
                    <i class="fa-solid fa-bars"></i>
                </button>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href='<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/Analysis.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-chart-line"></i> Analysis & Reports
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> Project Management
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Mentor Requests
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/TaskManagement.aspx") %>' class="nav-link">
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
                    <div class="avatar"><%= Session["FullName"] != null ? Session["FullName"].ToString().Substring(0,1).ToUpper() : "U" %></div>
                    <div class="user-info">
                        <h4><%= Session["FullName"] ?? "Faculty Mentor" %></h4>
                        <p><%= Session["Email"] ?? "faculty@example.com" %></p>
                    </div>
                </div>
            </div>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="main-content">
            <header class="topbar">
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
            </header>
            
            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Mentored Groups Analysis</h1>
                        <p>Analyze progress and statistics of groups under your mentorship.</p>
                    </div>
                </div>

                <div class="analysis-grid">
                    <div class="chart-container">
                        <h3><i class="fa-solid fa-folder-tree" style="color:#3b82f6;"></i> Projects by Status</h3>
                        <canvas id="projectsChart" style="max-height: 300px;"></canvas>
                    </div>
                    <div class="chart-container">
                        <h3><i class="fa-solid fa-users" style="color:#10b981;"></i> Groups by Status</h3>
                        <canvas id="groupsChart" style="max-height: 300px;"></canvas>
                    </div>
                    <div class="chart-container">
                        <h3><i class="fa-solid fa-list-check" style="color:#ef4444;"></i> Tasks by Status</h3>
                        <canvas id="tasksChart" style="max-height: 300px;"></canvas>
                    </div>
                    <div class="chart-container">
                        <h3><i class="fa-solid fa-microchip" style="color:#8b5cf6;"></i> Mentored Tech Domains</h3>
                        <canvas id="techChart" style="max-height: 300px;"></canvas>
                    </div>
                </div>
            </div>
        </main>
    </form>
    
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const chartOptions = {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' }
                }
            };

            // Projects Chart
            const projectsData = <%= ProjectsByStatusJson %>;
            new Chart(document.getElementById('projectsChart'), {
                type: 'doughnut',
                data: {
                    labels: Object.keys(projectsData),
                    datasets: [{
                        data: Object.values(projectsData),
                        backgroundColor: ['#3b82f6', '#10b981', '#ef4444', '#f59e0b']
                    }]
                },
                options: chartOptions
            });

            // Groups Chart
            const groupsData = <%= GroupsByStatusJson %>;
            new Chart(document.getElementById('groupsChart'), {
                type: 'pie',
                data: {
                    labels: Object.keys(groupsData),
                    datasets: [{
                        data: Object.values(groupsData),
                        backgroundColor: ['#10b981', '#f59e0b', '#3b82f6', '#ef4444']
                    }]
                },
                options: chartOptions
            });
            
            // Tech Chart
            const techData = <%= TechsJson %>;
            new Chart(document.getElementById('techChart'), {
                type: 'doughnut',
                data: {
                    labels: Object.keys(techData),
                    datasets: [{
                        data: Object.values(techData),
                        backgroundColor: ['#8b5cf6', '#ec4899', '#f59e0b', '#10b981', '#3b82f6']
                    }]
                },
                options: chartOptions
            });

            // Tasks Chart
            const tasksData = <%= TasksByStatusJson %>;
            new Chart(document.getElementById('tasksChart'), {
                type: 'bar',
                data: {
                    labels: Object.keys(tasksData),
                    datasets: [{
                        label: 'Tasks',
                        data: Object.values(tasksData),
                        backgroundColor: ['#6366f1', '#14b8a6', '#f43f5e', '#8b5cf6']
                    }]
                },
                options: { ...chartOptions, plugins: { legend: { display: false } } }
            });
        });
    </script>
</body>
</html>
