// pages/DownloadPage.jsx
import { useState } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import './DownloadPage.css';

const DownloadPage = () => {
    const [showQR, setShowQR] = useState(false);

    // URL to the APK file - This should be updated to actual APK URL on server
    const APK_URL = 'http://148.230.97.130/download/smile-insurance.apk';
    const WEBSITE_URL = 'http://148.230.97.130';

    const handleDownloadClick = () => {
        // Create a download link
        const link = document.createElement('a');
        link.href = APK_URL;
        link.download = 'smile-insurance.apk';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    return (
        <div className="download-page">
            {/* Hero Section */}
            <section className="download-hero">
                <div className="download-hero-bg">
                    <div className="hero-gradient"></div>
                    <div className="hero-pattern"></div>
                </div>

                <div className="container">
                    <div className="download-hero-content">
                        <div className="download-text">
                            <span className="download-badge">
                                <span className="badge-icon">📱</span>
                                Aplikasi Android
                            </span>

                            <h1>Download Smile Insurance</h1>
                            <p className="download-description">
                                Lindungi smartphone Anda kapan saja, di mana saja.
                                Download aplikasi Smile Insurance dan nikmati kemudahan mengajukan klaim
                                langsung dari genggaman Anda.
                            </p>

                            <div className="download-buttons">
                                <button onClick={handleDownloadClick} className="btn btn-primary btn-lg download-btn">
                                    <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4" />
                                        <polyline points="7,10 12,15 17,10" />
                                        <line x1="12" y1="15" x2="12" y2="3" />
                                    </svg>
                                    Download APK
                                    <span className="btn-meta">v1.0.0 • 48.4 MB</span>
                                </button>

                                <button
                                    onClick={() => setShowQR(!showQR)}
                                    className="btn btn-secondary btn-lg qr-btn"
                                >
                                    <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <rect x="3" y="3" width="7" height="7" rx="1" />
                                        <rect x="14" y="3" width="7" height="7" rx="1" />
                                        <rect x="3" y="14" width="7" height="7" rx="1" />
                                        <rect x="14" y="14" width="7" height="7" rx="1" />
                                    </svg>
                                    {showQR ? 'Sembunyikan QR' : 'Scan QR Code'}
                                </button>
                            </div>

                            {/* QR Code Section */}
                            {showQR && (
                                <div className="qr-section animate-slideUp">
                                    <div className="qr-card">
                                        <div className="qr-wrapper">
                                            <QRCodeSVG
                                                value={APK_URL}
                                                size={180}
                                                level="H"
                                                includeMargin={true}
                                                fgColor="#1f2937"
                                                bgColor="#ffffff"
                                            />
                                        </div>
                                        <div className="qr-info">
                                            <h4>Scan untuk Download</h4>
                                            <p>Arahkan kamera smartphone Anda ke QR code ini untuk langsung download APK</p>
                                        </div>
                                    </div>
                                </div>
                            )}
                        </div>

                        <div className="download-visual">
                            <div className="phone-showcase">
                                <div className="phone-frame">
                                    <div className="phone-notch"></div>
                                    <div className="phone-screen">
                                        <div className="screen-header">
                                            <span className="screen-emoji">😊</span>
                                            <span className="screen-title">Dashboard</span>
                                        </div>
                                        <div className="screen-card">
                                            <div className="card-header-mini">
                                                <span>🛡️</span>
                                                <span>Premium Gold</span>
                                            </div>
                                            <div className="card-balance">
                                                <span className="balance-label">Saldo</span>
                                                <span className="balance-value">Rp 5.000.000</span>
                                            </div>
                                        </div>
                                        <div className="screen-button">Ajukan Klaim</div>
                                    </div>
                                </div>
                                {/* Floating Elements */}
                                <div className="floating-badge badge-1">
                                    <span>✅</span> Terverifikasi
                                </div>
                                <div className="floating-badge badge-2">
                                    <span>⚡</span> Proses Cepat
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Features Section */}
            <section className="download-features">
                <div className="container">
                    <h2>Fitur Aplikasi</h2>

                    <div className="features-list">
                        <div className="feature-item">
                            <div className="feature-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <rect x="3" y="3" width="18" height="18" rx="2" />
                                    <path d="M3 9h18" />
                                    <path d="M9 21V9" />
                                </svg>
                            </div>
                            <div className="feature-content">
                                <h4>Dashboard Intuitif</h4>
                                <p>Lihat semua polis dan saldo Anda dalam satu tampilan yang mudah dipahami</p>
                            </div>
                        </div>

                        <div className="feature-item">
                            <div className="feature-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                    <path d="M9 12l2 2 4-4" />
                                </svg>
                            </div>
                            <div className="feature-content">
                                <h4>Perlindungan Lengkap</h4>
                                <p>Berbagai paket perlindungan sesuai kebutuhan smartphone Anda</p>
                            </div>
                        </div>

                        <div className="feature-item">
                            <div className="feature-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M14.5 4h-5L7 7H4a2 2 0 00-2 2v9a2 2 0 002 2h16a2 2 0 002-2V9a2 2 0 00-2-2h-3l-2.5-3z" />
                                    <circle cx="12" cy="13" r="3" />
                                </svg>
                            </div>
                            <div className="feature-content">
                                <h4>Upload Foto Kerusakan</h4>
                                <p>Ajukan klaim dengan mudah - cukup foto kerusakan dan upload</p>
                            </div>
                        </div>

                        <div className="feature-item">
                            <div className="feature-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9" />
                                    <path d="M13.73 21a2 2 0 01-3.46 0" />
                                </svg>
                            </div>
                            <div className="feature-content">
                                <h4>Notifikasi Real-time</h4>
                                <p>Dapatkan update status klaim dan informasi penting lainnya</p>
                            </div>
                        </div>

                        <div className="feature-item">
                            <div className="feature-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <rect x="3" y="11" width="18" height="11" rx="2" />
                                    <path d="M7 11V7a5 5 0 0110 0v4" />
                                </svg>
                            </div>
                            <div className="feature-content">
                                <h4>Keamanan Terjamin</h4>
                                <p>Data Anda aman dengan enkripsi dan autentikasi yang kuat</p>
                            </div>
                        </div>

                        <div className="feature-item">
                            <div className="feature-icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                    <circle cx="12" cy="12" r="10" />
                                    <polyline points="12,6 12,12 16,14" />
                                </svg>
                            </div>
                            <div className="feature-content">
                                <h4>Proses 24-48 Jam</h4>
                                <p>Klaim diproses cepat dalam waktu 24-48 jam kerja</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            {/* Requirements Section */}
            <section className="requirements">
                <div className="container">
                    <div className="requirements-card">
                        <div className="requirements-content">
                            <h3>Persyaratan Sistem</h3>
                            <ul className="requirements-list">
                                <li>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <polyline points="20,6 9,17 4,12" />
                                    </svg>
                                    Android 6.0 (Marshmallow) atau lebih baru
                                </li>
                                <li>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <polyline points="20,6 9,17 4,12" />
                                    </svg>
                                    Minimal 100 MB ruang penyimpanan
                                </li>
                                <li>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <polyline points="20,6 9,17 4,12" />
                                    </svg>
                                    Koneksi internet aktif
                                </li>
                                <li>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                        <polyline points="20,6 9,17 4,12" />
                                    </svg>
                                    Kamera untuk upload foto klaim
                                </li>
                            </ul>
                        </div>

                        <div className="install-guide">
                            <h3>Cara Install</h3>
                            <ol className="install-steps">
                                <li>
                                    <span className="step-num">1</span>
                                    <div>
                                        <strong>Download APK</strong>
                                        <p>Klik tombol Download APK di atas</p>
                                    </div>
                                </li>
                                <li>
                                    <span className="step-num">2</span>
                                    <div>
                                        <strong>Izinkan Instalasi</strong>
                                        <p>Buka Pengaturan → Keamanan → Izinkan sumber tidak dikenal</p>
                                    </div>
                                </li>
                                <li>
                                    <span className="step-num">3</span>
                                    <div>
                                        <strong>Install & Buka</strong>
                                        <p>Buka file APK dan ikuti instruksi instalasi</p>
                                    </div>
                                </li>
                            </ol>
                        </div>
                    </div>
                </div>
            </section>

            {/* Alternative QR Section */}
            <section className="qr-download-section">
                <div className="container">
                    <div className="qr-download-card">
                        <div className="qr-download-content">
                            <h2>Scan & Download</h2>
                            <p>Gunakan kamera smartphone Anda untuk scan QR code dan langsung download aplikasi</p>
                        </div>
                        <div className="qr-large">
                            <QRCodeSVG
                                value={APK_URL}
                                size={200}
                                level="H"
                                includeMargin={true}
                                fgColor="#1f2937"
                                bgColor="#ffffff"
                            />
                            <span className="qr-label">Smile Insurance v1.0.0</span>
                        </div>
                    </div>
                </div>
            </section>
        </div>
    );
};

export default DownloadPage;
