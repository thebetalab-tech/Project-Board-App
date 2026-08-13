<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Leader_Mentor.aspx.cs" Inherits="Project_Board.Student.Leader.Leader_Mentor" MasterPageFile="~/Student/Leader/Leader.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Leader - Mentor Request
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

            <div class="dashboard-container">
                <div class="page-header">
                    <div class="page-title">
                        <h1>Faculty Mentor Request</h1>
                        <p>Select and manage your team's faculty mentor.</p>
                    </div>
                </div>

                <div class="data-section">
                    <div class="section-header">
                        <h2>Faculty Mentor Information</h2>
                    </div>
                    <div style="padding: 1.5rem;">
                        <!-- If there's an active request or assigned mentor -->
                        <div id="divCurrentRequest" runat="server" visible="false"
                            style="margin-bottom: 1.5rem; padding: 1rem; border: 1px solid var(--c-border); border-radius: 8px; background-color: var(--c-bg-elevated);">
                            <asp:Label ID="lblStatus" runat="server" Text=""></asp:Label>
                            <br /><br />
                            <asp:Button ID="btnWithdraw" runat="server" CssClass="btn-primary"
                                style="background-color: #ef4444 !important; border-color: #ef4444 !important; color: white !important;"
                                Text="Withdraw Request" OnClick="btnWithdraw_Click" />
                        </div>

                        <!-- If no active request -->
                        <div id="divRequestForm" runat="server">
                            <p style="color: var(--c-text-muted); margin-bottom: 1.5rem; font-size: 0.875rem;">
                                Select your faculty mentor. Note: you can only have one active request outstanding. If your request is pending, you must withdraw it to request a different mentor.
                            </p>
                            <div class="form-group" style="max-width: 400px;">
                                <label for="ddlMentors">Available Faculty</label>
                                <asp:DropDownList ID="ddlMentors" runat="server" CssClass="form-control">
                                    <asp:ListItem Value="" Text="Select a Professor" />
                                </asp:DropDownList>
                            </div>
                            <asp:Button ID="btnRequest" runat="server" CssClass="btn-primary" Text="Send Request"
                                OnClick="btnRequest_Click" />
                        </div>
                    </div>
                </div>
            </div>
</asp:Content>