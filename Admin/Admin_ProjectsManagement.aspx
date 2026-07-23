<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_ProjectsManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_ProjectsManagement" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — Projects</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css" />
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
                <a href="<%= ResolveUrl("~/Admin/Admin_Dashboard.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href="<%= ResolveUrl("~/Admin/Admin_UserManagement.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-users"></i> Users Management
                </a>
                <a href="<%= ResolveUrl("~/Admin/Admin_GroupsManagement.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-user-group"></i> Groups
                </a>
                <a href="<%= ResolveUrl("~/Admin/Admin_ProjectsManagement.aspx") %>" class="nav-link active">
                    <i class="fa-solid fa-folder-open"></i> Projects
                </a>
                <a href="<%= ResolveUrl("~/Admin/Admin_TechManagement.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-microchip"></i> Technologies
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
                <input type="text" placeholder="Search projects...">
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
                        <h1>Projects Directory</h1>
                        <p>Track all UDP/IDP projects and their approval status.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>All Projects</h2>
                        <div class="section-actions">
                            <select class="form-control" style="width:auto; padding: 0.5rem;">
                                <option>All Status</option>
                                <option>Pending</option>
                                <option>Approved</option>
                                <option>Rejected</option>
                            </select>
                        </div>
                    </div>
                    <table>
                        <thead>
                            <tr>
                                <th>Title & Functionality</th>
                                <th>Group</th>
                                <th>Keywords</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptProjects" runat="server" OnItemCommand="rptProjects_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div style="max-width: 300px;">
                                                <strong><%# Eval("ProjectTitle") %></strong>
                                                <p style="font-size:0.75rem; color:var(--c-text-muted); margin-top:0.25rem;">
                                                    <%# Eval("Functionality") %>
                                                </p>
                                            </div>
                                        </td>
                                        <td><%# Eval("GroupName") %></td>
                                        <td>
                                            <%# Eval("KeywordHtml") %>
                                        </td>
                                        <td><span class='badge status-<%# Eval("Status").ToString().ToLower() %>'><%# Eval("Status") %></span></td>
                                        <td>
                                            <div class="table-actions">
                                                <asp:LinkButton ID="btnApprove" runat="server" CssClass="icon-btn" style="color:var(--c-green)" ToolTip="Approve" CommandName="Approve" CommandArgument='<%# Eval("ProjectId") %>' Visible='<%# Eval("Status").ToString() == "Pending" %>'>
                                                    <i class="fa-solid fa-check"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnReject" runat="server" CssClass="icon-btn" style="color:var(--c-red)" ToolTip="Reject" CommandName="Reject" CommandArgument='<%# Eval("ProjectId") %>' Visible='<%# Eval("Status").ToString() == "Pending" %>'>
                                                    <i class="fa-solid fa-xmark"></i>
                                                </asp:LinkButton>
                                                <a href='<%# ResolveUrl("~/Admin/Details/Project_Details.aspx?ProjectId=" + Eval("ProjectId")) %>' class="icon-btn" title="View Details">
                                                    <i class="fa-solid fa-eye" style="color: var(--c-primary);"></i>
                                                </a>
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

    <script src="<%= ResolveUrl("~/Admin/admin.js") %>"></script>
    </form>
</body>
</html>

