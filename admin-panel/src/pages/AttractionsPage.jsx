import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Circle, Popup, useMapEvents, useMap } from 'react-leaflet';
import { Plus, Save, X, Edit2, Trash2 } from 'lucide-react';
import L from 'leaflet';

function FitBounds({ attractions }) {
  const map = useMap();

  useEffect(() => {
    // Rozwiązuje częsty błąd Leaflet, gdzie mapa ładuje tylko kilka kafelków po wejściu na stronę
    const timer = setTimeout(() => {
      map.invalidateSize();
    }, 200);
    return () => clearTimeout(timer);
  }, [map]);

  useEffect(() => {
    if (attractions.length > 0) {
      const bounds = L.latLngBounds(attractions.map(a => [a.latitude, a.longitude]));
      map.fitBounds(bounds, { padding: [50, 50], maxZoom: 17 });
    } else {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
          (pos) => map.setView([pos.coords.latitude, pos.coords.longitude], 16),
          () => {}
        );
      }
    }
  }, [attractions, map]);
  return null;
}

function LocationMarker({ newAttraction, setNewAttraction }) {
  useMapEvents({
    click(e) {
      if (newAttraction) {
        setNewAttraction({
          ...newAttraction,
          latitude: e.latlng.lat,
          longitude: e.latlng.lng
        });
      }
    },
  });
  return null;
}

function FlyToLocation({ lat, lng }) {
  const map = useMap();
  useEffect(() => {
    if (lat && lng) map.flyTo([lat, lng], 17);
  }, [lat, lng, map]);
  return null;
}

export default function AttractionsPage({ token, showToast, handleAuthError }) {
  const [attractions, setAttractions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [newAttraction, setNewAttraction] = useState(null); // null when not adding
  const [editAttraction, setEditAttraction] = useState(null);
  const [focusLocation, setFocusLocation] = useState(null); // [lat, lng]

  // Default center if no attractions
  const defaultCenter = [50.000000, 20.000000];
  const mapCenter = attractions.length > 0 ? [attractions[0].latitude, attractions[0].longitude] : defaultCenter;

  const fetchAttractions = async () => {
    setLoading(true);
    try {
      // Use the public endpoint to fetch all attractions
      const response = await fetch('/api/attractions', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        setAttractions(data);
      } else {
        showToast('Błąd pobierania atrakcji');
      }
    } catch (err) {
      showToast('Błąd połączenia');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAttractions();
  }, []);

  const handleSave = async (attractionData, isEdit) => {
    try {
      const url = isEdit ? `/api/admin/attractions/${attractionData.id}` : '/api/admin/attractions';
      const method = isEdit ? 'PUT' : 'POST';
      
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(attractionData)
      });
      
      if (response.ok) {
        showToast(isEdit ? 'Zaktualizowano strefę' : 'Dodano nową strefę');
        setNewAttraction(null);
        setEditAttraction(null);
        fetchAttractions();
      } else if (response.status === 401 || response.status === 403) {
        handleAuthError();
      } else {
        showToast('Wystąpił błąd podczas zapisywania');
      }
    } catch (err) {
      showToast('Błąd połączenia');
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Na pewno usunąć tę strefę?")) return;
    try {
      const response = await fetch(`/api/admin/attractions/${id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (response.ok) {
        showToast('Strefa usunięta');
        fetchAttractions();
      } else {
        showToast('Błąd usuwania');
      }
    } catch (err) {
      showToast('Błąd połączenia');
    }
  };

  return (
    <div style={{ display: 'flex', gap: '2rem', height: '100%' }}>
      {/* Sidebar with list & forms */}
      <div className="glass-panel" style={{ width: '400px', display: 'flex', flexDirection: 'column', padding: '1.5rem' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
          <h2 style={{ fontSize: '1.4rem', color: 'var(--primary)' }}>Strefy Leśne</h2>
          {!newAttraction && !editAttraction && (
            <button className="btn btn-primary" style={{ padding: '0.5rem' }} onClick={() => setNewAttraction({ name: 'Nowa Strefa', radius: 10, latitude: mapCenter[0], longitude: mapCenter[1], isActive: true })}>
              <Plus size={20} />
            </button>
          )}
        </div>

        {(newAttraction || editAttraction) ? (
          <div style={{ background: 'var(--bg-color)', padding: '1.5rem', borderRadius: 'var(--radius-md)', border: '1px solid var(--border-color)' }}>
            <h3 style={{ marginBottom: '1rem', fontSize: '1.1rem' }}>{editAttraction ? 'Edytuj Strefę' : 'Kliknij na mapie by ustalić pozycję'}</h3>
            <div className="form-group" style={{ marginBottom: '1rem' }}>
              <label>Nazwa strefy</label>
              <input 
                type="text" 
                className="form-control" 
                value={editAttraction ? editAttraction.name : newAttraction.name}
                onChange={e => editAttraction 
                  ? setEditAttraction({...editAttraction, name: e.target.value}) 
                  : setNewAttraction({...newAttraction, name: e.target.value})}
              />
            </div>
            <div className="form-group" style={{ marginBottom: '1rem' }}>
              <label>Promień geofence (metry)</label>
              <input 
                type="number" 
                className="form-control" 
                value={editAttraction ? editAttraction.radius : newAttraction.radius}
                onChange={e => editAttraction 
                  ? setEditAttraction({...editAttraction, radius: parseFloat(e.target.value)}) 
                  : setNewAttraction({...newAttraction, radius: parseFloat(e.target.value)})}
              />
            </div>
            <div style={{ display: 'flex', gap: '0.5rem', marginTop: '1.5rem' }}>
              <button className="btn btn-primary" style={{ flex: 1, padding: '0.6rem' }} onClick={() => handleSave(editAttraction || newAttraction, !!editAttraction)}>
                <Save size={18} /> Zapisz
              </button>
              <button className="btn btn-danger" style={{ padding: '0.6rem' }} onClick={() => { setNewAttraction(null); setEditAttraction(null); }}>
                <X size={18} />
              </button>
            </div>
          </div>
        ) : (
          <div style={{ overflowY: 'auto', flex: 1, display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
            {loading ? <p>Ładowanie...</p> : attractions.map(attr => (
              <div 
                key={attr.id} 
                style={{ 
                  padding: '1rem', 
                  background: 'var(--bg-color)', 
                  borderRadius: 'var(--radius-md)', 
                  border: '1px solid var(--border-color)',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  cursor: 'pointer'
                }}
                onClick={() => setFocusLocation([attr.latitude, attr.longitude])}
              >
                <div>
                  <div style={{ fontWeight: '700', color: 'var(--text-main)', fontSize: '0.95rem' }}>{attr.name}</div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Radius: {attr.radius}m • {attr.isActive ? 'Aktywna' : 'Nieaktywna'}</div>
                </div>
                <div style={{ display: 'flex', gap: '0.2rem' }}>
                  <button className="btn btn-danger" style={{ padding: '0.4rem', border: 'none', background: 'transparent' }} onClick={(e) => { e.stopPropagation(); setEditAttraction(attr); }}>
                    <Edit2 size={16} color="var(--primary)" />
                  </button>
                  <button className="btn btn-danger" style={{ padding: '0.4rem', border: 'none', background: 'transparent' }} onClick={(e) => { e.stopPropagation(); handleDelete(attr.id); }}>
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Map */}
      <div className="glass-panel" style={{ flex: 1, padding: '0', overflow: 'hidden', position: 'relative' }}>
        <MapContainer center={mapCenter} zoom={16} style={{ height: '100%', width: '100%', zIndex: 1 }}>
          <TileLayer
            url="https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png"
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OSM</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
          />
          <FitBounds attractions={attractions} />
          <LocationMarker newAttraction={newAttraction} setNewAttraction={setNewAttraction} />
          {focusLocation && <FlyToLocation lat={focusLocation[0]} lng={focusLocation[1]} />}
          
          {attractions.map(attr => (
            <Circle 
              key={attr.id} 
              center={[attr.latitude, attr.longitude]} 
              radius={attr.radius || 10}
              pathOptions={{ 
                color: 'var(--primary)', 
                fillColor: 'var(--primary)', 
                fillOpacity: 0.15,
                dashArray: '8, 8', 
                weight: 2
              }}
            >
              <Popup>
                <strong>{attr.name}</strong><br/>
                Zasięg aplikacji: {attr.radius}m<br/>
                Lat: {attr.latitude.toFixed(6)}<br/>
                Lng: {attr.longitude.toFixed(6)}
              </Popup>
            </Circle>
          ))}

          {(newAttraction || editAttraction) && (
            <Circle 
              center={[editAttraction ? editAttraction.latitude : newAttraction.latitude, editAttraction ? editAttraction.longitude : newAttraction.longitude]} 
              radius={editAttraction ? editAttraction.radius : newAttraction.radius}
              pathOptions={{ 
                color: 'var(--secondary)', 
                fillColor: 'var(--secondary)', 
                fillOpacity: 0.3,
                dashArray: '8, 8',
                weight: 3
              }}
            >
               <Popup>Trwa ustalanie zasięgu...</Popup>
            </Circle>
          )}
        </MapContainer>
        {newAttraction && (
          <div style={{ position: 'absolute', top: '1rem', left: '50%', transform: 'translateX(-50%)', zIndex: 1000, background: 'var(--surface)', padding: '0.5rem 1rem', borderRadius: '100px', boxShadow: 'var(--shadow-soft)', fontWeight: 'bold' }}>
            Tryb dodawania: Kliknij na mapie, by postawić znacznik
          </div>
        )}
      </div>
    </div>
  );
}
