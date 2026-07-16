<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Student_Member.aspx.cs" Inherits="Project_Board.UI.Student.Student_Member" %>

<!DOCTYPE html>
<html lang="en">

<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Member Dashboard — Project Board</title>
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
                <nav class="sidebar-nav" id="sidebar-navigation">
                    <a href="../../HTML/dashboard-student.html" class="nav-item">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                            <polyline points="9 22 9 12 15 12 15 22" />
                        </svg>
                        Student Home
                    </a>
                    <a href="#" class="nav-item active">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                        </svg>
                        Member Panel
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
                            <span class="status-dot"></span> Mentor Selection
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

                        <!-- LEFT COLUMN: Leader Info & Project Details -->
                        <div class="glass-column">

                            <!-- Team Leader Card -->
                            <div class="glass-card">
                                <h3 class="card-title">Team Leader</h3>
                                <div class="leader-card-detail">
                                    <div class="leader-avatar" id="leader-avatar-initials">TL</div>
                                    <div class="leader-meta">
                                        <h4 id="leader-name">Tirth Leader</h4>
                                        <p>Enrollment: <span id="leader-enrollment">123456789</span></p>
                                        <p>Email: <span id="leader-email">tirth.leader@example.com</span></p>
                                    </div>
                                </div>
                            </div>

                            <!-- Project Details Card -->
                            <div class="glass-card mt-24">
                                <h3 class="card-title">Project Specifications</h3>
                                <p class="card-text">Core specifications and technology alignment details submitted for the academic project board.</p>

                                <div class="project-detail-list">
                                    <div class="project-detail-item">
                                        <h5>Project Title</h5>
                                        <p id="project-title"
                                            style="font-weight: 700; color: var(--white); font-size: 1.1rem;"></p>
                                    </div>
                                    <div class="project-detail-item">
                                        <h5>Domain Alignment</h5>
                                        <p id="project-domain"></p>
                                    </div>
                                    <div class="project-detail-item">
                                        <h5>Functional Scope</h5>
                                        <p id="project-description"></p>
                                    </div>
                                </div>
                            </div>

                        </div>

                        <!-- RIGHT COLUMN: Mentor Details -->
                        <div class="glass-column">

                            <!-- Mentor Status Card -->
                            <div class="glass-card">
                                <h3 class="card-title">Faculty Mentor Status</h3>
                                <p class="card-text">Current status of your team's faculty mentor request. Updates are synced automatically when the leader makes a change.</p>

                                <!-- State Box Container (rendered dynamically) -->
                                <div id="mentor-status-container">
                                    <!-- Dynamic Status Box -->
                                </div>

                                <div class="mentor-role-info">
                                    <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor"
                                        stroke-width="2">
                                        <circle cx="12" cy="12" r="10" />
                                        <line x1="12" y1="8" x2="12" y2="12" />
                                        <line x1="12" y1="16" x2="12.01" y2="16" />
                                    </svg>
                                    <span>Only the Team Leader has permissions to select or change mentors.</span>
                                </div>
                            </div>

                            <!-- Active Roster Panel -->
                            <div class="glass-card mt-24">
                                <h3 class="card-title">Roster Members</h3>
                                <ul class="roster-list" id="member-roster-list" style="margin-top: 16px;">
                                    <!-- Dynamic roster list -->
                                </ul>
                            </div>

                        </div>
                    </div>
                </div>
            </main>
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
        // Shared State Definition (fallback if localStorage empty)
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
                appState = JSON.parse(DEFAULT_STATE);
                localStorage.setItem('projectBoard_studentState', JSON.stringify(appState));
            }
        }

        // Render UI elements
        function renderUI() {
            // Dynamically show Return to Leader Panel if role is Leader
            const navContainer = document.getElementById('sidebar-navigation');
            const hasLeaderLink = document.getElementById('nav-back-to-leader');
            const currentRole = localStorage.getItem('projectBoard_userRole');

            if (currentRole === 'Leader') {
                if (!hasLeaderLink) {
                    const leaderLink = document.createElement('a');
                    leaderLink.href = 'Student_Leader.aspx';
                    leaderLink.className = 'nav-item';
                    leaderLink.id = 'nav-back-to-leader';
                    leaderLink.innerHTML = `
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M23 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" /></svg>
                        Leader Panel
                    `;
                    navContainer.insertBefore(leaderLink, navContainer.children[1]);
                }
            } else {
                if (hasLeaderLink) {
                    hasLeaderLink.remove();
                }
            }

            // Set header info
            document.getElementById('team-name-title').textContent = appState.teamName;
            document.getElementById('team-tech-domain').textContent = `Technology Domain: ${appState.domain}`;

            // Set Leader Info
            document.getElementById('leader-name').textContent = appState.leader.name;
            document.getElementById('leader-enrollment').textContent = appState.leader.enrollment;
            document.getElementById('leader-email').textContent = appState.leader.email;

            // Leader Initials
            const leaderInitials = appState.leader.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
            document.getElementById('leader-avatar-initials').textContent = leaderInitials;

            // Set Project Specs
            document.getElementById('project-title').textContent = appState.project.title;
            document.getElementById('project-domain').textContent = appState.domain;
            document.getElementById('project-description').textContent = appState.project.description;

            // Update page status badge
            const statusBadge = document.getElementById('team-status-badge');
            if (appState.mentorRequest.status === 'Approved') {
                statusBadge.innerHTML = `<span class="status-dot" style="background:#34D399; box-shadow:0 0 8px #34D399;"></span> Active Group`;
            } else if (appState.mentorRequest.status === 'Pending') {
                statusBadge.innerHTML = `<span class="status-dot" style="background:#FBBF24; box-shadow:0 0 8px #FBBF24;"></span> Mentor Selection`;
            } else {
                statusBadge.innerHTML = `<span class="status-dot" style="background:#60A5FA; box-shadow:0 0 8px #60A5FA;"></span> Team Forming`;
            }

            // Render Mentor Status Box
            const mentorContainer = document.getElementById('mentor-status-container');
            mentorContainer.innerHTML = '';

            const status = appState.mentorRequest.status;
            if (status === 'Approved') {
                mentorContainer.innerHTML = `
                    <div class="mentor-status-box mentor-status-box--approved">
                        <div class="status-box-icon status-box-icon--approved">
                            <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/>
                            </svg>
                        </div>
                        <div>
                            <h4 style="font-weight: 700; color: #34D399; font-size: 1.1rem;">Assigned Mentor</h4>
                            <p style="font-size: 1rem; color: var(--text-primary); margin-top: 6px; font-weight: 600;">
                                ${appState.mentorRequest.mentorName}
                            </p>
                            <p style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 4px;">
                                Your group has been approved and matched with this mentor.
                            </p>
                        </div>
                    </div>
                `;
            } else if (status === 'Pending') {
                mentorContainer.innerHTML = `
                    <div class="mentor-status-box mentor-status-box--pending">
                        <div class="status-box-icon status-box-icon--pending">
                            <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                            </svg>
                        </div>
                        <div>
                            <h4 style="font-weight: 700; color: #F59E0B; font-size: 1.1rem;">Request Pending Faculty Approval</h4>
                            <p style="font-size: 1rem; color: var(--text-primary); margin-top: 6px; font-weight: 600;">
                                ${appState.mentorRequest.mentorName}
                            </p>
                            <p style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 4px;">
                                Team Leader sent a request. Waiting for professor response.
                            </p>
                        </div>
                    </div>
                `;
            } else {
                mentorContainer.innerHTML = `
                    <div class="mentor-status-box mentor-status-box--none">
                        <div class="status-box-icon status-box-icon--none">
                            <svg viewBox="0 0 24 24" width="24" height="24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" /><circle cx="12" cy="7" r="4" />
                            </svg>
                        </div>
                        <div>
                            <h4 style="font-weight: 700; color: var(--text-secondary); font-size: 1.1rem;">No Mentor Requested</h4>
                            <p style="font-size: 0.85rem; color: var(--text-muted); margin-top: 6px; line-height: 1.4;">
                                Your team leader hasn't submitted a faculty mentor request yet. Once submitted, status updates will show here.
                            </p>
                        </div>
                    </div>
                `;
            }

            // Render Roster Members
            const rosterList = document.getElementById('member-roster-list');
            rosterList.innerHTML = '';

            // Add leader
            const leaderLi = document.createElement('li');
            leaderLi.className = 'roster-item leader-item';
            leaderLi.innerHTML = `
                <div class="roster-info">
                    <div class="avatar" style="background: rgba(245,158,11,0.2); color:#FCD34D;">TL</div>
                    <div>
                        <h4>${appState.leader.name}</h4>
                        <p>Leader</p>
                    </div>
                </div>
                <span class="badge badge-leader">Leader</span>
            `;
            rosterList.appendChild(leaderLi);

            // Add members
            appState.members.forEach(member => {
                const memberLi = document.createElement('li');
                memberLi.className = 'roster-item';
                const initials = member.name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();
                memberLi.innerHTML = `
                    <div class="roster-info">
                        <div class="avatar bg-gray" style="background: rgba(255, 255, 255, 0.1); color: var(--text-secondary);">${initials}</div>
                        <div>
                            <h4>${member.name}</h4>
                            <p>Member</p>
                        </div>
                    </div>
                    <span class="badge badge-member">Member</span>
                `;
                rosterList.appendChild(memberLi);
            });
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
            } else {
                // Switch to Light Mode
                body.classList.add('theme-light');
                appState.theme = 'light';
                btnIcon.innerHTML = `
                    <circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/>
                `;
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

        // Show Toast Feedback
        function showToast(message) {
            const toast = document.getElementById('toast-message');
            toast.textContent = message;
            toast.classList.add('show');
            setTimeout(() => {
                toast.classList.remove('show');
            }, 4000);
        }

        // Profile Modal Dialog Operations
        function openProfileModal() {
            const name = `<%= Session["FullName"] ?? "Student Member" %>`;
            const email = `<%= Session["Email"] ?? "member@example.com" %>`;
            const enrollment = `<%= Session["EnrollmentNo"] ?? "987654321" %>`;
            const role = "Team Member";

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

            // Check for access denied warnings in URL params
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('error') === 'access-denied') {
                localStorage.setItem('projectBoard_userRole', 'Member');
                setTimeout(() => {
                    showToast("Access Denied: You do not have permissions to access the Team Leader Panel.");
                }, 300);

                // Clean the search params from navigation bar
                const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                window.history.replaceState({ path: cleanUrl }, '', cleanUrl);
            }

            // Set up a storage listener so that if Leader modifies state in another tab, Member dashboard updates automatically
            window.addEventListener('storage', (event) => {
                if (event.key === 'projectBoard_studentState') {
                    loadState();
                    initTheme();
                    renderUI();
                }
            });
        });
    </script>
</body>

</html>
