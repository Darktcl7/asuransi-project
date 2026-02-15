// pages/ActivityLogsPage.jsx
/**
 * Activity Logs Page - Super Admin Only
 * View all system activities
 */
import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { activityService } from '../services/activityService';
import { authService } from '../services/authService';

const ActivityLogsPage = () => {
    const [filters, setFilters] = useState({
        store: '',
        action: '',
        user: '',
        date_from: '',
        date_to: '',
    });

    const isSuperAdmin = authService.isSuperAdmin();

    // Fetch activity logs
    const { data, isLoading, error, refetch } = useQuery({
        queryKey: ['activity-logs', filters],
        queryFn: () => activityService.getLogs(filters),
        enabled: isSuperAdmin,
    });

    const handleFilterChange = (key, value) => {
        setFilters(prev => ({ ...prev, [key]: value }));
    };

    const handleApplyFilters = () => {
        refetch();
    };

    const handleClearFilters = () => {
        setFilters({
            store: '',
            action: '',
            user: '',
            date_from: '',
            date_to: '',
        });
    };

    // Format date
    const formatDate = (dateStr) => {
        const date = new Date(dateStr);
        return date.toLocaleString('id-ID', {
            day: '2-digit',
            month: 'short',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
        });
    };

    // Get action color
    const getActionColor = (action) => {
        if (action.includes('CREATE')) return 'bg-green-100 text-green-800';
        if (action.includes('UPDATE')) return 'bg-blue-100 text-blue-800';
        if (action.includes('DELETE') || action.includes('DEACTIVATE')) return 'bg-red-100 text-red-800';
        if (action.includes('APPROVE')) return 'bg-emerald-100 text-emerald-800';
        if (action.includes('REJECT')) return 'bg-orange-100 text-orange-800';
        if (action.includes('LOGIN')) return 'bg-purple-100 text-purple-800';
        return 'bg-gray-100 text-gray-800';
    };

    // Access denied for non-Super Admin
    if (!isSuperAdmin) {
        return (
            <div className="flex items-center justify-center h-96">
                <div className="text-center">
                    <div className="text-6xl mb-4">🔒</div>
                    <h2 className="text-2xl font-bold text-gray-800 mb-2">Akses Ditolak</h2>
                    <p className="text-gray-600">Hanya Super Admin yang dapat mengakses halaman ini.</p>
                </div>
            </div>
        );
    }

    if (isLoading) {
        return (
            <div className="flex items-center justify-center h-96">
                <div className="text-center">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500 mx-auto"></div>
                    <p className="mt-4 text-gray-600">Loading activity logs...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-red-50 p-4 rounded-lg">
                <p className="text-red-600">Error loading logs: {error.message}</p>
            </div>
        );
    }

    const logs = data?.results || [];
    const actionChoices = data?.action_choices || [];

    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-gray-800">Activity Logs</h1>
                <p className="text-gray-600">Monitor semua aktivitas di sistem</p>
            </div>

            {/* Filters */}
            <div className="bg-white rounded-lg shadow p-4">
                <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Store Code</label>
                        <input
                            type="text"
                            value={filters.store}
                            onChange={(e) => handleFilterChange('store', e.target.value)}
                            placeholder="e.g. JKT-01"
                            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Action</label>
                        <select
                            value={filters.action}
                            onChange={(e) => handleFilterChange('action', e.target.value)}
                            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                        >
                            <option value="">All Actions</option>
                            {actionChoices.map((choice, index) => (
                                <option key={`${index}-${choice.value}`} value={choice.value}>{choice.label}</option>
                            ))}
                        </select>
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">User Email</label>
                        <input
                            type="text"
                            value={filters.user}
                            onChange={(e) => handleFilterChange('user', e.target.value)}
                            placeholder="e.g. admin@"
                            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">From Date</label>
                        <input
                            type="date"
                            value={filters.date_from}
                            onChange={(e) => handleFilterChange('date_from', e.target.value)}
                            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                        />
                    </div>
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">To Date</label>
                        <input
                            type="date"
                            value={filters.date_to}
                            onChange={(e) => handleFilterChange('date_to', e.target.value)}
                            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                        />
                    </div>
                </div>
                <div className="flex gap-2 mt-4">
                    <button
                        onClick={handleApplyFilters}
                        className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition"
                    >
                        🔍 Apply Filters
                    </button>
                    <button
                        onClick={handleClearFilters}
                        className="bg-gray-200 hover:bg-gray-300 text-gray-800 px-4 py-2 rounded-lg text-sm font-medium transition"
                    >
                        ✕ Clear
                    </button>
                </div>
            </div>

            {/* Stats */}
            <div className="bg-white rounded-lg shadow p-4">
                <p className="text-gray-600">
                    Showing <span className="font-bold text-orange-600">{logs.length}</span> activities
                    {!filters.date_from && !filters.date_to && ' (last 7 days)'}
                </p>
            </div>

            {/* Logs Table */}
            <div className="bg-white rounded-lg shadow overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Time</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Role</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Store</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Target</th>
                                <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-200">
                            {logs.map((log) => (
                                <tr key={log.id} className="hover:bg-gray-50">
                                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                                        {formatDate(log.created_at)}
                                    </td>
                                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900">
                                        {log.user_email}
                                    </td>
                                    <td className="px-4 py-3 whitespace-nowrap text-sm">
                                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${log.user_role === 'super_admin' ? 'bg-purple-100 text-purple-800' :
                                            log.user_role === 'store_admin' ? 'bg-blue-100 text-blue-800' :
                                                'bg-gray-100 text-gray-800'
                                            }`}>
                                            {log.user_role}
                                        </span>
                                    </td>
                                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                                        {log.store_code || '-'}
                                    </td>
                                    <td className="px-4 py-3 whitespace-nowrap text-sm">
                                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getActionColor(log.action)}`}>
                                            {log.action_display}
                                        </span>
                                    </td>
                                    <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                                        {log.target_model}
                                        {log.target_id && <span className="text-xs text-gray-400 ml-1">#{log.target_id.slice(0, 8)}</span>}
                                    </td>
                                    <td className="px-4 py-3 text-sm text-gray-500 max-w-xs truncate">
                                        {log.description || '-'}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>

                {logs.length === 0 && (
                    <div className="text-center py-12">
                        <div className="text-4xl mb-4">📋</div>
                        <h3 className="text-lg font-medium text-gray-900">No Activity Logs</h3>
                        <p className="text-gray-500">Try adjusting your filters</p>
                    </div>
                )}
            </div>
        </div>
    );
};

export default ActivityLogsPage;
