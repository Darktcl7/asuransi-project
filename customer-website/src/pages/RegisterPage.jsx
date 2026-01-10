// pages/RegisterPage.jsx
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import { useToast } from '../components/Toast';
import './AuthPages.css';

const RegisterPage = () => {
    const navigate = useNavigate();
    const toast = useToast();
    const [formData, setFormData] = useState({
        full_name: '',
        email: '',
        phone_number: '',
        password: '',
        confirmPassword: '',
    });
    const [isLoading, setIsLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    const validateForm = () => {
        if (!formData.full_name || !formData.email || !formData.phone_number || !formData.password) {
            toast.error('Mohon isi semua field');
            return false;
        }

        if (formData.password.length < 6) {
            toast.error('Password minimal 6 karakter');
            return false;
        }

        if (formData.password !== formData.confirmPassword) {
            toast.error('Password tidak cocok');
            return false;
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(formData.email)) {
            toast.error('Format email tidak valid');
            return false;
        }

        const phoneRegex = /^[0-9]{10,13}$/;
        if (!phoneRegex.test(formData.phone_number.replace(/[^0-9]/g, ''))) {
            toast.error('Nomor telepon tidak valid');
            return false;
        }

        return true;
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!validateForm()) return;

        setIsLoading(true);

        try {
            await authService.register({
                full_name: formData.full_name,
                email: formData.email,
                phone_number: formData.phone_number,
                password: formData.password,
            });

            toast.success('Registrasi berhasil! Silakan login.');
            navigate('/login');
        } catch (error) {
            console.error('Register error:', error);
            const message = error.response?.data?.detail ||
                error.response?.data?.email?.[0] ||
                error.response?.data?.phone_number?.[0] ||
                'Registrasi gagal. Silakan coba lagi.';
            toast.error(message);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="auth-page">
            <div className="auth-container">
                {/* Left Side - Form */}
                <div className="auth-form-section">
                    <div className="auth-form-wrapper">
                        <Link to="/" className="auth-logo">
                            <span className="logo-emoji">😊</span>
                            <span className="logo-text">Smile Insurance</span>
                        </Link>

                        <div className="auth-header">
                            <h1>Buat Akun Baru</h1>
                            <p>Daftar untuk mendapatkan perlindungan terbaik</p>
                        </div>

                        <form onSubmit={handleSubmit} className="auth-form">
                            <div className="form-group">
                                <label className="form-label">Nama Lengkap</label>
                                <div className="input-wrapper">
                                    <svg className="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" />
                                        <circle cx="12" cy="7" r="4" />
                                    </svg>
                                    <input
                                        type="text"
                                        name="full_name"
                                        className="form-input"
                                        placeholder="Masukkan nama lengkap"
                                        value={formData.full_name}
                                        onChange={handleChange}
                                        disabled={isLoading}
                                    />
                                </div>
                            </div>

                            <div className="form-group">
                                <label className="form-label">Email</label>
                                <div className="input-wrapper">
                                    <svg className="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                                        <polyline points="22,6 12,13 2,6" />
                                    </svg>
                                    <input
                                        type="email"
                                        name="email"
                                        className="form-input"
                                        placeholder="email@contoh.com"
                                        value={formData.email}
                                        onChange={handleChange}
                                        disabled={isLoading}
                                    />
                                </div>
                            </div>

                            <div className="form-group">
                                <label className="form-label">Nomor Telepon</label>
                                <div className="input-wrapper">
                                    <svg className="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z" />
                                    </svg>
                                    <input
                                        type="tel"
                                        name="phone_number"
                                        className="form-input"
                                        placeholder="08xxxxxxxxxx"
                                        value={formData.phone_number}
                                        onChange={handleChange}
                                        disabled={isLoading}
                                    />
                                </div>
                            </div>

                            <div className="form-row">
                                <div className="form-group">
                                    <label className="form-label">Password</label>
                                    <div className="input-wrapper">
                                        <svg className="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <rect x="3" y="11" width="18" height="11" rx="2" />
                                            <path d="M7 11V7a5 5 0 0110 0v4" />
                                        </svg>
                                        <input
                                            type={showPassword ? 'text' : 'password'}
                                            name="password"
                                            className="form-input"
                                            placeholder="Min. 6 karakter"
                                            value={formData.password}
                                            onChange={handleChange}
                                            disabled={isLoading}
                                        />
                                    </div>
                                </div>

                                <div className="form-group">
                                    <label className="form-label">Konfirmasi Password</label>
                                    <div className="input-wrapper">
                                        <svg className="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <rect x="3" y="11" width="18" height="11" rx="2" />
                                            <path d="M7 11V7a5 5 0 0110 0v4" />
                                        </svg>
                                        <input
                                            type={showPassword ? 'text' : 'password'}
                                            name="confirmPassword"
                                            className="form-input"
                                            placeholder="Ulangi password"
                                            value={formData.confirmPassword}
                                            onChange={handleChange}
                                            disabled={isLoading}
                                        />
                                        <button
                                            type="button"
                                            className="password-toggle"
                                            onClick={() => setShowPassword(!showPassword)}
                                        >
                                            {showPassword ? (
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                    <path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24" />
                                                    <line x1="1" y1="1" x2="23" y2="23" />
                                                </svg>
                                            ) : (
                                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                                                    <circle cx="12" cy="12" r="3" />
                                                </svg>
                                            )}
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <div className="form-options">
                                <label className="checkbox-wrapper">
                                    <input type="checkbox" required />
                                    <span className="checkmark"></span>
                                    <span>Saya setuju dengan <a href="#">Syarat & Ketentuan</a></span>
                                </label>
                            </div>

                            <button type="submit" className="btn btn-primary btn-lg auth-submit" disabled={isLoading}>
                                {isLoading ? (
                                    <>
                                        <span className="spinner spinner-sm"></span>
                                        Memproses...
                                    </>
                                ) : (
                                    <>
                                        Daftar Sekarang
                                        <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <line x1="5" y1="12" x2="19" y2="12" />
                                            <polyline points="12,5 19,12 12,19" />
                                        </svg>
                                    </>
                                )}
                            </button>
                        </form>

                        <p className="auth-footer">
                            Sudah punya akun? <Link to="/login">Masuk</Link>
                        </p>
                    </div>
                </div>

                {/* Right Side - Visual */}
                <div className="auth-visual-section">
                    <div className="auth-visual-content">
                        <div className="visual-card">
                            <div className="visual-icon">🚀</div>
                            <h3>Mulai Perjalanan Anda</h3>
                            <p>Bergabung dengan ribuan pengguna yang sudah mempercayakan perlindungan smartphone mereka</p>
                        </div>
                        <div className="visual-features">
                            <div className="visual-feature">
                                <span className="feature-check">✓</span>
                                <span>Proses registrasi cepat</span>
                            </div>
                            <div className="visual-feature">
                                <span className="feature-check">✓</span>
                                <span>Perlindungan segera aktif</span>
                            </div>
                            <div className="visual-feature">
                                <span className="feature-check">✓</span>
                                <span>Klaim mudah & transparan</span>
                            </div>
                        </div>
                    </div>
                    <div className="auth-visual-bg register-bg"></div>
                </div>
            </div>
        </div>
    );
};

export default RegisterPage;
