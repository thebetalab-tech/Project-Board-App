// Modal Logic for Admin Pages
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if(modal) {
        modal.classList.add('active');
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if(modal) {
        modal.classList.remove('active');
    }
}

// Close modal when clicking outside content
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', (e) => {
            if(e.target === overlay) {
                overlay.classList.remove('active');
            }
        });
    });

    // Generic filter functionality for all search/filter inputs
    const searchInputs = document.querySelectorAll('.search-bar input');
    
    searchInputs.forEach(input => {
        input.addEventListener('keyup', function() {
            const filterValue = this.value.toLowerCase();
            const tableRows = document.querySelectorAll('tbody tr');
            
            tableRows.forEach(row => {
                const text = row.textContent.toLowerCase();
                if (text.includes(filterValue)) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        });
    });

    // Mobile Responsiveness Logic
    const mainContent = document.querySelector('.main-content');
    if (mainContent) {
        // Inject Mobile Toggle FAB (Floating Action Button)
        const toggleBtn = document.createElement('button');
        toggleBtn.className = 'mobile-toggle';
        toggleBtn.innerHTML = '<i class="fa-solid fa-bars"></i>';
        document.body.appendChild(toggleBtn);

        const sidebar = document.querySelector('.sidebar');
        
        // Inject Overlay
        const mobileOverlay = document.createElement('div');
        mobileOverlay.className = 'mobile-sidebar-overlay';
        document.body.appendChild(mobileOverlay);

        toggleBtn.addEventListener('click', () => {
            if (sidebar) {
                sidebar.classList.toggle('active');
                mobileOverlay.classList.toggle('active');
                // Toggle icon
                if (sidebar.classList.contains('active')) {
                    toggleBtn.innerHTML = '<i class="fa-solid fa-xmark"></i>';
                } else {
                    toggleBtn.innerHTML = '<i class="fa-solid fa-bars"></i>';
                }
            }
        });
        
        mobileOverlay.addEventListener('click', () => {
            if (sidebar) {
                sidebar.classList.remove('active');
                mobileOverlay.classList.remove('active');
                toggleBtn.innerHTML = '<i class="fa-solid fa-bars"></i>';
            }
        });
    }

    // Auto-wrap tables for responsiveness
    const dataSections = document.querySelectorAll('.data-section');
    dataSections.forEach(section => {
        const table = section.querySelector('table');
        if (table && !table.parentElement.classList.contains('table-responsive')) {
            const wrapper = document.createElement('div');
            wrapper.className = 'table-responsive';
            table.parentNode.insertBefore(wrapper, table);
            wrapper.appendChild(table);
        }
    });

    // Profile Dropdown Toggle
    const profileTrigger = document.querySelector('.profile-trigger');
    const profileDropdown = document.querySelector('.profile-dropdown');
    
    if (profileTrigger && profileDropdown) {
        profileTrigger.addEventListener('click', (e) => {
            e.stopPropagation();
            profileTrigger.classList.toggle('active');
            profileDropdown.classList.toggle('show');
        });
        
        document.addEventListener('click', (e) => {
            if (!profileTrigger.contains(e.target) && !profileDropdown.contains(e.target)) {
                profileTrigger.classList.remove('active');
                profileDropdown.classList.remove('show');
            }
        });
    }

    // Sidebar Toggle Logic
    const sidebarToggleBtn = document.getElementById('sidebarToggle');
    if (sidebarToggleBtn) {
        // Initialize from localStorage
        if (localStorage.getItem('sidebarCollapsed') === 'true') {
            document.body.classList.add('sidebar-collapsed');
        }
        
        sidebarToggleBtn.addEventListener('click', () => {
            document.body.classList.toggle('sidebar-collapsed');
            const isCollapsed = document.body.classList.contains('sidebar-collapsed');
            localStorage.setItem('sidebarCollapsed', isCollapsed);
        });
    }
});

// Generic Password Show/Hide Toggle Logic (for Admin/Profile pages)
document.addEventListener('click', (e) => {
    const toggleBtn = e.target.closest('.password-toggle');
    if (toggleBtn) {
        e.preventDefault();
        e.stopPropagation();
        
        const wrapper = toggleBtn.closest('.input-wrapper') || toggleBtn.parentElement;
        if (!wrapper) return;

        const input = wrapper.querySelector('input');
        if (!input) return;

        const eyeOpen = toggleBtn.querySelector('.eye-open');
        const eyeClosed = toggleBtn.querySelector('.eye-closed');

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

        toggleBtn.style.transform = 'translateY(-50%) scale(0.8)';
        setTimeout(() => {
            toggleBtn.style.transform = '';
        }, 150);
    }
});

