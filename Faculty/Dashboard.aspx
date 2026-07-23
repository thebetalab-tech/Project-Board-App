<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Faculty.Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board - Faculty Dashboard</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200797339083061" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo-icon"><i class="fa-solid fa-graduation-cap" style="color: white;"></i></div>
                <h2>Project Board</h2>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href="<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> Project Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Mentor Requests
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
                        <h4><%= Session["FullName"] ?? "Faculty Member" %></h4>
                        <p><%= Session["Email"] ?? "faculty@example.com" %></p>
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
                    <a href="<%= ResolveUrl("~/User/Profile.aspx") %>" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Faculty Dashboard</h1>
                        <p>Welcome to the Faculty Dashboard section.</p>
                    </div>
                </div>
                
                                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users"><i class="fa-solid fa-users"></i></div>
                        </div>
                        <div class="stat-value"><%= MentoredGroupsCount %></div>
                        <div class="stat-label">Mentored Groups</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects"><i class="fa-solid fa-folder-tree"></i></div>
                        </div>
                        <div class="stat-value"><%= ActiveProjectsCount %></div>
                        <div class="stat-label">Active Projects</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-envelope"></i></div>
                        </div>
                        <div class="stat-value"><%= PendingRequestsCount %></div>
                        <div class="stat-label">Pending Requests</div>
                    </div>
                </div>
            </div>
        </main>
    </form>
    
    <!-- Mobile toggle script -->
    <script src="<%= ResolveUrl("~/Admin/admin.js") %>"></script>
</body>
</html>

