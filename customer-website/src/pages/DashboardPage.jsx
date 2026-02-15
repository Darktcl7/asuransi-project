// pages/DashboardPage.jsx
import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { apiService } from '../services/apiService';
import { authService } from '../services/authService';
import { useToast } from '../components/Toast';
import './DashboardPage.css';

const DashboardPage = () => {
    const navigate = useNavigate();
    const toast = useToast();
    const [user, setUser] = useState(null);
    const [policies, setPolicies] = useState([]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setIsLoading(true);
        try {
            const [userResponse, policiesResponse] = await Promise.all([
                apiService.getUserProfile(),
                apiService.getPolicies(),
            ]);

            setUser(userResponse);
            setPolicies(policiesResponse);
        } catch (error) {
            console.error('Error loading dashboard data:', error);
            if (error.response?.status === 401) {
                authService.logout();
                navigate('/login');
            } else {
                toast.error('Gagal memuat data. Silakan coba lagi.');
            }
        } finally {
            setIsLoading(false);
        }
    };

    const getStatusBadge = (status) => {
        const statusMap = {
            active: { label: 'Aktif', class: 'badge-success' },
            pending: { label: 'Pending', class: 'badge-pending' },
            expired: { label: 'Kadaluarsa', class: 'badge-error' },
            cancelled: { label: 'Dibatalkan', class: 'badge-error' },
        };
        return statusMap[status] || { label: status, class: 'badge-info' };
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
        }).format(amount || 0);
    };

    if (isLoading) {
        return (
            <div className="dashboard-page">
                <div className="container">
                    <div className="loading-screen">
                        <div className="spinner"></div>
                        <p>Memuat dashboard...</p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="dashboard-page">
            <div className="container">
                {/* Welcome Section */}
                <div className="dashboard-header animate-slideDown">
                    <div className="welcome-section">
                        <h1>Selamat Datang, {user?.full_name || 'Pengguna'}! 👋</h1>
                        <p>Kelola polis dan ajukan klaim dengan mudah</p>
                    </div>
                    <div className="header-actions">
                        <Link to="/claims" className="btn btn-secondary">
                            <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                <path d="M9 12l2 2 4-4" />
                                <path d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            Riwayat Klaim
                        </Link>
                    </div>
                </div>

                {/* Stats Cards */}
                <div className="stats-grid animate-slideUp">
                    <div className="stat-card">
                        <div className="stat-icon policies">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                            </svg>
                        </div>
                        <div className="stat-info">
                            <span className="stat-label">Total Polis</span>
                            <span className="stat-value">{policies.length}</span>
                        </div>
                    </div>

                    <div className="stat-card">
                        <div className="stat-icon active">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                <path d="M22 11.08V12a10 10 0 11-5.93-9.14" />
                                <polyline points="22,4 12,14.01 9,11.01" />
                            </svg>
                        </div>
                        <div className="stat-info">
                            <span className="stat-label">Polis Aktif</span>
                            <span className="stat-value">{policies.filter(p => p.status === 'active').length}</span>
                        </div>
                    </div>
                </div>

                {/* Policies Section */}
                <div className="policies-section animate-slideUp">
                    <div className="section-header">
                        <h2>Polis Anda</h2>
                        <span className="section-note">Dikelola oleh Admin</span>
                    </div>

                    {policies.length === 0 ? (
                        <div className="empty-state">
                            <div className="empty-icon">🛡️</div>
                            <h3>Belum Ada Polis</h3>
                            <p>Admin akan menambahkan polis untuk perangkat Anda. Silakan hubungi admin untuk informasi lebih lanjut.</p>
                        </div>
                    ) : (
                        <div className="policies-grid">
                            {policies.map((policy) => {
                                const status = getStatusBadge(policy.status);
                                return (
                                    <div key={policy.id} className="policy-card">
                                        <div className="policy-header">
                                            <div className="policy-tier">
                                                <div className="tier-icon">🛡️</div>
                                                <div className="tier-info">
                                                    <h3>{policy.tier_name || 'Standard'}</h3>
                                                    <span className="policy-number">{policy.policy_number}</span>
                                                </div>
                                            </div>
                                            <span className={`badge ${status.class}`}>{status.label}</span>
                                        </div>

                                        <div className="policy-balance">
                                            <span className="balance-label">Saldo Policy</span>
                                            <span className="balance-value">{formatCurrency(policy.policy_balance)}</span>
                                        </div>

                                        <div className="policy-device">
                                            <div className="device-row">
                                                <span className="device-label">Perangkat</span>
                                                <span className="device-value">{policy.device_brand} {policy.device_model}</span>
                                            </div>
                                            <div className="device-row">
                                                <span className="device-label">IMEI</span>
                                                <span className="device-value">{policy.imei_number}</span>
                                            </div>
                                        </div>

                                        <div className="policy-actions">
                                            {policy.status === 'active' ? (
                                                <Link
                                                    to={`/claims?policy=${policy.id}`}
                                                    className="btn btn-primary"
                                                >
                                                    <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                        <path d="M14.5 4h-5L7 7H4a2 2 0 00-2 2v9a2 2 0 002 2h16a2 2 0 002-2V9a2 2 0 00-2-2h-3l-2.5-3z" />
                                                        <circle cx="12" cy="13" r="3" />
                                                    </svg>
                                                    Ajukan Klaim
                                                </Link>
                                            ) : (
                                                <button className="btn btn-secondary" disabled>
                                                    <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                        <circle cx="12" cy="12" r="10" />
                                                        <line x1="4.93" y1="4.93" x2="19.07" y2="19.07" />
                                                    </svg>
                                                    {policy.status === 'expired' ? 'Polis Kadaluarsa' : 'Polis Tidak Aktif'}
                                                </button>
                                            )}
                                        </div>
                                    </div>
                                );
                            })}
                        </div>
                    )}
                </div>

                {/* Quick Info - Download App Only */}
                <div className="quick-info animate-slideUp">
                    <div className="info-card info-card-full">
                        <div className="info-icon">📱</div>
                        <h4>Download Aplikasi</h4>
                        <p>Kelola polis dari smartphone Anda dengan aplikasi Smile Insurance</p>
                        <Link to="/download" className="btn btn-primary btn-sm">Download App</Link>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default DashboardPage;
