<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MyRequests.aspx.cs" Inherits="Project_Board.Student.Member.MyRequests" MasterPageFile="~/Student/Member/Member.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    My Group Requests - Project Board
</asp:Content>

<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .request-card {
            background: var(--c-bg-card);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.25rem;
            transition: all 0.2s;
        }

        .request-card:hover {
            box-shadow: var(--shadow-sm);
            border-color: var(--c-accent);
        }

        .request-header {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--c-border);
        }

        .request-avatar {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: rgba(59, 130, 246, 0.1);
            color: var(--c-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }

        .request-info {
            flex: 1;
        }

        .request-info h3 {
            margin: 0 0 0.25rem 0;
            font-size: 1.1rem;
            color: var(--c-text);
        }

        .request-info p {
            margin: 0;
            color: var(--c-text-muted);
            font-size: 0.875rem;
        }

        .request-tech {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.35rem 0.75rem;
            background: rgba(59, 130, 246, 0.1);
            color: var(--c-primary);
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
        }

        .badge-status {
            padding: 0.35rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-pending { background: rgba(234, 179, 8, 0.15); color: #eab308; }
        .badge-requested { background: rgba(59, 130, 246, 0.15); color: #3b82f6; }
        .badge-accepted { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
        .badge-rejected { background: rgba(239, 68, 68, 0.15); color: #ef4444; }

        .status-description {
            font-size: 0.85rem;
            color: var(--c-text-muted);
            margin-top: 0.5rem;
        }

        .request-actions {
            display: flex;
            gap: 0.75rem;
            align-items: center;
        }

        .no-requests {
            text-align: center;
            padding: 3rem 1rem;
            color: var(--c-text-muted);
        }

        .no-requests i {
            font-size: 3rem;
            margin-bottom: 1rem;
            color: var(--c-text-dim);
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <div class="page-header">
            <div class="page-title">
                <h1>My Group Requests</h1>
                <p>Track all your group join requests and their status.</p>
            </div>
        </div>

        <div class="data-section">
            <div class="section-header">
                <h2>All Requests</h2>
            </div>
            
            <!-- Success/Error Messages -->
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" style="margin-bottom:1.5rem; padding:1rem; border-radius:8px;">
                <asp:Literal ID="litMessage" runat="server"></asp:Literal>
            </asp:Panel>

            <div id="requestsList" runat="server">
                <asp:Repeater ID="rptRequests" runat="server" OnItemCommand="rptRequests_ItemCommand">
                    <ItemTemplate>
                        <div class="request-card">
                            <div class="request-header">
                                <div class="request-avatar">
                                    <i class="fa-solid fa-users"></i>
                                </div>
                                <div class="request-info">
                                    <h3><%# Eval("GroupName") %></h3>
                                    <p><i class="fa-solid fa-user-tie"></i> Leader: <%# Eval("LeaderName") %> | <i class="fa-solid fa-microchip"></i> <%# Eval("TechName") %></p>
                                </div>
                                <span class="request-tech">
                                    <i class="fa-solid fa-microchip"></i> <%# Eval("TechName") %>
                                </span>
                            </div>
                            <div style="display:flex; justify-content:space-between; align-items:center;">
                                <div>
                                    <span class='badge-status <%# GetStatusClass(Eval("JoinStatus").ToString()) %>'>
                                        <%# Eval("JoinStatus") %>
                                    </span>
                                    <div class="status-description">
                                        <i class="fa-solid fa-calendar"></i> Requested: <%# Eval("RequestedAt") != DBNull.Value ? Convert.ToDateTime(Eval("RequestedAt")).ToString("MMM dd, yyyy") : "N/A" %>
                                    </div>
                                </div>
                                <div class="request-actions">
                                    <asp:LinkButton ID="btnCancel" runat="server" CommandName="CancelRequest" CommandArgument='<%# Eval("GroupId") %>' 
                                        Visible='<%# Eval("JoinStatus").ToString() == "Requested" || Eval("JoinStatus").ToString() == "Pending" %>'
                                        CssClass="btn-secondary" style="padding:0.4rem 0.8rem; font-size:0.8rem; border-radius:6px; color:#ef4444; border:1px solid rgba(239, 68, 68, 0.2); text-decoration:none; display:inline-flex; align-items:center; gap:0.4rem;"
                                        OnClientClick="return confirm('Are you sure you want to cancel this request?');">
                                        <i class="fa-solid fa-times"></i> Cancel Request
                                    </asp:LinkButton>
                                    <span class="request-date" style="font-size:0.85rem; color:var(--c-text-muted);">
                                        <i class="fa-solid fa-user-tie"></i> Leader: <%# Eval("LeaderName") %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <%# rptRequests.Items.Count == 0 ? "<div class='no-requests'><i class='fa-solid fa-inbox'></i><h3>No requests found</h3><p>You haven't requested to join any groups yet.</p></div>" : "" %>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
</asp:Content>
