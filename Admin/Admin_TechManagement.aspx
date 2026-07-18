<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_TechManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_TechManagement" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Technologies</title>
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
                <a href="Admin_GroupsManagement.aspx" class="nav-link">
                    <i class="fa-solid fa-user-group"></i> Groups
                </a>
                <a href="Admin_ProjectsManagement.aspx" class="nav-link">
                    <i class="fa-solid fa-folder-open"></i> Projects
                </a>
                <a href="Admin_TechManagement.aspx" class="nav-link active">
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
                <input type="text" placeholder="Search technologies...">
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
                        <h1>Technologies Master</h1>
                        <p>Manage the list of approved technologies for projects.</p>
                    </div>

                </div>

                <div class="data-section" style="max-width: 600px;">
                    <div class="section-header">
                        <h2>Available Technologies</h2>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Tech ID</th>
                                <th>Technology Name</th>
                                <th style="text-align: right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptTechs" runat="server" OnItemCommand="rptTechs_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td>#<%# Eval("TechId") %></td>
                                        <td><strong><%# Eval("TechName") %></strong></td>
                                        <td style="text-align: right;">
                                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="icon-btn delete" CommandName="DeleteTech" CommandArgument='<%# Eval("TechId") %>' OnClientClick="return confirm('Are you sure you want to delete this technology?');">
                                                <i class="fa-solid fa-trash"></i>
                                            </asp:LinkButton>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <div style="margin-top: 2rem; display: flex; gap: 1rem; align-items: center;">
                        <asp:TextBox ID="txtNewTech" runat="server" CssClass="form-control" placeholder="New Technology Name..." Width="300px"></asp:TextBox>
                        <asp:Button ID="btnAddTech" runat="server" Text="Add Technology" CssClass="btn-primary" OnClick="btnAddTech_Click" />
                    </div>
                    <asp:Label ID="lblMessage" runat="server" EnableViewState="false" style="display:block; margin-top: 1rem; font-weight: 500;"></asp:Label>
                </div>

                <div class="data-section" style="max-width: 800px; margin-top: 2rem;">
                    <div class="section-header">
                        <h2>Assign Technology to Faculty</h2>
                    </div>
                    
                    <div style="padding: 1.5rem; background-color: var(--c-bg-elevated); border-radius: 8px; border: 1px solid var(--c-border); margin-bottom: 2rem;">
                        <div style="display: flex; gap: 1rem; align-items: flex-end;">
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label>Faculty Member</label>
                                <asp:DropDownList ID="ddlFaculty" runat="server" CssClass="form-control"></asp:DropDownList>
                            </div>
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label>Technology</label>
                                <asp:DropDownList ID="ddlTech" runat="server" CssClass="form-control"></asp:DropDownList>
                            </div>
                            <asp:Button ID="btnAssign" runat="server" Text="Assign" CssClass="btn-primary" OnClick="btnAssign_Click" />
                        </div>
                        <asp:Label ID="lblAssignMessage" runat="server" EnableViewState="false" style="display:block; margin-top: 1rem; font-weight: 500;"></asp:Label>
                    </div>

                    <div class="section-header">
                        <h2>Current Assignments</h2>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Faculty Name</th>
                                <th>Assigned Technology</th>
                                <th style="text-align: right;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptFacultyTech" runat="server" OnItemCommand="rptTechs_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("FacultyName") %></strong></td>
                                        <td><%# Eval("TechName") %></td>
                                        <td style="text-align: right;">
                                            <asp:LinkButton ID="btnDeleteAssign" runat="server" CssClass="icon-btn delete" CommandName="DeleteAssignment" CommandArgument='<%# Eval("FacultyId") + "|" + Eval("TechId") %>' OnClientClick="return confirm('Are you sure you want to remove this assignment?');">
                                                <i class="fa-solid fa-trash"></i>
                                            </asp:LinkButton>
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

