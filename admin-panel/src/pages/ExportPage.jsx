import React from 'react';
import { Download, FileJson, Table2 } from 'lucide-react';

export default function ExportPage({ token, showToast }) {
  
  const handleExport = async (url, filename) => {
    try {
      const response = await fetch(url, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (response.ok) {
        const blob = await response.blob();
        const downloadUrl = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = downloadUrl;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        link.remove();
      } else {
        showToast('Błąd podczas generowania pliku');
      }
    } catch (err) {
      showToast('Błąd połączenia');
    }
  };

  return (
    <div>
      <div className="header">
        <h1>
          <Download style={{ display: 'inline', marginRight: '10px', verticalAlign: 'middle', color: 'var(--primary)' }} />
          Eksport Danych
        </h1>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '2rem' }}>
        
        {/* Measurements Card */}
        <div className="glass-panel" style={{ display: 'flex', flexDirection: 'column', gap: '1rem', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ background: 'rgba(65, 106, 89, 0.05)', padding: '1.5rem', borderRadius: '50%', color: 'var(--primary)' }}>
            <Table2 size={40} />
          </div>
          <h3>Eksport Pomiarów (CSV)</h3>
          <p style={{ color: 'var(--text-muted)' }}>Pobierz wszystkie zebrane pomiary geofencingowe przebywania w strefach w formacie arkusza kalkulacyjnego.</p>
          <button className="btn btn-primary" style={{ marginTop: 'auto', width: '100%' }} onClick={() => handleExport('/api/export/measurements/csv', 'pomiary_las.csv')}>
            <Download size={18} /> Pobierz Pomiary
          </button>
        </div>

        {/* Surveys Card */}
        <div className="glass-panel" style={{ display: 'flex', flexDirection: 'column', gap: '1rem', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ background: 'rgba(212, 163, 115, 0.1)', padding: '1.5rem', borderRadius: '50%', color: 'var(--secondary)' }}>
            <Table2 size={40} />
          </div>
          <h3>Eksport Ankiet (CSV)</h3>
          <p style={{ color: 'var(--text-muted)' }}>Pobierz arkusz z wynikami wszystkich ankiet przeprowadzonych przez operatorów.</p>
          <button className="btn btn-primary" style={{ marginTop: 'auto', width: '100%', backgroundColor: 'var(--secondary)' }} onClick={() => handleExport('/api/export/surveys/csv', 'ankiety_las.csv')}>
            <Download size={18} /> Pobierz Ankiety
          </button>
        </div>

        {/* JSON Card */}
        <div className="glass-panel" style={{ display: 'flex', flexDirection: 'column', gap: '1rem', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ background: 'rgba(134, 142, 150, 0.1)', padding: '1.5rem', borderRadius: '50%', color: 'var(--text-main)' }}>
            <FileJson size={40} />
          </div>
          <h3>Surowe Dane (JSON)</h3>
          <p style={{ color: 'var(--text-muted)' }}>Pobierz wszystkie dane o atrakcjach i logach w surowym formacie JSON dla programistów.</p>
          <div style={{ display: 'flex', gap: '1rem', width: '100%', marginTop: 'auto' }}>
             <button className="btn btn-primary" style={{ flex: 1, backgroundColor: 'var(--text-muted)' }} onClick={() => handleExport('/api/export/measurements/json', 'pomiary.json')}>
              Pomiary
            </button>
            <button className="btn btn-primary" style={{ flex: 1, backgroundColor: 'var(--text-muted)' }} onClick={() => handleExport('/api/export/surveys/json', 'ankiety.json')}>
              Ankiety
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}

