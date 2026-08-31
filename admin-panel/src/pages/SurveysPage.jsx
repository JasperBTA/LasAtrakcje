import React, { useState, useEffect } from 'react';
import { RefreshCcw, FileText } from 'lucide-react';

export default function SurveysPage({ token, showToast, handleAuthError }) {
  const [surveys, setSurveys] = useState([]);
  const [loading, setLoading] = useState(false);

  const fetchSurveys = async () => {
    if (!token) return;
    setLoading(true);
    try {
      const response = await fetch('/api/surveys', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        setSurveys(data);
      } else if (response.status === 401 || response.status === 403) {
        handleAuthError();
      } else {
        showToast('Błąd pobierania ankiet');
      }
    } catch (error) {
      showToast('Błąd połączenia z serwerem');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSurveys();
  }, [token]);

  return (
    <div>
      <div className="header">
        <h1>
          <FileText style={{ display: 'inline', marginRight: '10px', verticalAlign: 'middle', color: 'var(--primary)' }} />
          Ankiety Odwiedzających
        </h1>
        <button className="btn btn-primary" onClick={fetchSurveys} disabled={loading}>
          <RefreshCcw size={18} className={loading ? 'loading-skeleton' : ''} style={loading ? {background: 'transparent'} : {}} /> 
          Odśwież
        </button>
      </div>

      <div className="glass-panel">
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Data</th>
                <th>Ocena Atrakcji</th>
                <th>Opinia / Uwagi</th>
                <th>Co Poprawić?</th>
                <th>Polecenie</th>
                <th>Źródło</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                Array.from({ length: 5 }).map((_, idx) => (
                  <tr key={idx}>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                    <td><div className="loading-skeleton"></div></td>
                  </tr>
                ))
              ) : surveys.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-muted)' }}>
                    Brak zebranych ankiet od ankieterów.
                  </td>
                </tr>
              ) : (
                surveys.map((s) => (
                  <tr key={s.id}>
                    <td style={{ fontSize: '0.9rem' }}>{new Date(s.createdAt).toLocaleString()}</td>
                    <td>
                      <span className="badge" style={{ background: s.rating >= 4 ? 'rgba(65, 106, 89, 0.15)' : 'rgba(250, 82, 82, 0.15)', color: s.rating >= 4 ? 'var(--primary)' : 'var(--danger)' }}>
                        {s.rating}/5
                      </span>
                    </td>
                    <td style={{ maxWidth: '250px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {s.strengths || '-'}
                    </td>
                    <td style={{ maxWidth: '250px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {s.improvements || '-'}
                    </td>
                    <td>{s.recommendRating != null ? `${s.recommendRating}/10` : '-'}</td>
                    <td>{s.sourceOther || s.source || 'Brak'}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

