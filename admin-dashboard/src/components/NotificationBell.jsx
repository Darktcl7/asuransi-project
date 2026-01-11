// components/NotificationBell.jsx
import { useState, useRef, useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useNavigate } from 'react-router-dom';
import { adminService } from '../services/adminService';
import { Bell } from 'lucide-react';

const NotificationBell = () => {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);
  const navigate = useNavigate();

  // Fetch notifications with auto-refresh every 30 seconds
  const { data, refetch } = useQuery({
    queryKey: ['claim-notifications'],
    queryFn: () => adminService.getClaimNotifications(),
    refetchInterval: 30000, // Refresh every 30 seconds
    staleTime: 15000, // Consider data stale after 15 seconds
  });

  const pendingCount = data?.pending_count || 0;
  const recentClaims = data?.recent_claims || [];

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Format date
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
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const handleClaimClick = (claimId) => {
    setIsOpen(false);
    navigate('/claims');
  };

  const handleViewAll = () => {
    setIsOpen(false);
    navigate('/claims?status=pending');
  };

  return (
    <div className="relative" ref={dropdownRef}>
      {/* Bell Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-2 text-gray-600 hover:bg-gray-100 rounded-lg transition"
      >
        <Bell className="w-6 h-6" />
        {pendingCount > 0 && (
          <span className="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-500 rounded-full">
            {pendingCount > 99 ? '99+' : pendingCount}
          </span>
        )}
      </button>

      {/* Dropdown */}
      {isOpen && (
        <div className="absolute right-0 mt-2 w-96 bg-white rounded-lg shadow-2xl border border-gray-200 z-50">
          {/* Header */}
          <div className="px-4 py-3 border-b border-gray-200">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-semibold text-gray-900">
                Notifikasi Klaim
              </h3>
              {pendingCount > 0 && (
                <span className="px-2 py-1 text-xs font-medium text-white bg-red-500 rounded-full">
                  {pendingCount} Pending
                </span>
              )}
            </div>
          </div>

          {/* Notifications List */}
          <div className="max-h-96 overflow-y-auto">
            {recentClaims.length === 0 ? (
              <div className="px-4 py-8 text-center">
                <div className="inline-flex items-center justify-center w-16 h-16 mb-4 bg-gray-100 rounded-full">
                  <Bell className="w-8 h-8 text-gray-400" />
                </div>
                <p className="text-gray-600 font-medium">Tidak ada klaim pending</p>
                <p className="text-sm text-gray-500 mt-1">Semua klaim sudah diproses</p>
              </div>
            ) : (
              <>
                {recentClaims.map((claim) => (
                  <div
                    key={claim.id}
                    onClick={() => handleClaimClick(claim.id)}
                    className="px-4 py-3 border-b border-gray-100 hover:bg-gray-50 cursor-pointer transition"
                  >
                    <div className="flex items-start gap-3">
                      {/* Icon */}
                      <div className="flex-shrink-0 w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center">
                        <span className="text-orange-600 text-lg">🎫</span>
                      </div>

                      {/* Content */}
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-gray-900 truncate">
                          {claim.user_name}
                        </p>
                        <p className="text-xs text-gray-600 truncate">
                          {claim.device} - {claim.damage_type}
                        </p>
                        <div className="flex items-center gap-2 mt-1">
                          <span className="text-xs font-medium text-indigo-600">
                            {claim.claim_number}
                          </span>
                          <span className="text-xs text-gray-500">
                            {formatDate(claim.created_at)}
                          </span>
                        </div>
                      </div>

                      {/* Status Badge */}
                      <div className="flex-shrink-0">
                        <span className="inline-flex items-center px-2 py-1 text-xs font-medium text-orange-700 bg-orange-100 rounded-full">
                          Pending
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </>
            )}
          </div>

          {/* Footer */}
          {recentClaims.length > 0 && (
            <div className="px-4 py-3 border-t border-gray-200 bg-gray-50">
              <button
                onClick={handleViewAll}
                className="w-full text-center text-sm font-medium text-indigo-600 hover:text-indigo-700 transition"
              >
                Lihat Semua Klaim Pending ({pendingCount})
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default NotificationBell;
