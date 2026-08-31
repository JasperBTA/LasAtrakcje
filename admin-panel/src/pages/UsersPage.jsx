import React, { useState, useEffect } from 'react';
import { Trash2, UserPlus, Save, Users, RefreshCcw } from 'lucide-react';

export default function UsersPage({ token, showToast, handleAuthError }) {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [formData, setFormData] = useState({
    username: '',
    password: '',
    pin: '',
    firstName: '',
    lastName: '',
    role: 'WORKER'
  });

  const API_URL = '/api/admin/users';

  const fetchUsers = async () => {
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
        setUsers(data);
      } else if (response.status === 401 || response.status === 403) {
        handleAuthError();
      } else {
        showToast('Błąd pobierania danych');
      }
    } catch (error) {
      showToast('Błąd połączenia z serwerem');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, [token]);

  const handleDelete = async (id, username) => {
    if (!window.confirm(`Czy na pewno chcesz usunąć pracownika: ${username}?`)) return;
    
    try {
      const response = await fetch(`${API_URL}/${id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        showToast('Pracownik usunięty');
        fetchUsers();
      } else {
        showToast('Błąd podczas usuwania. (Administratora nie można usunąć)');
      }
    } catch (error) {
      showToast('Błąd połączenia');
    }
  };

  const handleSaveUser = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch(API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        showToast('Pracownik dodany pomyślnie!');
        setShowModal(false);
        setFormData({ username: '', password: '', pin: '', firstName: '', lastName: '', role: 'WORKER' });
        fetchUsers();
      } else {
        const data = await response.json();
        showToast(data.error || 'Błąd podczas dodawania pracownika');
      }
    } catch (error) {
      showToast('Błąd połączenia');
    }
  };

  return (
    <div>
      <div className="header">
        <h1>Pracownicy</h1>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="btn btn-primary" onClick={fetchUsers} disabled={loading}>
            <RefreshCcw size={18} className={loading ? 'loading-skeleton' : ''} style={loading ? {background: 'transparent'} : {}} /> 
            Odśwież
          </button>
          <button className="btn btn-primary" onClick={() => setShowModal(true)}>
            <UserPlus size={18} /> Dodaj Pracownika
          </button>
        </div>
      </div>

      <div className="glass-panel">
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Imię i Nazwisko</th>
                <th>Login (Username)</th>
                <th>Rola</th>
                <th>Akcje</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 3 }).map((_, idx) => (
                  <tr key={idx}>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                  </tr>
                ))
              ) : users.length === 0 ? (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                    Brak pracowników. Dodaj pierwszego pracownika!
                  </td>
                </tr>
              ) : (
                users.map((u) => (
                  <tr key={u.id}>
                    <td style={{ fontFamily: 'monospace', color: 'var(--text-muted)' }}>{u.id.substring(0, 8)}...</td>
                    <td style={{ fontWeight: '500' }}>
                      {u.firstName || u.lastName ? `${u.firstName || ''} ${u.lastName || ''}` : <span style={{color: '#999'}}>Brak</span>}
                    </td>
                    <td>{u.username}</td>
                    <td><span className="badge">{u.role}</span></td>
                    <td>
                      {u.role !== 'ADMIN' && u.username !== 'admin' && (
                        <button className="btn btn-danger" style={{ padding: '0.25rem 0.5rem', minHeight: 'auto' }} onClick={() => handleDelete(u.id, u.username)}>
                          <Trash2 size={16} />
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h3>Dodaj Pracownika</h3>
            </div>
            <form onSubmit={handleSaveUser}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '15px', marginBottom: '15px' }}>
                <div className="form-group">
                  <label>Imię</label>
                  <input type="text" value={formData.firstName} onChange={(e) => setFormData({...formData, firstName: e.target.value})} placeholder="np. Jan" />
                </div>
                <div className="form-group">
                  <label>Nazwisko</label>
                  <input type="text" value={formData.lastName} onChange={(e) => setFormData({...formData, lastName: e.target.value})} placeholder="np. Kowalski" />
                </div>
              </div>
              <div className="form-group">
                <label>Login (Username) *</label>
                <input type="text" value={formData.username} onChange={(e) => setFormData({...formData, username: e.target.value})} required placeholder="np. jkowalski" />
              </div>
              <div className="form-group">
                <label>Hasło *</label>
                <input type="password" value={formData.password} onChange={(e) => setFormData({...formData, password: e.target.value})} required />
              </div>
              <div className="form-group">
                <label>PIN (do szybkiego logowania pracownika)</label>
                <input type="text" value={formData.pin} onChange={(e) => setFormData({...formData, pin: e.target.value})} placeholder="np. 1234" maxLength="4" />
              </div>
              
              <div style={{ display: 'flex', gap: '10px', marginTop: '20px' }}>
                <button type="submit" className="btn btn-primary" style={{ flex: 1 }}>
                  <Save size={18} /> Zapisz
                </button>
                <button type="button" className="btn btn-secondary" onClick={() => setShowModal(false)}>
                  Anuluj
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

