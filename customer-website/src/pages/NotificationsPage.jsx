// pages/NotificationsPage.jsx
import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/apiService';
import { authService } from '../services/authService';
import { useToast } from '../components/Toast';
import './NotificationsPage.css';

const NotificationsPage = () => {
    const navigate = useNavigate();
    const toast = useToast();
    const [notifications, setNotifications] = useState([]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        loadNotifications();
    }, []);

    const loadNotifications = async () => {
        setIsLoading(true);
        try {
            const response = await apiService.getNotifications();
            setNotifications(response);
        } catch (error) {
            console.error('Error loading notifications:', error);
            if (error.response?.status === 401) {
                authService.logout();
                navigate('/login');
            } else {
                toast.error('Gagal memuat notifikasi.');
            }
        } finally {
            setIsLoading(false);
        }
    };

    const handleMarkAsRead = async (id) => {
        try {
            await apiService.markNotificationAsRead(id);
            setNotifications(notifications.map(n =>
                n.id === id ? { ...n, is_read: true } : n
            ));
        } catch (error) {
            toast.error('Gagal menandai notifikasi.');
        }
    };

    const handleMarkAllAsRead = async () => {
        try {
            await apiService.markAllNotificationsAsRead();
            setNotifications(notifications.map(n => ({ ...n, is_read: true })));
            toast.success('Semua notifikasi telah ditandai dibaca.');
        } catch (error) {
            toast.error('Gagal menandai semua notifikasi.');
        }
    };

    const formatDate = (dateString) => {
        const date = new Date(dateString);
        const now = new Date();
        const diffMs = now - date;
        const diffMins = Math.floor(diffMs / 60000);
        const diffHours = Math.floor(diffMs / 3600000);
        const diffDays = Math.floor(diffMs / 86400000);

        if (diffMins < 1) return 'Baru saja';
        if (diffMins < 60) return `${diffMins} menit lalu`;
        if (diffHours < 24) return `${diffHours} jam lalu`;
        if (diffDays < 7) return `${diffDays} hari lalu`;

        return date.toLocaleDateString('id-ID', {
            day: 'numeric',
            month: 'short',
            year: 'numeric',
        });
    };

    const getNotificationIcon = (type) => {
        const iconMap = {
            claim_approved: { icon: '✅', color: 'success' },
            claim_rejected: { icon: '❌', color: 'error' },
            claim_submitted: { icon: '📋', color: 'info' },
            policy_created: { icon: '🛡️', color: 'primary' },
            policy_expired: { icon: '⚠️', color: 'warning' },
            balance_added: { icon: '💰', color: 'success' },
            general: { icon: '🔔', color: 'info' },
        };
        return iconMap[type] || iconMap.general;
    };

    const unreadCount = notifications.filter(n => !n.is_read).length;

    if (isLoading) {
        return (
            <div className="notifications-page">
                <div className="container">
                    <div className="loading-screen">
                        <div className="spinner"></div>
                        <p>Memuat notifikasi...</p>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="notifications-page">
            <div className="container">
                {/* Header */}
                <div className="notifications-header animate-slideDown">
                    <div>
                        <h1>Notifikasi</h1>
                        <p>
                            {unreadCount > 0
                                ? `${unreadCount} notifikasi belum dibaca`
                                : 'Semua notifikasi sudah dibaca'}
                        </p>
                    </div>
                    {unreadCount > 0 && (
                        <button className="btn btn-secondary" onClick={handleMarkAllAsRead}>
                            <svg className="btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                                <polyline points="9,11 12,14 22,4" />
                                <path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" />
                            </svg>
                            Tandai Semua Dibaca
                        </button>
                    )}
                </div>

                {/* Notifications List */}
                <div className="notifications-list animate-slideUp">
                    {notifications.length === 0 ? (
                        <div className="empty-state">
                            <div className="empty-icon">🔔</div>
                            <h3>Tidak Ada Notifikasi</h3>
                            <p>Anda akan menerima notifikasi ketika ada update tentang polis atau klaim Anda.</p>
                        </div>
                    ) : (
                        <div className="notifications-container">
                            {notifications.map(notification => {
                                const iconInfo = getNotificationIcon(notification.notification_type);
                                return (
                                    <div
                                        key={notification.id}
                                        className={`notification-item ${!notification.is_read ? 'unread' : ''}`}
                                        onClick={() => !notification.is_read && handleMarkAsRead(notification.id)}
                                    >
                                        <div className={`notification-icon ${iconInfo.color}`}>
                                            <span>{iconInfo.icon}</span>
                                        </div>
                                        <div className="notification-content">
                                            <h4>{notification.title}</h4>
                                            <p>{notification.message}</p>
                                            <span className="notification-time">{formatDate(notification.created_at)}</span>
                                        </div>
                                        {!notification.is_read && (
                                            <div className="unread-indicator"></div>
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

export default NotificationsPage;
