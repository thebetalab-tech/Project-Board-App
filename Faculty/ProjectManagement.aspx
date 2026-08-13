<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProjectManagement.aspx.cs" Inherits="Project_Board.Faculty.ProjectManagement" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Board - Project Management</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:ital,wght@0,400;0,600;0,700;1,400&display=swap" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Premium editorial theme -->
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <style>
        .tag-pill {
            display: inline-block;
            background: rgba(59, 130, 246, 0.12);
            color: var(--c-accent, #3b82f6);
            border: 1px solid rgba(59, 130, 246, 0.3);
            padding: 0.15rem 0.5rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
            margin-right: 0.25rem;
            margin-top: 0.25rem;
        }
    </style>
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
                    <a href='<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/Analysis.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-chart-line"></i> Analysis & Reports
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="nav-link active">
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
                                <a href="<%= ResolveUrl("~/User/Profile.aspx") %>"><i class="fa-solid fa-key"></i> Change Password</a>
                                <a href="<%= ResolveUrl("~/Logout.aspx") %>"><i class="fa-solid fa-lock"></i> Log Out</a>
                            </div>
                        </div>
                    </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Project Proposals Management</h1>
                        <p>Review, approve, or decline group project proposals.</p>
                    </div>
                </div>
                
                <div class="data-section">
                    <div class="section-header" style="display:flex; justify-content:space-between; align-items:center;">
                        <h2>Group Project Proposals</h2>
                        <div style="display:flex; gap: 10px; align-items:center;">
                            <a href="javascript:void(0)" class="btn-secondary" onclick="openModal('reportModal')">
                                <i class="fa-solid fa-file-export"></i> Export Report
                            </a>
                            <div class="search-bar" style="width: 250px;">
                                <i class="fa-solid fa-search"></i>
                                <input type="text" id="searchProjects" placeholder="Filter projects...">
                            </div>
                        </div>
                    </div>
                    
                    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="form-message"></asp:Label>

                    <div class="table-responsive">
                        <table id="projectsTable">
                            <thead>
                                <tr>
                                    <th>Project Title & Keywords</th>
                                    <th>Group Name</th>
                                    <th>Type</th>
                                    <th>Submitted On</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptProjects" runat="server" OnItemCommand="rptProjects_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <strong style="font-size: 1rem;"><%# Eval("ProjectTitle") %></strong>
                                                <%# !string.IsNullOrWhiteSpace(Convert.ToString(Eval("Keywords"))) ? "<div style='margin-top:0.25rem;'>" + string.Join("", Eval("Keywords").ToString().Split(',').Select(k => "<span class=\"tag-pill\">" + k.Trim() + "</span>")) + "</div>" : "" %>
                                            </td>
                                            <td><%# Eval("GroupName") %></td>
                                            <td><%# Eval("ProjectType") %></td>
                                            <td><%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("MMM dd, yyyy") %></td>
                                            <td>
                                                <span class='badge status-<%# Eval("Status").ToString().ToLower() %>'><%# Eval("Status") %></span>
                                            </td>
                                            <td>
                                                <div class="table-actions" style="display:flex; gap:0.5rem;">
                                                    <asp:LinkButton ID="btnApprove" runat="server" CommandName="Approve" CommandArgument='<%# Eval("ProjectId") %>' CssClass="icon-btn" title="Approve Project" Visible='<%# Eval("Status").ToString() != "Approved" %>'>
                                                        <i class="fa-solid fa-check" style="color: var(--c-green, #22c55e);"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("ProjectId") %>' CssClass="icon-btn delete" title="Reject Project" Visible='<%# Eval("Status").ToString() != "Rejected" %>'>
                                                        <i class="fa-solid fa-xmark" style="color: #ef4444;"></i>
                                                    </asp:LinkButton>
                                                    <a href='<%# ResolveUrl("~/Faculty/Details/Project_Details.aspx?ProjectId=" + Eval("ProjectId")) %>' class="icon-btn" title="View Details">
                                                        <i class="fa-solid fa-eye" style="color: var(--c-primary, #3b82f6);"></i>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                        <%# rptProjects.Items.Count == 0 ? "<tr><td colspan='6' style='text-align:center; padding: 2rem; color: var(--c-text-muted);'>No project proposals submitted by your groups yet.</td></tr>" : "" %>
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
                <h2>Export Mentored Projects Report</h2>
                <button type="button" class="close-btn" onclick="closeModal('reportModal')"><i class="fa-solid fa-times"></i></button>
            </div>
            <div style="padding: 1.5rem;">
                <p style="margin-bottom: 1rem; color: var(--c-text-dim);">Select the columns you want to include in the PDF report:</p>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin-bottom: 1.5rem;">
                    <label><asp:CheckBox ID="chkColProjectTitle" runat="server" Checked="true" /> Project Title</label>
                    <label><asp:CheckBox ID="chkColKeywords" runat="server" Checked="true" /> Keywords</label>
                    <label><asp:CheckBox ID="chkColGroupName" runat="server" Checked="true" /> Group Name</label>
                    <label><asp:CheckBox ID="chkColProjectType" runat="server" Checked="true" /> Project Type</label>
                    <label><asp:CheckBox ID="chkColSubmittedOn" runat="server" Checked="true" /> Submitted On</label>
                    <label><asp:CheckBox ID="chkColStatus" runat="server" Checked="true" /> Status</label>
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
            initTableSearch('searchProjects', 'projectsTable');
        });
    </script>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>
</html>
