<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_UserManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_UserManagement" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Users</title>
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
                <a href='<%= ResolveUrl("~/Admin/Admin_Dashboard.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_Analysis.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-chart-line"></i> Analysis & Reports
                </a>
                <a href='<%= ResolveUrl("~/Admin/Admin_UserManagement.aspx") %>' class="nav-link active">
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
            <div class="search-bar">
                <i class="fa-solid fa-search"></i>
                <input type="text" placeholder="Search users...">
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
            <div class="view-section active">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Users Management</h1>
                        <p>Manage all students, faculty, and administrators.</p>
                    </div>
                    <button class="btn-primary" onclick="openModal('userModal')">
                        <i class="fa-solid fa-user-plus"></i> Add User
                    </button>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>All Users</h2>
                        <div style="display:flex; gap: 10px; align-items:center;">
                            <asp:DropDownList ID="ddlReportFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReportFilter_SelectedIndexChanged" CssClass="form-control" style="width:auto; padding: 0.5rem;">
                                <asp:ListItem Text="All Roles" Value="All"></asp:ListItem>
                                <asp:ListItem Text="Students" Value="Student"></asp:ListItem>
                                <asp:ListItem Text="Faculty" Value="Faculty"></asp:ListItem>
                                <asp:ListItem Text="Admins" Value="Admin"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:LinkButton ID="btnExportReport" runat="server" CssClass="btn-secondary" OnClick="btnExportReport_Click">
                                <i class="fa-solid fa-file-export"></i> Export Report
                            </asp:LinkButton>
                            <div class="search-bar" style="width: 250px;">
                                <i class="fa-solid fa-search"></i>
                                <input type="text" id="searchUsers" placeholder="Filter users...">
                            </div>
                        </div>
                    </div>
                    <table id="usersTable">
                        <thead>
                            <tr>
                                <th>User</th>
                                <th>Enrollment/ID</th>
                                <th>Role</th>
                                <th>Leader Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div class="user-cell">
                                                <div class="user-cell-avatar" style='<%# GetAvatarStyle(Eval("Role").ToString()) %>'>
                                                    <%# GetInitials(Eval("FullName").ToString()) %>
                                                </div>
                                                <div class="user-cell-info">
                                                    <h4><%# Eval("FullName") %></h4>
                                                    <p><%# Eval("Email") %></p>
                                                </div>
                                            </div>
                                        </td>
                                        <td><%# string.IsNullOrEmpty(Convert.ToString(Eval("EnrollmentNo"))) ? "N/A" : Eval("EnrollmentNo") %></td>
                                        <td><span class='badge <%# Eval("Role").ToString().ToLower() %>'><%# Eval("Role") %></span></td>
                                        <td>
                                            <%# Convert.ToBoolean(Eval("IsLeader")) ? "<i class='fa-solid fa-crown' style='color: var(--c-yellow);' title='Group Leader'></i> Yes" : "-" %>
                                        </td>
                                        <td>
                                            <div class="table-actions">
                                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="icon-btn delete" CommandName="DeleteUser" CommandArgument='<%# Eval("UserId") %>' OnClientClick="return confirm('Are you sure you want to deactivate this user?');">
                                                    <i class="fa-solid fa-trash"></i>
                                                </asp:LinkButton>
                                            </div>
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

    <!-- Modals -->
    <div class="modal-overlay" id="userModal">
        <div class="modal-content">
            <h2 style="margin-bottom: 1.5rem; font-family: var(--f-display);">Add New User</h2>
            <div id="addUserForm">
                <div class="form-group">
                    <label>Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Enter full name" Required="true"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label>Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="user@university.edu" Required="true"></asp:TextBox>
                </div>

                <div class="form-group" style="position:relative;">
                    <label>Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Create a temporary password" Required="true" style="padding-right:40px;"></asp:TextBox>
                    <button type="button" class="password-toggle" aria-label="Toggle password visibility" style="position:absolute; right:10px; top:35px; background:none; border:none; color:var(--text-secondary, #666); cursor:pointer;">
                        <svg class="eye-icon eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                            <circle cx="12" cy="12" r="3" />
                        </svg>
                        <svg class="eye-icon eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" width="18" height="18" style="display:none;">
                            <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                            <line x1="1" y1="1" x2="23" y2="23" />
                        </svg>
                    </button>
                </div>
                
                <div style="display:flex; gap:1rem;">
                    <div class="form-group" style="flex:1;">
                        <label>Enrollment / Faculty ID</label>
                        <asp:TextBox ID="txtEnrollment" runat="server" CssClass="form-control" placeholder="e.g. ENR2023..."></asp:TextBox>
                    </div>
                    
                    <div class="form-group" style="flex:1;">
                        <label>Role</label>
                        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Student">Student</asp:ListItem>
                            <asp:ListItem Value="Faculty">Faculty</asp:ListItem>
                            <asp:ListItem Value="Admin">Admin</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                
                <asp:Label ID="lblMessage" runat="server" ForeColor="#ff4d4d" EnableViewState="false" style="display:block;margin-bottom:10px;"></asp:Label>
                
                <div class="form-actions">
                    <button type="button" class="btn-secondary" onclick="closeModal('userModal')">Cancel</button>
                    <asp:Button ID="btnAddUser" runat="server" Text="Save User" CssClass="btn-primary" OnClick="btnAddUser_Click" />
                </div>
            </div>
        </div>
    </div>
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchUsers', 'usersTable');
        });
    </script>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
    </form>
</body>
</html>

