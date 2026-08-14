<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PublicProfile.aspx.cs" Inherits="Project_Board.User.PublicProfile" MasterPageFile="~/Dashboard.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Public Profile
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .profile-container {
            max-width: 800px;
            margin: 0 auto;
            margin-top: 2rem;
        }

        .profile-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 24px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03);
            overflow: hidden;
        }

        .profile-header-bg {
            height: 140px;
            background: linear-gradient(135deg, var(--c-accent), var(--c-accent-light));
        }

        .profile-content {
            padding: 0 3rem 3rem 3rem;
            position: relative;
        }

        .profile-avatar-container {
            margin-top: -60px;
            margin-bottom: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
        }

        .profile-avatar-large {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            background: #ffffff;
            border: 4px solid #ffffff;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            font-weight: 700;
            color: var(--c-accent);
        }

        .profile-name {
            font-family: var(--f-display);
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--c-text);
            margin-bottom: 0.25rem;
        }

        .profile-role {
            font-size: 1.1rem;
            color: var(--c-text-muted);
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .role-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 16px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .role-student { background: var(--c-green-bg); color: var(--c-green); }
        .role-faculty { background: var(--c-blue-bg); color: var(--c-blue); }
        .role-admin { background: var(--c-red-bg); color: var(--c-red); }

        .profile-details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
        }

        .detail-item {
            background: var(--c-bg-warm);
            padding: 1.5rem;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
        }

        .detail-label {
            font-size: 0.85rem;
            color: var(--c-text-muted);
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 0.5rem;
            font-weight: 600;
        }

        .detail-value {
            font-size: 1.1rem;
            font-weight: 500;
            color: var(--c-text);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .detail-value i {
            color: var(--c-accent);
            opacity: 0.8;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--c-text-muted);
            text-decoration: none;
            font-weight: 500;
            margin-bottom: 1.5rem;
            transition: var(--transition);
        }
        
        .back-link:hover {
            color: var(--c-accent);
        }

    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="SidebarNav" runat="server">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        
        <div class="profile-container">
            <a href="javascript:history.back()" class="back-link">
                <i class="fa-solid fa-arrow-left"></i> Back
            </a>

            <asp:Label ID="lblError" runat="server" CssClass="text-danger" style="color: red; display: block; margin-bottom: 1rem;"></asp:Label>

            <asp:Panel ID="pnlProfile" runat="server" Visible="false">
                <div class="profile-card">
                    <div class="profile-header-bg"></div>
                    <div class="profile-content">
                        <div class="profile-avatar-container">
                            <div class="profile-avatar-large">
                                <asp:Literal ID="litAvatar" runat="server"></asp:Literal>
                            </div>
                        </div>

                        <h1 class="profile-name"><asp:Literal ID="litName" runat="server"></asp:Literal></h1>
                        <div class="profile-role">
                            <asp:Literal ID="litRoleBadge" runat="server"></asp:Literal>
                        </div>

                        <div class="profile-details-grid">
                            <div class="detail-item">
                                <div class="detail-label">Email Address</div>
                                <div class="detail-value">
                                    <i class="fa-solid fa-envelope"></i>
                                    <asp:Literal ID="litEmail" runat="server"></asp:Literal>
                                </div>
                            </div>

                            <asp:Panel ID="pnlEnrollment" runat="server" CssClass="detail-item" Visible="false">
                                <div class="detail-label">Enrollment Number</div>
                                <div class="detail-value">
                                    <i class="fa-solid fa-id-card"></i>
                                    <asp:Literal ID="litEnrollment" runat="server"></asp:Literal>
                                </div>
                            </asp:Panel>
                            
                            <div class="detail-item">
                                <div class="detail-label">Account Status</div>
                                <div class="detail-value">
                                    <i class="fa-solid fa-circle-check" style="color: var(--c-green);"></i> Active Member
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="ScriptsContent" runat="server">
</asp:Content>
