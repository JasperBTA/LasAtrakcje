import React from 'react';
import { NavLink, Outlet, useNavigate } from 'react-router-dom';
import { Activity, MapPin, Download, FileText, LogOut, Settings, Users } from 'lucide-react';
import './DashboardLayout.css';

export default function DashboardLayout({ onLogout }) {
  const navigate = useNavigate();

  const handleLogout = () => {
    onLogout();
    navigate('/');
  };

  return (
    <div className="dashboard-container">
      <aside className="sidebar">
        <div className="sidebar-header">
          <h2>Las Odkrywców</h2>
          <p>Panel Administratora</p>
        </div>
        <nav className="sidebar-nav">
          <NavLink to="/measurements" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <Activity size={20} />
            <span>Pomiary</span>
          </NavLink>
          <NavLink to="/attractions" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <MapPin size={20} />
            <span>Atrakcje (Mapa)</span>
          </NavLink>
          <NavLink to="/surveys" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <FileText size={20} />
            <span>Ankiety</span>
          </NavLink>
          <NavLink to="/users" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <Users size={20} />
            <span>Pracownicy</span>
          </NavLink>
          <NavLink to="/export" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <Download size={20} />
            <span>Eksport CSV</span>
          </NavLink>
          <NavLink to="/settings" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <Settings size={20} />
            <span>Ustawienia Radaru</span>
          </NavLink>
        </nav>
        <div className="sidebar-footer">
          <button onClick={handleLogout} className="logout-btn">
            <LogOut size={20} />
            <span>Wyloguj</span>
          </button>
        </div>
      </aside>
      <main className="dashboard-content">
        <Outlet />
      </main>
    </div>
  );
}

