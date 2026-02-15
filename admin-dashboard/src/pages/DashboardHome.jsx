// pages/DashboardHome.jsx
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../services/adminService';
import { authService } from '../services/authService';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  LineChart, Line, AreaChart, Area
} from 'recharts';

const DashboardHome = () => {
  // Get current user to check role
  const currentUser = authService.getUser();
  const isSuperAdmin = currentUser?.role === 'super_admin';

  const { data: stats, isLoading } = useQuery({
    queryKey: ['dashboardStats'],
    queryFn: adminService.getDashboardStats,
    refetchInterval: 300000, // Refetch every 5 minutes (data is heavy)
  });

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="flex flex-col items-center gap-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600"></div>
          <p className="text-gray-500">Memuat Executive Dashboard...</p>
        </div>
      </div>
    );
  }

  const formatCurrency = (val) => new Intl.NumberFormat('id-ID', {
    style: 'currency', currency: 'IDR', minimumFractionDigits: 0, maximumFractionDigits: 0
  }).format(val || 0);

  const StatCard = ({ title, value, icon, color, subtitle, trend }) => (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 flex flex-col justify-between h-full relative overflow-hidden group hover:shadow-md transition-all">
      <div className={`absolute top-0 right-0 p-3 opacity-10 group-hover:opacity-20 transition-opacity`}>
        <div className={`text-6xl text-${color}-600`}>{icon}</div>
      </div>
      <div>
        <p className="text-gray-500 text-sm font-medium uppercase tracking-wider">{title}</p>
        <h3 className="text-2xl font-bold mt-2 text-gray-800">{value}</h3>
      </div>
      {subtitle && (
        <div className="mt-4 flex items-center gap-2">
          <span className={`text-xs px-2 py-1 rounded-full bg-${color}-50 text-${color}-700 font-medium`}>
            {subtitle}
          </span>
          {trend && <span className="text-xs text-gray-400">{trend}</span>}
        </div>
      )}
    </div>
  );

  return (
    <div className="space-y-6 pb-12">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-800">Executive Dashboard</h1>
        <p className="text-gray-500">Overview performa bisnis dan operasional asuransi (Real-time)</p>
      </div>

      {/* 1. Overview Metrics (Financial & Ops) */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Pendapatan Premi"
          value={formatCurrency(stats?.overview?.total_premium)}
          icon="💰"
          color="green"
          subtitle={`${stats?.policies?.active || 0} Polis Aktif`}
          trend="Lifetime Revenue"
        />
        <StatCard
          title="Total Klaim Dibayarkan"
          value={formatCurrency(stats?.overview?.total_claim_paid)}
          icon="🛡️"
          color="blue"
          subtitle={`${stats?.claims?.approved || 0} Klaim Approved`}
        />
        <StatCard
          title="Loss Ratio"
          value={`${stats?.overview?.loss_ratio}%`}
          icon="📉"
          color={stats?.overview?.loss_ratio > 70 ? "red" : "indigo"}
          subtitle="Klaim vs Premi"
          trend={stats?.overview?.loss_ratio > 70 ? "High Risk!" : "Healthy"}
        />
        <StatCard
          title="Outstanding Claims"
          value={stats?.overview?.outstanding_claims}
          icon="⚠️"
          color="orange"
          subtitle="Butuh Approval"
          trend="Action Needed"
        />
      </div>

      {/* 2. Financial Trend Chart */}
      <div className={`grid grid-cols-1 ${isSuperAdmin ? 'lg:grid-cols-3' : ''} gap-6`}>
        <div className={`${isSuperAdmin ? 'lg:col-span-2' : ''} bg-white p-6 rounded-xl shadow-sm border border-gray-100`}>
          <h3 className="font-bold text-lg text-gray-800 mb-4">Tren Pendapatan vs Klaim (6 Bulan)</h3>
          <ResponsiveContainer width="100%" height={300}>
            <AreaChart data={stats?.trends || []}>
              <defs>
                <linearGradient id="colorPremium" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#10B981" stopOpacity={0.1} />
                  <stop offset="95%" stopColor="#10B981" stopOpacity={0} />
                </linearGradient>
                <linearGradient id="colorClaim" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#EF4444" stopOpacity={0.1} />
                  <stop offset="95%" stopColor="#EF4444" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" vertical={false} />
              <XAxis dataKey="name" axisLine={false} tickLine={false} />
              <YAxis axisLine={false} tickLine={false} tickFormatter={(val) => `Rp${val / 1000000}M`} />
              <Tooltip formatter={(value) => formatCurrency(value)} />
              <Area type="monotone" dataKey="premium" name="Premi Masuk" stroke="#10B981" fillOpacity={1} fill="url(#colorPremium)" strokeWidth={2} />
              <Area type="monotone" dataKey="claims" name="Klaim Keluar" stroke="#EF4444" fillOpacity={1} fill="url(#colorClaim)" strokeWidth={2} />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* 3. Top Performing Stores - Only for Super Admin */}
        {isSuperAdmin && (
          <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
            <h3 className="font-bold text-lg text-gray-800 mb-4">Top 5 Toko Terbaik</h3>
            <div className="space-y-4">
              {stats?.top_stores?.map((store, idx) => (
                <div key={store.id} className="flex items-center justify-between pb-3 border-b border-gray-50 last:border-0">
                  <div className="flex items-center gap-3">
                    <div className="flex items-center justify-center w-8 h-8 rounded-full bg-gray-100 text-sm font-bold text-gray-600">
                      {idx + 1}
                    </div>
                    <div>
                      <p className="font-medium text-gray-800">{store.name}</p>
                      <p className="text-xs text-gray-500">{store.code}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-bold text-gray-800">{store.policy_count} Polis</p>
                    <p className="text-xs text-green-600">{formatCurrency(store.premium_value)}</p>
                  </div>
                </div>
              ))}
            </div>
            <button className="w-full mt-4 py-2 text-sm text-center text-indigo-600 hover:bg-indigo-50 rounded-lg transition">
              Lihat Laporan Semua Toko →
            </button>
          </div>
        )}
      </div>

      {/* 4. Operational Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h3 className="font-bold text-lg text-gray-800 mb-4">Status Polis</h3>
          <div className="grid grid-cols-3 gap-4 text-center">
            <div className="p-4 bg-green-50 rounded-xl">
              <p className="text-2xl font-bold text-green-600">{stats?.policies?.active}</p>
              <p className="text-sm text-gray-600">Aktif</p>
            </div>
            <div className="p-4 bg-yellow-50 rounded-xl">
              <p className="text-2xl font-bold text-yellow-600">{stats?.policies?.pending}</p>
              <p className="text-sm text-gray-600">Pending</p>
            </div>
            <div className="p-4 bg-gray-50 rounded-xl">
              <p className="text-2xl font-bold text-gray-600">{stats?.policies?.expired}</p>
              <p className="text-sm text-gray-600">Expired</p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h3 className="font-bold text-lg text-gray-800 mb-4">Status Klaim (SLA Monitoring)</h3>
          <div className="space-y-4">
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Total Klaim Masuk</span>
              <span className="font-bold">{stats?.claims?.total}</span>
            </div>
            <div className="w-full bg-gray-100 rounded-full h-2">
              <div className="bg-blue-600 h-2 rounded-full" style={{ width: '100%' }}></div>
            </div>

            <div className="flex justify-between items-center pt-2">
              <span className="text-gray-600">Approved (Paid)</span>
              <span className="font-bold text-green-600">{stats?.claims?.approved}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-gray-600">Rejected</span>
              <span className="font-bold text-red-600">{stats?.claims?.rejected}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DashboardHome;
