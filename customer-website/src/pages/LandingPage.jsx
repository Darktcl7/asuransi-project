// pages/LandingPage.jsx
import { Link } from 'react-router-dom';
import { authService } from '../services/authService';
import './LandingPage.css';

const LandingPage = () => {
    const isLoggedIn = authService.isAuthenticated();

    return (
        <div className="landing-page">
            {/* Hero Section */}
            <section className="hero">
                <div className="hero-bg">
                    <div className="hero-gradient"></div>
                    <div className="hero-shapes">
                        <div className="shape shape-1"></div>
                        <div className="shape shape-2"></div>
                        <div className="shape shape-3"></div>
                    </div>
                </div>

                <div className="container hero-content">
                    <div className="hero-text">
                        <div className="hero-badge animate-slideDown">
                            <span className="badge-icon">🛡️</span>
                            <span>Proteksi Smartphone #1 di Indonesia</span>
                        </div>

                        <h1 className="hero-title animate-slideUp">
                            Lindungi Smartphone Anda dengan
                            <span className="highlight"> Smile Insurance</span>
                        </h1>

                        <p className="hero-description animate-slideUp">
                            Perlindungan lengkap untuk smartphone kesayangan Anda dari kerusakan,
                            kehilangan, dan kecelakaan. Proses klaim mudah dan cepat!
                        </p>

                        <div className="hero-actions animate-slideUp">
                            {isLoggedIn ? (
                                <Link to="/dashboard" className="btn btn-primary btn-lg">
                                    <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <rect x="3" y="3" width="7" height="9" rx="1" />
                                        <rect x="14" y="3" width="7" height="5" rx="1" />
                                        <rect x="14" y="12" width="7" height="9" rx="1" />
                                        <rect x="3" y="16" width="7" height="5" rx="1" />
                                    </svg>
                                    Buka Dashboard
                                </Link>
                            ) : (
                                <>
                                    <Link to="/register" className="btn btn-primary btn-lg">
                                        Daftar Sekarang
                                        <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <line x1="5" y1="12" x2="19" y2="12" />
                                            <polyline points="12,5 19,12 12,19" />
                                        </svg>
                                    </Link>
                                    <Link to="/download" className="btn btn-secondary btn-lg">
                                        <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                            <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
                                            <polyline points="7,10 12,15 17,10" />
                                            <line x1="12" y1="15" x2="12" y2="3" />
                                        </svg>
                                        Download App
                                    </Link>
                                </>
                            )}
                        </div>

                        <div className="hero-stats animate-slideUp">
                            <div className="stat-item">
                                <span className="stat-number">10K+</span>
                                <span className="stat-label">Pengguna Aktif</span>
                            </div>
                            <div className="stat-divider"></div>
                            <div className="stat-item">
                                <span className="stat-number">5K+</span>
                                <span className="stat-label">Klaim Diproses</span>
                            </div>
                            <div className="stat-divider"></div>
                            <div className="stat-item">
                                <span className="stat-number">98%</span>
                                <span className="stat-label">Kepuasan</span>
                            </div>
                        </div>
                    </div>

                    <div className="hero-visual animate-fadeIn">
                        <div className="phone-mockup">
                            <div className="phone-frame">
                                <div className="phone-screen">
                                    <div className="app-header">
                                        <span className="app-emoji">😊</span>
                                        <span>Smile Insurance</span>
                                    </div>
                                    <div className="app-content">
                                        <div className="app-balance">
                                            <span className="balance-label">Saldo Polis</span>
                                            <span className="balance-amount">Rp 5.000.000</span>
                                        </div>
                                        <div className="app-policy">
                                            <div className="policy-icon">🛡️</div>
                                            <div className="policy-info">
                                                <span className="policy-name">Premium Gold</span>
                                                <span className="policy-status">Active</span>
                                            </div>
                                        </div>
                                        <button className="app-claim-btn">Ajukan Klaim</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="floating-card card-1">
                            <span className="card-emoji">✅</span>
                            <span>Klaim Disetujui!</span>
                        </div>
                        <div className="floating-card card-2">
                            <span className="card-emoji">💰</span>
                            <span>+Rp 2.500.000</span>
                        </div>
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section className="features" id="features">
                <div className="container">
                    <div className="section-header">
                        <span className="section-badge">Fitur Unggulan</span>
                        <h2 className="section-title">Kenapa Pilih Smile Insurance?</h2>
                        <p className="section-description">
                            Kami memberikan perlindungan terbaik dengan proses yang mudah dan transparan
                        </p>
                    </div>

                    <div className="features-grid">
                        <div className="feature-card">
                            <div className="feature-icon">
                                <span>⚡</span>
                            </div>
                            <h3>Proses Cepat</h3>
                            <p>Klaim diproses dalam 24-48 jam kerja. Tidak perlu menunggu lama!</p>
                        </div>

                        <div className="feature-card">
                            <div className="feature-icon">
                                <span>📱</span>
                            </div>
                            <h3>Mobile App</h3>
                            <p>Kelola polis dan ajukan klaim langsung dari smartphone Anda</p>
                        </div>

                        <div className="feature-card">
                            <div className="feature-icon">
                                <span>🔒</span>
                            </div>
                            <h3>Perlindungan Lengkap</h3>
                            <p>Dari kerusakan layar, baterai, hingga kerusakan akibat air</p>
                        </div>

                        <div className="feature-card">
                            <div className="feature-icon">
                                <span>💳</span>
                            </div>
                            <h3>Pembayaran Fleksibel</h3>
                            <p>Berbagai pilihan paket sesuai kebutuhan dan budget Anda</p>
                        </div>

                        <div className="feature-card">
                            <div className="feature-icon">
                                <span>🏆</span>
                            </div>
                            <h3>Terpercaya</h3>
                            <p>Didukung oleh perusahaan asuransi terkemuka di Indonesia</p>
                        </div>

                        <div className="feature-card">
                            <div className="feature-icon">
                                <span>🎧</span>
                            </div>
                            <h3>Support 24/7</h3>
                            <p>Tim customer service siap membantu kapan saja Anda butuhkan</p>
                        </div>
                    </div>
                </div>
            </section>

            {/* How It Works */}
            <section className="how-it-works">
                <div className="container">
                    <div className="section-header">
                        <span className="section-badge">Cara Kerja</span>
                        <h2 className="section-title">Mudah dan Simpel</h2>
                        <p className="section-description">
                            Hanya 3 langkah untuk melindungi smartphone Anda
                        </p>
                    </div>

                    <div className="steps-container">
                        <div className="step">
                            <div className="step-number">1</div>
                            <div className="step-content">
                                <h3>Daftar & Login</h3>
                                <p>Buat akun gratis dan masuk ke aplikasi Smile Insurance</p>
                            </div>
                        </div>
                        <div className="step-connector"></div>
                        <div className="step">
                            <div className="step-number">2</div>
                            <div className="step-content">
                                <h3>Aktivasi Polis</h3>
                                <p>Admin akan mengaktifkan polis untuk perangkat Anda</p>
                            </div>
                        </div>
                        <div className="step-connector"></div>
                        <div className="step">
                            <div className="step-number">3</div>
                            <div className="step-content">
                                <h3>Ajukan Klaim</h3>
                                <p>Upload foto kerusakan dan dapatkan penggantian</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* CTA Section */}
            <section className="cta">
                <div className="container">
                    <div className="cta-card">
                        <div className="cta-content">
                            <h2>Siap Melindungi Smartphone Anda?</h2>
                            <p>Download aplikasi Smile Insurance sekarang dan dapatkan perlindungan terbaik</p>
                            <div className="cta-actions">
                                <Link to="/download" className="btn btn-primary btn-lg">
                                    <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
                                        <polyline points="7,10 12,15 17,10" />
                                        <line x1="12" y1="15" x2="12" y2="3" />
                                    </svg>
                                    Download Sekarang
                                </Link>
                                {!isLoggedIn && (
                                    <Link to="/register" className="btn btn-outline btn-lg">
                                        Daftar Gratis
                                    </Link>
                                )}
                            </div>
                        </div>
                        <div className="cta-visual">
                            <span className="cta-emoji">📱</span>
                        </div>
                    </div>
                </div>
            </section>

            {/* Footer */}
            <footer className="footer">
                <div className="container">
                    <div className="footer-content">
                        <div className="footer-brand">
                            <div className="footer-logo">
                                <span>😊</span>
                                <span>Smile Insurance</span>
                            </div>
                            <p>Perlindungan smartphone terpercaya di Indonesia</p>
                        </div>
                        <div className="footer-links">
                            <div className="footer-column">
                                <h4>Produk</h4>
                                <a href="#features">Fitur</a>
                                <a href="#how-it-works">Cara Kerja</a>
                                <Link to="/download">Download App</Link>
                            </div>
                            <div className="footer-column">
                                <h4>Dukungan</h4>
                                <a href="#">FAQ</a>
                                <a href="#">Hubungi Kami</a>
                                <a href="#">Syarat & Ketentuan</a>
                            </div>
                        </div>
                    </div>
                    <div className="footer-bottom">
                        <p>&copy; 2026 Smile Insurance. All rights reserved.</p>
                    </div>
                </div>
            </footer>
        </div>
    );
};

export default LandingPage;
