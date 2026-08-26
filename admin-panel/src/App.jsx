import React, { useState, useEffect } from 'react';
import { Trash2, RefreshCcw, Activity, LogOut } from 'lucide-react';
import Login from './components/Login';

function App() {
  const [token, setTokenState] = useState(() => localStorage.getItem('jwt_token') || null);
  const [measurements, setMeasurements] = useState([]);
  const [selectedIds, setSelectedIds] = useState(new Set());
  const [loading, setLoading] = useState(false);
  const [toastMessage, setToastMessage] = useState(null);

  const API_URL = 'http://localhost:8080/api/admin/measurements';

  const setToken = (newToken) => {
    if (newToken) {
      localStorage.setItem('jwt_token', newToken);
    } else {
      localStorage.removeItem('jwt_token');
    }
    setTokenState(newToken);
  };

  const showToast = (message) => {
    setToastMessage(message);
    setTimeout(() => setToastMessage(null), 3000);
  };

  const handleAuthError = () => {
    setToken(null);
    showToast('Sesja wygasła. Zaloguj się ponownie.');
  };

  const fetchMeasurements = async () => {
    if (!token) return;
    setLoading(true);
    try {
      const response = await fetch(API_URL, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        setMeasurements(data);
        setSelectedIds(new Set());
      } else if (response.status === 401 || response.status === 403) {
        handleAuthError();
      } else {
        showToast('Błąd pobierania danych');
      }
    } catch (error) {
      console.error('Błąd pobierania danych:', error);
      showToast('Błąd połączenia z serwerem');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (token) {
      fetchMeasurements();
    }
  }, [token]);

  const handleSelectAll = (e) => {
    if (e.target.checked) {
      const allIds = new Set(measurements.map(m => m.id));
      setSelectedIds(allIds);
    } else {
      setSelectedIds(new Set());
    }
  };

  const handleSelectOne = (id) => {
    const newSelected = new Set(selectedIds);
    if (newSelected.has(id)) {
      newSelected.delete(id);
    } else {
      newSelected.add(id);
    }
    setSelectedIds(newSelected);
  };

  const handleDeleteSelected = async () => {
    if (selectedIds.size === 0) return;
    
    try {
      const response = await fetch(API_URL, {
        method: 'DELETE',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ ids: Array.from(selectedIds) })
      });
      
      if (response.ok) {
        showToast(`Usunięto ${selectedIds.size} pomiarów`);
        fetchMeasurements();
      } else if (response.status === 401 || response.status === 403) {
        handleAuthError();
      } else {
        showToast('Błąd podczas usuwania');
      }
    } catch (error) {
      console.error('Błąd usuwania:', error);
      showToast('Błąd połączenia z serwerem podczas usuwania');
    }
  };

  const formatDuration = (seconds) => {
    if (seconds == null) return 'Brak';
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}m ${secs}s`;
  };

  const handleLogout = () => {
    setToken(null);
    showToast('Wylogowano pomyślnie');
  };

  if (!token) {
    return (
      <div className="app-container">
        <div className={`toast ${toastMessage ? 'visible' : ''}`}>
          {toastMessage}
        </div>
        <Login setToken={setToken} showToast={showToast} />
      </div>
    );
  }

  return (
    <div className="app-container">
      <div className={`toast ${toastMessage ? 'visible' : ''}`}>
        {toastMessage}
      </div>

      <header className="header">
        <h1>
          <Activity style={{ display: 'inline', marginRight: '10px', verticalAlign: 'middle', color: 'var(--primary)' }} />
          Pomiary Z Lasu
        </h1>
        <div style={{ display: 'flex', gap: '1rem' }}>
          <button className="btn btn-primary" onClick={fetchMeasurements} disabled={loading}>
            <RefreshCcw size={18} className={loading ? 'loading-skeleton' : ''} style={loading ? {background: 'transparent'} : {}} /> 
            Odśwież
          </button>
          <button className="btn btn-danger" onClick={handleLogout} style={{ backgroundColor: 'var(--text-muted)' }}>
            <LogOut size={18} />
            Wyloguj
          </button>
        </div>
      </header>

      <div className="glass-panel">
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th style={{ width: '50px' }}>
                  <label className="checkbox-container">
                    <input 
                      type="checkbox" 
                      checked={measurements.length > 0 && selectedIds.size === measurements.length}
                      onChange={handleSelectAll}
                    />
                    <span className="checkmark"></span>
                  </label>
                </th>
                <th>ID Pomiaru</th>
                <th>ID Operatora</th>
                <th>Atrakcja</th>
                <th>Wejście (Czas)</th>
                <th>Czas Trwania</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 5 }).map((_, idx) => (
                  <tr key={idx}>
                    <td><div className="loading-skeleton" style={{width: '20px'}}></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                  </tr>
                ))
              ) : measurements.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                    Brak pomiarów w bazie danych. Wyślij dane z aplikacji mobilnej!
                  </td>
                </tr>
              ) : (
                measurements.map((m) => (
                  <tr key={m.id}>
                    <td>
                      <label className="checkbox-container">
                        <input 
                          type="checkbox" 
                          checked={selectedIds.has(m.id)}
                          onChange={() => handleSelectOne(m.id)}
                        />
                        <span className="checkmark"></span>
                      </label>
                    </td>
                    <td style={{ fontFamily: 'monospace', color: 'var(--text-muted)' }}>
                      {m.id.substring(0, 8)}...
                    </td>
                    <td><span className="badge">{m.operatorId || 'Nieznany'}</span></td>
                    <td style={{ fontWeight: '500' }}>{m.attractionId || 'Brak'}</td>
                    <td>{new Date(m.startTime).toLocaleString()}</td>
                    <td>
                      <strong>{formatDuration(m.totalDurationSeconds)}</strong>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className={`floating-action-bar ${selectedIds.size > 0 ? 'visible' : ''}`}>
        <span>Zaznaczono {selectedIds.size} elementów</span>
        <button className="btn btn-danger" onClick={handleDeleteSelected}>
          <Trash2 size={18} /> Usuń Zaznaczone
        </button>
      </div>
    </div>
  );
}

export default App;
