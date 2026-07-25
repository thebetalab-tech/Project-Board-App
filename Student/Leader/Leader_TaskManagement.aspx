<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_TaskManagement.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_TaskManagement" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader Task Management — Project Board</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link runat="server" rel="stylesheet" href="~/Admin/admin.css" />
    <style>
        .tab-nav {
            display: flex;
            gap: 1rem;
            border-bottom: 2px solid var(--c-border);
            margin-bottom: 1.5rem;
        }
        .tab-btn {
            padding: 0.75rem 1.25rem;
            background: none;
            border: none;
            border-bottom: 3px solid transparent;
            font-family: var(--f-body);
            font-weight: 600;
            font-size: 0.95rem;
            color: var(--c-text-muted);
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        .tab-btn.active {
            color: var(--c-accent);
            border-bottom-color: var(--c-accent);
        }
        .tab-content { display: none; }
        .tab-content.active { display: block; }

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
            <div class="logo-icon"><i class="fa-solid fa-user-tie" style="color: white;"></i></div>
            <h2>Project Board</h2>
        </div>
        
        <nav class="sidebar-nav">
            <div class="nav-section">
                <div class="nav-section-title">Main Menu</div>
                <a href="<%= ResolveUrl("~/Student/Leader/Dashboard.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-chart-pie"></i> Overview
                </a>
                <a href="<%= ResolveUrl("~/Student/Leader/Leader_Members.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-users"></i> Team Members
                </a>
                <a href="<%= ResolveUrl("~/Student/Leader/Leader_Mentor.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                </a>
                <a href="<%= ResolveUrl("~/Student/Leader/InvitationManager.aspx") %>" class="nav-link">
                    <i class="fa-solid fa-envelope"></i> Invitations
                </a>
                <a href="<%= ResolveUrl("~/Student/Leader/Leader_TaskManagement.aspx") %>" class="nav-link active">
                    <i class="fa-solid fa-list-check"></i> Tasks
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
                        <h1>Leader Task Hub (<%= GroupName %>)</h1>
                        <p>Manage mentor tasks, report status to mentor, and assign subtasks to team members.</p>
                    </div>
                </div>

                <!-- STATS GRID -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon tech"><i class="fa-solid fa-inbox"></i></div>
                        </div>
                        <div class="stat-value"><%= TotalMentorTasks %></div>
                        <div class="stat-label">Mentor Tasks Received</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon users" style="background: rgba(184,134,11,0.12); color: var(--c-yellow);"><i class="fa-solid fa-clock"></i></div>
                        </div>
                        <div class="stat-value"><%= PendingMentorTasks %></div>
                        <div class="stat-label">Pending Mentor Tasks</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon projects" style="background: rgba(43,92,143,0.12); color: var(--c-blue);"><i class="fa-solid fa-list-check"></i></div>
                        </div>
                        <div class="stat-value"><%= TotalMemberTasks %></div>
                        <div class="stat-label">Member Tasks Assigned</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-header">
                            <div class="stat-icon groups" style="background: rgba(45,125,70,0.12); color: var(--c-green);"><i class="fa-solid fa-check-double"></i></div>
                        </div>
                        <div class="stat-value"><%= MemberTasksCompleted %></div>
                        <div class="stat-label">Member Tasks Done</div>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

                <!-- TAB NAVIGATION -->
                <div class="tab-nav">
                    <button type="button" class="tab-btn active" onclick="switchTab('mentorTasksTab', this)">
                        <i class="fa-solid fa-chalkboard-user"></i> Received Tasks from Mentor (<%= TotalMentorTasks %>)
                    </button>
                    <button type="button" class="tab-btn" onclick="switchTab('memberTasksTab', this)">
                        <i class="fa-solid fa-users"></i> Tasks Assigned to Members (<%= TotalMemberTasks %>)
                    </button>
                </div>

                <!-- TAB 1: MENTOR TASKS -->
                <div id="mentorTasksTab" class="tab-content active">
                    <div class="data-section">
                        <div class="section-header">
                            <h2>Tasks From Mentor</h2>
                        </div>
                        <div class="table-container">
                            <asp:Repeater ID="rptMentorTasks" runat="server" OnItemCommand="rptMentorTasks_ItemCommand">
                                <HeaderTemplate>
                                    <table class="modern-table">
                                        <thead>
                                            <tr>
                                                <th>Task Title</th>
                                                <th>Assigned By</th>
                                                <th>Due Date</th>
                                                <th>Status</th>
                                                <th>Submitted Report</th>
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
                                        </td>
                                        <td><%# Eval("AssignedByName") %></td>
                                        <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No due date" %></td>
                                        <td>
                                            <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "In Progress" ? "badge-progress" : "badge-pending") %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>
                                        <td>
                                            <%# Eval("ReportText") != DBNull.Value && !string.IsNullOrEmpty(Eval("ReportText").ToString()) 
                                                ? "<span style='color:var(--c-green); font-weight:600;'><i class='fa-solid fa-check-circle'></i> Report Sent</span>" 
                                                : "<span style='color:var(--c-text-muted);'><i class='fa-solid fa-clock'></i> Pending Report</span>" %>
                                        </td>
                                        <td>
                                            <asp:LinkButton ID="btnReport" runat="server" CommandName="ReportToMentor" CommandArgument='<%# Eval("TaskId") %>' CssClass="btn-primary" style="padding:0.4rem 0.8rem; font-size:0.8rem;">
                                                <i class="fa-solid fa-pen-to-square"></i> Report & Update
                                            </asp:LinkButton>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>

                            <asp:Label ID="lblNoMentorTasks" runat="server" Text="No tasks received from Mentor yet." Visible="false" style="display:block; padding:2rem; text-align:center; color:var(--c-text-muted);"></asp:Label>
                        </div>
                    </div>
                </div>

                <!-- TAB 2: MEMBER TASKS -->
                <div id="memberTasksTab" class="tab-content">
                    <!-- ASSIGN TASK TO MEMBER CARD -->
                    <div class="data-section" style="margin-bottom: 2rem;">
                        <div class="section-header">
                            <h2><i class="fa-solid fa-user-plus" style="margin-right:0.5rem; color:var(--c-accent);"></i> Assign Task to Team Member</h2>
                        </div>
                        <div style="padding: 1.5rem;">
                            <div class="form-grid">
                                <div class="form-group">
                                    <label>Select Team Member</label>
                                    <asp:DropDownList ID="ddlMembers" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>

                                <div class="form-group">
                                    <label>Task Title</label>
                                    <asp:TextBox ID="txtMemberTaskTitle" runat="server" CssClass="form-control" Placeholder="e.g. Develop User Registration module"></asp:TextBox>
                                </div>

                                <div class="form-group">
                                    <label>Due Date</label>
                                    <asp:TextBox ID="txtMemberTaskDueDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                                </div>

                                <div class="form-group full-width">
                                    <label>Task Description / Deliverables</label>
                                    <asp:TextBox ID="txtMemberTaskDescription" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" Placeholder="Details on what the member needs to build or research..."></asp:TextBox>
                                </div>
                            </div>

                            <asp:Button ID="btnAssignMemberTask" runat="server" Text="Assign Task to Member" CssClass="btn-primary" OnClick="btnAssignMemberTask_Click" />
                        </div>
                    </div>

                    <!-- MEMBER TASKS GRID -->
                    <div class="data-section">
                        <div class="section-header">
                            <h2>Assigned Member Tasks & Progress</h2>
                        </div>
                        <div class="table-container">
                            <asp:Repeater ID="rptMemberTasks" runat="server" OnItemCommand="rptMemberTasks_ItemCommand">
                                <HeaderTemplate>
                                    <table class="modern-table">
                                        <thead>
                                            <tr>
                                                <th>Task Title</th>
                                                <th>Assigned Member</th>
                                                <th>Due Date</th>
                                                <th>Status</th>
                                                <th>Member Report</th>
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
                                                <%# Eval("TaskDescription") != DBNull.Value && !string.IsNullOrEmpty(Eval("TaskDescription").ToString()) ? Eval("TaskDescription") : "No description" %>
                                            </div>
                                        </td>
                                        <td><%# Eval("AssignedToName") %></td>
                                        <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No due date" %></td>
                                        <td>
                                            <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "In Progress" ? "badge-progress" : "badge-pending") %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>
                                        <td>
                                            <%# Eval("ReportText") != DBNull.Value && !string.IsNullOrEmpty(Eval("ReportText").ToString()) 
                                                ? "<span style='color:var(--c-green); font-weight:600;'><i class='fa-solid fa-file-lines'></i> Report Submitted</span>" 
                                                : "<span style='color:var(--c-text-muted);'><i class='fa-solid fa-hourglass-start'></i> Pending</span>" %>
                                        </td>
                                        <td>
                                            <asp:LinkButton ID="btnViewMemberReport" runat="server" CommandName="ViewMemberReport" CommandArgument='<%# Eval("TaskId") %>' CssClass="action-btn" ToolTip="View Report" style="font-size:1rem; color:var(--c-blue);">
                                                <i class="fa-solid fa-eye"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnDeleteMemberTask" runat="server" CommandName="DeleteMemberTask" CommandArgument='<%# Eval("TaskId") %>' CssClass="action-btn" ToolTip="Delete Task" OnClientClick="return confirm('Delete this task?');" style="font-size:1rem; color:var(--c-red);">
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

                            <asp:Label ID="lblNoMemberTasks" runat="server" Text="No tasks assigned to team members yet." Visible="false" style="display:block; padding:2rem; text-align:center; color:var(--c-text-muted);"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- UPDATE & REPORT TO MENTOR MODAL -->
    <div id="reportMentorModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-header">
                <h3><i class="fa-solid fa-paper-plane" style="color:var(--c-accent); margin-right:0.5rem;"></i> Report Task Progress to Mentor</h3>
                <button type="button" class="close-btn" onclick="closeModal('reportMentorModal')">&times;</button>
            </div>
            <div>
                <asp:HiddenField ID="hfReportTaskId" runat="server" />
                <h4 style="margin-bottom:1rem; font-size:1.1rem;"><asp:Label ID="lblMentorModalTaskTitle" runat="server"></asp:Label></h4>

                <div class="form-group" style="margin-bottom:1.25rem;">
                    <label>Update Status</label>
                    <asp:DropDownList ID="ddlUpdateStatus" runat="server" CssClass="form-control">
                        <asp:ListItem Text="Pending" Value="Pending"></asp:ListItem>
                        <asp:ListItem Text="In Progress" Value="In Progress"></asp:ListItem>
                        <asp:ListItem Text="Completed" Value="Completed"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <label>Progress Report / Remarks for Mentor</label>
                    <asp:TextBox ID="txtLeaderReportText" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control" Placeholder="Describe progress, completed modules, or any blockers for your Mentor..."></asp:TextBox>
                </div>
            </div>
            <div style="margin-top:1.5rem; text-align:right; display:flex; gap:0.75rem; justify-content:flex-end;">
                <button type="button" class="btn-primary" style="background-color:var(--c-surface); color:var(--c-text);" onclick="closeModal('reportMentorModal')">Cancel</button>
                <asp:Button ID="btnSubmitReportToMentor" runat="server" Text="Submit Report to Mentor" CssClass="btn-primary" OnClick="btnSubmitReportToMentor_Click" />
            </div>
        </div>
    </div>

    <!-- VIEW MEMBER REPORT MODAL -->
    <div id="viewMemberModal" class="modal-overlay">
        <div class="modal-box">
            <div class="modal-header">
                <h3><i class="fa-solid fa-file-invoice" style="color:var(--c-accent); margin-right:0.5rem;"></i> Member Task & Report Details</h3>
                <button type="button" class="close-btn" onclick="closeModal('viewMemberModal')">&times;</button>
            </div>
            <div>
                <h4 style="margin-bottom:0.5rem; font-size:1.1rem;"><asp:Label ID="lblViewMemberModalTaskTitle" runat="server"></asp:Label></h4>
                <p style="font-size:0.85rem; color:var(--c-text-muted); margin-bottom:1rem;">
                    Assigned Member: <strong><asp:Label ID="lblViewMemberModalMember" runat="server"></asp:Label></strong> &nbsp;|&nbsp;
                    Status: <strong><asp:Label ID="lblViewMemberModalStatus" runat="server"></asp:Label></strong>
                </p>

                <div style="margin-bottom:1.25rem;">
                    <label style="font-size:0.75rem; font-weight:700; text-transform:uppercase; color:var(--c-text-dim);">Task Description</label>
                    <p style="font-size:0.9rem; margin-top:0.3rem;"><asp:Label ID="lblViewMemberModalDesc" runat="server"></asp:Label></p>
                </div>

                <div style="border-top:1px solid var(--c-border); padding-top:1rem;">
                    <label style="font-size:0.75rem; font-weight:700; text-transform:uppercase; color:var(--c-text-dim);">Member's Report</label>

                    <asp:Panel ID="pnlMemberReportContent" runat="server">
                        <div class="report-box">
                            <asp:Label ID="lblViewMemberModalReportText" runat="server"></asp:Label>
                        </div>
                        <p style="font-size:0.75rem; color:var(--c-text-muted); margin-top:0.5rem;">
                            <asp:Label ID="lblViewMemberModalReportDate" runat="server"></asp:Label>
                        </p>
                    </asp:Panel>

                    <asp:Panel ID="pnlNoMemberReport" runat="server">
                        <p style="font-size:0.875rem; color:var(--c-text-muted); font-style:italic; margin-top:0.5rem;">
                            No report submitted by the member yet.
                        </p>
                    </asp:Panel>
                </div>
            </div>
            <div style="margin-top:1.5rem; text-align:right;">
                <button type="button" class="btn-primary" onclick="closeModal('viewMemberModal')">Close</button>
            </div>
        </div>
    </div>

    </form>

    <script>
        function switchTab(tabId, btn) {
            document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
            document.getElementById(tabId).classList.add('active');
            btn.classList.add('active');
        }
        function openModal(id) {
            document.getElementById(id).classList.add('active');
        }
        function closeModal(id) {
            document.getElementById(id).classList.remove('active');
        }
    </script>
</body>
</html>
