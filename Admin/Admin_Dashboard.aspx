<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Dashboard.aspx.cs" Inherits="Project_Board.Admin.Admin_Dashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Overview</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
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
                <a href='<%= ResolveUrl("~/Admin/Admin_Dashboard.aspx") %>' class="nav-link active">
                    <i class="fa-solid fa-chart-pie"></i> Overview
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
                            <span class="notification-badge">0</span>
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
                        </div>
                        <div class="stat-value"><asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-label">Total Active Users</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon groups"><i class="fa-solid fa-user-group"></i></div>
                        </div>
                        <div class="stat-value"><asp:Label ID="lblTotalGroups" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-label">Total Groups</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects"><i class="fa-solid fa-folder-open"></i></div>
                        </div>
                        <div class="stat-value"><asp:Label ID="lblPendingProjects" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-label">Pending Projects</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-microchip"></i></div>
                        </div>
                        <div class="stat-value"><asp:Label ID="lblTotalTechs" runat="server" Text="0"></asp:Label></div>
                        <div class="stat-label">Registered Technologies</div>
                    </div>
                </div>

                
            </div>
        </div>
    </main>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
    </form>
</body>
</html>

