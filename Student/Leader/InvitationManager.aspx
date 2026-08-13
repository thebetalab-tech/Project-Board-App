<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InvitationManager.aspx.cs" Inherits="Project_Board.Student.Leader.InvitationManager" MasterPageFile="~/Student/Leader/Leader.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leader Invitations — Project Board
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
                <div class="dashboard-container">
                    <div class="page-header">
                        <div class="page-title">
                            <h1>Invitations Manager</h1>
                            <p>Manage join requests and pending invitations for your group.</p>
                        </div>
                    </div>

                    <asp:Panel ID="pnlRequests" runat="server" CssClass="data-section" Visible="false">
                        <div class="section-header">
                            <h2>Join Requests <span class="badge"
                                    style="background: var(--c-red); color: white;">New</span></h2>
                        </div>
                        <div class="table-responsive">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Student Details</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptRequests" runat="server"
                                        OnItemCommand="rptRequests_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <div class="user-cell">
                                                        <div class="user-cell-avatar"><i class="fa-solid fa-user-clock"
                                                                style="color: var(--c-text-muted);"></i></div>
                                                        <div class="user-cell-info">
                                                            <h4>
                                                                <%# Eval("FullName") %>
                                                            </h4>
                                                            <p>
                                                                <%# Eval("Email") %> | <%# Eval("EnrollmentNo") %>
                                                            </p>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td
                                                    style="text-align: right; display: flex; gap: 0.5rem; justify-content: flex-end;">
                                                    <asp:Button ID="btnAccept" runat="server" CssClass="btn-primary"
                                                        Text="Accept" CommandName="Accept"
                                                        CommandArgument='<%# Eval("UserId") %>'
                                                        style="background: var(--c-green);" />
                                                    <asp:Button ID="btnReject" runat="server" CssClass="btn-secondary"
                                                        Text="Reject" CommandName="Reject"
                                                        CommandArgument='<%# Eval("UserId") %>'
                                                        style="background: var(--c-red); color: white; border: none;" />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlPending" runat="server" CssClass="data-section" Visible="false">
                        <div class="section-header">
                            <h2>Sent Invitations</h2>
                        </div>
                        <div class="table-responsive">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Student Details</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptPending" runat="server" OnItemCommand="rptPending_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <div class="user-cell">
                                                        <div class="user-cell-avatar"><i class="fa-solid fa-paper-plane"
                                                                style="color: var(--c-text-muted);"></i></div>
                                                        <div class="user-cell-info">
                                                            <h4>
                                                                <%# Eval("FullName") %>
                                                            </h4>
                                                            <p>
                                                                <%# Eval("Email") %> | <%# Eval("EnrollmentNo") %>
                                                            </p>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td style="text-align: right;">
                                                    <asp:Button ID="btnRevoke" runat="server" CssClass="btn-secondary"
                                                        Text="Revoke" CommandName="Revoke"
                                                        CommandArgument='<%# Eval("UserId") %>' />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlEmptyState" runat="server" CssClass="data-section"
                        style="text-align: center; padding: 4rem 2rem;">
                        <i class="fa-solid fa-inbox"
                            style="font-size: 3rem; color: var(--c-text-muted); margin-bottom: 1rem;"></i>
                        <h2 style="font-size: 1.5rem; margin-bottom: 0.5rem;">Inbox Zero</h2>
                        <p style="color: var(--c-text-muted); margin-bottom: 2rem;">You do not have any pending requests
                            or sent invitations.</p>
                    </asp:Panel>
                </div>
                </div>
</asp:Content>