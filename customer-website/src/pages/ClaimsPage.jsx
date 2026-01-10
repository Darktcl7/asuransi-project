// pages/ClaimsPage.jsx
import { useState, useEffect } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { apiService } from '../services/apiService';
import { authService } from '../services/authService';
import { useToast } from '../components/Toast';
import './ClaimsPage.css';

const ClaimsPage = () => {
    const navigate = useNavigate();
    const toast = useToast();
    const [searchParams] = useSearchParams();
    const [claims, setClaims] = useState([]);
    const [policies, setPolicies] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [showClaimForm, setShowClaimForm] = useState(false);
    const [selectedPolicy, setSelectedPolicy] = useState(null);
    const [claimForm, setClaimForm] = useState({
        damage_description: '',
        photos: [],
    });
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        loadData();

        // Check if we should open claim form for a specific policy
        const policyId = searchParams.get('policy');
        if (policyId) {
            setShowClaimForm(true);
        }
    }, [searchParams]);

    const loadData = async () => {
        setIsLoading(true);
        try {
            const [claimsResponse, policiesResponse] = await Promise.all([
                apiService.getClaims(),
                apiService.getPolicies(),
            ]);

            setClaims(claimsResponse);
            setPolicies(policiesResponse.filter(p => p.status === 'active'));

            // Set selected policy from URL if exists
            const policyId = searchParams.get('policy');
            if (policyId) {
                const policy = policiesResponse.find(p => p.id === parseInt(policyId));
                if (policy) {
                    setSelectedPolicy(policy);
                }
            }
        } catch (error) {
            console.error('Error loading claims data:', error);
            if (error.response?.status === 401) {
                authService.logout();
                navigate('/login');
            } else {
                toast.error('Gagal memuat data klaim.');
            }
        } finally {
            setIsLoading(false);
        }
    };

    const getStatusBadge = (status) => {
        const statusMap = {
            pending: { label: 'Menunggu', class: 'badge-pending', icon: '⏳' },
            approved: { label: 'Disetujui', class: 'badge-success', icon: '✅' },
            rejected: { label: 'Ditolak', class: 'badge-error', icon: '❌' },
            processing: { label: 'Diproses', class: 'badge-info', icon: '🔄' },
        };
        return statusMap[status] || { label: status, class: 'badge-info', icon: '📋' };
    };

    const formatDate = (dateString) => {
        return new Date(dateString).toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'long',
            year: 'numeric',
        });
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
        }).format(amount || 0);
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
            formData.append('damage_description', claimForm.damage_description);

            claimForm.photos.forEach((photo, index) => {
                formData.append(`photo_${index}`, photo);
            });

            await apiService.submitClaim(formData);

            toast.success('Klaim berhasil diajukan! Tim kami akan segera memprosesnya.');
            setShowClaimForm(false);
            setClaimForm({ damage_description: '', photos: [] });
            setSelectedPolicy(null);
            loadData();
        } catch (error) {
            console.error('Error submitting claim:', error);
            toast.error(error.response?.data?.detail || 'Gagal mengajukan klaim. Silakan coba lagi.');
        } finally {
            setIsSubmitting(false);
        }
    };

    if (isLoading) {
        return (
            <div className="claims-page">
                <div className="container">
                    <div className="loading-screen">
                        <div className="spinner"></div>
                        <p>Memuat riwayat klaim...</p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="claims-page">
            <div className="container">
                {/* Header */}
                <div className="claims-header animate-slideDown">
                    <div>
                        <h1>Klaim Asuransi</h1>
                        <p>Ajukan dan pantau status klaim Anda</p>
                    </div>
                    <button
                        className="btn btn-primary"
                        onClick={() => setShowClaimForm(true)}
                        disabled={policies.length === 0}
                    >
                        <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                            <line x1="12" y1="5" x2="12" y2="19" />
                            <line x1="5" y1="12" x2="19" y2="12" />
                        </svg>
                        Ajukan Klaim Baru
                    </button>
                </div>

                {/* Claim Form Modal */}
                {showClaimForm && (
                    <div className="modal-overlay" onClick={() => setShowClaimForm(false)}>
                        <div className="claim-form-modal animate-slideUp" onClick={e => e.stopPropagation()}>
                            <div className="modal-header">
                                <h2>Ajukan Klaim Baru</h2>
                                <button className="close-btn" onClick={() => setShowClaimForm(false)}>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <line x1="18" y1="6" x2="6" y2="18" />
                                        <line x1="6" y1="6" x2="18" y2="18" />
                                    </svg>
                                </button>
                            </div>

                            <form onSubmit={handleSubmitClaim} className="claim-form">
                                {/* Policy Selection */}
                                <div className="form-group">
                                    <label className="form-label">Pilih Polis</label>
                                    <div className="policy-select-grid">
                                        {policies.map(policy => (
                                            <div
                                                key={policy.id}
                                                className={`policy-option ${selectedPolicy?.id === policy.id ? 'selected' : ''}`}
                                                onClick={() => setSelectedPolicy(policy)}
                                            >
                                                <div className="policy-option-header">
                                                    <span className="policy-tier">{policy.tier_name || 'Standard'}</span>
                                                    {selectedPolicy?.id === policy.id && <span className="check-icon">✓</span>}
                                                </div>
                                                <div className="policy-option-device">
                                                    {policy.device_brand} {policy.device_model}
                                                </div>
                                                <div className="policy-option-balance">
                                                    Saldo: {formatCurrency(policy.policy_balance)}
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </div>

                                {/* Description */}
                                <div className="form-group">
                                    <label className="form-label">Deskripsi Kerusakan</label>
                                    <textarea
                                        className="form-textarea"
                                        rows="4"
                                        placeholder="Jelaskan kerusakan yang terjadi pada perangkat Anda..."
                                        value={claimForm.damage_description}
                                        onChange={(e) => setClaimForm({ ...claimForm, damage_description: e.target.value })}
                                        disabled={isSubmitting}
                                    />
                                </div>

                                {/* Photo Upload */}
                                <div className="form-group">
                                    <label className="form-label">Foto Kerusakan (Maks. 5 foto, 10MB/foto)</label>
                                    <div className="photo-upload-area">
                                        <input
                                            type="file"
                                            id="photos"
                                            accept="image/*"
                                            multiple
                                            onChange={handlePhotoChange}
                                            disabled={isSubmitting || claimForm.photos.length >= 5}
                                            hidden
                                        />
                                        <label htmlFor="photos" className="upload-label">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
                                                <polyline points="17,8 12,3 7,8" />
                                                <line x1="12" y1="3" x2="12" y2="15" />
                                            </svg>
                                            <span>Klik untuk upload foto</span>
                                        </label>

                                        {claimForm.photos.length > 0 && (
                                            <div className="photo-preview-grid">
                                                {claimForm.photos.map((photo, index) => (
                                                    <div key={index} className="photo-preview">
                                                        <img src={URL.createObjectURL(photo)} alt={`Preview ${index + 1}`} />
                                                        <button
                                                            type="button"
                                                            className="remove-photo"
                                                            onClick={() => removePhoto(index)}
                                                        >
                                                            ×
                                                        </button>
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                </div>

                                <div className="modal-actions">
                                    <button type="button" className="btn btn-secondary" onClick={() => setShowClaimForm(false)}>
                                        Batal
                                    </button>
                                    <button type="submit" className="btn btn-primary" disabled={isSubmitting}>
                                        {isSubmitting ? (
                                            <>
                                                <span className="spinner spinner-sm"></span>
                                                Mengirim...
                                            </>
                                        ) : (
                                            'Ajukan Klaim'
                                        )}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                )}

                {/* Claims List */}
                <div className="claims-list animate-slideUp">
                    {claims.length === 0 ? (
                        <div className="empty-state">
                            <div className="empty-icon">📋</div>
                            <h3>Belum Ada Klaim</h3>
                            <p>Anda belum pernah mengajukan klaim. Klik tombol di atas untuk mengajukan klaim baru.</p>
                        </div>
                    ) : (
                        <div className="claims-grid">
                            {claims.map(claim => {
                                const status = getStatusBadge(claim.status);
                                return (
                                    <div key={claim.id} className="claim-card">
                                        <div className="claim-header">
                                            <div className="claim-status">
                                                <span className="status-icon">{status.icon}</span>
                                                <span className={`badge ${status.class}`}>{status.label}</span>
                                            </div>
                                            <span className="claim-date">{formatDate(claim.created_at)}</span>
                                        </div>

                                        <div className="claim-policy">
                                            <div className="policy-badge">
                                                <span className="policy-emoji">🛡️</span>
                                                <span>{claim.policy_tier || 'Standard'}</span>
                                            </div>
                                            <span className="policy-device">{claim.device_brand} {claim.device_model}</span>
                                        </div>

                                        <div className="claim-description">
                                            <h4>Deskripsi Kerusakan</h4>
                                            <p>{claim.damage_description || 'Tidak ada deskripsi'}</p>
                                        </div>

                                        {claim.claim_amount && (
                                            <div className="claim-amount">
                                                <span className="amount-label">Jumlah Klaim</span>
                                                <span className="amount-value">{formatCurrency(claim.claim_amount)}</span>
                                            </div>
                                        )}

                                        {claim.admin_notes && (
                                            <div className="admin-notes">
                                                <h4>Catatan Admin</h4>
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
        </div>
    );
};

export default ClaimsPage;
