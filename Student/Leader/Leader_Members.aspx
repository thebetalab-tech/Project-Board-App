<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Members.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Members" MasterPageFile="~/Student/Leader/Leader.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leader Dashboard — Team Members
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
                <div class="dashboard-container">
                    <div class="page-header">
                        <div class="page-title">
                            <h1>Team Members</h1>
                            <p>Manage your group members and send invitations.</p>
                        </div>
                        <div>
                            <asp:Button ID="btnToggleStatus" runat="server" CssClass="btn-primary"
                                OnClick="btnToggleStatus_Click" />
                        </div>
                    </div>

                    <div class="data-section">
                        <div class="section-header" style="display:flex; justify-content:space-between; align-items:center;">
                            <h2>Active Members</h2>
                            <div style="display:flex; gap:10px; align-items:center;">
                                <a href="javascript:void(0)" class="btn-secondary" onclick="openModal('reportModal')">
                                    <i class="fa-solid fa-file-export"></i> Export Report
                                </a>
                                <div class="search-bar" style="width: 250px;">
                                    <i class="fa-solid fa-search"></i>
                                    <input type="text" id="searchMembers" placeholder="Filter active members...">
                                </div>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table id="membersTable">
                                <thead>
                                    <tr>
                                        <th>Member ID</th>
                                        <th>Member Name</th>
                                        <th>Enrollment No.</th>
                                        <th>Email</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptGroups" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><strong>
                                                        <%# Eval("UserId") %>
                                                    </strong></td>
                                                <td>
                                                    <%# Eval("FullName") %>
                                                </td>
                                                <td>
                                                    <%# Eval("EnrollmentNo") %>
                                                </td>
                                                <td>
                                                    <%# Eval("Email") %>
                                                </td>
                                                <td>
                                                    <span
                                                        class='badge status-<%# Eval("JoinStatus").ToString().ToLower() %>'>
                                                        <%# Eval("JoinStatus") %>
                                                    </span>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <asp:Panel ID="pnlInviteSection" runat="server" CssClass="data-section">
                        <div class="section-header" style="display:flex; justify-content:space-between; align-items:center;">
                            <h2>Invite New Members</h2>
                            <div class="search-bar" style="width: 250px;">
                                <i class="fa-solid fa-search"></i>
                                <input type="text" id="searchInvites" placeholder="Filter students...">
                            </div>
                        </div>
                        <div class="table-responsive">
                            <table id="invitesTable">
                                <thead>
                                    <tr>
                                        <th>Student Details</th>
                                        <th style="text-align: right;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptEligible" runat="server"
                                        OnItemCommand="rptEligible_ItemCommand">
                                        <ItemTemplate>
                                            <tr>
                                                <td>
                                                    <div class="user-cell">
                                                        <div class="user-cell-avatar"><i class="fa-solid fa-user"
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
                                                    <asp:Button ID="btnInvite" runat="server" CssClass="btn-secondary"
                                                        Text="Invite" CommandName="Invite"
                                                        CommandArgument='<%# Eval("UserId") %>' />
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </asp:Panel>
                </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="ScriptsContent" runat="server">
        <!-- REPORT EXPORT MODAL -->
        <div id="reportModal" class="modal-overlay">
            <div class="modal-content" style="max-width: 500px;">
                <div class="modal-header">
                    <h2>Export Team Members Report</h2>
                    <button type="button" class="close-btn" onclick="closeModal('reportModal')"><i class="fa-solid fa-times"></i></button>
                </div>
                <div style="padding: 1.5rem;">
                    <p style="margin-bottom: 1rem; color: var(--c-text-dim);">Select the columns you want to include in the PDF report:</p>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin-bottom: 1.5rem;">
                        <label><asp:CheckBox ID="chkColMemberId" runat="server" Checked="true" /> Member ID</label>
                        <label><asp:CheckBox ID="chkColMemberName" runat="server" Checked="true" /> Member Name</label>
                        <label><asp:CheckBox ID="chkColEnrollmentNo" runat="server" Checked="true" /> Enrollment No.</label>
                        <label><asp:CheckBox ID="chkColEmail" runat="server" Checked="true" /> Email</label>
                        <label><asp:CheckBox ID="chkColStatus" runat="server" Checked="true" /> Status</label>
                    </div>
                    <div style="text-align: right;">
                        <button type="button" class="btn-secondary" onclick="closeModal('reportModal')">Cancel</button>
                        <asp:Button ID="btnGeneratePdf" runat="server" Text="Generate PDF" CssClass="btn-primary" OnClick="btnGeneratePdf_Click" />
                    </div>
                </div>
            </div>
        </div>
    <script src='<%= ResolveUrl("~/Scripts/tableSearch.js") %>'></script>
    <script>
            document.addEventListener('DOMContentLoaded', function() {
                initTableSearch('searchMembers', 'membersTable');
                initTableSearch('searchInvites', 'invitesTable');
            });
    </script>
</asp:Content>