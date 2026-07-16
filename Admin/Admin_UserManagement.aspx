<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_UserManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_UserManagement" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Users</title>
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
                <a href="Admin_Dashboard.aspx" class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href="Admin_UserManagement.aspx" class="nav-link active">
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
                <input type="text" placeholder="Search users...">
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
                        <div class="search-bar" style="width: 250px;">
                            <i class="fa-solid fa-search"></i>
                            <input type="text" placeholder="Filter users...">
                        </div>
                    </div>
                    <table>
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
                                        <td><%# string.IsNullOrEmpty(Eval("EnrollmentNo")?.ToString()) ? "N/A" : Eval("EnrollmentNo") %></td>
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

                <div class="form-group">
                    <label>Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Create a temporary password" Required="true"></asp:TextBox>
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
    <script src="admin.js"></script>
    </form>
</body>
</html>

