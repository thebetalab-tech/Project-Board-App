<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Members.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Members" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader Dashboard — Team Members</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../../Admin/admin.css">
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
                    <a href="Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-chart-pie"></i> Overview
                    </a>
                    <a href="Leader_Members.aspx" class="nav-link active">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href="Leader_Mentor.aspx" class="nav-link">
                        <i class="fa-solid fa-chalkboard-user"></i> Mentor Request
                    </a>
                    <a href="../Member/Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-user-group"></i> View as Member
                    </a>
                </div>
                <div class="nav-section">
                    <div class="nav-section-title">Preferences</div>
                    <a href="../../User/Profile.aspx" class="nav-link">
                        <i class="fa-solid fa-user"></i> Profile
                    </a>
                    <a href="../../Logout.aspx" class="nav-link">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i> Logout
                    </a>
                </div>
            </nav>
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="avatar">TL</div>
                    <div class="user-info">
                        <h4><%= Session["FullName"] ?? "Student Leader" %></h4>
                        <p><%= Session["Email"] ?? "leader@example.com" %></p>
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
                    <a href="../../User/Profile.aspx" class="action-btn" title="Profile">
                        <i class="fa-solid fa-user"></i>
                    </a>
                </div>
            </div>

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Team Members</h1>
                        <p>Manage your group members and send invitations.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Active Roster</h2>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Member Name</th>
                                    <th>Role</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <div class="user-cell">
                                            <div class="user-cell-avatar">TL</div>
                                            <div class="user-cell-info">
                                                <h4>Tirth Leader</h4>
                                                <p>123456789</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="badge admin">Leader</span></td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="user-cell">
                                            <div class="user-cell-avatar">JD</div>
                                            <div class="user-cell-info">
                                                <h4>John Doe</h4>
                                                <p>987654321</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="badge student">Member</span></td>
                                    <td>
                                        <div class="table-actions">
                                            <button type="button" class="icon-btn delete" title="Remove Member"><i class="fa-solid fa-trash"></i></button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div class="data-section">
                    <div class="section-header">
                        <h2>Invite New Members</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <p style="color: var(--c-text-muted); margin-bottom: 1rem; font-size: 0.875rem;">Enter enrollment number or email to send invitations to join the team.</p>
                        <div class="form-group" style="display: flex; gap: 1rem; max-width: 500px; margin-bottom: 0;">
                            <input type="text" class="form-control" placeholder="e.g. 190209012 or member@example.com">
                            <button type="button" class="btn-primary">Invite</button>
                        </div>
                    </div>
                    <div class="section-header" style="border-top: 1px solid var(--c-border); border-bottom: none;">
                        <h2 style="font-size: 1.25rem;">Sent Invitations</h2>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <tbody>
                                <tr>
                                    <td>
                                        <div class="user-cell">
                                            <div class="user-cell-avatar"><i class="fa-solid fa-envelope" style="color: var(--c-text-muted);"></i></div>
                                            <div class="user-cell-info">
                                                <h4>alice.smith@example.com</h4>
                                                <p>Invited on: 16-Jul-2026</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="text-align: right;">
                                        <span class="badge status-pending">Pending</span>
                                    </td>
                                    <td style="text-align: right; width: 60px;">
                                        <button type="button" class="icon-btn delete" title="Cancel Invite"><i class="fa-solid fa-times"></i></button>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div class="user-cell">
                                            <div class="user-cell-avatar"><i class="fa-solid fa-envelope" style="color: var(--c-text-muted);"></i></div>
                                            <div class="user-cell-info">
                                                <h4>bob.johnson@example.com</h4>
                                                <p>Invited on: 16-Jul-2026</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td style="text-align: right;">
                                        <span class="badge status-pending">Pending</span>
                                    </td>
                                    <td style="text-align: right; width: 60px;">
                                        <button type="button" class="icon-btn delete" title="Cancel Invite"><i class="fa-solid fa-times"></i></button>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
