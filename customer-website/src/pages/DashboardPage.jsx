// pages/DashboardPage.jsx
import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { apiService } from '../services/apiService';
import { authService } from '../services/authService';
import { useToast } from '../components/Toast';
import './DashboardPage.css';
import './ClaimsPage.css';

const DashboardPage = () => {
    const navigate = useNavigate();
    const toast = useToast();
    const [user, setUser] = useState(null);
    const [policies, setPolicies] = useState([]);
    const [claims, setClaims] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [showClaimForm, setShowClaimForm] = useState(false);
    const [selectedPolicy, setSelectedPolicy] = useState(null);
    const [claimForm, setClaimForm] = useState({
        damage_description: '',
        incident_date: new Date().toISOString().split('T')[0],
        photos: [],
    });
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setIsLoading(true);
        try {
            const [userResponse, policiesResponse, claimsResponse] = await Promise.all([
                apiService.getUserProfile(),
                apiService.getPolicies(),
                apiService.getClaims(),
            ]);

            setUser(userResponse);
            setPolicies(policiesResponse);
            setClaims(claimsResponse);
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

    const getPolicyStatusBadge = (status) => {
        const statusMap = {
            active: { label: 'Aktif', class: 'badge-success' },
            pending: { label: 'Pending', class: 'badge-pending' },
            expired: { label: 'Kadaluarsa', class: 'badge-error' },
            cancelled: { label: 'Dibatalkan', class: 'badge-error' },
        };
        return statusMap[status] || { label: status, class: 'badge-info' };
    };

    const getClaimStatusBadge = (status) => {
        const statusMap = {
            pending: { label: 'Menunggu', class: 'badge-pending', icon: '⏳' },
            approved: { label: 'Disetujui', class: 'badge-success', icon: '✅' },
            rejected: { label: 'Ditolak', class: 'badge-error', icon: '❌' },
            processing: { label: 'Diproses', class: 'badge-info', icon: '🔄' },
        };
        return statusMap[status] || { label: status, class: 'badge-info', icon: '📋' };
    };

    const formatCurrency = (amount) => {
        if (!amount && amount !== 0) return 'Rp 0';
        const formatted = Math.floor(amount).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
        return `Rp ${formatted}`;
    };

    const formatDate = (dateString) => {
        return new Date(dateString).toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
        });
    };

    const handlePhotoChange = (e) => {
        const files = Array.from(e.target.files);
        const validFiles = files.filter(file => {
            if (file.size > 10 * 1024 * 1024) {
                toast.warning(`${file.name} melebihi 10MB dan tidak akan diupload`);
                return false;
            }
            return true;
        });
        setClaimForm({
            ...claimForm,
            photos: [...claimForm.photos, ...validFiles].slice(0, 5),
        });
    };

    const removePhoto = (index) => {
        setClaimForm({
            ...claimForm,
            photos: claimForm.photos.filter((_, i) => i !== index),
        });
    };

    const resetClaimForm = () => {
        setClaimForm({
            damage_description: '',
            incident_date: new Date().toISOString().split('T')[0],
            photos: [],
        });
        setSelectedPolicy(null);
        setShowClaimForm(false);
    };

    const handleSubmitClaim = async (e) => {
        e.preventDefault();
        if (!selectedPolicy) {
            toast.error('Pilih polis terlebih dahulu');
            return;
        }
        if (!claimForm.damage_description.trim()) {
            toast.error('Mohon isi deskripsi kerusakan');
            return;
        }
        setIsSubmitting(true);
        try {
            const formData = new FormData();
            formData.append('policy', selectedPolicy.id);
            formData.append('damage_type', 'Kerusakan Umum');
            formData.append('damage_description', claimForm.damage_description);
            formData.append('incident_date', claimForm.incident_date);
            claimForm.photos.forEach((photo, index) => {
                formData.append(`photo_${index}`, photo);
            });
            await apiService.submitClaim(formData);
            toast.success('Klaim berhasil diajukan!');
            resetClaimForm();
            loadData();
        } catch (error) {
            console.error('Error submitting claim:', error);
            toast.error(error.response?.data?.detail || 'Gagal mengajukan klaim.');
        } finally {
            setIsSubmitting(false);
        }
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
                        <p>{user?.store?.name ? `Terdaftar di toko: ${user.store.name}` : 'Kelola polis dan ajukan klaim dengan mudah'}</p>
                    </div>
                </div>

                {/* Stats Cards */}
                <div className="stats-grid animate-slideUp">
                    <div className="stat-card">
                        <div className="stat-icon policies">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                            </svg>
                        </div>
                        <div className="stat-info">
                            <span className="stat-label">Total Polis</span>
                            <span className="stat-value">{policies.length}</span>
                        </div>
                    </div>

                    <div className="stat-card">
                        <div className="stat-icon balance">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2" />
                                <rect x="8" y="2" width="8" height="4" rx="1" ry="1" />
                            </svg>
                        </div>
                        <div className="stat-info">
                            <span className="stat-label">Riwayat Klaim</span>
                            <span className="stat-value">{claims.length}</span>
                        </div>
                    </div>
                </div>

                {/* Main Content Sections: Side by Side on Desktop */}
                <div className="sections-grid">
                    {/* Policies Section */}
                    <div className="policies-section animate-slideUp">
                        <div className="section-header">
                            <h2>Polis Anda</h2>
                        </div>

                        {policies.length === 0 ? (
                            <div className="empty-state">
                                <div className="empty-icon">🛡️</div>
                                <h3>Belum Ada Polis</h3>
                                <p>Admin akan menambahkan polis untuk perangkat Anda.</p>
                            </div>
                        ) : (
                            <div className="policies-list-stack">
                                {policies.map((policy) => {
                                    const status = getPolicyStatusBadge(policy.status);
                                    return (
                                        <div key={policy.id} className="policy-card compact">
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
                                                <span className="balance-value text-success font-bold">{formatCurrency(policy.policy_balance)}</span>
                                            </div>

                                            <div className="policy-footer">
                                                <div className="store-info-badge">
                                                    <span className="store-label">🏪 Terdaftar di:</span>
                                                    <span className="store-value">{policy.store_name || 'Smile Center'}</span>
                                                </div>
                                            </div>
                                            <div className="policy-device">
                                                <div className="device-row mb-1">
                                                    <span className="device-label">Perangkat:</span>
                                                    <span className="device-value font-medium">{policy.device_brand} {policy.device_model}</span>
                                                </div>
                                            </div>

                                            <div className="policy-actions mt-4">
                                                {policy.status === 'active' ? (
                                                    <button
                                                        onClick={() => {
                                                            setSelectedPolicy(policy);
                                                            setShowClaimForm(true);
                                                        }}
                                                        className="btn btn-primary btn-block"
                                                    >
                                                        <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                            <path d="M14.5 4h-5L7 7H4a2 2 0 00-2 2v9a2 2 0 002 2h16a2 2 0 002-2V9a2 2 0 00-2-2h-3l-2.5-3z" />
                                                            <circle cx="12" cy="13" r="3" />
                                                        </svg>
                                                        Ajukan Klaim
                                                    </button>
                                                ) : (
                                                    <button className="btn btn-secondary btn-block" disabled>
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

                    {/* Claims History Section */}
                    <div className="claims-history-section animate-slideUp delay-100">
                        <div className="section-header">
                            <h2>Riwayat Klaim</h2>
                        </div>

                        {claims.length === 0 ? (
                            <div className="empty-state">
                                <div className="empty-icon">📋</div>
                                <h3>Belum Ada Klaim</h3>
                                <p>Riwayat klaim Anda akan muncul di sini.</p>
                            </div>
                        ) : (
                            <div className="claims-list-stack">
                                {claims.map((claim) => {
                                    const status = getClaimStatusBadge(claim.status);
                                    return (
                                        <div key={claim.id} className="dashboard-claim-card">
                                            <div className="claim-header">
                                                <div className="claim-status">
                                                    <span className="status-icon">{status.icon}</span>
                                                    <span className={`badge ${status.class}`}>{status.label}</span>
                                                </div>
                                                <span className="claim-date">{formatDate(claim.created_at)}</span>
                                            </div>
                                            <div className="claim-device">
                                                <strong>{claim.device_brand} {claim.device_model}</strong>
                                                <p className="claim-type">{claim.damage_type}</p>
                                            </div>
                                            {claim.claim_amount > 0 && (
                                                <div className="claim-amount">
                                                    <span className="amount-label">Jumlah : </span>
                                                    <span className="amount-value text-primary">{formatCurrency(claim.claim_amount)}</span>
                                                </div>
                                            )}
                                            {claim.admin_notes && (
                                                <div className="claim-notes">
                                                    <span className="notes-label">Note Admin:</span>
                                                    <p>{claim.admin_notes}</p>
                                                </div>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </div>
                </div>

                {/* Claim Form Modal - Reuse from ClaimsPage */}
                {showClaimForm && (
                    <div className="modal-overlay" onClick={() => resetClaimForm()}>
                        <div className="claim-form-modal animate-slideUp" onClick={e => e.stopPropagation()}>
                            <div className="modal-header">
                                <h2>Ajukan Klaim Baru</h2>
                                <button className="close-btn" onClick={() => resetClaimForm()}>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <line x1="18" y1="6" x2="6" y2="18" />
                                        <line x1="6" y1="6" x2="18" y2="18" />
                                    </svg>
                                </button>
                            </div>

                            <form onSubmit={handleSubmitClaim} className="claim-form">
                                <div className="form-group">
                                    <label className="form-label">Polis</label>
                                    <div className="policy-info-card">
                                        <div className="policy-info-header">
                                            <span className="policy-icon">🛡️</span>
                                            <div className="policy-info-details">
                                                <h4>{selectedPolicy.device_brand} {selectedPolicy.device_model}</h4>
                                                <span className="policy-number">{selectedPolicy.policy_number}</span>
                                            </div>
                                        </div>
                                        <div className="policy-balance-row">
                                            <span>Saldo Policy:</span>
                                            <strong>{formatCurrency(selectedPolicy.policy_balance)}</strong>
                                        </div>
                                    </div>
                                </div>

                                <div className="form-group">
                                    <label className="form-label">Deskripsi Kerusakan</label>
                                    <textarea
                                        className="form-textarea"
                                        rows="3"
                                        placeholder="Jelaskan detail kerusakan..."
                                        value={claimForm.damage_description}
                                        onChange={(e) => setClaimForm({ ...claimForm, damage_description: e.target.value })}
                                        disabled={isSubmitting}
                                        maxLength={500}
                                    />
                                </div>

                                <div className="form-group">
                                    <label className="form-label">Tanggal Kejadian</label>
                                    <input
                                        type="date"
                                        className="form-input"
                                        value={claimForm.incident_date}
                                        onChange={(e) => setClaimForm({ ...claimForm, incident_date: e.target.value })}
                                        max={new Date().toISOString().split('T')[0]}
                                        disabled={isSubmitting}
                                    />
                                </div>

                                <div className="form-group">
                                    <label className="form-label">Foto Kerusakan (Maks. 5)</label>
                                    <div className="photo-upload-area">
                                        <div className="photo-grid">
                                            {claimForm.photos.map((photo, index) => (
                                                <div key={index} className="photo-preview">
                                                    <img src={URL.createObjectURL(photo)} alt="Preview" />
                                                    <button type="button" className="remove-photo" onClick={() => removePhoto(index)}>×</button>
                                                </div>
                                            ))}
                                            {claimForm.photos.length < 5 && (
                                                <label className="add-photo-btn">
                                                    <input type="file" accept="image/*" onChange={handlePhotoChange} disabled={isSubmitting} hidden />
                                                    <span className="add-icon">+</span>
                                                </label>
                                            )}
                                        </div>
                                    </div>
                                </div>

                                <div className="modal-actions">
                                    <button type="button" className="btn btn-secondary" onClick={() => resetClaimForm()}>Batal</button>
                                    <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
                                        {isSubmitting ? 'Mengirim...' : 'Ajukan Klaim'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}

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
