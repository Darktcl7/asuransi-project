// pages/DashboardHome.jsx
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../services/adminService';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';

const DashboardHome = () => {
  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboardStats'],
    queryFn: adminService.getDashboardStats,
    refetchInterval: 60000, // Refetch every minute
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
      </div>
    );
  }

  const StatCard = ({ title, value, icon, color, subtitle }) => (
    <div className={`bg-gradient-to-br ${color} rounded-xl shadow-lg p-6 text-white`}>
      <div className="flex items-center justify-between">
        <div>
          <p className="text-white/80 text-sm font-medium">{title}</p>
          <h3 className="text-3xl font-bold mt-2">{value.toLocaleString()}</h3>
          {subtitle && <p className="text-white/70 text-xs mt-1">{subtitle}</p>}
        </div>
        <div className="text-5xl opacity-80">{icon}</div>
      </div>
    </div>
  );

  return (
    <div className="space-y-6">
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Users"
          value={stats?.users?.total || 0}
          icon="👥"
          color="from-blue-500 to-blue-600"
          subtitle={`${stats?.users?.verified || 0} verified`}
        />
        <StatCard
          title="Active Policies"
          value={stats?.policies?.active || 0}
          icon="📋"
          color="from-green-500 to-green-600"
          subtitle={`${stats?.policies?.pending || 0} pending`}
        />
        <StatCard
          title="Pending Claims"
          value={stats?.claims?.pending || 0}
          icon="🎫"
          color="from-orange-500 to-orange-600"
          subtitle={`${stats?.claims?.approved || 0} approved`}
        />
        <StatCard
          title="Total Balance"
          value={`Rp ${Math.floor((stats?.wallet?.total_balance || 0) / 1000000)}M`}
          icon="💰"
          color="from-purple-500 to-purple-600"
          subtitle={`${stats?.wallet?.pending_topups || 0} pending top-ups`}
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Stats */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-lg font-bold text-gray-800 mb-4">User Statistics</h3>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={[
              { name: 'Total', value: stats?.users?.total || 0 },
              { name: 'Verified', value: stats?.users?.verified || 0 },
              { name: 'Active', value: stats?.users?.active || 0 },
            ]}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="value" fill="#4F46E5" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* Policy Stats */}
        <div className="bg-white rounded-xl shadow-lg p-6">
          <h3 className="text-lg font-bold text-gray-800 mb-4">Policy Status</h3>
          <ResponsiveContainer width="100%" height={250}>
            <BarChart data={[
              { name: 'Active', value: stats?.policies?.active || 0 },
              { name: 'Pending', value: stats?.policies?.pending || 0 },
              { name: 'Expired', value: stats?.policies?.expired || 0 },
            ]}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="value" fill="#10B981" />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <h3 className="text-lg font-bold text-gray-800 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <button className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-indigo-500 hover:bg-indigo-50 transition">
            <span className="text-2xl">🎫</span>
            <div className="text-left">
              <p className="font-semibold text-gray-800">Review Claims</p>
              <p className="text-xs text-gray-500">{stats?.claims?.pending || 0} pending</p>
            </div>
          </button>
          <button className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-green-500 hover:bg-green-50 transition">
            <span className="text-2xl">✅</span>
            <div className="text-left">
              <p className="font-semibold text-gray-800">Approve Policies</p>
              <p className="text-xs text-gray-500">{stats?.policies?.pending || 0} pending</p>
            </div>
          </button>
          <button className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-purple-500 hover:bg-purple-50 transition">
            <span className="text-2xl">💳</span>
            <div className="text-left">
              <p className="font-semibold text-gray-800">Process Top-Ups</p>
              <p className="text-xs text-gray-500">{stats?.wallet?.pending_topups || 0} pending</p>
            </div>
          </button>
          <button className="flex items-center gap-3 p-4 border-2 border-gray-200 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition">
            <span className="text-2xl">👥</span>
            <div className="text-left">
              <p className="font-semibold text-gray-800">Manage Users</p>
              <p className="text-xs text-gray-500">{stats?.users?.total || 0} total</p>
            </div>
          </button>
        </div>
      </div>

      {/* System Info */}
      <div className="bg-gradient-to-r from-indigo-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-lg font-bold">System Status</h3>
            <p className="text-white/80 text-sm mt-1">All systems operational</p>
          </div>
          <div className="flex items-center gap-4">
            <div className="text-center">
              <p className="text-2xl font-bold">{stats?.claims?.total || 0}</p>
              <p className="text-xs text-white/70">Total Claims</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold">{stats?.policies?.total || 0}</p>
              <p className="text-xs text-white/70">Total Policies</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold">Rp {Math.floor((stats?.claims?.total_amount || 0) / 1000000)}M</p>
              <p className="text-xs text-white/70">Claims Paid</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardHome;
