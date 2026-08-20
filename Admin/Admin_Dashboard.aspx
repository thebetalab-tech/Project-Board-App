<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Dashboard.aspx.cs" Inherits="Project_Board.Admin.Admin_Dashboard" MasterPageFile="~/Admin/Admin.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Dashboard — Overview
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <div class="view-section active">
            <div class="page-header">
                <div class="page-title">
                    <h1>Dashboard Overview</h1>
                    <p>Welcome back, Admin. Here is what's happening today.</p>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon users"><i class="fa-solid fa-users"></i></div>
                    </div>
                    <div class="stat-value"><asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-label">Total Active Users</div>
                </div>

                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon groups"><i class="fa-solid fa-user-group"></i></div>
                    </div>
                    <div class="stat-value"><asp:Label ID="lblTotalGroups" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-label">Total Groups</div>
                </div>

                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon projects"><i class="fa-solid fa-folder-open"></i></div>
                    </div>
                    <div class="stat-value"><asp:Label ID="lblPendingProjects" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-label">Pending Projects</div>
                </div>

                <div class="stat-card">
                    <div class="stat-header">
                        <div class="stat-icon tech"><i class="fa-solid fa-microchip"></i></div>
                    </div>
                    <div class="stat-value"><asp:Label ID="lblTotalTechs" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-label">Registered Technologies</div>
                </div>

                <div class="stat-card" style="cursor:pointer;" onclick="window.location='<%= ResolveUrl("~/Admin/Admin_DeletedRecords.aspx") %>'">
                    <div class="stat-header">
                        <div class="stat-icon" style="background:rgba(239,68,68,.12);color:#ef4444;"><i class="fa-solid fa-trash-can-arrow-up"></i></div>
                    </div>
                    <div class="stat-value"><asp:Label ID="lblTotalDeletedDash" runat="server" Text="0"></asp:Label></div>
                    <div class="stat-label">Deleted Records <i class="fa-solid fa-arrow-right" style="font-size:.7rem;margin-left:.25rem;"></i></div>
                </div>
            </div>

            <div class="charts-section" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 300px), 1fr)); gap: 1.5rem; margin-top: 2rem;">
                <div class="stat-card">
                    <h3>Users by Role</h3>
                    <canvas id="usersChart" style="max-height: 250px;"></canvas>
                </div>
                <div class="stat-card">
                    <h3>Projects by Status</h3>
                    <canvas id="projectsChart" style="max-height: 250px;"></canvas>
                </div>
                <div class="stat-card">
                    <h3>Tasks by Status</h3>
                    <canvas id="tasksChart" style="max-height: 250px;"></canvas>
                </div>
            </div>
            
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const chartOptions = {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom' }
                }
            };
            
            // Users Chart
            const usersData = <%= UsersByRoleJson %>;
            if(Object.keys(usersData).length > 0) {
                new Chart(document.getElementById('usersChart'), {
                    type: 'pie',
                    data: {
                        labels: Object.keys(usersData),
                        datasets: [{
                            data: Object.values(usersData),
                            backgroundColor: ['#4f46e5', '#10b981', '#f59e0b', '#ef4444']
                        }]
                    },
                    options: chartOptions
                });
            }

            // Projects Chart
            const projectsData = <%= ProjectsByStatusJson %>;
            if(Object.keys(projectsData).length > 0) {
                new Chart(document.getElementById('projectsChart'), {
                    type: 'doughnut',
                    data: {
                        labels: Object.keys(projectsData),
                        datasets: [{
                            data: Object.values(projectsData),
                            backgroundColor: ['#3b82f6', '#10b981', '#ef4444', '#f59e0b']
                        }]
                    },
                    options: chartOptions
                });
            }

            // Tasks Chart
            const tasksData = <%= TasksByStatusJson %>;
            if(Object.keys(tasksData).length > 0) {
                new Chart(document.getElementById('tasksChart'), {
                    type: 'bar',
                    data: {
                        labels: Object.keys(tasksData),
                        datasets: [{
                            label: 'Tasks',
                            data: Object.values(tasksData),
                            backgroundColor: ['#6366f1', '#14b8a6', '#f43f5e', '#8b5cf6']
                        }]
                    },
                    options: { ...chartOptions, plugins: { legend: { display: false } } }
                });
            }
        });
    </script>
</asp:Content>
