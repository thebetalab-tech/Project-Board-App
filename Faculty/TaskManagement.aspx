<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TaskManagement.aspx.cs" Inherits="Project_Board.Faculty.TaskManagement" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faculty - Task Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <style>
        .badge-status {
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-completed { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
        .badge-appealed { background: rgba(168, 85, 247, 0.15); color: #a855f7; }
        .badge-danger { background: rgba(239, 68, 68, 0.15); color: #ef4444; }
        .badge-progress { background: rgba(59, 130, 246, 0.15); color: #3b82f6; }

        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1rem;
        }

        .data-table th, .data-table td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid var(--c-border);
        }

        .data-table th {
            color: var(--c-text-dim);
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 0.4rem;
        }

        .form-group label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--c-text);
        }

        .form-control {
            background: var(--c-bg);
            border: 1px solid var(--c-border);
            color: var(--c-text);
            padding: 0.6rem 0.8rem;
            border-radius: 8px;
            font-family: inherit;
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
                    <a href='<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> Project Management
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>' class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Mentor Requests
                    </a>
                    <a href='<%= ResolveUrl("~/Faculty/TaskManagement.aspx") %>' class="nav-link active">
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
                        <h4><%= UserName %></h4>
                        <p><%= UserEmail %></p>
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
                        <h1>Faculty Task Management</h1>
                        <p>Manage and assign tasks for your mentored groups and review appeals.</p>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; margin-bottom:1rem;"></asp:Label>

                <!-- TASK CREATION CARD -->
                <div class="stat-card" style="margin-bottom: 1.5rem;">
                    <h3><i class="fa-solid fa-plus-circle" style="color:var(--c-accent); margin-right:0.5rem;"></i> Create New Mentor Task</h3>
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label>Select Mentored Group</label>
                            <asp:DropDownList ID="ddlGroups" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlGroups_SelectedIndexChanged"></asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <label>Assign To Student / Leader</label>
                            <asp:DropDownList ID="ddlAssignee" runat="server" CssClass="form-control"></asp:DropDownList>
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Task Title</label>
                            <asp:TextBox ID="txtTaskTitle" runat="server" CssClass="form-control" placeholder="Enter task title..."></asp:TextBox>
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Task Description</label>
                            <asp:TextBox ID="txtTaskDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" placeholder="Enter detailed task instructions..."></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Points to Cover</label>
                            <asp:TextBox ID="txtPointsToCover" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control" placeholder="Key points or requirements..."></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Due Date</label>
                            <asp:TextBox ID="txtDueDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                        </div>
                    </div>
                    <div style="margin-top:1rem; text-align:right;">
                        <asp:Button ID="btnCreateTask" runat="server" Text="Create & Assign Task" CssClass="btn-primary" OnClick="btnCreateTask_Click" />
                    </div>
                </div>

                <!-- MENTORED GROUP TASKS LIST -->
                <div class="stat-card">
                    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem; margin-bottom:1rem; border-bottom:1px solid var(--c-border); padding-bottom:0.75rem;">
                        <h3><i class="fa-solid fa-tasks" style="color:var(--c-accent); margin-right:0.5rem;"></i> Mentored Group Tasks</h3>
                        <div style="display:flex; align-items:center; gap:0.5rem;">
                            <label style="font-size:0.85rem; font-weight:600; color:var(--c-text);">Filter by Group:</label>
                            <asp:DropDownList ID="ddlFilterGroup" runat="server" CssClass="form-control" style="width: auto; min-width: 220px;" AutoPostBack="true" OnSelectedIndexChanged="ddlFilterGroup_SelectedIndexChanged">
                            </asp:DropDownList>
                        </div>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Task Title</th>
                                <th>Group</th>
                                <th>Assigned To</th>
                                <th>Due Date</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptTasks" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("TaskTitle") %></strong></td>
                                        <td><%# Eval("GroupName") %></td>
                                        <td><%# Eval("AssignedToName") %></td>
                                        <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No Due Date" %></td>
                                        <td>
                                            <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "Appealed" ? "badge-appealed" : "badge-progress") %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>
                                        <td>
                                            <div class="table-actions">
                                                <a href='<%# ResolveUrl("~/Faculty/TaskDetails.aspx?TaskId=" + Eval("TaskId")) %>' class="icon-btn" title="View Details">
                                                    <i class="fa-solid fa-eye" style="color: var(--c-primary);"></i>
                                                </a>
                                                <a href='<%# ResolveUrl("~/Faculty/ReviewAppeal.aspx?TaskId=" + Eval("TaskId")) %>' class="icon-btn" title="Review Appeal">
                                                    <i class="fa-solid fa-gavel" style="color: var(--c-accent);"></i>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <asp:Label ID="lblNoTasks" runat="server" Text="No tasks found for your mentored groups." Visible="false" Style="display:block; padding:1rem; color:var(--c-text-dim); text-align:center;"></asp:Label>
                </div>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>

</html>
