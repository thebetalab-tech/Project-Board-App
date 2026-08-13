<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InvitationManager.aspx.cs" Inherits="Project_Board.Student.Member.InvitationManager" MasterPageFile="~/Student/Member/Member.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Member Dashboard - Invitations
</asp:Content>
<asp:Content ID="ContentHead" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .invitation-card {
            background: var(--c-bg-card);
            border: 1px solid var(--c-border);
            border-radius: 12px;
            padding: 1.25rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1rem;
        }

        .invitation-info h4 {
            margin: 0 0 0.3rem 0;
            font-size: 1.1rem;
            color: var(--c-text);
        }

        .invitation-info p {
            margin: 0;
            font-size: 0.85rem;
            color: var(--c-text-dim);
        }

        .btn-accept {
            background-color: var(--c-accent);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            text-decoration: none;
            margin-right: 0.5rem;
        }

        .btn-reject {
            background-color: rgba(239, 68, 68, 0.15);
            color: #ef4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
            padding: 0.5rem 1rem;
            border-radius: 6px;
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            text-decoration: none;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Invitations Inbox</h1>
                        <p>Manage invitations sent to you by team leaders.</p>
                    </div>
                </div>

                <!-- EMPTY INVITATIONS STATE -->
                <asp:Panel ID="pnlEmptyState" runat="server" CssClass="stat-card" style="padding: 3rem 1.5rem; text-align: center;">
                    <i class="fa-solid fa-envelope-open" style="font-size: 3rem; color: var(--c-text-dim); margin-bottom: 1rem; display: block;"></i>
                    <h2 style="margin-bottom: 0.5rem;">No Pending Invitations</h2>
                    <p style="color: var(--c-text-dim);">You do not have any incoming group invitations from leaders right now.</p>
                </asp:Panel>

                <!-- INVITATIONS LIST -->
                <asp:Panel ID="pnlInvitations" runat="server" Visible="false">
                    <asp:Repeater ID="rptInvitations" runat="server" OnItemCommand="rptInvitations_ItemCommand">
                        <ItemTemplate>
                            <div class="invitation-card">
                                <div class="invitation-info">
                                    <h4><i class="fa-solid fa-users" style="color:var(--c-accent); margin-right:0.4rem;"></i> <%# Eval("GroupName") %></h4>
                                    <p>Invited by Leader: <strong><%# Eval("LeaderName") %></strong> | Technology: <%# Eval("TechName") != DBNull.Value ? Eval("TechName") : "General" %></p>
                                </div>
                                <div>
                                    <asp:Button ID="btnAccept" runat="server" CommandName="Accept" CommandArgument='<%# Eval("GroupId") %>' Text="Accept Invitation" CssClass="btn-accept" />
                                    <asp:Button ID="btnReject" runat="server" CommandName="Reject" CommandArgument='<%# Eval("GroupId") %>' Text="Decline" CssClass="btn-reject" />
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>

            </div>
            </div>
</asp:Content>