<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TaskDetails.aspx.cs" Inherits="Project_Board.Faculty.TaskDetails" %>
<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Details — Faculty Review</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link  rel="stylesheet" href="../Admin/admin.css?v=latest_v3" />
    <style>
        .detail-card {
            background: var(--c-bg-card);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .detail-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1.25rem;
            margin-top: 1rem;
        }

        .detail-item label {
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--c-text-dim);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            display: block;
            margin-bottom: 0.3rem;
        }

        .detail-item span {
            font-size: 1rem;
            color: var(--c-text);
            font-weight: 500;
        }

        .badge-status {
            padding: 0.25rem 0.6rem;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-block;
        }
        .badge-success { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
        .badge-warning { background: rgba(234, 179, 8, 0.15); color: #eab308; }
        .badge-danger { background: rgba(239, 68, 68, 0.15); color: #ef4444; }
        .badge-purple { background: rgba(168, 85, 247, 0.15); color: #a855f7; }

        .form-control {
            background: var(--c-bg);
            border: 1px solid var(--c-border);
            color: var(--c-text);
            padding: 0.6rem 0.8rem;
            border-radius: 8px;
            font-family: inherit;
            width: 100%;
            margin-top: 0.5rem;
        }

        .action-bar {
            display: flex;
            gap: 1rem;
            margin-top: 1rem;
            flex-wrap: wrap;
        }

        .btn-success { background: #22c55e; color: #fff; border: none; padding: 0.6rem 1.2rem; border-radius: 8px; font-weight: 600; cursor: pointer; }
        .btn-danger { background: #ef4444; color: #fff; border: none; padding: 0.6rem 1.2rem; border-radius: 8px; font-weight: 600; cursor: pointer; }
        .btn-purple { background: #8b5cf6; color: #fff; border: none; padding: 0.6rem 1.2rem; border-radius: 8px; font-weight: 600; cursor: pointer; }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <!-- SIDEBAR -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="logo-icon"><i class="fa-solid fa-graduation-cap" style="color: white;"></i></div>
                <h2 class="sidebar-title">Project Board</h2>
                <button type="button" id="sidebarToggle" class="sidebar-toggle-btn" title="Toggle Sidebar">
                    <i class="fa-solid fa-bars"></i>
                </button>
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
                        <h1>Task Details & Appeal Review</h1>
                        <p>Detailed view of task assignment, student submission, and appeal management.</p>
                    </div>
                </div>

                <asp:Label ID="lblMessage" runat="server" Visible="false" Style="display:block; margin-bottom:1rem;"></asp:Label>

                <!-- TASK INFORMATION CARD -->
                <div class="detail-card">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <h2><asp:Label ID="lblTaskTitle" runat="server"></asp:Label></h2>
                        <span class="badge-status badge-purple"><asp:Label ID="lblStatus" runat="server"></asp:Label></span>
                    </div>

                    <div class="detail-grid">
                        <div class="detail-item">
                            <label>Group Name</label>
                            <span><asp:Label ID="lblGroupName" runat="server"></asp:Label></span>
                        </div>
                        <div class="detail-item">
                            <label>Assigned Student</label>
                            <span><asp:Label ID="lblAssignedTo" runat="server"></asp:Label></span>
                        </div>
                        <div class="detail-item">
                            <label>Student Role</label>
                            <span><asp:Label ID="lblStudentRole" runat="server"></asp:Label></span>
                        </div>
                        <div class="detail-item">
                            <label>Assigned By</label>
                            <span><asp:Label ID="lblAssignedBy" runat="server"></asp:Label></span>
                        </div>
                        <div class="detail-item">
                            <label>Due Date</label>
                            <span><asp:Label ID="lblDueDate" runat="server"></asp:Label></span>
                        </div>
                    </div>

                    <div style="margin-top:1.25rem;">
                        <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Task Description</label>
                        <p style="margin-top:0.4rem; color:var(--c-text);"><asp:Label ID="lblDescription" runat="server"></asp:Label></p>
                    </div>

                    <div style="margin-top:1rem;">
                        <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Points to Cover</label>
                        <p style="margin-top:0.4rem; color:var(--c-text);"><asp:Label ID="lblPointsToCover" runat="server"></asp:Label></p>
                    </div>
                </div>

                <!-- STUDENT SUBMISSION CARD -->
                <div class="detail-card">
                    <h3><i class="fa-solid fa-file-lines" style="color:var(--c-accent); margin-right:0.5rem;"></i> Student Submission / Progress Report</h3>
                    <div style="margin-top:0.8rem;">
                        <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Submitted Report Text</label>
                        <p style="margin-top:0.4rem; color:var(--c-text); background:var(--c-bg); padding:0.8rem; border-radius:8px; border:1px solid var(--c-border);">
                            <asp:Label ID="lblReportText" runat="server"></asp:Label>
                        </p>
                        <p style="font-size:0.8rem; color:var(--c-text-dim); margin-top:0.4rem;">
                            Submitted at: <asp:Label ID="lblReportSubmittedAt" runat="server"></asp:Label>
                        </p>
                    </div>
                </div>

                <!-- APPEAL INFORMATION CARD -->
                <asp:Panel ID="pnlAppealSection" runat="server" CssClass="detail-card" Visible="false">
                    <div style="display:flex; justify-content:space-between; align-items:center;">
                        <h3><i class="fa-solid fa-flag" style="color:#a855f7; margin-right:0.5rem;"></i> Appeal Information</h3>
                        <span class="badge-status badge-warning"><asp:Label ID="lblAppealStatus" runat="server"></asp:Label></span>
                    </div>

                    <div style="margin-top:1rem;">
                        <label style="font-size:0.75rem; font-weight:700; color:var(--c-text-dim); text-transform:uppercase;">Student Appeal Reason</label>
                        <p style="margin-top:0.4rem; color:var(--c-text); background:var(--c-bg); padding:0.8rem; border-radius:8px; border:1px solid var(--c-border);">
                            <asp:Label ID="lblAppealReason" runat="server"></asp:Label>
                        </p>
                    </div>

                    <div class="detail-grid" style="margin-top:1rem;">
                        <div class="detail-item">
                            <label>Appeal Created Date</label>
                            <span><asp:Label ID="lblAppealCreatedAt" runat="server"></asp:Label></span>
                        </div>
                        <div class="detail-item">
                            <label>Reviewer</label>
                            <span><asp:Label ID="lblReviewerName" runat="server"></asp:Label></span>
                        </div>
                        <div class="detail-item">
                            <label>Reviewer Remarks</label>
                            <span><asp:Label ID="lblReviewerRemarks" runat="server"></asp:Label></span>
                        </div>
                    </div>
                </asp:Panel>

                <!-- REVIEW & AUTHORIZED ACTIONS CARD -->
                <div class="detail-card">
                    <h3><i class="fa-solid fa-gavel" style="color:var(--c-accent); margin-right:0.5rem;"></i> Review & Authorized Actions</h3>
                    
                    <div style="margin-top:1rem;">
                        <label style="font-size:0.85rem; font-weight:600;">Faculty / Reviewer Feedback & Remarks</label>
                        <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control" placeholder="Enter remarks or revision feedback for student..."></asp:TextBox>
                    </div>

                    <div class="action-bar">
                        <asp:Button ID="btnMarkCompleted" runat="server" Text="Mark Completed" CssClass="btn-success" OnClick="btnMarkCompleted_Click" />
                        <asp:Button ID="btnRejectCompletion" runat="server" Text="Request Revision" CssClass="btn-danger" OnClick="btnRejectCompletion_Click" />
                        <asp:Button ID="btnAcceptAppeal" runat="server" Text="Accept Appeal" CssClass="btn-purple" OnClick="btnAcceptAppeal_Click" Visible="false" />
                        <asp:Button ID="btnRejectAppeal" runat="server" Text="Reject Appeal" CssClass="btn-danger" OnClick="btnRejectAppeal_Click" Visible="false" />
                    </div>
                </div>

            </div>
        </main>
    </form>
    <script src='<%= ResolveUrl("~/Admin/admin.js?v=latest_v2") %>'></script>
</body>

</html>
