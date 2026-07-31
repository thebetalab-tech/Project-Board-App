<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_TaskManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_TaskManagement" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin — Global Task Management</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css?v=639200797339083061" />
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

        .btn-delete {
            background: rgba(239, 68, 68, 0.15);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
            padding: 0.3rem 0.7rem;
            border-radius: 6px;
            font-size: 0.8rem;
            cursor: pointer;
        }
        .btn-delete:hover {
            background: #ef4444;
            color: #fff;
        }
    </style>
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
                    <a href='<%= ResolveUrl("~/Admin/Admin_TaskManagement.aspx") %>' class="nav-link active">
                        <i class="fa-solid fa-list-check"></i> Tasks Management
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
                    <div class="avatar"><asp:Label ID="userintial" runat="server"></asp:Label></div>
                    <div class="user-info">
                        <h4><asp:Label ID="userNameLabel" runat="server"></asp:Label></h4>
                        <p><asp:Label ID="userEmailLabel" runat="server"></asp:Label></p>
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
                    <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Global Admin Task Management</h1>
                        <p>Global system visibility: Assign and oversee tasks across all groups, students, and faculty.</p>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; margin-bottom:1rem;"></asp:Label>

                <!-- GLOBAL TASK CREATION CARD -->
                <div class="stat-card" style="margin-bottom: 1.5rem;">
                    <h3><i class="fa-solid fa-plus-circle" style="color:var(--c-accent); margin-right:0.5rem;"></i> Create & Assign Global Task</h3>
                    <div class="form-grid" style="margin-top:1rem;">
                        <div class="form-group">
                            <label>Target Group</label>
                            <asp:DropDownList ID="ddlGroups" runat="server" CssClass="form-control"></asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <label>Assign To Any User (Student / Faculty / Leader)</label>
                            <asp:DropDownList ID="ddlAssignToUser" runat="server" CssClass="form-control"></asp:DropDownList>
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Task Title</label>
                            <asp:TextBox ID="txtTaskTitle" runat="server" CssClass="form-control" placeholder="Enter task title..."></asp:TextBox>
                        </div>
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Task Description</label>
                            <asp:TextBox ID="txtTaskDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" placeholder="Enter full task instructions..."></asp:TextBox>
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
                        <asp:Button ID="btnAdminCreateTask" runat="server" Text="Assign Global Task" CssClass="btn-primary" OnClick="btnAdminCreateTask_Click" />
                    </div>
                </div>

                <!-- GLOBAL TASKS LIST -->
                <div class="stat-card">
                    <h3><i class="fa-solid fa-globe" style="color:var(--c-accent); margin-right:0.5rem;"></i> All System Tasks</h3>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Task Title</th>
                                <th>Group</th>
                                <th>Assigned To</th>
                                <th>Assigned By</th>
                                <th>Level</th>
                                <th>Due Date</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptAdminTasks" runat="server" OnItemCommand="rptAdminTasks_ItemCommand">
                                <ItemTemplate>
                                    <tr>
                                        <td><strong><%# Eval("TaskTitle") %></strong></td>
                                        <td><%# Eval("GroupName") %></td>
                                        <td><%# Eval("AssignedToName") %></td>
                                        <td><%# Eval("AssignedByName") %></td>
                                        <td><span class="badge-status badge-progress"><%# Eval("TaskLevel") %></span></td>
                                        <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No Due Date" %></td>
                                        <td>
                                            <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "Appealed" ? "badge-appealed" : "badge-progress") %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>
                                        <td>
                                            <a href='<%# ResolveUrl("~/Faculty/TaskDetails.aspx?TaskId=" + Eval("TaskId")) %>' class="btn-primary" style="padding:0.3rem 0.6rem; font-size:0.75rem; text-decoration:none; margin-right:0.3rem;">
                                                <i class="fa-solid fa-eye"></i> View
                                            </a>
                                            <a href='<%# ResolveUrl("~/Admin/ReviewAppeal.aspx?TaskId=" + Eval("TaskId")) %>' class="btn-primary" style="padding:0.3rem 0.6rem; font-size:0.75rem; text-decoration:none; margin-right:0.3rem; background-color: var(--c-accent);" title="Review Appeal">
                                                <i class="fa-solid fa-gavel"></i> Appeal
                                            </a>
                                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn-delete" CommandName="DeleteTask" CommandArgument='<%# Eval("TaskId") %>' OnClientClick="return confirm('Are you sure you want to delete this task?');" />
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <asp:Label ID="lblNoTasks" runat="server" Text="No tasks found in the system." Visible="false" Style="display:block; padding:1rem; color:var(--c-text-dim); text-align:center;"></asp:Label>
                </div>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js") %>'></script>
</body>

</html>
