import React, { useState, useEffect } from 'react';
import { Save, Settings } from 'lucide-react';

export default function SettingsPage({ token, showToast, handleAuthError }) {
  const [settings, setSettings] = useState({
    gpsAccuracyThreshold: 30,
    entryBufferSeconds: 5,
    exitBufferSeconds: 10,
    hysteresisMargin: 5
  });
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchSettings();
  }, [token]);

  const fetchSettings = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/settings', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        const data = await response.json();
        if (data) setSettings(data);
      } else if (response.status === 401) {
        handleAuthError();
      }
    } catch (error) {
      showToast('Błąd pobierania ustawień');
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async () => {
    setSaving(true);
    try {
      const response = await fetch('/api/settings', {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}` 
        },
        body: JSON.stringify(settings)
      });
      if (response.ok) {
        showToast('Ustawienia zapisane pomyślnie');
      } else if (response.status === 401) {
        handleAuthError();
      } else {
        showToast('Błąd zapisywania ustawień');
      }
    } catch (error) {
      showToast('Błąd połączenia z serwerem');
    } finally {
      setSaving(false);
    }
  };

  const handleChange = (key, value) => {
    setSettings(prev => ({ ...prev, [key]: parseInt(value) || 0 }));
  };

  if (loading) return <div>Ładowanie ustawień...</div>;

  return (
    <div>
      <div className="header">
        <h1>
          <Settings style={{ display: 'inline', marginRight: '10px', verticalAlign: 'middle', color: 'var(--primary)' }} />
          Ustawienia Aplikacji Mobilnej
        </h1>
      </div>

      <div className="glass-panel" style={{ maxWidth: '600px' }}>
        <p style={{ marginBottom: '2rem', color: 'var(--text-muted)' }}>
          Te ustawienia globalne są pobierane przez aplikację mobilną ankieterów podczas synchronizacji i wpływają na czułość systemu Geofencing.
        </p>

        <div className="form-group" style={{ marginBottom: '1.5rem' }}>
          <label>Zasięg radaru / Dopuszczalny błąd GPS (metry)</label>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <input 
              type="number" 
              className="form-control" 
              value={settings.gpsAccuracyThreshold}
              onChange={(e) => handleChange('gpsAccuracyThreshold', e.target.value)}
              style={{ width: '150px' }}
            />
            <span style={{ color: 'var(--text-muted)' }}>m</span>
          </div>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '0.5rem' }}>
            Określa promień przerywanej linii na radarze w telefonie. Zamiast sztywnych przedziałów (15, 30, 60), możesz tu podać dokładną wartość co do metra.
          </p>
        </div>

        <div className="form-group" style={{ marginBottom: '1.5rem' }}>
          <label>Bufor wejścia (sekundy)</label>
          <input 
            type="number" 
            className="form-control" 
            value={settings.entryBufferSeconds}
            onChange={(e) => handleChange('entryBufferSeconds', e.target.value)}
            style={{ width: '150px' }}
          />
        </div>

        <div className="form-group" style={{ marginBottom: '1.5rem' }}>
          <label>Bufor wyjścia (sekundy)</label>
          <input 
            type="number" 
            className="form-control" 
            value={settings.exitBufferSeconds}
            onChange={(e) => handleChange('exitBufferSeconds', e.target.value)}
            style={{ width: '150px' }}
          />
        </div>

        <div className="form-group" style={{ marginBottom: '2.5rem' }}>
          <label>Margines histerezy (metry)</label>
          <input 
            type="number" 
            className="form-control" 
            value={settings.hysteresisMargin}
            onChange={(e) => handleChange('hysteresisMargin', e.target.value)}
            style={{ width: '150px' }}
          />
        </div>

        <button className="btn btn-primary" onClick={handleSave} disabled={saving} style={{ width: '100%', justifyContent: 'center' }}>
          <Save size={18} />
          {saving ? 'Zapisywanie...' : 'Zapisz Ustawienia'}
        </button>
      </div>
    </div>
  );
}

