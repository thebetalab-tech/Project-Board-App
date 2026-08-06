<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Member_TaskManagement.aspx.cs" Inherits="Project_Board.Student.Member.Member_TaskManagement" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard - My Task Workspace</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../../Admin/admin.css" />
    <style>
        .badge-status {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.35rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-pending { background-color: var(--c-yellow-bg); color: var(--c-yellow); border: 1px solid rgba(184, 134, 11, 0.2); }
        .badge-progress { background-color: var(--c-blue-bg); color: var(--c-blue); border: 1px solid rgba(43, 92, 143, 0.2); }
        .badge-completed { background-color: var(--c-green-bg); color: var(--c-green); border: 1px solid rgba(45, 125, 70, 0.2); }
        .badge-appealed { background-color: rgba(138, 43, 226, 0.12); color: #8a2be2; border: 1px solid rgba(138, 43, 226, 0.2); }
        .badge-danger { background-color: var(--c-red-bg); color: var(--c-red); border: 1px solid rgba(184, 41, 61, 0.2); }

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
                <a href='<%= ResolveUrl("~/Student/Member/Dashboard.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href='<%= ResolveUrl("~/Student/Member/Member_Team.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-users"></i> Team & Mentor
                </a>
                <a href='<%= ResolveUrl("~/Student/Member/Member_Project.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-folder-open"></i> Project Details
                </a>
                <a href='<%= ResolveUrl("~/Student/Member/InvitationManager.aspx") %>' class="nav-link">
                    <i class="fa-solid fa-envelope"></i> Invitations
                </a>
                <a href='<%= ResolveUrl("~/Student/Member/Member_TaskManagement.aspx") %>' class="nav-link active">
                    <i class="fa-solid fa-list-check"></i> My Tasks
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
        <header class="topbar">
            <div class="search-bar" style="visibility: hidden;">
                <i class="fa-solid fa-search"></i>
                <input type="text" placeholder="Search...">
            </div>
            <div class="topbar-actions">
                <a href='<%= ResolveUrl("~/User/Profile.aspx") %>' class="action-btn" title="Profile">
                    <i class="fa-solid fa-user"></i>
                </a>
            </div>
        </header>

        <div class="dashboard-container">
            <div class="view-section active">
                <div class="page-header">
                    <div class="page-title">
                        <h1>My Task Workspace</h1>
                        <p>View tasks assigned to you by your Team Leader and update task progress & reports.</p>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" style="display:block; margin-bottom:1.5rem;"></asp:Label>

                <!-- STATS GRID -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-tasks"></i></div>
                        </div>
                        <div class="stat-value"><%= TotalTasks %></div>
                        <div class="stat-label">Assigned Tasks</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users" style="background: rgba(184,134,11,0.12); color: var(--c-yellow);"><i class="fa-solid fa-clock"></i></div>
                        </div>
                        <div class="stat-value"><%= PendingCount %></div>
                        <div class="stat-label">Pending</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects" style="background: rgba(43,92,143,0.12); color: var(--c-blue);"><i class="fa-solid fa-spinner"></i></div>
                        </div>
                        <div class="stat-value"><%= InProgressCount %></div>
                        <div class="stat-label">In Progress</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon groups" style="background: rgba(45,125,70,0.12); color: var(--c-green);"><i class="fa-solid fa-check-circle"></i></div>
                        </div>
                        <div class="stat-value"><%= CompletedCount %></div>
                        <div class="stat-label">Completed</div>
                    </div>
                </div>

                <!-- MENTOR MAIN PROJECT TASKS (GROUP OVERVIEW) -->
                <div class="data-section" style="margin-top: 1.5rem;">
                    <div class="section-header">
                        <h2><i class="fa-solid fa-layer-group" style="color:var(--c-accent); margin-right:0.5rem;"></i> Mentor's Tasks (Group Overview)</h2>
                    </div>
                    <div class="table-container">
                        <asp:Repeater ID="rptGroupMentorTasks" runat="server">
                            <HeaderTemplate>
                                <table class="modern-table">
                                    <thead>
                                        <tr>
                                            <th>Task Title & Description</th>
                                            <th>Points to Cover</th>
                                            <th>Due Date</th>
                                            <th>Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <strong><%# Eval("TaskTitle") %></strong>
                                        <div style="font-size: 0.8rem; color: var(--c-text-muted); margin-top: 0.2rem;">
                                            <%# Eval("TaskDescription") != DBNull.Value && !string.IsNullOrEmpty(Eval("TaskDescription").ToString()) ? Eval("TaskDescription") : "No description" %>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-size: 0.85rem; color: var(--c-text); max-width: 300px;">
                                            <%# Eval("PointsToCover") != DBNull.Value && !string.IsNullOrEmpty(Eval("PointsToCover").ToString()) ? Eval("PointsToCover") : "None specified" %>
                                        </div>
                                    </td>
                                    <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No due date" %></td>
                                    <td>
                                        <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "Appealed" ? "badge-appealed" : (Eval("Status").ToString() == "Revision Needed" || Eval("Status").ToString() == "Failed" ? "badge-danger" : "badge-progress")) %>'>
                                            <i class='fa-solid <%# Eval("Status").ToString() == "Completed" ? "fa-check" : (Eval("Status").ToString() == "Appealed" ? "fa-bell" : (Eval("Status").ToString() == "Revision Needed" ? "fa-triangle-exclamation" : "fa-clock")) %>'></i>
                                            <%# Eval("Status") %>
                                        </span>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                        <asp:Label ID="lblNoGroupMentorTasks" runat="server" Text="No main project tasks assigned to your group by mentor yet." Visible="false" style="display:block; padding:1.5rem; text-align:center; color:var(--c-text-muted);"></asp:Label>
                    </div>
                </div>

                <!-- MEMBER TASKS TABLE -->
                <div class="data-section" style="margin-top: 1.5rem;">
                    <div class="section-header">
                        <h2>My Assigned Tasks</h2>
                    </div>

                    <div class="table-container">
                        <asp:Repeater ID="rptMemberTasks" runat="server" OnItemCommand="rptMemberTasks_ItemCommand">
                            <HeaderTemplate>
                                <table class="modern-table">
                                    <thead>
                                        <tr>
                                            <th>Task Title</th>
                                            <th>Leader</th>
                                            <th>Due Date</th>
                                            <th>Status</th>
                                            <th>My Submitted Report</th>
                                            <th>Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <strong><%# Eval("TaskTitle") %></strong>
                                        <div style="font-size: 0.8rem; color: var(--c-text-muted); margin-top: 0.2rem;">
                                            <%# Eval("TaskDescription") != DBNull.Value && !string.IsNullOrEmpty(Eval("TaskDescription").ToString()) ? Eval("TaskDescription") : "No description" %>
                                        </div>
                                        <div style="font-size: 0.75rem; color: var(--c-accent); margin-top: 0.25rem; font-weight: 600;">
                                            <%# Eval("ParentTaskTitle") != DBNull.Value && !string.IsNullOrEmpty(Eval("ParentTaskTitle").ToString()) ? "<i class='fa-solid fa-link'></i> Subtask of: " + Eval("ParentTaskTitle") : "" %>
                                        </div>
                                    </td>
                                    <td><%# Eval("AssignedByName") %></td>
                                    <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No due date" %></td>
                                    <td>
                                        <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "Appealed" ? "badge-appealed" : (Eval("Status").ToString() == "Revision Needed" || Eval("Status").ToString() == "Failed" ? "badge-danger" : "badge-progress")) %>'>
                                            <i class='fa-solid <%# Eval("Status").ToString() == "Completed" ? "fa-check" : (Eval("Status").ToString() == "Appealed" ? "fa-bell" : (Eval("Status").ToString() == "Revision Needed" ? "fa-triangle-exclamation" : "fa-clock")) %>'></i>
                                            <%# Eval("Status") %>
                                        </span>
                                    </td>
                                    <td>
                                        <%# Eval("ReportText") != DBNull.Value && !string.IsNullOrEmpty(Eval("ReportText").ToString()) 
                                            ? "<span style='color:var(--c-green); font-weight:600;'><i class='fa-solid fa-check-circle'></i> Appeal Sent</span>" 
                                            : "<span style='color:var(--c-text-muted);'><i class='fa-solid fa-clock'></i> Working</span>" %>
                                    </td>
                                    <td>
                                        <asp:LinkButton ID="btnReport" runat="server" CommandName="ReportToLeader" CommandArgument='<%# Eval("TaskId") %>' Visible='<%# Eval("Status").ToString() != "Completed" %>' CssClass="btn-primary" style="padding:0.4rem 0.8rem; font-size:0.8rem;">
                                            <i class="fa-solid fa-flag"></i> Appeal Completion
                                        </asp:LinkButton>
                                        <button type="button" disabled="disabled" class="btn-primary" visible='<%# Eval("Status").ToString() == "Completed" %>' runat="server" style="padding:0.4rem 0.8rem; font-size:0.8rem; opacity:0.5; cursor:not-allowed; background-color:#64748b; border:1px solid #64748b;">
                                            <i class="fa-solid fa-flag"></i> Appeal Completion
                                        </button>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <asp:Label ID="lblNoTasks" runat="server" Text="No tasks currently assigned to you." Visible="false" style="display:block; padding:2rem; text-align:center; color:var(--c-text-muted);"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </main>



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
