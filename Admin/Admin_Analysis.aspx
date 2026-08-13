<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Analysis.aspx.cs" Inherits="Project_Board.Admin.Admin_Analysis" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Analysis</title>
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
            <h2>Project Board</h2>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href='<%= ResolveUrl("~/Admin/Admin_Dashboard.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_Analysis.aspx") %>' class="nav-link active">
                    <i class="fa-solid fa-chart-line"></i> Analysis & Reports
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_UserManagement.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-users"></i> Users Management
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_GroupsManagement.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-user-group"></i> Groups
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_ProjectsManagement.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-folder-open"></i> Projects
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_TechManagement.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-microchip"></i> Technologies
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_TaskManagement.aspx") %>' class="nav-link">
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
                <!-- Fetch From Session -->
                <div class="avatar"><asp:Label ID="userintial" runat="server"></asp:Label></div>
                <div class="user-info" ID="userInfo">
                    <h4><asp:Label ID="userNameLabel" runat="server"></asp:Label></h4>
                    <p><asp:Label ID="userEmailLabel" runat="server"></asp:Label></p>
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
                    <h1>System Analysis</h1>
                    <p>In-depth visualization and charts of platform activity.</p>
                </div>
            </div>

            <div class="analysis-grid">
                <div class="chart-container">
                    <h3><i class="fa-solid fa-users" style="color:#4f46e5;"></i> Users by Role</h3>
                    <canvas id="usersChart" style="max-height: 300px;"></canvas>
                </div>
                <div class="chart-container">
                    <h3><i class="fa-solid fa-folder-tree" style="color:#10b981;"></i> Projects by Status</h3>
                    <canvas id="projectsChart" style="max-height: 300px;"></canvas>
                </div>
                <div class="chart-container">
                    <h3><i class="fa-solid fa-microchip" style="color:#f59e0b;"></i> Projects by Technology</h3>
                    <canvas id="techChart" style="max-height: 300px;"></canvas>
                </div>
                <div class="chart-container">
                    <h3><i class="fa-solid fa-list-check" style="color:#ef4444;"></i> Tasks by Status</h3>
                    <canvas id="tasksChart" style="max-height: 300px;"></canvas>
                </div>
            </div>
        </div>
    </main>
    
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
            
            // Users Chart
            const usersData = <%= UsersByRoleJson %>;
            new Chart(document.getElementById('usersChart'), {
                type: 'pie',
                data: {
                    labels: Object.keys(usersData),
                    datasets: [{
                        data: Object.values(usersData),
                        backgroundColor: ['#4f46e5', '#10b981', '#f59e0b', '#ef4444']
                    }]
                },
                options: chartOptions
            });

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

            // Tech Chart
            const techData = <%= ProjectsByTechJson %>;
            new Chart(document.getElementById('techChart'), {
                type: 'bar',
                data: {
                    labels: Object.keys(techData),
                    datasets: [{
                        label: 'Projects',
                        data: Object.values(techData),
                        backgroundColor: ['#f59e0b', '#8b5cf6', '#3b82f6', '#10b981', '#ef4444']
                    }]
                },
                options: { ...chartOptions, plugins: { legend: { display: false } } }
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
    </form>
</body>
</html>
