<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Member_Team.aspx.cs" Inherits="Project_Board.Student.Member.Member_Team" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Member Dashboard — Team & Mentor</title>
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
                    <a href="Member_Team.aspx" class="nav-link active">
                        <i class="fa-solid fa-users"></i> Team & Mentor
                    </a>
                    <% if (Session["UserRole"] != null && Session["UserRole"].ToString() == "Leader") { %>
                    <a href="../Leader/Dashboard.aspx" class="nav-link">
                        <i class="fa-solid fa-user-tie"></i> Leader Panel
                    </a>
                    <% } %>
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
                    <div class="avatar">SM</div>
                    <div class="user-info">
                        <h4><%= Session["FullName"] ?? "Student Member" %></h4>
                        <p><%= Session["Email"] ?? "member@example.com" %></p>
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
                        <h1>Team & Mentor</h1>
                        <p>View your roster members and mentor request status.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Faculty Mentor Status</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <p style="color: var(--c-text-muted); margin-bottom: 1.5rem; font-size: 0.875rem;">Current status of your team's faculty mentor request. Only the Team Leader has permissions to select or change mentors.</p>
                        
                        <div style="background: var(--c-bg-elevated); border: 1px solid var(--c-border); padding: 1.5rem; border-radius: 8px;">
                            <h4 style="color: var(--c-text-muted); margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.5rem;">
                                <i class="fa-solid fa-user-slash"></i> No Mentor Requested
                            </h4>
                            <p style="font-size: 0.85rem; color: var(--c-text-muted);">Your team leader hasn't submitted a faculty mentor request yet. Once submitted, status updates will show here.</p>
                        </div>
                    </div>
                </div>
                
                <div class="data-section">
                    <div class="section-header">
                        <h2>Roster Members</h2>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Member Name</th>
                                    <th>Role</th>
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
                                    <td style="text-align: right;"><span class="badge admin">Leader</span></td>
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
                                    <td style="text-align: right;"><span class="badge student">Member</span></td>
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
