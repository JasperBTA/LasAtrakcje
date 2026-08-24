// auth.js
// Ten skrypt sprawdza czy użytkownik ma token (z wyjątkiem strony login.html).
// Automatycznie dodaje token JWT do nagłówków we wszystkich strzałach fetch (API) lub używa $.ajaxSetup.

const token = localStorage.getItem('jwt_token');

if (!token && !window.location.pathname.endsWith('login.html')) {
    window.location.href = '/login.html';
}

function logout() {
    localStorage.removeItem('jwt_token');
    window.location.href = '/login.html';
}

// Konfiguracja jQuery AJAX (dla DataTables i innych zapytań)
if (typeof $ !== 'undefined') {
    $.ajaxSetup({
        beforeSend: function(xhr) {
            if (token) {
                xhr.setRequestHeader('Authorization', 'Bearer ' + token);
            }
        },
        error: function(jqXHR) {
            if (jqXHR.status === 403 || jqXHR.status === 401) {
                alert("Brak autoryzacji (403/401). Zaloguj się ponownie.");
                logout();
            }
        }
    });
}

// Wsparcie dla natywnego fetch()
const originalFetch = window.fetch;
window.fetch = function() {
    let [resource, config] = arguments;
    if(config === undefined) {
        config = {};
    }
    if(config.headers === undefined) {
        config.headers = {};
    }
    if(token) {
        config.headers['Authorization'] = 'Bearer ' + token;
    }
    return originalFetch(resource, config).then(response => {
        if (response.status === 401 || response.status === 403) {
            alert("Brak autoryzacji (403/401). Zaloguj się ponownie.");
            logout();
        }
        return response;
    });
};

function buildNavbar() {
    const nav = document.createElement('nav');
    nav.innerHTML = `
        <div style="background-color: #222; padding: 15px; margin-bottom: 20px; display: flex; gap: 20px; align-items: center; border-radius: 8px;">
            <strong style="color: #ff9800; font-size: 1.2em;">Las Odkrywców</strong>
            <a href="/mapa.html" style="color: white; text-decoration: none;">🌍 Mapa na żywo</a>
            <a href="/ankiety.html" style="color: white; text-decoration: none;">📝 Ankiety</a>
            <a href="/pomiary.html" style="color: white; text-decoration: none;">⏱️ Pomiary</a>
            <a href="/atrakcje.html" style="color: white; text-decoration: none;">⚙️ Strefy (CRUD)</a>
            <div style="flex-grow: 1;"></div>
            <button onclick="logout()" style="background-color: #F44336; color: white; border: none; padding: 8px 15px; border-radius: 5px; cursor: pointer;">Wyloguj</button>
        </div>
    `;
    document.body.insertBefore(nav, document.body.firstChild);
}

document.addEventListener("DOMContentLoaded", function() {
    if (!window.location.pathname.endsWith('login.html')) {
        buildNavbar();
    }
});
