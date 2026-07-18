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
                        <h2>Active Members</h2>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <thead>
                                <tr>
                                    <th>Member ID</th>
                                    <th>Member Name</th>
                                    <th>Enrollment No.</th>
                                    <th>Email</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptGroups" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <td><strong><%# Eval("UserId") %></strong></td>
                                            <td><%# Eval("FullName") %></td>
                                            <td><%# Eval("EnrollmentNo") %></td>
                                            <td><%# Eval("Email") %></td>
                                            <td>
                                                <span class='badge status-<%# Eval("JoinStatus").ToString().ToLower() %>'>
                                                    <%# Eval("JoinStatus") %>
                                                </span>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
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
                            <asp:TextBox ID="txtInviteEmail" runat="server" CssClass="form-control" placeholder="e.g. 190209012 or member@example.com"></asp:TextBox>
                            <asp:Button ID="btnInvite" runat="server" CssClass="btn-primary" Text="Invite" OnClick="btnInvite_Click" />
                        </div>
                    </div>
                    <div class="section-header" style="border-top: 1px solid var(--c-border); border-bottom: none;">
                        <h2 style="font-size: 1.25rem;">Sent Invitations</h2>
                    </div>
                    <div class="table-responsive">
                        <table>
                            <tbody>
                                <asp:Repeater ID="rptPending" runat="server" OnItemCommand="rptPending_ItemCommand">
                                    <ItemTemplate>
                                        <tr>
                                            <td>
                                                <div class="user-cell">
                                                    <div class="user-cell-avatar"><i class="fa-solid fa-envelope" style="color: var(--c-text-muted);"></i></div>
                                                    <div class="user-cell-info">
                                                        <h4><%# Eval("Email") %></h4>
                                                        <p>Name: <%# Eval("FullName") %></p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td style="text-align: right;">
                                                <span class="badge status-pending">Pending</span>
                                            </td>
                                            <td style="text-align: right; width: 60px;">
                                                <asp:LinkButton ID="btnCancel" runat="server" CssClass="icon-btn delete" CommandName="Cancel" CommandArgument='<%# Eval("UserId") %>' ToolTip="Cancel Invite"><i class="fa-solid fa-times"></i></asp:LinkButton>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
