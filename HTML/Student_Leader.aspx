<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Student_Leader.aspx.cs" Inherits="Project_Board.UI.Student.Student_Leader" %>

<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Leader Dashboard — Project Board</title>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../../HTML/style.css">

    <link rel="stylesheet" href="student.css">
</head>

<body>
    <form id="form1" runat="server">
        <!-- Index Theme Background -->
        <div class="theme-bg">
            <div class="theme-bg__image"></div>
            <div class="theme-bg__blur"></div>
            <div class="theme-bg__gradient"></div>
        </div>

        <div class="dashboard-layout">
            <!-- Sidebar -->
            <aside class="dash-sidebar">
                <div class="sidebar-brand">
                    <h1 class="brand-title" style="font-size: 1.5rem;">
                        <span class="brand-word brand-word--project">Project</span>
                        <br><span class="brand-word brand-word--board">Board</span>
                    </h1>
                </div>
                <nav class="sidebar-nav">
                    <a href="../../HTML/dashboard-student.html" class="nav-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                            <polyline points="9 22 9 12 15 12 15 22" />
                        </svg>
                        Student Home
                    </a>
                    <a href="#" class="nav-item active">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" />
                            <circle cx="9" cy="7" r="4" />
                            <path d="M23 21v-2a4 4 0 0 0-3-3.87" />
                            <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                        </svg>
                        Leader Panel
                    </a>

                </nav>
                <div class="sidebar-footer">
                    <a href="../../Logout.aspx" class="nav-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                            <polyline points="16 17 21 12 16 7" />
                            <line x1="21" y1="12" x2="9" y2="12" />
                        </svg>
                        Log Out
                    </a>
                </div>
            </aside>

            <!-- Main Content -->
            <main class="dash-main">
                <!-- Header -->
                <header class="dash-header">
                    <div>
                        <h2 class="dash-title" id="team-name-title">Beta Lab Core Team</h2>
                        <p class="dash-subtitle" id="team-tech-domain">Technology Domain: Web Development (Full Stack)</p>
                    </div>
                    <div class="header-actions">
                        <div class="status-badge" id="team-status-badge">
                            <span class="status-dot" style="background:#FBBF24; box-shadow:0 0 8px #FBBF24;"></span> Mentor Selection
                        </div>
                        <!-- Tiny Circular Theme Switch Toggle Button -->
                        <button type="button" onclick="toggleTheme()" class="theme-toggle-circular" id="theme-btn" title="Toggle Theme">
                            <svg id="theme-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
                            </svg>
                        </button>
                        <!-- Profile Button -->
                        <button type="button" onclick="openProfileModal()" class="theme-toggle-circular" id="profile-btn" title="View Profile">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                <circle cx="12" cy="7" r="4" />
                            </svg>
                        </button>
                    </div>
                </header>

                <div class="dash-content">
                    <div class="dash-grid">

                        <!-- LEFT COLUMN: Team Roster and Invitations -->
                        <div class="glass-column">

                            <!-- Team Roster Card -->
                            <div class="glass-card">
                                <div class="header-flex">
                                    <h3 class="card-title">Team Members</h3>
                                    <div class="badge-count">Total: <span id="member-total-count">2</span></div>
                                </div>
                                <ul class="roster-list" id="team-roster-list">
                                    <!-- Rendered dynamically -->
                                </ul>
                            </div>

                            <!-- Invitation Management Card -->
                            <div class="glass-card mt-24">
                                <h3 class="card-title">Invite New Members</h3>
                                <p class="card-text mb-16">Enter enrollment number or email to send invitations to join the team.</p>

                                <div class="invitation-badge-container">
                                    <div class="badge-count">Total Invited: <span id="invite-total">2</span></div>
                                    <div class="badge-count">Pending: <span id="invite-pending" style="color: #FBBF24;">2</span></div>
                                    <div class="badge-count">Accepted: <span id="invite-accepted" style="color: #34D399;">0</span></div>
                                </div>

                                <div class="invite-form-container">
                                    <div class="glass-input-wrapper">
                                        <input type="text" id="inviteInput" class="glass-input"
                                            placeholder="e.g. 190209012 or member@example.com"
                                            onkeydown="if(event.key === 'Enter') { handleInvite(event); return false; }">
                                        <button type="button" class="btn-invite" onclick="handleInvite(event)">Invite</button>
                                    </div>
                                </div>

                                <div class="mt-24">
                                    <h4 class="card-title" style="font-size: 0.95rem; margin-bottom: 12px;">Sent Invitations</h4>
                                    <ul class="roster-list" id="sent-invitations-list">
                                        <!-- Rendered dynamically -->
                                    </ul>
                                </div>
                            </div>

                        </div>

                        <!-- RIGHT COLUMN: Mentor Request Management & Simulation -->
                        <div class="glass-column">

                            <!-- Mentor Selection Card -->
                            <div class="glass-card" id="mentor-card">
                                <h3 class="card-title">Faculty Mentor Request</h3>
                                <p class="card-text">Select your faculty mentor. Note: you can only have one active request outstanding. If your request is pending, you must withdraw it to request a different mentor.</p>

                                <!-- State 1: No Request Sent (Select Form) -->
                                <div id="mentor-select-section" class="mt-24">
                                    <div class="login-form">
                                        <div class="input-group">
                                            <label for="mentorSelect" class="input-label">Available Faculty</label>
                                            <div class="input-wrapper input-wrapper--select">
                                                <svg class="input-icon" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="1.5">
                                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                                    <circle cx="12" cy="7" r="4" />
                                                </svg>
                                                <select id="mentorSelect" name="mentorSelect" class="glass-select">
                                                    <option value="" disabled selected>Select a Professor</option>
                                                    <option value="Prof. Jane Smith">Prof. Jane Smith (Web Tech)</option>
                                                    <option value="Prof. Alan Turing">Prof. Alan Turing (AI & Web)</option>
                                                    <option value="Dr. Sarah Connor">Dr. Sarah Connor (Full Stack)</option>
                                                </select>
                                                <svg class="select-chevron" viewBox="0 0 24 24" fill="none"
                                                    stroke="currentColor" stroke-width="2">
                                                    <polyline points="6 9 12 15 18 9" />
                                                </svg>
                                            </div>
                                        </div>

                                        <button type="button" onclick="handleMentorRequest(event)" class="login-btn mt-24">
                                            <span class="btn-text">Send Request</span>
                                            <span class="btn-arrow">
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                    <line x1="5" y1="12" x2="19" y2="12" />
                                                    <polyline points="12 5 19 12 12 19" />
                                                </svg>
                                            </span>
                                        </button>
                                    </div>
                                </div>

                                <!-- State 2: Request Pending -->
                                <div id="mentor-pending-section" class="request-banner mt-24 d-none">
                                    <div class="request-header">
                                        <svg class="request-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                            stroke-width="2">
                                            <circle cx="12" cy="12" r="10" />
                                            <polyline points="12 6 12 12 16 14" />
                                        </svg>
                                        <div>
                                            <h4 style="font-weight: 700; color: #F59E0B;">Mentor Approval Pending</h4>
                                            <p style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 2px;">
                                                Request sent to: <strong id="pending-mentor-name">Prof. Jane Smith</strong>
                                            </p>
                                        </div>
                                    </div>
                                    <button type="button" class="btn-withdraw mt-8" onclick="withdrawMentorRequest()">
                                        <svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor"
                                            stroke-width="2">
                                            <line x1="18" y1="6" x2="6" y2="18" />
                                            <line x1="6" y1="6" x2="18" y2="18" />
                                        </svg>
                                        Withdraw Request & Change Mentor
                                    </button>
                                </div>

                                <!-- State 3: Approved -->
                                <div id="mentor-approved-section" class="approved-banner mt-24 d-none">
                                    <svg class="approved-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                                        <polyline points="22 4 12 14.01 9 11.01" />
                                    </svg>
                                    <div>
                                        <h4 style="font-weight: 700; color: #34D399;">Mentor Assigned</h4>
                                        <p style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 2px;">
                                            Assigned Mentor: <strong id="assigned-mentor-name">Prof. Jane Smith</strong>
                                        </p>
                                    </div>
                                </div>
                            </div>

                            <!-- Simulation Utilities (For Testing Sync) -->
                            <div class="glass-card mt-24 simulation-card">
                                <h4 class="simulation-title">
                                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <polygon points="12 2 2 7 12 12 22 7 12 2"></polygon>
                                        <path d="M2 17l10 5 10-5"></path>
                                        <path d="M2 12l10 5 10-5"></path>
                                    </svg>
                                    Dashboard Simulator
                                </h4>
                                <p class="card-text" style="font-size:0.8rem; color: var(--text-muted);">
                                    Use these simulator buttons to approve or reject the pending mentor requests and test
                                    the UI responsiveness. State updates in real-time and will sync with the Member view page.
                                </p>

                                <div class="sim-btn-group">
                                    <button type="button" class="btn-sim btn-sim--approve" onclick="simulateMentorApproval()">Approve Request</button>
                                    <button type="button" class="btn-sim btn-sim--reject" onclick="simulateMentorRejection()">Reject Request</button>
                                </div>

                                <div style="border-top:1px solid rgba(255,255,255,0.05); margin-top:16px; padding-top:16px;">
                                    <h5 style="color:var(--text-secondary); font-size:0.8rem; margin-bottom:8px;">Invitation Simulator:</h5>
                                    <button type="button" class="btn-sim btn-sim--approve" style="width:100%;"
                                        onclick="simulateMemberAcceptance()">
                                        Simulate Member accepting first pending invite
                                    </button>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </main>
        </div>

        <!-- Member Details Modal -->
        <div id="member-details-modal" class="modal-overlay" onclick="closeMemberModal(event)">
            <div class="modal-card" onclick="event.stopPropagation()">
                <div class="modal-header-row">
                    <h3 class="card-title" style="margin-bottom:0;" id="modal-member-name">Member Name Details</h3>
                    <button type="button" class="modal-close-btn" onclick="closeMemberModal(event)">
                        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="18" y1="6" x2="6" y2="18"></line>
                            <line x1="6" y1="6" x2="18" y2="18"></line>
                        </svg>
                    </button>
                </div>
                <div class="modal-body-grid">
                    <div class="modal-detail-item">
                        <h5>Enrollment Number</h5>
                        <p id="modal-member-enrollment">987654321</p>
                    </div>
                    <div class="modal-detail-item">
                        <h5>Email Address</h5>
                        <p id="modal-member-email">member@example.com</p>
                    </div>
                    <div class="modal-detail-item">
                        <h5>Assigned Role</h5>
                        <p>Team Member / Contributor</p>
                    </div>
                    <div class="modal-detail-item">
                        <h5>Technology Focus</h5>
                        <p id="modal-member-domain">Web Development (Full Stack)</p>
                    </div>
                    <div class="modal-detail-item">
                        <h5>Task Status Stats</h5>
                        <p id="modal-member-stats" style="font-weight: 600; color: #34D399;">Completed: 3 | In Progress: 1 | To Do: 2</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Profile Details Modal -->
        <div id="profile-details-modal" class="modal-overlay" onclick="closeProfileModal(event)">
            <div class="modal-card" onclick="event.stopPropagation()">
                <div class="modal-header-row">
                    <h3 class="card-title" style="margin-bottom:0;">Student Profile</h3>
                    <button type="button" class="modal-close-btn" onclick="closeProfileModal(event)">
                        <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="18" y1="6" x2="6" y2="18"></line>
                            <line x1="6" y1="6" x2="18" y2="18"></line>
                        </svg>
                    </button>
                </div>
                <div class="modal-body-grid">
                    <div class="modal-detail-item" style="display: flex; align-items: center; gap: 16px; padding: 16px;">
                        <div class="avatar" style="background: rgba(245,158,11,0.2); color:#FCD34D; width: 48px; height: 48px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; font-weight: 800;" id="profile-avatar">S</div>
                        <div>
                            <h4 id="profile-modal-name" style="font-weight: 700; color: var(--white); margin: 0;">Student Name</h4>
                            <p id="profile-modal-role" style="font-size: 0.85rem; color: var(--text-muted); margin: 0;">Student Role</p>
                        </div>
                    </div>
                    <div class="modal-detail-item">
                        <h5>Enrollment Number</h5>
                        <p id="profile-modal-enrollment">N/A</p>
                    </div>
                    <div class="modal-detail-item">
                        <h5>Email Address</h5>
                        <p id="profile-modal-email">N/A</p>
                    </div>
                    <div class="modal-detail-item">
                        <h5>Team Details</h5>
                        <p id="profile-modal-team">N/A</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Toast Notification Element -->
        <div id="toast-message" class="toast">Action completed successfully!</div>
    </form>

    <script>
        // Shared State Definition
        const DEFAULT_STATE = {
            teamName: "Beta Lab Core Team",
            domain: "Web Development (Full Stack)",
            leader: {
                name: "Tirth Leader",
                enrollment: "123456789",
                email: "tirth.leader@example.com"
            },
            members: [
                { name: "John Doe", enrollment: "987654321", email: "john.doe@example.com" }
            ],
            invitations: [
                { id: 1, email: "alice.smith@example.com", status: "Pending" },
                { id: 2, email: "bob.johnson@example.com", status: "Pending" }
            ],
            mentorRequest: {
                status: "None", // "None", "Pending", "Approved"
                mentorName: ""
            },
            project: {
                title: "Project Board App",
                description: "Creating a collaborative dashboard workspace. The application supports team tracking, mentor selection, proposal approval workflows, and task boards for agile project development.",
                status: "Forming"
            },
            theme: "dark"
        };

        let appState = null;

        // Load state from local storage or set defaults
        function loadState() {
            const savedState = localStorage.getItem('projectBoard_studentState');
            if (savedState) {
                try {
                    appState = JSON.parse(savedState);
                } catch (e) {
                    console.error("Error parsing saved state, resetting defaults.", e);
                    appState = JSON.parse(JSON.stringify(DEFAULT_STATE));
                }
            } else {
                appState = JSON.parse(JSON.stringify(DEFAULT_STATE));
                saveState();
            }
        }

        // Save state to local storage
        function saveState() {
            localStorage.setItem('projectBoard_studentState', JSON.stringify(appState));
        }

        // Show Toast Feedback
        function showToast(message) {
            const toast = document.getElementById('toast-message');
            toast.textContent = message;
            toast.classList.add('show');
            setTimeout(() => {
                toast.classList.remove('show');
            }, 3000);
        }

        // Render UI based on state
        function renderUI() {
            // Set header info
            document.getElementById('team-name-title').textContent = appState.teamName;
            document.getElementById('team-tech-domain').textContent = `Technology Domain: ${appState.domain}`;

            // Update page status badge
            const statusBadge = document.getElementById('team-status-badge');
            if (appState.mentorRequest.status === 'Approved') {
                statusBadge.innerHTML = `<span class="status-dot" style="background:#34D399; box-shadow:0 0 8px #34D399;"></span> Active Group`;
                appState.project.status = "Active";
            } else if (appState.mentorRequest.status === 'Pending') {
                statusBadge.innerHTML = `<span class="status-dot" style="background:#FBBF24; box-shadow:0 0 8px #FBBF24;"></span> Mentor Request Pending`;
                appState.project.status = "Waiting for Mentor";
            } else {
                statusBadge.innerHTML = `<span class="status-dot" style="background:#60A5FA; box-shadow:0 0 8px #60A5FA;"></span> Team Forming`;
                appState.project.status = "Forming";
            }

            // Render Roster list
            const rosterList = document.getElementById('team-roster-list');
            rosterList.innerHTML = '';

            // Add Team Leader
            const leaderLi = document.createElement('li');
            leaderLi.className = 'roster-item leader-item';
            leaderLi.innerHTML = `
                <div class="roster-info">
                    <div class="avatar" style="background: rgba(245,158,11,0.2); color:#FCD34D;">TL</div>
                    <div>
                        <h4>${appState.leader.name}</h4>
                        <p>Enrollment: ${appState.leader.enrollment}</p>
                    </div>
                </div>
                <span class="badge badge-leader">Leader</span>
            `;
            rosterList.appendChild(leaderLi);

            // Add other members
            appState.members.forEach(member => {
                const memberLi = document.createElement('li');
                memberLi.className = 'roster-item member-clickable';
                memberLi.setAttribute('onclick', `openMemberModal('${member.name}', '${member.enrollment}', '${member.email || member.name.toLowerCase().replace(' ', '.') + '@example.com'}')`);

                // Get initials
                const initials = member.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();

                memberLi.innerHTML = `
                    <div class="roster-info">
                        <div class="avatar bg-gray" style="background: rgba(255, 255, 255, 0.1); color: var(--text-secondary);">${initials}</div>
                        <div>
                            <h4>${member.name}</h4>
                            <p>Enrollment: ${member.enrollment}</p>
                        </div>
                    </div>
                    <span class="badge badge-member">Member</span>
                `;
                rosterList.appendChild(memberLi);
            });

            // Update total roster count
            document.getElementById('member-total-count').textContent = appState.members.length + 1; // +1 for Leader

            // Update Invitation Badges
            const pendingInvitesCount = appState.invitations.filter(i => i.status === 'Pending').length;
            const acceptedInvitesCount = appState.invitations.filter(i => i.status === 'Accepted').length;

            document.getElementById('invite-total').textContent = appState.invitations.length;
            document.getElementById('invite-pending').textContent = pendingInvitesCount;
            document.getElementById('invite-accepted').textContent = acceptedInvitesCount;

            // Render invitations roster
            const inviteList = document.getElementById('sent-invitations-list');
            inviteList.innerHTML = '';

            if (appState.invitations.length === 0) {
                inviteList.innerHTML = `<li class="roster-item" style="justify-content: center; opacity: 0.5;"><p class="card-text">No invitations sent yet</p></li>`;
            } else {
                appState.invitations.forEach(invite => {
                    const inviteLi = document.createElement('li');
                    inviteLi.className = 'roster-item';

                    const isAccepted = invite.status === 'Accepted';
                    const badgeClass = isAccepted ? 'badge-accepted' : 'badge-pending';

                    inviteLi.innerHTML = `
                        <div class="roster-info">
                            <div class="avatar" style="background: rgba(255,255,255,0.05); color: var(--text-muted);">
                                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            </div>
                            <div>
                                <h4 style="font-weight: 500; font-size: 0.9rem;">${invite.email}</h4>
                                <p style="font-size: 0.75rem; color: var(--text-muted);">Invited on: 16-Jul-2026</p>
                            </div>
                        </div>
                        <span class="badge ${badgeClass}">${invite.status}</span>
                    `;
                    inviteList.appendChild(inviteLi);
                });
            }

            // Render Mentor Selection Cards States
            const selectSection = document.getElementById('mentor-select-section');
            const pendingSection = document.getElementById('mentor-pending-section');
            const approvedSection = document.getElementById('mentor-approved-section');

            // Hide all first
            selectSection.classList.add('d-none');
            pendingSection.classList.add('d-none');
            approvedSection.classList.add('d-none');

            if (appState.mentorRequest.status === 'Pending') {
                pendingSection.classList.remove('d-none');
                document.getElementById('pending-mentor-name').textContent = appState.mentorRequest.mentorName;
            } else if (appState.mentorRequest.status === 'Approved') {
                approvedSection.classList.remove('d-none');
                document.getElementById('assigned-mentor-name').textContent = appState.mentorRequest.mentorName;
            } else {
                selectSection.classList.remove('d-none');
                document.getElementById('mentorSelect').value = ""; // Reset select dropdown
            }
        }

        // Form Submit: Invite Member
        // Form Submit: Invite Member
        function handleInvite(event) {
            if (event) event.preventDefault();
            const inputVal = document.getElementById('inviteInput').value.trim();
            if (!inputVal) return;

            // Check if already in invitations or team members
            const isAlreadyInvited = appState.invitations.some(i => i.email.toLowerCase() === inputVal.toLowerCase());
            const isMember = appState.members.some(m => m.enrollment === inputVal || m.email.toLowerCase() === inputVal.toLowerCase());
            const isLeader = appState.leader.enrollment === inputVal || appState.leader.email.toLowerCase() === inputVal.toLowerCase();

            if (isAlreadyInvited) {
                showToast("This email or enrollment is already invited.");
                return;
            }
            if (isMember || isLeader) {
                showToast("This student is already a team member.");
                return;
            }

            // Add to invitations
            const newInvite = {
                id: Date.now(),
                email: inputVal.includes('@') ? inputVal : `${inputVal}@example.com`,
                status: "Pending"
            };

            appState.invitations.push(newInvite);
            saveState();
            renderUI();

            document.getElementById('inviteInput').value = '';
            showToast(`Invitation sent to ${newInvite.email}`);
        }

        // Form Submit: Mentor Request
        function handleMentorRequest(event) {
            if (event) event.preventDefault();
            const selectEl = document.getElementById('mentorSelect');
            const selectedMentor = selectEl.value;

            if (!selectedMentor) {
                showToast("Please select a faculty mentor.");
                return;
            }

            // Enforce single active request constraint
            if (appState.mentorRequest.status !== 'None') {
                showToast("There can only be one request active at a time.");
                return;
            }

            appState.mentorRequest.status = 'Pending';
            appState.mentorRequest.mentorName = selectedMentor;

            saveState();
            renderUI();
            showToast(`Mentor request sent to ${selectedMentor}`);
        }

        // Action: Withdraw Request
        function withdrawMentorRequest() {
            if (appState.mentorRequest.status !== 'Pending') return;

            const oldMentor = appState.mentorRequest.mentorName;
            appState.mentorRequest.status = 'None';
            appState.mentorRequest.mentorName = '';

            saveState();
            renderUI();
            showToast(`Withdrew request to ${oldMentor}`);
        }

        // Simulator: Approve Request
        function simulateMentorApproval() {
            if (appState.mentorRequest.status !== 'Pending') {
                showToast("No pending request to approve. Select a mentor and send a request first.");
                return;
            }

            appState.mentorRequest.status = 'Approved';
            saveState();
            renderUI();
            showToast(`Simulator: ${appState.mentorRequest.mentorName} approved the group!`);
        }

        // Simulator: Reject Request
        function simulateMentorRejection() {
            if (appState.mentorRequest.status !== 'Pending') {
                showToast("No pending request to reject. Select a mentor and send a request first.");
                return;
            }

            const rejectedMentor = appState.mentorRequest.mentorName;
            appState.mentorRequest.status = 'None';
            appState.mentorRequest.mentorName = '';

            saveState();
            renderUI();
            showToast(`Simulator: ${rejectedMentor} declined your request.`);
        }

        // Simulator: Member Acceptance
        function simulateMemberAcceptance() {
            const firstPending = appState.invitations.find(i => i.status === 'Pending');
            if (!firstPending) {
                showToast("No pending invitations to accept.");
                return;
            }

            // Modify status to accepted
            firstPending.status = 'Accepted';

            // Move to active members roster
            const name = firstPending.email.split('@')[0];
            const cleanName = name.charAt(0).toUpperCase() + name.slice(1).replace('.', ' ');
            const newMember = {
                name: cleanName,
                enrollment: String(Math.floor(100000000 + Math.random() * 900000000)),
                email: firstPending.email
            };

            appState.members.push(newMember);
            saveState();
            renderUI();
            showToast(`Simulator: ${cleanName} accepted invitation and joined!`);
        }

        // Theme Management Logic
        function toggleTheme() {
            const body = document.body;
            const btnIcon = document.getElementById('theme-icon');

            if (body.classList.contains('theme-light')) {
                // Switch to Dark Mode
                body.classList.remove('theme-light');
                appState.theme = 'dark';
                btnIcon.innerHTML = `
                    <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                `;
                showToast('Theme set to Dark.');
            } else {
                // Switch to Light Mode
                body.classList.add('theme-light');
                appState.theme = 'light';
                btnIcon.innerHTML = `
                    <circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                `;
                showToast('Theme set to Light.');
            }
            saveState();
        }

        function initTheme() {
            const body = document.body;
            const btnIcon = document.getElementById('theme-icon');
            if (!appState.theme) {
                appState.theme = 'dark';
            }

            if (appState.theme === 'light') {
                body.classList.add('theme-light');
                btnIcon.innerHTML = `
                    <circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                `;
            } else {
                body.classList.remove('theme-light');
                btnIcon.innerHTML = `
                    <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
                `;
            }
        }

        // Modal Dialog Operations
        function openMemberModal(name, enrollment, email) {
            document.getElementById('modal-member-name').textContent = name;
            document.getElementById('modal-member-enrollment').textContent = enrollment;
            document.getElementById('modal-member-email').textContent = email;

            // Randomize stats slightly to simulate task entries for demo
            const completed = Math.floor(Math.random() * 5) + 1;
            const progress = Math.floor(Math.random() * 3);
            const todo = Math.floor(Math.random() * 4) + 1;
            document.getElementById('modal-member-stats').textContent = `Completed: ${completed} | In Progress: ${progress} | To Do: ${todo}`;

            // Show modal
            document.getElementById('member-details-modal').classList.add('active');
        }

        function closeMemberModal(event) {
            document.getElementById('member-details-modal').classList.remove('active');
        }

        // Profile Modal Dialog Operations
        function openProfileModal() {
            const name = `<%= Session["FullName"] ?? "Student Leader" %>`;
            const email = `<%= Session["Email"] ?? "leader@example.com" %>`;
            const enrollment = `<%= Session["EnrollmentNo"] ?? "123456789" %>`;
            const role = "Team Leader";

            document.getElementById('profile-modal-name').textContent = name;
            document.getElementById('profile-modal-role').textContent = role;
            document.getElementById('profile-modal-enrollment').textContent = enrollment;
            document.getElementById('profile-modal-email').textContent = email;
            document.getElementById('profile-modal-team').textContent = appState.teamName + " (" + appState.domain + ")";

            const initials = name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
            document.getElementById('profile-avatar').textContent = initials;

            document.getElementById('profile-details-modal').classList.add('active');
        }

        function closeProfileModal(event) {
            document.getElementById('profile-details-modal').classList.remove('active');
        }

        // Page Init
        document.addEventListener('DOMContentLoaded', () => {
            loadState();
            initTheme();
            renderUI();
        });
    </script>
</body>

</html>
