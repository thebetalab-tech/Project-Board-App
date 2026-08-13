<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Project_Board.Faculty.Dashboard" MasterPageFile="~/Faculty/Faculty.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Faculty Dashboard
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <div class="page-header">
            <div class="page-title">
                <h1>Faculty Dashboard</h1>
                <p>Welcome to the Faculty Dashboard section.</p>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon users"><i class="fa-solid fa-users"></i></div>
                </div>
                <div class="stat-value">
                    <%= MentoredGroupsCount %>
                </div>
                <div class="stat-label">Mentored Groups</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon projects"><i class="fa-solid fa-folder-tree"></i></div>
                </div>
                <div class="stat-value">
                    <%= ActiveProjectsCount %>
                </div>
                <div class="stat-label">Active Projects</div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <div class="stat-icon tech"><i class="fa-solid fa-envelope"></i></div>
                </div>
                <div class="stat-value">
                    <%= PendingRequestsCount %>
                </div>
                <div class="stat-label">Pending Requests</div>
            </div>
        </div>

        <div class="charts-section" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 1.5rem; margin-top: 2rem;">
            <div class="stat-card">
                <h3>Groups by Status</h3>
                <canvas id="groupsChart" style="max-height: 250px;"></canvas>
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
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const chartOptions = {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { position: 'bottom' } }
            };
            
            // Groups Chart
            const groupsData = <%= GroupsByStatusJson %>;
            if(Object.keys(groupsData).length > 0) {
                new Chart(document.getElementById('groupsChart'), {
                    type: 'pie',
                    data: {
                        labels: Object.keys(groupsData),
                        datasets: [{
                            data: Object.values(groupsData),
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