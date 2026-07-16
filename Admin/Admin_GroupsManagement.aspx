<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_GroupsManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_GroupsManagement" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Groups</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="admin.css">
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
                <a href="Admin_Dashboard.aspx" class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href="Admin_UserManagement.aspx" class="nav-link">
                    <i class="fa-solid fa-users"></i> Users Management
                </a>
                <a href="Admin_GroupsManagement.aspx" class="nav-link active">
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
                <a href="../User/Profile.aspx" class="nav-link">
                    <i class="fa-solid fa-user"></i> Profile
                </a>
                <a href="../Logout.aspx" class="nav-link">
                    <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                </a>
            </div>
        </nav>

        <div class="sidebar-footer">
                <!-- Fetch From Session -->
                <div class="avatar"><asp:Label ID="userintial" runat="server"></asp:Label></div>
                <div class="user-info" ID="userInfo">
                    <h4><asp:Label ID="userNameLabel" runat="server"></asp:Label></h4>
                    <p><asp:Label ID="userEmailLabel" runat="server"></asp:Label></p>
                </div>
            </div>
    </aside>

    <!-- MAIN CONTENT -->
    <main class="main-content">
        <header class="topbar">
            <div class="search-bar">
                <i class="fa-solid fa-search"></i>
                <input type="text" placeholder="Search groups...">
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
                        <h1>Groups</h1>
                        <p>View all student groups, members, and faculty mentors.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Group Details (Aggregated)</h2>
                        <button class="btn-secondary"><i class="fa-solid fa-file-export"></i> Export Report</button>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Group Name</th>
                                <th>Leader</th>
                                <th>Members</th>
                                <th>Faculty Mentor</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptGroups" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("GroupName") %></strong></td>
                                        <td><%# Eval("LeaderName") %></td>
                                        <td><%# string.IsNullOrEmpty(Eval("Members")?.ToString()) ? "<span style='color:var(--c-text-muted)'>None</span>" : Eval("Members") %></td>
                                        <td><%# Eval("MentorName") != DBNull.Value ? Eval("MentorName") : "<span style='color:var(--c-text-muted)'>Not Assigned</span>" %></td>
                                        <td>
                                            <span class='badge status-<%# Eval("Status").ToString().ToLower() %>'><%# Eval("Status") %></span>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
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

