<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Mentor_TaskManagement.aspx.cs" Inherits="Project_Board.Admin.Mentor_TaskManagement" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mentor Task Management — Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css" />
    <style>
        .badge-status {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.35rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: capitalize;
        }
        .badge-pending { background-color: var(--c-yellow-bg); color: var(--c-yellow); border: 1px solid rgba(184, 134, 11, 0.2); }
        .badge-progress { background-color: var(--c-blue-bg); color: var(--c-blue); border: 1px solid rgba(43, 92, 143, 0.2); }
        .badge-completed { background-color: var(--c-green-bg); color: var(--c-green); border: 1px solid rgba(45, 125, 70, 0.2); }
        
        .badge-report-yes { background-color: rgba(45, 125, 70, 0.12); color: var(--c-green); padding: 0.25rem 0.6rem; border-radius: 12px; font-size: 0.75rem; font-weight: 600; }
        .badge-report-no { background-color: rgba(0, 0, 0, 0.05); color: var(--c-text-muted); padding: 0.25rem 0.6rem; border-radius: 12px; font-size: 0.75rem; }

        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(4px);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.active { display: flex; }
        .modal-box {
            background: var(--c-bg);
            border-radius: 16px;
            width: 100%;
            max-width: 600px;
            padding: 2rem;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--c-border);
            position: relative;
        }
        .modal-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.25rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid var(--c-border);
        }
        .modal-header h3 { font-family: var(--f-display); font-size: 1.25rem; color: var(--c-accent); }
        .close-btn { background: none; border: none; font-size: 1.25rem; cursor: pointer; color: var(--c-text-muted); }
        
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        .form-group.full-width { grid-column: span 2; }
        .form-group label {
            display: block;
            font-size: 0.8rem;
            font-weight: 600;
            margin-bottom: 0.4rem;
            color: var(--c-text);
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }
        .form-control {
            width: 100%;
            padding: 0.65rem 0.85rem;
            border-radius: 8px;
            border: 1px solid var(--c-border);
            font-family: var(--f-body);
            font-size: 0.875rem;
            background: var(--c-bg);
            color: var(--c-text);
            transition: var(--transition);
        }
        .form-control:focus {
            border-color: var(--c-accent);
            outline: none;
            box-shadow: 0 0 0 3px var(--c-accent-glow);
        }
        .btn-primary {
            background-color: var(--c-accent);
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.875rem;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        .btn-primary:hover { background-color: var(--c-accent-light); }
        .alert {
            padding: 0.85rem 1.25rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            font-size: 0.875rem;
            font-weight: 500;
        }
        .alert-success { background-color: var(--c-green-bg); color: var(--c-green); border: 1px solid rgba(45, 125, 70, 0.2); }
        .alert-danger { background-color: var(--c-red-bg); color: var(--c-red); border: 1px solid rgba(184, 41, 61, 0.2); }

        .report-box {
            background-color: var(--c-bg-warm);
            border-radius: 8px;
            padding: 1.25rem;
            border: 1px solid var(--c-border);
            margin-top: 1rem;
            white-space: pre-wrap;
            font-size: 0.9rem;
            line-height: 1.6;
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
                <% if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Faculty") { %>
                    <a href="<%= ResolveUrl("~/Faculty/Dashboard.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Dashboard
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/GroupManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-users-gear"></i> Group Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/ProjectManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-folder-tree"></i> Project Management
                    </a>
                    <a href="<%= ResolveUrl("~/Faculty/InvitationManager.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-envelope"></i> Mentor Requests
                    </a>
                    <a href="<%= ResolveUrl("~/Admin/Mentor_TaskManagement.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-list-check"></i> Tasks
                    </a>
                <% } else { %>
                    <a href="<%= ResolveUrl("~/Admin/Admin_Dashboard.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="<%= ResolveUrl("~/Admin/Admin_UserManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-users"></i> Users Management
                    </a>
                    <a href="<%= ResolveUrl("~/Admin/Admin_GroupsManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-user-group"></i> Groups
                    </a>
                    <a href="<%= ResolveUrl("~/Admin/Admin_ProjectsManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-folder-open"></i> Projects
                    </a>
                    <a href="<%= ResolveUrl("~/Admin/Admin_TechManagement.aspx") %>" class="nav-link">
                        <i class="fa-solid fa-microchip"></i> Technologies
                    </a>
                    <a href="<%= ResolveUrl("~/Admin/Mentor_TaskManagement.aspx") %>" class="nav-link active">
                        <i class="fa-solid fa-list-check"></i> Tasks
                    </a>
                <% } %>
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
        <div class="dashboard-container">
            <div class="view-section active">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Mentor Task Management</h1>
                        <p>Assign tasks to Student Leaders and track task progress & reports.</p>
                    </div>
                </div>

                <!-- STATS GRID -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-tasks"></i></div>
                        </div>
                        <div class="stat-value"><%= TotalTasks %></div>
                        <div class="stat-label">Total Assigned Tasks</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users" style="background: rgba(184,134,11,0.12); color: var(--c-yellow);"><i class="fa-solid fa-clock"></i></div>
                        </div>
                        <div class="stat-value"><%= PendingCount %></div>
                        <div class="stat-label">Pending Tasks</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects" style="background: rgba(43,92,143,0.12); color: var(--c-blue);"><i class="fa-solid fa-spinner"></i></div>
                        </div>
                        <div class="stat-value"><%= InProgressCount %></div>
                        <div class="stat-label">In Progress Tasks</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon groups" style="background: rgba(45,125,70,0.12); color: var(--c-green);"><i class="fa-solid fa-check-circle"></i></div>
                        </div>
                        <div class="stat-value"><%= CompletedCount %></div>
                        <div class="stat-label">Completed Tasks</div>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

                <!-- ASSIGN TASK CARD -->
                <div class="data-section" style="margin-bottom: 2rem;">
                    <div class="section-header">
                        <h2><i class="fa-solid fa-paper-plane" style="margin-right: 0.5rem; color: var(--c-accent);"></i> Send Task to Leader</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <div class="form-grid">
                            <div class="form-group full-width">
                                <label>Select Target Group & Leader</label>
                                <asp:DropDownList ID="ddlGroups" runat="server" CssClass="form-control"></asp:DropDownList>
                            </div>

                            <div class="form-group">
                                <label>Task Title</label>
                                <asp:TextBox ID="txtTaskTitle" runat="server" CssClass="form-control" Placeholder="e.g. Complete System Architecture & ER Diagram"></asp:TextBox>
                            </div>

                            <div class="form-group">
                                <label>Due Date</label>
                                <asp:TextBox ID="txtDueDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                            </div>

                            <div class="form-group full-width">
                                <label>Task Description & Instructions</label>
                                <asp:TextBox ID="txtTaskDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" Placeholder="Describe the task expectations and deliverables..."></asp:TextBox>
                            </div>
                        </div>

                        <asp:Button ID="btnCreateTask" runat="server" Text="Send Task to Leader" CssClass="btn-primary" OnClick="btnCreateTask_Click" />
                    </div>
                </div>

                <!-- TASKS & REPORTS TABLE -->
                <div class="data-section">
                    <div class="section-header">
                        <h2>Assigned Leader Tasks & Reports</h2>
                        <div class="section-actions" style="display: flex; gap: 0.75rem;">
                            <asp:DropDownList ID="ddlFilterGroup" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged" style="width: auto;">
                                <asp:ListItem Text="All Groups" Value=""></asp:ListItem>
                            </asp:DropDownList>

                            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged" style="width: auto;">
                                <asp:ListItem Text="All Statuses" Value=""></asp:ListItem>
                                <asp:ListItem Text="Pending" Value="Pending"></asp:ListItem>
                                <asp:ListItem Text="In Progress" Value="In Progress"></asp:ListItem>
                                <asp:ListItem Text="Completed" Value="Completed"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="table-container">
                        <asp:Repeater ID="rptMentorTasks" runat="server" OnItemCommand="rptMentorTasks_ItemCommand">
                            <HeaderTemplate>
                                <table class="modern-table">
                                    <thead>
                                        <tr>
                                            <th>Task Title</th>
                                            <th>Group</th>
                                            <th>Leader</th>
                                            <th>Due Date</th>
                                            <th>Status</th>
                                            <th>Leader Report</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <strong><%# Eval("TaskTitle") %></strong>
                                        <div style="font-size: 0.8rem; color: var(--c-text-muted); margin-top: 0.2rem;">
                                            <%# Eval("TaskDescription") != DBNull.Value && !string.IsNullOrEmpty(Eval("TaskDescription").ToString()) ? Eval("TaskDescription") : "No details" %>
                                        </div>
                                    </td>
                                    <td><%# Eval("GroupName") %></td>
                                    <td><%# Eval("AssignedToName") %></td>
                                    <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No due date" %></td>
                                    <td>
                                        <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "In Progress" ? "badge-progress" : "badge-pending") %>'>
                                            <i class='fa-solid <%# Eval("Status").ToString() == "Completed" ? "fa-check" : (Eval("Status").ToString() == "In Progress" ? "fa-spinner" : "fa-clock") %>'></i>
                                            <%# Eval("Status") %>
                                        </span>
                                    </td>
                                    <td>
                                        <%# Eval("ReportText") != DBNull.Value && !string.IsNullOrEmpty(Eval("ReportText").ToString()) 
                                            ? "<span class='badge-report-yes'><i class='fa-solid fa-file-lines'></i> Submitted</span>" 
                                            : "<span class='badge-report-no'><i class='fa-solid fa-hourglass-start'></i> Awaiting</span>" %>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="btnViewReport" runat="server" CommandName="ViewReport" CommandArgument='<%# Eval("TaskId") %>' CssClass="action-btn" ToolTip="View Report / Task Details" style="font-size:1rem; color:var(--c-blue);">
                                            <i class="fa-solid fa-eye"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnDeleteTask" runat="server" CommandName="DeleteTask" CommandArgument='<%# Eval("TaskId") %>' CssClass="action-btn" ToolTip="Delete Task" OnClientClick="return confirm('Are you sure you want to delete this task?');" style="font-size:1rem; color:var(--c-red);">
                                            <i class="fa-solid fa-trash"></i>
                                        </asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <asp:Label ID="lblNoTasks" runat="server" Text="No tasks found matching criteria." Visible="false" style="display:block; padding:2rem; text-align:center; color:var(--c-text-muted);"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- VIEW REPORT MODAL -->
    <div id="reportModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-header">
                <h3><i class="fa-solid fa-clipboard-check" style="color:var(--c-accent); margin-right:0.5rem;"></i> Task Details & Leader Report</h3>
                <button type="button" class="close-btn" onclick="closeModal('reportModal')">&times;</button>
            </div>
            <div>
                <h4 style="margin-bottom:0.5rem; font-size:1.1rem;"><asp:Label ID="lblModalTitle" runat="server"></asp:Label></h4>
                <p style="font-size:0.85rem; color:var(--c-text-muted); margin-bottom:1rem;">
                    Group: <strong><asp:Label ID="lblModalGroup" runat="server"></asp:Label></strong> &nbsp;|&nbsp; 
                    Leader: <strong><asp:Label ID="lblModalLeader" runat="server"></asp:Label></strong> &nbsp;|&nbsp;
                    Status: <strong><asp:Label ID="lblModalStatus" runat="server"></asp:Label></strong>
                </p>

                <div style="margin-bottom:1.25rem;">
                    <label style="font-size:0.75rem; font-weight:700; text-transform:uppercase; color:var(--c-text-dim);">Task Description</label>
                    <p style="font-size:0.9rem; margin-top:0.3rem;"><asp:Label ID="lblModalDescription" runat="server"></asp:Label></p>
                </div>

                <div style="border-top:1px solid var(--c-border); padding-top:1rem;">
                    <label style="font-size:0.75rem; font-weight:700; text-transform:uppercase; color:var(--c-text-dim);">Leader Progress Report</label>

                    <asp:Panel ID="pnlReportContent" runat="server">
                        <div class="report-box">
                            <asp:Label ID="lblModalReportText" runat="server"></asp:Label>
                        </div>
                        <p style="font-size:0.75rem; color:var(--c-text-muted); margin-top:0.5rem;">
                            <asp:Label ID="lblModalReportDate" runat="server"></asp:Label>
                        </p>
                    </asp:Panel>

                    <asp:Panel ID="pnlNoReport" runat="server">
                        <p style="font-size:0.875rem; color:var(--c-text-muted); font-style:italic; margin-top:0.5rem;">
                            No report has been submitted by the leader yet.
                        </p>
                    </asp:Panel>
                </div>
            </div>
            <div style="margin-top:1.5rem; text-align:right;">
                <button type="button" class="btn-primary" onclick="closeModal('reportModal')">Close</button>
            </div>
        </div>
    </div>

    </form>

    <script>
        function openModal(id) {
            document.getElementById(id).classList.add('active');
        }
        function closeModal(id) {
            document.getElementById(id).classList.remove('active');
        }
    </script>
</body>
</html>
