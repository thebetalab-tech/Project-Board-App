// tableSearch.js
// Provides generic client-side table filtering.

function initTableSearch(inputId, tableId) {
    const searchInput = document.getElementById(inputId);
    const table = document.getElementById(tableId);

    if (!searchInput || !table) {
        console.warn('initTableSearch: Input or Table not found. Input:', inputId, 'Table:', tableId);
        return;
    }

    searchInput.addEventListener('keyup', function () {
        const filter = this.value.toLowerCase();
        // Assume the first tbody contains the data rows
        const tbody = table.querySelector('tbody') || table;
        const rows = tbody.getElementsByTagName('tr');

        for (let i = 0; i < rows.length; i++) {
            // Skip header rows if inside tbody (e.g., using th)
            if (rows[i].getElementsByTagName('th').length > 0) continue;

            const cells = rows[i].getElementsByTagName('td');
            let match = false;
            for (let j = 0; j < cells.length; j++) {
                if (cells[j]) {
                    const textValue = cells[j].textContent || cells[j].innerText;
                    if (textValue.toLowerCase().indexOf(filter) > -1) {
                        match = true;
                        break;
                    }
                }
            }
            if (match) {
                rows[i].style.display = "";
            } else {
                rows[i].style.display = "none";
            }
        }
    });
}
