/* ============================================
   PROJECT BOARD — LOGIN PAGE SCRIPTS
   3D Background, Particles, Form Interactions
   ============================================ */

document.addEventListener('DOMContentLoaded', () => {
    initParticles();
    initPasswordToggle();
    initPasswordStrength();
    initFormValidation();
    initRippleEffect();
    initInputAnimations();
    initSeamlessVideoLoop();
});


/* ============================================
   PASSWORD STRENGTH METER
   ============================================ */
function updatePasswordStrength(passwordInput) {
    if (!passwordInput) return;
    const strengthContainer = document.getElementById('passwordStrength');
    const strengthLabel = document.getElementById('strengthLabel');
    if (!strengthContainer || !strengthLabel) return;

    const bars = strengthContainer.querySelectorAll('.strength-bar');
    const reqItems = strengthContainer.querySelectorAll('.strength-requirements li');
    const val = passwordInput.value;

    if (!val.length) {
        strengthContainer.classList.remove('visible');
        bars.forEach(bar => {
            bar.classList.remove('active');
            bar.removeAttribute('data-level');
        });
        strengthLabel.textContent = '';
        strengthLabel.removeAttribute('data-level');
        reqItems.forEach(li => li.classList.remove('met'));
        return;
    }

    strengthContainer.classList.add('visible');

    // Check individual requirements
    const checks = {
        length: val.length >= 8,
        uppercase: /[A-Z]/.test(val),
        lowercase: /[a-z]/.test(val),
        number: /[0-9]/.test(val),
        special: /[^a-zA-Z0-9]/.test(val)
    };

    // Update requirement checklist
    reqItems.forEach(li => {
        const req = li.getAttribute('data-req');
        if (checks[req]) {
            li.classList.add('met');
        } else {
            li.classList.remove('met');
        }
    });

    // Evaluate overall strength
    const score = evaluatePassword(val, checks);
    const levels = ['weak', 'fair', 'good', 'strong'];
    const labels = ['Weak', 'Fair', 'Good', 'Strong'];
    const level = levels[score];

    bars.forEach((bar, i) => {
        if (i <= score) {
            bar.classList.add('active');
            bar.setAttribute('data-level', level);
        } else {
            bar.classList.remove('active');
            bar.removeAttribute('data-level');
        }
    });

    strengthLabel.textContent = labels[score];
    strengthLabel.setAttribute('data-level', level);
}

function initPasswordStrength() {
    const passwordInput = document.getElementById('password');
    if (passwordInput) {
        updatePasswordStrength(passwordInput);
    }
}

function evaluatePassword(password, checks) {
    let score = 0;

    // Length checks
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety
    const variety = [checks.lowercase, checks.uppercase, checks.number, checks.special].filter(Boolean).length;
    if (variety >= 2) score++;
    if (variety >= 4) score++;

    // Clamp to 0-3 (weak, fair, good, strong)
    return Math.min(Math.max(score - 1, 0), 3);
}


/* ============================================
   FLOATING PARTICLES
   ============================================ */
function initParticles() {
    const field = document.getElementById('particleField');
    if (!field) return;

    const particleCount = 30;

    for (let i = 0; i < particleCount; i++) {
        createParticle(field, i);
    }
}

function createParticle(container, index) {
    const particle = document.createElement('div');
    particle.classList.add('particle');

    // Randomize properties
    const size = Math.random() * 3 + 1;
    const left = Math.random() * 100;
    const duration = Math.random() * 12 + 10;
    const delay = Math.random() * 15;
    const opacity = Math.random() * 0.4 + 0.1;

    // Some particles are red-tinted
    const isRed = Math.random() > 0.7;

    particle.style.cssText = `
        width: ${size}px;
        height: ${size}px;
        left: ${left}%;
        animation-duration: ${duration}s;
        animation-delay: ${delay}s;
        opacity: 0;
        background: ${isRed ? 'rgba(163, 11, 11, 0.6)' : 'rgba(255, 255, 255, 0.5)'};
        box-shadow: 0 0 ${size * 2}px ${isRed ? 'rgba(163, 11, 11, 0.3)' : 'rgba(255, 255, 255, 0.2)'};
    `;

    container.appendChild(particle);
}


/* ============================================
   PASSWORD SHOW/HIDE TOGGLE
   ============================================ */
function togglePasswordVisibility(button) {
    if (!button) return;
    const wrapper = button.closest('.input-wrapper') || button.parentElement;
    if (!wrapper) return;

    const input = wrapper.querySelector('input');
    if (!input) return;

    const eyeOpen = button.querySelector('.eye-open');
    const eyeClosed = button.querySelector('.eye-closed');

    const currentType = input.getAttribute('type') || input.type;
    const isPassword = currentType === 'password';

    if (isPassword) {
        input.type = 'text';
        input.setAttribute('type', 'text');
        if (eyeOpen) eyeOpen.style.display = 'none';
        if (eyeClosed) eyeClosed.style.display = 'block';
    } else {
        input.type = 'password';
        input.setAttribute('type', 'password');
        if (eyeOpen) eyeOpen.style.display = 'block';
        if (eyeClosed) eyeClosed.style.display = 'none';
    }

    // Micro animation on toggle — preserve translateY(-50%) for vertical centering
    button.style.transform = 'translateY(-50%) scale(0.8)';
    setTimeout(() => {
        button.style.transform = '';
    }, 150);
}

function initPasswordToggle() {
    // Handled via global event delegation below
}

// Global Event Delegation for dynamic/ASP.NET renders and password input
document.addEventListener('click', (e) => {
    const toggleBtn = e.target.closest('.password-toggle');
    if (toggleBtn) {
        e.preventDefault();
        e.stopPropagation();
        togglePasswordVisibility(toggleBtn);
    }
});

document.addEventListener('input', (e) => {
    if (e.target && e.target.id === 'password') {
        updatePasswordStrength(e.target);
    }
});




/* ============================================
   FORM VALIDATION & SUBMIT
   ============================================ */
function initFormValidation() {
    const form = document.getElementById('loginForm') || document.getElementById('signupForm');
    const loginBtn = document.getElementById('loginBtn');

    // Support both Default.aspx (txtLoginID, txtPassword) and SignUp.aspx (loginId, password)
    const loginIdInput = document.getElementById('loginId') || document.getElementById('txtLoginID');
    const passwordInput = document.getElementById('password') || document.getElementById('txtPassword');
    const emailGroup = document.getElementById('emailGroup');
    const passwordGroup = document.getElementById('passwordGroup');

    if (form) {
        form.addEventListener('submit', (e) => {
            // Let ASP.NET handle the submit if it's an asp:LinkButton
            // e.preventDefault(); 
        });
    }

    if (loginIdInput && emailGroup) {
        loginIdInput.addEventListener('input', () => {
            emailGroup.classList.remove('error');
        });
    }

    if (passwordInput && passwordGroup) {
        passwordInput.addEventListener('input', () => {
            passwordGroup.classList.remove('error');
        });
    }
}

function showSuccessPulse() {
    const card = document.querySelector('.form-side-content');
    if (!card) return;
    card.style.filter = 'drop-shadow(0 0 20px rgba(46, 204, 113, 0.35))';
    setTimeout(() => {
        card.style.filter = '';
    }, 1500);
}


/* ============================================
   BUTTON RIPPLE EFFECT
   ============================================ */
function initRippleEffect() {
    const loginBtn = document.getElementById('loginBtn');
    if (!loginBtn) return;

    loginBtn.addEventListener('click', (e) => {
        const ripple = loginBtn.querySelector('.btn-ripple');
        const rect = loginBtn.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);

        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
        ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';

        ripple.classList.remove('active');
        // Force reflow
        void ripple.offsetWidth;
        ripple.classList.add('active');

        setTimeout(() => {
            ripple.classList.remove('active');
        }, 600);
    });
}


/* ============================================
   INPUT FOCUS ANIMATIONS
   ============================================ */
function initInputAnimations() {
    const inputs = document.querySelectorAll('.input-wrapper input');

    inputs.forEach(input => {
        // Floating label effect on focus/blur
        input.addEventListener('focus', () => {
            input.closest('.input-group').classList.add('focused');
        });

        input.addEventListener('blur', () => {
            input.closest('.input-group').classList.remove('focused');
            if (input.value.trim()) {
                input.closest('.input-group').classList.add('has-value');
            } else {
                input.closest('.input-group').classList.remove('has-value');
            }
        });
    });

    // Links hover sound (visual feedback only)
    const links = document.querySelectorAll('.forgot-link, .register-btn');
    links.forEach(link => {
        link.addEventListener('mouseenter', () => {
            link.style.transition = 'all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1)';
        });
    });
}

/* ============================================
   SEAMLESS VIDEO LOOP CROSSFADE
   ============================================ */
function initSeamlessVideoLoop() {
    const v1 = document.getElementById('bg-video-1');
    const v2 = document.getElementById('bg-video-2');
    if (!v1 || !v2) return;

    let activeVideo = v1;
    let inactiveVideo = v2;
    let crossfading = false;
    const crossfadeTime = 1.2; // matching CSS opacity transition

    function checkTime() {
        if (crossfading) return;

        const duration = activeVideo.duration;
        if (!duration || isNaN(duration)) return;

        // Trigger crossfade 1.5 seconds before the active video ends
        if (activeVideo.currentTime >= duration - 1.5) {
            crossfading = true;

            inactiveVideo.currentTime = 0;
            inactiveVideo.play().then(() => {
                // Crossfade: fade inactive video in, active video out
                inactiveVideo.style.opacity = '1';
                activeVideo.style.opacity = '0';

                setTimeout(() => {
                    activeVideo.pause();
                    activeVideo.currentTime = 0;

                    // Swap references
                    const temp = activeVideo;
                    activeVideo = inactiveVideo;
                    inactiveVideo = temp;
                    crossfading = false;
                }, crossfadeTime * 1000);
            }).catch(err => {
                console.warn("Seamless video loop play failed:", err);
                crossfading = false;
            });
        }
    }

    // Check progress on timeupdate
    v1.addEventListener('timeupdate', checkTime);
    v2.addEventListener('timeupdate', checkTime);

    // Fallbacks
    v1.addEventListener('ended', () => {
        if (activeVideo === v1) {
            v2.currentTime = 0;
            v2.play();
            v2.style.opacity = '1';
            v1.style.opacity = '0';
            activeVideo = v2;
            inactiveVideo = v1;
        }
    });

    v2.addEventListener('ended', () => {
        if (activeVideo === v2) {
            v1.currentTime = 0;
            v1.play();
            v1.style.opacity = '1';
            v2.style.opacity = '0';
            activeVideo = v1;
            inactiveVideo = v2;
        }
    });
}
