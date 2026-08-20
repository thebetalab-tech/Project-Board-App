<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_TaskManagement.aspx.cs" Inherits="Project_Board.Admin.Admin_TaskManagement" MasterPageFile="~/Admin/Admin.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Dashboard — Tasks
</asp:Content>
<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
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
            word-break: break-word;
            overflow-wrap: anywhere;
        }

        .data-table th {
            color: var(--c-text-dim);
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr));
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
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

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
                        <div class="form-group" style="grid-column: span 2;">
                            <label>Select Target Group & Leader</label>
                            <asp:DropDownList ID="ddlGroups" runat="server" CssClass="form-control"></asp:DropDownList>
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
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                        <h3><i class="fa-solid fa-globe" style="color:var(--c-accent); margin-right:0.5rem;"></i> All System Tasks</h3>
                        <div style="display:flex; gap: 10px; align-items:center;">
                            <asp:DropDownList ID="ddlReportFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReportFilter_SelectedIndexChanged" CssClass="form-control" style="width:auto; padding: 0.5rem;">
                                <asp:ListItem Text="All Tasks" Value="All"></asp:ListItem>
                                <asp:ListItem Text="Completed" Value="Completed"></asp:ListItem>
                                <asp:ListItem Text="In Progress" Value="In Progress"></asp:ListItem>
                                <asp:ListItem Text="Appealed" Value="Appealed"></asp:ListItem>
                            </asp:DropDownList>
                            <a href="javascript:void(0)" class="btn-secondary" onclick="openModal('reportModal')">
                                <i class="fa-solid fa-file-export"></i> Export Report
                            </a>
                            <div class="search-bar" style="width: 250px;">
                                <i class="fa-solid fa-search"></i>
                                <input type="text" id="searchTasks" placeholder="Filter tasks...">
                            </div>
                        </div>
                    </div>
                    <table class="data-table" id="tasksTable">
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
                                            <div class="table-actions">
                                                <button type="button" class="icon-btn edit" onclick="openEditTaskModal('<%# Eval("TaskId") %>', '<%# HttpUtility.JavaScriptStringEncode(Eval("TaskTitle").ToString()) %>', '<%# HttpUtility.JavaScriptStringEncode(Eval("TaskDescription").ToString()) %>', '<%# Eval("Status") %>')" style="color:var(--c-primary); background:none; border:none; cursor:pointer;" title="Edit Task">
                                                    <i class="fa-solid fa-edit"></i>
                                                </button>
                                                <a href='<%# ResolveUrl("~/Faculty/TaskDetails.aspx?TaskId=" + Eval("TaskId")) %>' class="icon-btn" title="View Details">
                                                    <i class="fa-solid fa-eye" style="color: var(--c-primary);"></i>
                                                </a>
                                                <a href='<%# ResolveUrl("~/Admin/ReviewAppeal.aspx?TaskId=" + Eval("TaskId")) %>' class="icon-btn" title="Review Appeal">
                                                    <i class="fa-solid fa-gavel" style="color: var(--c-accent);"></i>
                                                </a>
                                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="icon-btn" CommandName="DeleteTask" CommandArgument='<%# Eval("TaskId") %>' OnClientClick="return confirm('Are you sure you want to delete this task?');" title="Delete Task" style="color: var(--c-red);">
                                                    <i class="fa-solid fa-trash"></i>
                                                </asp:LinkButton>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                    <asp:Label ID="lblNoTasks" runat="server" Text="No tasks found in the system." Visible="false" Style="display:block; padding:1rem; color:var(--c-text-dim); text-align:center;"></asp:Label>
                </div>

            </div>
            
    <!-- Edit Task Modal -->
    <div class="modal-overlay" id="editTaskModal">
        <div class="modal-content" style="max-width: 500px;">
            <h2 style="margin-bottom: 1.5rem; font-family: var(--f-display);">Edit Task</h2>
            <asp:HiddenField ID="hdnEditTaskId" runat="server" />
            <div id="editTaskForm">
                <div class="form-group">
                    <label>Task Title</label>
                    <asp:TextBox ID="txtEditTaskTitle" runat="server" CssClass="form-control"></asp:TextBox>
                </div>
                
                <div class="form-group" style="margin-top:1rem;">
                    <label>Description</label>
                    <asp:TextBox ID="txtEditTaskDesc" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control"></asp:TextBox>
                </div>
                
                <div class="form-group" style="margin-top:1rem;">
                    <label>Status</label>
                    <asp:DropDownList ID="ddlEditTaskStatus" runat="server" CssClass="form-control">
                        <asp:ListItem Value="In Progress">In Progress</asp:ListItem>
                        <asp:ListItem Value="Completed">Completed</asp:ListItem>
                        <asp:ListItem Value="Appealed">Appealed</asp:ListItem>
                    </asp:DropDownList>
                </div>
                
                <asp:Label ID="lblEditMessage" runat="server" ForeColor="#ff4d4d" EnableViewState="false" style="display:block;margin-bottom:10px;"></asp:Label>
                
                <div class="form-actions" style="margin-top: 1.5rem; text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('editTaskModal')">Cancel</button>
                    <asp:Button ID="btnUpdateTask" runat="server" Text="Save Changes" CssClass="btn-primary" OnClick="btnUpdateTask_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <!-- REPORT EXPORT MODAL -->
    <div id="reportModal" class="modal-overlay">
        <div class="modal-content" style="max-width: 500px;">
            <div class="modal-header">
                <h2>Export Task Report</h2>
                <button type="button" class="close-btn" onclick="closeModal('reportModal')"><i class="fa-solid fa-times"></i></button>
            </div>
            <div style="padding: 1.5rem;">
                <p style="margin-bottom: 1rem; color: var(--c-text-dim);">Select the columns you want to include in the PDF report:</p>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 250px), 1fr)); gap: 0.5rem; margin-bottom: 1.5rem;">
                    <label><asp:CheckBox ID="chkColTaskTitle" runat="server" Checked="true" /> Task Title</label>
                    <label><asp:CheckBox ID="chkColTaskDescription" runat="server" Checked="true" /> Description</label>
                    <label><asp:CheckBox ID="chkColGroupName" runat="server" Checked="true" /> Group Name</label>
                    <label><asp:CheckBox ID="chkColAssignedTo" runat="server" Checked="true" /> Assigned To</label>
                    <label><asp:CheckBox ID="chkColAssignedBy" runat="server" Checked="true" /> Assigned By</label>
                    <label><asp:CheckBox ID="chkColLevel" runat="server" Checked="true" /> Task Level</label>
                    <label><asp:CheckBox ID="chkColDueDate" runat="server" Checked="true" /> Due Date</label>
                    <label><asp:CheckBox ID="chkColStatus" runat="server" Checked="true" /> Status</label>
                </div>
                <div style="text-align: right;">
                    <button type="button" class="btn-secondary" onclick="closeModal('reportModal')">Cancel</button>
                    <asp:Button ID="btnGeneratePdf" runat="server" Text="Generate PDF" CssClass="btn-primary" OnClick="btnGeneratePdf_Click" />
                </div>
            </div>
        </div>
    </div>

    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            initTableSearch('searchTasks', 'tasksTable');
        });
        function openEditTaskModal(id, title, desc, status) {
            document.getElementById('<%= hdnEditTaskId.ClientID %>').value = id;
            document.getElementById('<%= txtEditTaskTitle.ClientID %>').value = title;
            document.getElementById('<%= txtEditTaskDesc.ClientID %>').value = desc;
            document.getElementById('<%= ddlEditTaskStatus.ClientID %>').value = status;
            openModal('editTaskModal');
        }
    </script>
</asp:Content>
