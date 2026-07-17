<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Mentor.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Mentor" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leader Dashboard — Mentor Request</title>
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
                    <a href="Leader_Members.aspx" class="nav-link">
                        <i class="fa-solid fa-users"></i> Team Members
                    </a>
                    <a href="Leader_Mentor.aspx" class="nav-link active">
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
                        <h1>Faculty Mentor Request</h1>
                        <p>Select and manage your team's faculty mentor.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Mentor Selection</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <p style="color: var(--c-text-muted); margin-bottom: 1.5rem; font-size: 0.875rem;">Select your faculty mentor. Note: you can only have one active request outstanding. If your request is pending, you must withdraw it to request a different mentor.</p>

                        <div class="form-group" style="max-width: 400px;">
                            <label for="mentorSelect">Available Faculty</label>
                            <select id="mentorSelect" name="mentorSelect" class="form-control">
                                <option value="" disabled selected>Select a Professor</option>
                                <option value="Prof. Jane Smith">Prof. Jane Smith (Web Tech)</option>
                                <option value="Prof. Alan Turing">Prof. Alan Turing (AI & Web)</option>
                                <option value="Dr. Sarah Connor">Dr. Sarah Connor (Full Stack)</option>
                            </select>
                        </div>
                        <button type="button" class="btn-primary">
                            Send Request <i class="fa-solid fa-arrow-right" style="margin-left: 0.5rem;"></i>
                        </button>
                    </div>
                </div>
            </div>
        </main>
    </form>
</body>
</html>
