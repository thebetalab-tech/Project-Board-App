<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="NotFoundPage.aspx.cs" Inherits="Project_Board.NotFoundPage" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>404 - Page Not Found | Project Board</title>
    <meta name="description" content="This is not the web page you are looking for." />

    <!-- Fonts & FontAwesome -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@700;800;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

    <style>
        :root {
            --sky-blue: #64b2dc;
            --sand-top: #e8d39e;
            --sand-bottom: #d1b47b;
            --text-dark: #1e293b;
            --text-muted: #475569;
            --btn-primary: #7B1E2D; /* Burgundy matching Faculty Dashboard theme */
            --btn-primary-hover: #5C0E1B;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body, html {
            width: 100%;
            height: 100%;
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: var(--sand-bottom);
            color: var(--text-dark);
        }

        .page-viewport {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
            background: linear-gradient(
                to bottom,
                #5aa9d6 0%,
                #64b2dc 42%,
                #e8d39e 42.1%,
                #d3b67d 80%,
                #c9aa6d 100%
            );
            overflow-x: hidden;
        }

        /* Top Brand Header */
        .top-navbar {
            padding: 1.5rem 2.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            z-index: 10;
        }

        .brand-link {
            display: flex;
            align-items: center;
            gap: 0.6rem;
            text-decoration: none;
            color: #ffffff;
            font-family: 'Outfit', sans-serif;
            font-size: 1.35rem;
            font-weight: 800;
            text-shadow: 0 1px 3px rgba(0, 0, 0, 0.2);
        }

        .brand-link i {
            font-size: 1.4rem;
        }

        .nav-badge {
            background: rgba(255, 255, 255, 0.25);
            backdrop-filter: blur(8px);
            color: #ffffff;
            font-size: 0.85rem;
            font-weight: 600;
            padding: 0.4rem 1rem;
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }

        /* Main Scene Container */
        .main-scene {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 1.5rem;
            position: relative;
            z-index: 5;
        }

        .scene-content {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 2.5rem;
            max-width: 1050px;
            width: 100%;
        }

        /* Left Side: 404 Text & Speech Bubble */
        .left-panel {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            max-width: 440px;
        }

        .huge-404 {
            font-family: 'Outfit', sans-serif;
            font-size: clamp(6rem, 12vw, 9.5rem);
            font-weight: 900;
            line-height: 0.85;
            color: #ffffff;
            text-shadow: 0 6px 0 rgba(0, 0, 0, 0.12), 0 12px 24px rgba(0, 0, 0, 0.1);
            letter-spacing: -3px;
            margin-bottom: 1.25rem;
        }

        /* White Speech Bubble */
        .speech-card {
            position: relative;
            background: #ffffff;
            padding: 1.5rem 1.75rem;
            border-radius: 16px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.12), 0 2px 6px rgba(0, 0, 0, 0.06);
            color: var(--text-dark);
        }

        /* Pointer tail pointing right to mascot */
        .speech-card::after {
            content: '';
            position: absolute;
            right: -16px;
            top: 50%;
            transform: translateY(-50%);
            border-style: solid;
            border-width: 12px 0 12px 16px;
            border-color: transparent transparent transparent #ffffff;
        }

        .speech-card h2 {
            font-family: 'Outfit', sans-serif;
            font-size: 1.3rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.4rem;
            line-height: 1.3;
        }

        .speech-card p {
            font-size: 0.92rem;
            color: var(--text-muted);
            line-height: 1.5;
        }

        /* Right Side: Desert Artwork & Mascot */
        .right-panel {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 480px;
            height: 320px;
        }

        .desert-svg {
            width: 100%;
            height: 100%;
            overflow: visible;
        }

        /* Classic Buttons Bar at Bottom */
        .actions-bar {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 1rem;
            padding-bottom: 3rem;
            z-index: 10;
        }

        .btn-classic {
            display: inline-flex;
            align-items: center;
            gap: 0.6rem;
            padding: 0.85rem 1.75rem;
            border-radius: 10px;
            font-family: 'Inter', sans-serif;
            font-size: 0.95rem;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
        }

        .btn-classic-primary {
            background-color: var(--btn-primary);
            color: #ffffff;
            box-shadow: 0 4px 14px rgba(123, 30, 45, 0.3);
        }

        .btn-classic-primary:hover {
            background-color: var(--btn-primary-hover);
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(123, 30, 45, 0.4);
        }

        .btn-classic-secondary {
            background-color: #ffffff;
            color: var(--text-dark);
            border: 1px solid rgba(0, 0, 0, 0.12);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
        }

        .btn-classic-secondary:hover {
            background-color: #f8fafc;
            border-color: rgba(0, 0, 0, 0.2);
            transform: translateY(-2px);
        }

        /* Mobile Adjustments */
        @media (max-width: 820px) {
            .scene-content {
                flex-direction: column;
                text-align: center;
                gap: 2rem;
            }

            .left-panel {
                align-items: center;
            }

            .speech-card::after {
                right: 50%;
                top: auto;
                bottom: -16px;
                transform: translateX(50%);
                border-width: 16px 12px 0 12px;
                border-color: #ffffff transparent transparent transparent;
            }

            .right-panel {
                width: 100%;
                max-width: 380px;
                height: 260px;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="page-viewport">
            <!-- Top Navbar -->
            <header class="top-navbar">
                <a href="<%= ResolveUrl("~/Default.aspx") %>" class="brand-link">
                    <i class="fa-solid fa-graduation-cap"></i>
                    <span>Project Board</span>
                </a>
                <span class="nav-badge">
                    <i class="fa-solid fa-circle-exclamation" style="margin-right: 5px;"></i> Error 404
                </span>
            </header>

            <!-- Main Desert 404 Scene -->
            <main class="main-scene">
                <div class="scene-content">
                    
                    <!-- Left: Bold 404 & White Speech Bubble -->
                    <div class="left-panel">
                        <h1 class="huge-404">404</h1>
                        <div class="speech-card">
                            <h2>This is not the web page you are looking for.</h2>
                            <p>The page you requested could not be found or has been moved to another board.</p>
                        </div>
                    </div>

                    <!-- Right: Desert Scenery Vector Illustration -->
                    <div class="right-panel">
                        <svg class="desert-svg" viewBox="0 0 480 320" fill="none" xmlns="http://www.w3.org/2000/svg">
                            
                            <!-- Background Desert Buildings / Domes -->
                            <g opacity="0.85">
                                <!-- Far Dome Building 1 -->
                                <path d="M340 135 C340 115 365 115 365 135 Z" fill="#d9be85" />
                                <rect x="335" y="135" width="35" height="15" fill="#c7aa6e" />
                                
                                <!-- Far Dome Building 2 -->
                                <path d="M400 130 C400 110 430 110 430 130 Z" fill="#d0b378" />
                                <rect x="395" y="130" width="40" height="20" fill="#bfa063" />
                                <rect x="410" y="136" width="6" height="10" rx="1" fill="#7a6132" />

                                <!-- Moisture Evaporator Antenna Towers -->
                                <line x1="320" y1="148" x2="320" y2="105" stroke="#a88c52" stroke-width="2" />
                                <circle cx="320" cy="115" r="4" fill="#a88c52" />
                                <circle cx="320" cy="125" r="5" fill="#a88c52" />
                            </g>

                            <!-- Hovering Landspeeder Vehicle -->
                            <g>
                                <!-- Vehicle Ground Shadow -->
                                <ellipse cx="270" cy="220" rx="75" ry="12" fill="#a3864a" opacity="0.5" />
                                
                                <!-- Landspeeder Main Body -->
                                <path d="M200 195 C200 185 220 180 270 180 L340 183 C350 183 355 190 355 198 L345 208 C340 213 325 215 270 215 C215 215 200 208 200 195 Z" fill="#b58d59" stroke="#8c6637" stroke-width="2" />

                                <!-- Windshield (Blue Glass) -->
                                <path d="M260 180 C265 168 285 168 290 180 Z" fill="#4fa4d4" opacity="0.9" />

                                <!-- Turbine Engines -->
                                <rect x="225" y="172" width="35" height="12" rx="4" fill="#8c6637" />
                                <rect x="275" y="172" width="35" height="12" rx="4" fill="#8c6637" />
                            </g>

                            <!-- Mascot Ground Shadow -->
                            <ellipse cx="120" cy="268" rx="45" ry="10" fill="#a3864a" opacity="0.65" />

                            <!-- Mascot in Jedi Robe / Cloak (Inspired by Octocat Jedi 404) -->
                            <g id="jediMascot">
                                <!-- Brown Hood & Cloak Body -->
                                <path d="M85 160 C80 220 90 262 120 262 C150 262 160 220 155 160 C150 125 138 110 120 110 C102 110 90 125 85 160 Z" fill="#5c4028" stroke="#3b2716" stroke-width="2.5" />
                                
                                <!-- Inner Cloak Layer -->
                                <path d="M102 165 L120 245 L138 165 Z" fill="#ebd7b0" />

                                <!-- Outer Hood Shadow Trim -->
                                <path d="M92 155 C98 128 108 120 120 120 C132 120 142 128 148 155 C136 142 128 138 120 138 C112 138 104 142 92 155 Z" fill="#3b2716" />

                                <!-- Cute Cat / Mascot Head inside Hood -->
                                <ellipse cx="120" cy="152" rx="20" ry="17" fill="#1e293b" />
                                
                                <!-- Cute Ears popping from Hood -->
                                <path d="M98 138 L90 122 L105 130 Z" fill="#5c4028" />
                                <path d="M142 138 L150 122 L135 130 Z" fill="#5c4028" />

                                <!-- Expressive Red / Orange Eyes (Star Wars / Octocat 404 style) -->
                                <circle cx="112" cy="151" r="4" fill="#ef4444" />
                                <circle cx="128" cy="151" r="4" fill="#ef4444" />
                                <circle cx="113" cy="150" r="1.5" fill="#ffffff" />
                                <circle cx="129" cy="150" r="1.5" fill="#ffffff" />

                                <!-- Small Nose & Whiskers -->
                                <circle cx="120" cy="156" r="1.5" fill="#f87171" />

                                <!-- Cloak Sleeves / Arms -->
                                <path d="M88 175 C75 190 70 210 82 225 C88 220 92 200 95 185 Z" fill="#4a331f" stroke="#3b2716" stroke-width="2" />
                                <path d="M152 175 C165 190 170 210 158 225 C152 220 148 200 145 185 Z" fill="#4a331f" stroke="#3b2716" stroke-width="2" />
                            </g>

                        </svg>
                    </div>

                </div>
            </main>

            <!-- Bottom Action Buttons -->
            <footer class="actions-bar">
                <a href="<%= ResolveUrl("~/Default.aspx") %>" class="btn-classic btn-classic-primary">
                    <i class="fa-solid fa-house"></i>
                    <span>Return to Dashboard</span>
                </a>
                <button type="button" class="btn-classic btn-classic-secondary" onclick="window.history.back()">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>Go Back</span>
                </button>
            </footer>
        </div>
    </form>
</body>
</html>
