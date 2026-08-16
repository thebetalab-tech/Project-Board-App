<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GroupManagement.aspx.cs" Inherits="Project_Board.Faculty.GroupManagement" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board - Group Management</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2 class="sidebar-title">Project Board</h2>
                <button type="button" id="sidebarToggle" class="sidebar-toggle-btn" title="Toggle Sidebar">
                    <i class="fa-solid fa-bars"></i>
                </button>
            </div>
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <div class="nav-section-title">Main Menu</div>
                    <a href='<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> <span>Dashboard</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/Analysis.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-line"></i> <span>Analysis & Reports</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-users-gear"></i> <span>Group Management</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> <span>Project Management</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> <span>Mentor Requests</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/TaskManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-list-check"></i> <span>Tasks</span>
                    </a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-user"></i> <span>Profile</span>
                    </a>
                    <a href='<%= ResolveUrl("~/Logout.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> <span>Logout</span>
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
                                <a href="<%= ResolveUrl("~/User/Profile.aspx") %>"><i class="fa-solid fa-key"></i> <span>Change Password</span></a>
                                <a href="<%= ResolveUrl("~/Logout.aspx") %>"><i class="fa-solid fa-lock"></i> <span>Log Out</span></a>
                            </div>
                        </div>
                    </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Group Management</h1>
                        <p>Welcome to the Group Management section.</p>
                    </div>
                </div>
                
                                <div class="data-section">
                    <div class="section-header" style="display:flex; justify-content:space-between; align-items:center;">
                        <h2>Actively Mentored Groups</h2>
                        <div style="display:flex; gap: 10px; align-items:center;">
                            <a href="javascript:void(0)" class="btn-secondary" onclick="openModal('reportModal')">
                                <i class="fa-solid fa-file-export"></i> <span>Export Report</span>
                            </a>
                            <div class="search-bar" style="width: 250px;">
                                <i class="fa-solid fa-search"></i>
                                <input type="text" id="searchGroups" placeholder="Filter groups...">
                            </div>
                        </div>
                    </div>
                    
                    <div class="table-responsive">
                        <table id="groupsTable">
                            <thead>
                                <tr>
                                    <th>Group Name</th>
                                    <th>Leader Name</th>
                                    <th>Technology</th>
                                    <th>Team Size</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptGroups" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("GroupName") %></strong></td>
                                            <td><%# Eval("LeaderName") %></td>
                                            <td><span class="badge status-forming"><%# Eval("TechName") %></span></td>
                                            <td><%# Eval("MemberCount") %></td>
                                            <td>
                                                <div class="table-actions">
                                                    <a href='<%# ResolveUrl("~/Faculty/Details/Group_Details.aspx?GroupId=" + Eval("GroupId")) %>' class="icon-btn" title="View Details">
                                                        <i class="fa-solid fa-eye" style="color: var(--c-primary);"></i> <span> </span></a>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <%# rptGroups.Items.Count == 0 ? "<tr><td colspan='5' style='text-align:center; padding: 2rem; color: var(--c-text-muted);'>No active groups assigned to you at this time.</td></tr>" : "" %>
                                    </FooterTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    <!-- REPORT EXPORT MODAL -->
    <div id="reportModal" class="modal-overlay">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h2>Export Mentored Groups Report</h2>
                <button type="button" class="close-btn" onclick="closeModal('reportModal')"><i class="fa-solid fa-times"></i></button>
            </div>
            <div style="padding: 1.5rem;">
                <p style="margin-bottom: 1rem; color: var(--c-text-dim);">Select the columns you want to include in the PDF report:</p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr)); gap: 0.5rem; margin-bottom: 1.5rem;">
                    <label><asp:CheckBox ID="chkColGroupName" runat="server" Checked="true" /> Group Name</label>
                    <label><asp:CheckBox ID="chkColLeaderName" runat="server" Checked="true" /> Leader Name</label>
                    <label><asp:CheckBox ID="chkColTechnology" runat="server" Checked="true" /> Technology</label>
                    <label><asp:CheckBox ID="chkColTeamSize" runat="server" Checked="true" /> Team Size</label>
                </div>
                <div style="text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('reportModal')">Cancel</button>
                    <asp:Button ID="btnGeneratePdf" runat="server" Text="Generate PDF" CssClass="btn-primary" OnClick="btnGeneratePdf_Click" />
                </div>
            </div>
        </div>
    </div>
    </form>
    
    <!-- Mobile toggle script -->
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchGroups', 'groupsTable');
        });
    </script>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>
</html>


