<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Directory.aspx.cs" Inherits="Project_Board.User.Directory" MasterPageFile="~/Dashboard.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Members Directory
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .directory-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 1.5rem;
            margin-top: 1rem;
        }

        .user-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1.25rem;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
            transition: var(--transition);
            text-decoration: none;
            color: var(--c-text);
        }

        .user-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.05);
            border-color: var(--c-border-hover);
        }

        .user-card .avatar-lg {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: var(--c-accent-bg);
            color: var(--c-accent);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            font-weight: 600;
            flex-shrink: 0;
        }

        .user-card-info {
            flex: 1;
            overflow: hidden;
        }

        .user-card-info h3 {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 0.25rem;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-card-info p {
            font-size: 0.85rem;
            color: var(--c-text-muted);
            margin: 0;
        }

        .role-badge {
            display: inline-block;
            padding: 0.15rem 0.5rem;
            border-radius: 12px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-top: 0.25rem;
        }

        .role-student { background: var(--c-green-bg); color: var(--c-green); }
        .role-faculty { background: var(--c-blue-bg); color: var(--c-blue); }
        .role-admin { background: var(--c-red-bg); color: var(--c-red); }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="SidebarNav" runat="server">
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard-container">
        <div class="page-header">
            <div class="page-title">
                <h1>Members Directory</h1>
                <p>Browse and connect with everyone on Project Board.</p>
            </div>
        </div>

        <asp:Label ID="lblError" runat="server" CssClass="text-danger" style="color: red; display: block; margin-bottom: 1rem;"></asp:Label>

        <div class="directory-grid">
            <asp:Repeater ID="rptUsers" runat="server">
                <ItemTemplate>
                    <a href='<%# ResolveUrl("~/User/PublicProfile.aspx?id=" + Eval("UserId")) %>' class="user-card">
                        <div class="avatar-lg">
                            <%# Eval("FullName").ToString().Substring(0,1).ToUpper() %>
                        </div>
                        <div class="user-card-info">
                            <h3><%# Eval("FullName") %></h3>
                            <p><%# Eval("Email") %></p>
                            <span class="role-badge <%# "role-" + Eval("Role").ToString().ToLower() %>">
                                <%# Convert.ToBoolean(Eval("IsLeader")) ? "Student Leader" : Eval("Role") %>
                            </span>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="ScriptsContent" runat="server">
</asp:Content>
