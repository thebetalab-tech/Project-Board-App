<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Analysis.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Analysis" MasterPageFile="~/Student/Leader/Leader.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leader Dashboard — Analysis
</asp:Content>
<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .analysis-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(min(100%, 400px), 1fr));
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
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Team & Tasks Analysis</h1>
                        <p>Analyze progress and statistics of your team.</p>
                    </div>
                </div>

                <div class="analysis-grid">
                    <div class="chart-container">
                        <h3><i class="fa-solid fa-list-check" style="color:#ef4444;"></i> Tasks by Status</h3>
                        <canvas id="tasksChart" style="max-height: 300px;"></canvas>
                    </div>
                    <div class="chart-container">
                        <h3><i class="fa-solid fa-user-check" style="color:#10b981;"></i> Tasks Completion by Member</h3>
                        <canvas id="memberTasksChart" style="max-height: 300px;"></canvas>
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

            // Tasks Chart
            const tasksData = <%= TasksByStatusJson %>;
            new Chart(document.getElementById('tasksChart'), {
                type: 'pie',
                data: {
                    labels: Object.keys(tasksData),
                    datasets: [{
                        data: Object.values(tasksData),
                        backgroundColor: ['#6366f1', '#14b8a6', '#f43f5e', '#8b5cf6']
                    }]
                },
                options: chartOptions
            });

            // Member Tasks Chart
            const memberData = <%= MemberTasksJson %>;
            new Chart(document.getElementById('memberTasksChart'), {
                type: 'bar',
                data: {
                    labels: Object.keys(memberData),
                    datasets: [{
                        label: 'Completed Tasks',
                        data: Object.values(memberData),
                        backgroundColor: ['#10b981', '#3b82f6', '#f59e0b', '#8b5cf6', '#ef4444']
                    }]
                },
                options: { ...chartOptions, plugins: { legend: { display: false } } }
            });
        });
    </script>
</asp:Content>
