import React, { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Login';
import DashboardLayout from './layouts/DashboardLayout';
import MeasurementsPage from './pages/MeasurementsPage';
import AttractionsPage from './pages/AttractionsPage';
import SurveysPage from './pages/SurveysPage';
import ExportPage from './pages/ExportPage';
import SettingsPage from './pages/SettingsPage';
import UsersPage from './pages/UsersPage';

function App() {
  const [token, setTokenState] = useState(() => localStorage.getItem('jwt_token') || null);
  const [toastMessage, setToastMessage] = useState(null);

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
    showToast('Sesja wygasla. Zaloguj sie ponownie.');
  };

  return (
    <BrowserRouter>
      <div className={`toast ${toastMessage ? 'visible' : ''}`}>
        {toastMessage}
      </div>
      <Routes>
        <Route 
          path="/" 
          element={!token ? <div className="app-container"><Login setToken={setToken} showToast={showToast} /></div> : <Navigate to="/measurements" />} 
        />
        {token && (
          <Route element={<DashboardLayout onLogout={() => setToken(null)} />}>
            <Route path="/measurements" element={<MeasurementsPage token={token} showToast={showToast} handleAuthError={handleAuthError} />} />
            <Route path="/attractions" element={<AttractionsPage token={token} showToast={showToast} handleAuthError={handleAuthError} />} />
            <Route path="/surveys" element={<SurveysPage token={token} showToast={showToast} handleAuthError={handleAuthError} />} />
            <Route path="/users" element={<UsersPage token={token} showToast={showToast} handleAuthError={handleAuthError} />} />
            <Route path="/export" element={<ExportPage token={token} showToast={showToast} handleAuthError={handleAuthError} />} />
            <Route path="/settings" element={<SettingsPage token={token} showToast={showToast} handleAuthError={handleAuthError} />} />
          </Route>
        )}
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
