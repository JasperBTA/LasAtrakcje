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
        <div style="background-color: #1b8b39; padding: 15px; margin-bottom: 20px; display: flex; gap: 20px; align-items: center; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            <strong style="color: white; font-size: 1.3em; letter-spacing: 1px;">LAS ODKRYWCÓW</strong>
            <a href="/mapa.html" style="color: white; text-decoration: none; font-weight: bold; padding: 5px 10px; border-radius: 4px; transition: background 0.3s;" onmouseover="this.style.backgroundColor='#ef6c20'" onmouseout="this.style.backgroundColor='transparent'">Mapa na żywo</a>
            <a href="/ankiety.html" style="color: white; text-decoration: none; font-weight: bold; padding: 5px 10px; border-radius: 4px; transition: background 0.3s;" onmouseover="this.style.backgroundColor='#ef6c20'" onmouseout="this.style.backgroundColor='transparent'">Ankiety</a>
            <a href="/pomiary.html" style="color: white; text-decoration: none; font-weight: bold; padding: 5px 10px; border-radius: 4px; transition: background 0.3s;" onmouseover="this.style.backgroundColor='#ef6c20'" onmouseout="this.style.backgroundColor='transparent'">Pomiary</a>
            <a href="/atrakcje.html" style="color: white; text-decoration: none; font-weight: bold; padding: 5px 10px; border-radius: 4px; transition: background 0.3s;" onmouseover="this.style.backgroundColor='#ef6c20'" onmouseout="this.style.backgroundColor='transparent'">Strefy (CRUD)</a>
            <div style="flex-grow: 1;"></div>
            <button onclick="logout()" style="background-color: #ef6c20; color: white; font-weight: bold; border: none; padding: 8px 20px; border-radius: 5px; cursor: pointer; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">Wyloguj</button>
        </div>
    `;
    document.body.insertBefore(nav, document.body.firstChild);
}

document.addEventListener("DOMContentLoaded", function() {
    if (!window.location.pathname.endsWith('login.html')) {
        buildNavbar();
    }
});
