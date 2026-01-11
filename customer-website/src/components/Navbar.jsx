// components/Navbar.jsx
import { useState, useEffect } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { authService } from '../services/authService';
import { apiService } from '../services/apiService';
import './Navbar.css';

const Navbar = () => {
    const navigate = useNavigate();
    const location = useLocation();
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [unreadCount, setUnreadCount] = useState(0);
    const [isScrolled, setIsScrolled] = useState(false);
    const user = authService.getUserData();

    useEffect(() => {
        const fetchUnreadCount = async () => {
            try {
                const count = await apiService.getUnreadNotificationCount();
                setUnreadCount(count);
            } catch (error) {
                console.error('Failed to fetch notification count:', error);
            }
        };

        if (authService.isAuthenticated()) {
            fetchUnreadCount();
        }

        // Handle scroll
        const handleScroll = () => {
            setIsScrolled(window.scrollY > 20);
        };

        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, [location]);

    const handleLogout = () => {
        authService.logout();
        navigate('/');
        setIsMenuOpen(false);
    };

    const isActive = (path) => location.pathname === path;

    return (
        <nav className={`navbar ${isScrolled ? 'navbar-scrolled' : ''}`}>
            <div className="navbar-container">
                {/* Logo */}
                <Link to="/" className="navbar-logo">
                    <span className="logo-emoji">😊</span>
                    <span className="logo-text">Smile Insurance</span>
                </Link>

                {/* Desktop Menu */}
                <div className="navbar-menu">
                    {authService.isAuthenticated() ? (
                        <>
                            <Link to="/dashboard" className={`nav-link ${isActive('/dashboard') ? 'active' : ''}`}>
                                <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <rect x="3" y="3" width="7" height="9" rx="1" />
                                    <rect x="14" y="3" width="7" height="5" rx="1" />
                                    <rect x="14" y="12" width="7" height="9" rx="1" />
                                    <rect x="3" y="16" width="7" height="5" rx="1" />
                                </svg>
                                Dashboard
                            </Link>
                            <Link to="/claims" className={`nav-link ${isActive('/claims') ? 'active' : ''}`}>
                                <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M9 12l2 2 4-4" />
                                    <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                                </svg>
                                Klaim
                            </Link>
                            <Link to="/notifications" className={`nav-link notification-link ${isActive('/notifications') ? 'active' : ''}`}>
                                <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9" />
                                    <path d="M13.73 21a2 2 0 01-3.46 0" />
                                </svg>
                                Notifikasi
                                {unreadCount > 0 && (
                                    <span className="notification-badge">{unreadCount > 9 ? '9+' : unreadCount}</span>
                                )}
                            </Link>
                            <Link to="/profile" className={`nav-link ${isActive('/profile') ? 'active' : ''}`}>
                                <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" />
                                    <circle cx="12" cy="7" r="4" />
                                </svg>
                                Profil
                            </Link>
                            <button onClick={handleLogout} className="nav-link nav-logout">
                                <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4" />
                                    <polyline points="16,17 21,12 16,7" />
                                    <line x1="21" y1="12" x2="9" y2="12" />
                                </svg>
                                Logout
                            </button>
                        </>
                    ) : (
                        <>
                            <Link to="/download" className={`nav-link ${isActive('/download') ? 'active' : ''}`}>
                                <svg className="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
                                    <polyline points="7,10 12,15 17,10" />
                                    <line x1="12" y1="15" x2="12" y2="3" />
                                </svg>
                                Download App
                            </Link>
                            <Link to="/login" className="btn btn-outline btn-sm">Masuk</Link>
                            <Link to="/register" className="btn btn-primary btn-sm">Daftar</Link>
                        </>
                    )}
                </div>

                {/* Mobile Menu Button */}
                <button
                    className={`navbar-toggle ${isMenuOpen ? 'active' : ''}`}
                    onClick={() => setIsMenuOpen(!isMenuOpen)}
                    aria-label="Toggle menu"
                >
                    <span></span>
                    <span></span>
                    <span></span>
                </button>
            </div>

            {/* Mobile Overlay */}
            <div
                className={`navbar-overlay ${isMenuOpen ? 'open' : ''}`}
                onClick={() => setIsMenuOpen(false)}
            />

            {/* Mobile Menu */}
            <div className={`navbar-mobile ${isMenuOpen ? 'open' : ''}`}>
                {/* Close Button */}
                <button
                    className="mobile-close-btn"
                    onClick={() => setIsMenuOpen(false)}
                    aria-label="Close menu"
                >
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                        <line x1="18" y1="6" x2="6" y2="18" />
                        <line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                </button>

                {authService.isAuthenticated() ? (
                    <>
                        <div className="mobile-user-info">
                            <div className="mobile-user-avatar">
                                {user?.full_name?.charAt(0) || 'U'}
                            </div>
                            <div>
                                <div className="mobile-user-name">{user?.full_name || 'User'}</div>
                                <div className="mobile-user-email">{user?.email}</div>
                            </div>
                        </div>
                        <Link to="/dashboard" className="mobile-nav-link" onClick={() => setIsMenuOpen(false)}>
                            Dashboard
                        </Link>
                        <Link to="/claims" className="mobile-nav-link" onClick={() => setIsMenuOpen(false)}>
                            Riwayat Klaim
                        </Link>
                        <Link to="/notifications" className="mobile-nav-link" onClick={() => setIsMenuOpen(false)}>
                            Notifikasi
                            {unreadCount > 0 && <span className="notification-badge">{unreadCount}</span>}
                        </Link>
                        <Link to="/profile" className="mobile-nav-link" onClick={() => setIsMenuOpen(false)}>
                            Profil
                        </Link>
                        <button onClick={handleLogout} className="mobile-nav-link mobile-logout">
                            Logout
                        </button>
                    </>
                ) : (
                    <>
                        <Link to="/download" className="mobile-nav-link" onClick={() => setIsMenuOpen(false)}>
                            Download App
                        </Link>
                        <Link to="/login" className="mobile-nav-link" onClick={() => setIsMenuOpen(false)}>
                            Masuk
                        </Link>
                        <Link to="/register" className="mobile-nav-link" onClick={() => setIsMenuOpen(false)}>
                            Daftar
                        </Link>
                    </>
                )}
            </div>
        </nav>
    );
};

export default Navbar;
