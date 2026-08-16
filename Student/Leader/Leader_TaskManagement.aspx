<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_TaskManagement.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_TaskManagement" MasterPageFile="~/Student/Leader/Leader.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leader Task Management — Project Board
</asp:Content>
<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
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

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr));
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
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
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
                        <div class="section-header" style="display:flex; justify-content:space-between; align-items:center;">
                            <h2>Tasks From Mentor</h2>
                            <div style="display:flex; gap:10px; align-items:center;">
                                <a href="javascript:void(0)" class="btn-secondary" onclick="openModal('reportModalMentor')">
                                    <i class="fa-solid fa-file-export"></i> Export Report
                                </a>
                                <div class="search-bar" style="width: 250px;">
                                    <i class="fa-solid fa-search"></i>
                                    <input type="text" id="searchMentorTasks" placeholder="Filter mentor tasks...">
                                </div>
                            </div>
                        </div>
                        <div class="table-container">
                            <asp:Repeater ID="rptMentorTasks" runat="server" OnItemCommand="rptMentorTasks_ItemCommand">
                                <HeaderTemplate>
                                    <table class="modern-table" id="mentorTasksTable">
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
                                            <asp:LinkButton ID="btnReport" runat="server" CommandName="ReportToMentor" CommandArgument='<%# Eval("TaskId") %>' Visible='<%# Eval("Status").ToString() != "Completed" %>' CssClass="btn-primary" style="padding:0.4rem 0.8rem; font-size:0.8rem;">
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
                                    <label>Task Category</label>
                                    <asp:DropDownList ID="ddlTaskCategory" runat="server" CssClass="form-control">
                                        <asp:ListItem Text="Normal Task" Value="Normal Task"></asp:ListItem>
                                        <asp:ListItem Text="Project Task" Value="Project Task"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="form-group">
                                    <label>Link to Mentor Task (Optional Subtask)</label>
                                    <asp:DropDownList ID="ddlParentTask" runat="server" CssClass="form-control"></asp:DropDownList>
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
                        <div class="section-header" style="display:flex; justify-content:space-between; align-items:center;">
                            <h2>Assigned Member Tasks & Progress</h2>
                            <div style="display:flex; gap:10px; align-items:center;">
                                <a href="javascript:void(0)" class="btn-secondary" onclick="openModal('reportModalMember')">
                                    <i class="fa-solid fa-file-export"></i> Export Report
                                </a>
                                <div class="search-bar" style="width: 250px;">
                                    <i class="fa-solid fa-search"></i>
                                    <input type="text" id="searchMemberTasks" placeholder="Filter member tasks...">
                                </div>
                            </div>
                        </div>
                        <div class="table-container">
                            <asp:Repeater ID="rptMemberTasks" runat="server" OnItemCommand="rptMemberTasks_ItemCommand">
                                <HeaderTemplate>
                                    <table class="modern-table" id="memberTasksTable">
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
                                            <div style="font-size: 0.75rem; color: var(--c-accent); margin-top: 0.25rem; font-weight: 600;">
                                                <%# Eval("ParentTaskTitle") != DBNull.Value && !string.IsNullOrEmpty(Eval("ParentTaskTitle").ToString()) ? "<i class='fa-solid fa-link'></i> Subtask of: " + Eval("ParentTaskTitle") : "" %>
                                            </div>
                                        </td>
                                        <td><%# Eval("AssignedToName") %></td>
                                        <td><%# Eval("DueDate") != DBNull.Value ? Convert.ToDateTime(Eval("DueDate")).ToString("MMM dd, yyyy") : "No due date" %></td>
                                        <td>
                                            <span class='badge-status <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : (Eval("Status").ToString() == "Appealed" ? "badge-appealed" : (Eval("Status").ToString() == "Revision Needed" || Eval("Status").ToString() == "Failed" ? "badge-danger" : "badge-progress")) %>'>
                                                <i class='fa-solid <%# Eval("Status").ToString() == "Completed" ? "fa-check" : (Eval("Status").ToString() == "Appealed" ? "fa-bell" : (Eval("Status").ToString() == "Revision Needed" ? "fa-triangle-exclamation" : "fa-clock")) %>'></i>
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
            </div>        </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <!-- REPORT EXPORT MODALS -->
    <div id="reportModalMentor" class="modal-overlay">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h2>Export Mentor Tasks Report</h2>
                <button type="button" class="close-btn" onclick="closeModal('reportModalMentor')"><i class="fa-solid fa-times"></i></button>
            </div>
            <div style="padding: 1.5rem;">
                <p style="margin-bottom: 1rem; color: var(--c-text-dim);">Select the columns you want to include in the PDF report:</p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr)); gap: 0.5rem; margin-bottom: 1.5rem;">
                    <label><asp:CheckBox ID="chkMentorColTaskTitle" runat="server" Checked="true" /> Task Title</label>
                    <label><asp:CheckBox ID="chkMentorColDescription" runat="server" Checked="true" /> Description</label>
                    <label><asp:CheckBox ID="chkMentorColAssignedBy" runat="server" Checked="true" /> Assigned By</label>
                    <label><asp:CheckBox ID="chkMentorColDueDate" runat="server" Checked="true" /> Due Date</label>
                    <label><asp:CheckBox ID="chkMentorColStatus" runat="server" Checked="true" /> Status</label>
                </div>
                <div style="text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('reportModalMentor')">Cancel</button>
                    <asp:Button ID="btnGenerateMentorPdf" runat="server" Text="Generate PDF" CssClass="btn-primary" OnClick="btnGenerateMentorPdf_Click" />
                </div>
            </div>
        </div>
    </div>

    <div id="reportModalMember" class="modal-overlay">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h2>Export Member Tasks Report</h2>
                <button type="button" class="close-btn" onclick="closeModal('reportModalMember')"><i class="fa-solid fa-times"></i></button>
            </div>
            <div style="padding: 1.5rem;">
                <p style="margin-bottom: 1rem; color: var(--c-text-dim);">Select the columns you want to include in the PDF report:</p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr)); gap: 0.5rem; margin-bottom: 1.5rem;">
                    <label><asp:CheckBox ID="chkMemberColTaskTitle" runat="server" Checked="true" /> Task Title</label>
                    <label><asp:CheckBox ID="chkMemberColDescription" runat="server" Checked="true" /> Description</label>
                    <label><asp:CheckBox ID="chkMemberColAssignedTo" runat="server" Checked="true" /> Assigned Member</label>
                    <label><asp:CheckBox ID="chkMemberColDueDate" runat="server" Checked="true" /> Due Date</label>
                    <label><asp:CheckBox ID="chkMemberColStatus" runat="server" Checked="true" /> Status</label>
                </div>
                <div style="text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('reportModalMember')">Cancel</button>
                    <asp:Button ID="btnGenerateMemberPdf" runat="server" Text="Generate PDF" CssClass="btn-primary" OnClick="btnGenerateMemberPdf_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchMentorTasks', 'mentorTasksTable');
            initTableSearch('searchMemberTasks', 'memberTasksTable');
        });
    </script>

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
</asp:Content>
