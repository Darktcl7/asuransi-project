// pages/LoginPage.jsx
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { authService } from '../services/authService';
import { useToast } from '../components/Toast';
import './AuthPages.css';

const LoginPage = () => {
    const navigate = useNavigate();
    const toast = useToast();
    const [formData, setFormData] = useState({
        identifier: '',
        password: '',
    });
    const [isLoading, setIsLoading] = useState(false);
    const [showPassword, setShowPassword] = useState(false);

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value,
        });
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!formData.identifier || !formData.password) {
            toast.error('Mohon isi semua field');
            return;
        }

        setIsLoading(true);

        try {
            await authService.login(formData.identifier, formData.password);
            toast.success('Login berhasil!');
            navigate('/dashboard');
        } catch (error) {
            console.error('Login error:', error);
            const message = error.response?.data?.detail || error.response?.data?.error || 'Login gagal. Periksa email dan password Anda.';
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
                            <h1>Selamat Datang!</h1>
                            <p>Masuk ke akun Anda untuk melanjutkan</p>
                        </div>

                        <form onSubmit={handleSubmit} className="auth-form">
                            <div className="form-group">
                                <label className="form-label">Email atau Nomor Telepon</label>
                                <div className="input-wrapper">
                                    <svg className="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" />
                                        <circle cx="12" cy="7" r="4" />
                                    </svg>
                                    <input
                                        type="text"
                                        name="identifier"
                                        className="form-input"
                                        placeholder="email@contoh.com atau 08xxxxxxxxxx"
                                        value={formData.identifier}
                                        onChange={handleChange}
                                        disabled={isLoading}
                                    />
                                </div>
                            </div>

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
                                        placeholder="Masukkan password"
                                        value={formData.password}
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

                            <div className="form-options">
                                <label className="checkbox-wrapper">
                                    <input type="checkbox" />
                                    <span className="checkmark"></span>
                                    <span>Ingat saya</span>
                                </label>
                                <Link to="/forgot-password" className="forgot-link">Lupa password?</Link>
                            </div>

                            <button type="submit" className="btn btn-primary btn-lg auth-submit" disabled={isLoading}>
                                {isLoading ? (
                                    <>
                                        <span className="spinner spinner-sm"></span>
                                        Memproses...
                                    </>
                                ) : (
                                    <>
                                        Masuk
                                        <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <line x1="5" y1="12" x2="19" y2="12" />
                                            <polyline points="12,5 19,12 12,19" />
                                        </svg>
                                    </>
                                )}
                            </button>
                        </form>

                        <p className="auth-footer">
                            Belum punya akun? <Link to="/register">Daftar sekarang</Link>
                        </p>
                    </div>
                </div>

                {/* Right Side - Visual */}
                <div className="auth-visual-section">
                    <div className="auth-visual-content">
                        <div className="visual-card">
                            <div className="visual-icon">🛡️</div>
                            <h3>Perlindungan Terpercaya</h3>
                            <p>Lebih dari 10.000 pengguna mempercayakan perlindungan smartphone mereka kepada kami</p>
                        </div>
                        <div className="visual-stats">
                            <div className="visual-stat">
                                <span className="stat-value">98%</span>
                                <span className="stat-label">Kepuasan</span>
                            </div>
                            <div className="visual-stat">
                                <span className="stat-value">24-48</span>
                                <span className="stat-label">Jam Proses</span>
                            </div>
                            <div className="visual-stat">
                                <span className="stat-value">5K+</span>
                                <span className="stat-label">Klaim</span>
                            </div>
                        </div>
                    </div>
                    <div className="auth-visual-bg"></div>
                </div>
            </div>
        </div>
    );
};

export default LoginPage;
