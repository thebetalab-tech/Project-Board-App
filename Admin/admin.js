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

    // Prevent form submission on demo
    const addUserForm = document.getElementById('addUserForm');
    if(addUserForm) {
        addUserForm.addEventListener('submit', (e) => {
            e.preventDefault();
            alert('User added successfully (Demo mode)');
            closeModal('userModal');
        });
    }
});
