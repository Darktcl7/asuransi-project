// pages/ProfilePage.jsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/apiService';
import { authService } from '../services/authService';
import { useToast } from '../components/Toast';
import './ProfilePage.css';

const ProfilePage = () => {
    const navigate = useNavigate();
    const toast = useToast();
    const [user, setUser] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isEditing, setIsEditing] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        phone_number: '',
        address: '',
        ktp_number: '',
    });

    useEffect(() => {
        loadProfile();
    }, []);

    const loadProfile = async () => {
        setIsLoading(true);
        try {
            const response = await apiService.getUserProfile();
            setUser(response);
            setFormData({
                full_name: response.full_name || '',
                email: response.email || '',
                phone_number: response.phone_number || '',
                address: response.address || '',
                ktp_number: response.ktp_number || '',
            });
        } catch (error) {
            console.error('Error loading profile:', error);
            if (error.response?.status === 401) {
                authService.logout();
                navigate('/login');
            } else {
                toast.error('Gagal memuat profil.');
            }
        } finally {
            setIsLoading(false);
        }
    };

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    const handleSave = async () => {
        if (!formData.full_name.trim()) {
            toast.error('Nama tidak boleh kosong');
            return;
        }

        setIsSaving(true);
        try {
            const response = await apiService.updateProfile({
                full_name: formData.full_name,
                phone_number: formData.phone_number,
                address: formData.address,
                ktp_number: formData.ktp_number,
            });

            setUser(response);
            localStorage.setItem('user_data', JSON.stringify(response));
            setIsEditing(false);
            toast.success('Profil berhasil diperbarui!');
        } catch (error) {
            console.error('Error updating profile:', error);
            toast.error(error.response?.data?.detail || 'Gagal memperbarui profil.');
        } finally {
            setIsSaving(false);
        }
    };

    const handleLogout = () => {
        authService.logout();
        navigate('/');
        toast.info('Anda telah keluar.');
    };

    const formatDate = (dateString) => {
        if (!dateString) return '-';
        return new Date(dateString).toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
        });
    };

    if (isLoading) {
        return (
            <div className="profile-page">
                <div className="container">
                    <div className="loading-screen">
                        <div className="spinner"></div>
                        <p>Memuat profil...</p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="profile-page">
            <div className="container">
                {/* Header */}
                <div className="profile-header animate-slideDown">
                    <h1>Profil Saya</h1>
                    <div className="header-actions">
                        {isEditing ? (
                            <>
                                <button className="btn btn-secondary" onClick={() => setIsEditing(false)} disabled={isSaving}>
                                    Batal
                                </button>
                                <button className="btn btn-primary" onClick={handleSave} disabled={isSaving}>
                                    {isSaving ? (
                                        <>
                                            <span className="spinner spinner-sm"></span>
                                            Menyimpan...
                                        </>
                                    ) : (
                                        <>
                                            <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                <polyline points="20,6 9,17 4,12" />
                                            </svg>
                                            Simpan
                                        </>
                                    )}
                                </button>
                            </>
                        ) : (
                            <button className="btn btn-secondary" onClick={() => setIsEditing(true)}>
                                <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" />
                                    <path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z" />
                                </svg>
                                Edit Profil
                            </button>
                        )}
                    </div>
                </div>

                <div className="profile-content animate-slideUp">
                    {/* Profile Card */}
                    <div className="profile-card">
                        <div className="profile-avatar">
                            <div className="avatar-circle">
                                {user?.full_name?.charAt(0)?.toUpperCase() || 'U'}
                            </div>
                            <h2>{user?.full_name || 'User'}</h2>
                            <p>{user?.email}</p>
                        </div>

                        <div className="profile-stats">
                            <div className="stat-item">
                                <span className="stat-value">{user?.policy_count || 0}</span>
                                <span className="stat-label">Polis</span>
                            </div>
                            <div className="stat-item">
                                <span className="stat-value">{user?.claim_count || 0}</span>
                                <span className="stat-label">Klaim</span>
                            </div>
                            <div className="stat-item">
                                <span className="stat-value">{formatDate(user?.date_joined)}</span>
                                <span className="stat-label">Bergabung</span>
                            </div>
                        </div>
                    </div>

                    {/* Profile Form */}
                    <div className="profile-form-card">
                        <h3>Informasi Pribadi</h3>

                        <div className="profile-form">
                            <div className="form-group">
                                <label className="form-label">Nama Lengkap</label>
                                <input
                                    type="text"
                                    name="full_name"
                                    className="form-input"
                                    value={formData.full_name}
                                    onChange={handleChange}
                                    disabled={!isEditing}
                                    placeholder="Masukkan nama lengkap"
                                />
                            </div>

                            <div className="form-group">
                                <label className="form-label">Email</label>
                                <input
                                    type="email"
                                    name="email"
                                    className="form-input"
                                    value={formData.email}
                                    disabled
                                    placeholder="Email tidak dapat diubah"
                                />
                                <span className="form-hint">Email tidak dapat diubah</span>
                            </div>

                            <div className="form-group">
                                <label className="form-label">Nomor Telepon</label>
                                <input
                                    type="tel"
                                    name="phone_number"
                                    className="form-input"
                                    value={formData.phone_number}
                                    onChange={handleChange}
                                    disabled={!isEditing}
                                    placeholder="Masukkan nomor telepon"
                                />
                            </div>

                            <div className="form-group">
                                <label className="form-label">Alamat</label>
                                <textarea
                                    name="address"
                                    className="form-textarea"
                                    rows="3"
                                    value={formData.address}
                                    onChange={handleChange}
                                    disabled={!isEditing}
                                    placeholder="Masukkan alamat lengkap"
                                />
                            </div>
                        </div>
                    </div>

                    {/* KTP Verification Card */}
                    <div className="profile-form-card">
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
                            <h3 style={{ margin: 0 }}>Verifikasi KTP</h3>
                            {user?.is_verified ? (
                                <span style={{
                                    backgroundColor: '#d1fae5',
                                    color: '#065f46',
                                    padding: '4px 12px',
                                    borderRadius: '20px',
                                    fontSize: '12px',
                                    fontWeight: '600'
                                }}>
                                    ✓ Terverifikasi
                                </span>
                            ) : (
                                <span style={{
                                    backgroundColor: '#fef3c7',
                                    color: '#92400e',
                                    padding: '4px 12px',
                                    borderRadius: '20px',
                                    fontSize: '12px',
                                    fontWeight: '600'
                                }}>
                                    Belum Terverifikasi
                                </span>
                            )}
                        </div>

                        {!user?.is_verified && (
                            <div style={{
                                backgroundColor: '#fffbeb',
                                border: '1px solid #f59e0b',
                                borderRadius: '8px',
                                padding: '12px',
                                marginBottom: '16px'
                            }}>
                                <p style={{ margin: 0, fontSize: '14px', color: '#92400e' }}>
                                    ⚠️ Lengkapi nomor KTP untuk aktivasi akun dan dapat mengajukan klaim.
                                </p>
                            </div>
                        )}

                        <div className="profile-form">
                            <div className="form-group">
                                <label className="form-label">Nomor KTP (16 digit)</label>
                                <input
                                    type="text"
                                    name="ktp_number"
                                    className="form-input"
                                    value={formData.ktp_number}
                                    onChange={(e) => {
                                        // Only allow numbers and max 16 digits
                                        const value = e.target.value.replace(/\D/g, '').slice(0, 16);
                                        setFormData({ ...formData, ktp_number: value });
                                    }}
                                    // Disabled jika: tidak editing ATAU sudah ada KTP (sudah pernah input)
                                    disabled={!isEditing || (user?.ktp_number && user?.ktp_number.trim())}
                                    placeholder="Contoh: 3173012345678901"
                                    maxLength={16}
                                    style={{
                                        letterSpacing: '2px',
                                        fontFamily: 'monospace',
                                        fontSize: '16px',
                                        backgroundColor: (user?.ktp_number && user?.ktp_number.trim()) ? '#f3f4f6' : undefined
                                    }}
                                />
                                {user?.is_verified ? (
                                    <span className="form-hint" style={{ color: '#059669' }}>
                                        ✓ KTP sudah terverifikasi oleh admin
                                    </span>
                                ) : user?.ktp_number && user?.ktp_number.trim() ? (
                                    <span className="form-hint" style={{ color: '#f59e0b' }}>
                                        ⏳ KTP menunggu verifikasi admin. Tidak dapat diubah.
                                    </span>
                                ) : (
                                    <span className="form-hint">
                                        ⚠️ Input nomor KTP hanya dapat dilakukan SEKALI. Pastikan benar!
                                    </span>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Danger Zone */}
                    <div className="danger-zone">
                        <h3>Zona Berbahaya</h3>
                        <p>Tindakan di bawah ini tidak dapat dibatalkan</p>
                        <button className="btn btn-outline danger" onClick={handleLogout}>
                            <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4" />
                                <polyline points="16,17 21,12 16,7" />
                                <line x1="21" y1="12" x2="9" y2="12" />
                            </svg>
                            Keluar dari Akun
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default ProfilePage;
