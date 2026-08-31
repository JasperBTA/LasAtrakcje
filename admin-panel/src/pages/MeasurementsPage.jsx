import React, { useState, useEffect } from 'react';
import { Trash2, RefreshCcw, Activity } from 'lucide-react';

export default function MeasurementsPage({ token, showToast, handleAuthError }) {
  const [measurements, setMeasurements] = useState([]);
  const [selectedIds, setSelectedIds] = useState(new Set());
  const [loading, setLoading] = useState(false);

  const [usersMap, setUsersMap] = useState({});
  const [attractionsMap, setAttractionsMap] = useState({});

  const API_URL = '/api/admin/measurements';

  const fetchMeasurements = async () => {
    if (!token) return;
    setLoading(true);
    try {
      const [measRes, usersRes, attrRes] = await Promise.all([
        fetch(API_URL, { headers: { 'Authorization': `Bearer ${token}` } }),
        fetch('/api/admin/users', { headers: { 'Authorization': `Bearer ${token}` } }),
        fetch('/api/attractions', { headers: { 'Authorization': `Bearer ${token}` } })
      ]);
      
      if (measRes.ok) {
        const data = await measRes.json();
        setMeasurements(data);
        setSelectedIds(new Set());
      } else if (measRes.status === 401 || measRes.status === 403) {
        handleAuthError();
        return;
      } else {
        showToast('Błąd pobierania danych');
      }

      if (usersRes.ok) {
        const usersData = await usersRes.json();
        const umap = {};
        usersData.forEach(u => umap[u.id] = u.username);
        setUsersMap(umap);
      }
      if (attrRes.ok) {
        const attrData = await attrRes.json();
        const amap = {};
        attrData.forEach(a => amap[a.id] = a.name);
        setAttractionsMap(amap);
      }
    } catch (error) {
      console.error('Błąd pobierania danych:', error);
      showToast('Błąd połączenia z serwerem');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMeasurements();
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

  return (
    <div>
      <div className="header">
        <h1>
          Pomiary
        </h1>
        <button className="btn btn-primary" onClick={fetchMeasurements} disabled={loading}>
          <RefreshCcw size={18} className={loading ? 'loading-skeleton' : ''} style={loading ? {background: 'transparent'} : {}} /> 
          Odśwież
        </button>
      </div>

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
                <th>Data</th>
                <th>Czas Startu</th>
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
                    <td><div className="loading-skeleton"></div></td>
                  </tr>
                ))
              ) : measurements.length === 0 ? (
                <tr>
                  <td colSpan="7" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
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
                    <td><span className="badge">{usersMap[m.operatorId] || m.operatorId || 'Nieznany'}</span></td>
                    <td style={{ fontWeight: '500' }}>{attractionsMap[m.attractionId] || m.attractionId || 'Brak'}</td>
                    <td>{new Date(m.startTime).toLocaleDateString()}</td>
                    <td>{new Date(m.startTime).toLocaleTimeString()}</td>
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



