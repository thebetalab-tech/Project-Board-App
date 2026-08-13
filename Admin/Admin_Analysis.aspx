<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Analysis.aspx.cs" Inherits="Project_Board.Admin.Admin_Analysis" MasterPageFile="~/Admin/Admin.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Admin Dashboard — Analysis
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .analysis-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        .chart-container {
            background: white;
            padding: 2rem;
            border-radius: 1rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--c-border);
        }
        .chart-container h3 {
            margin-top: 0;
            margin-bottom: 1.5rem;
            color: var(--c-text);
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <div class="page-header">
            <div class="page-title">
                <h1>System Analysis</h1>
                <p>In-depth visualization and charts of platform activity.</p>
            </div>
        </div>

        <div class="analysis-grid">
            <div class="chart-container">
                <h3><i class="fa-solid fa-users" style="color:#4f46e5;"></i> Users by Role</h3>
                <canvas id="usersChart" style="max-height: 300px;"></canvas>
            </div>
            <div class="chart-container">
                <h3><i class="fa-solid fa-folder-tree" style="color:#10b981;"></i> Projects by Status</h3>
                <canvas id="projectsChart" style="max-height: 300px;"></canvas>
            </div>
            <div class="chart-container">
                <h3><i class="fa-solid fa-microchip" style="color:#f59e0b;"></i> Projects by Technology</h3>
                <canvas id="techChart" style="max-height: 300px;"></canvas>
            </div>
            <div class="chart-container">
                <h3><i class="fa-solid fa-list-check" style="color:#ef4444;"></i> Tasks by Status</h3>
                <canvas id="tasksChart" style="max-height: 300px;"></canvas>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptsContent" runat="server">
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

            // Tech Chart
            const techData = <%= ProjectsByTechJson %>;
            if(Object.keys(techData).length > 0) {
                new Chart(document.getElementById('techChart'), {
                    type: 'bar',
                    data: {
                        labels: Object.keys(techData),
                        datasets: [{
                            label: 'Projects',
                            data: Object.values(techData),
                            backgroundColor: ['#f59e0b', '#8b5cf6', '#3b82f6', '#10b981', '#ef4444']
                        }]
                    },
                    options: { ...chartOptions, plugins: { legend: { display: false } } }
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
