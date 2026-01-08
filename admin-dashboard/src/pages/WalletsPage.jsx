// pages/WalletsPage.jsx
import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../services/adminService';
import { usePagination, useDebounce } from '../utils/hooks';
import { TableSkeleton } from '../components/LoadingSkeleton';

const WalletsPage = () => {
  const { page, nextPage, prevPage } = usePagination(1);
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);

  // Fetch wallet list (paginated)
  const { data, isLoading, isFetching } = useQuery({
    queryKey: ['wallets', page, debouncedSearch],
    queryFn: () => adminService.getWallets({ page, search: debouncedSearch }),
    keepPreviousData: true,
    staleTime: 30000,
    cacheTime: 300000,
  });

  // Fetch wallet stats (total for ALL wallets)
  const { data: stats } = useQuery({
    queryKey: ['wallet-stats'],
    queryFn: () => adminService.getWalletStats(),
    staleTime: 30000,
    cacheTime: 300000,
  });

  const formatCurrency = (value) => {
    return `Rp ${value.toLocaleString('id-ID')}`;
  };

  return (
    <div className="space-y-6">
      {/* ⚠️ DEPRECATED NOTICE */}
      <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-yellow-700">
              <strong className="font-medium">Sistem Wallet Sudah Tidak Dipakai!</strong> 
              <span className="block mt-1">
                Sekarang setiap policy punya saldo sendiri (policy balance) sesuai harga HP. 
                Wallet balance di halaman ini sudah tidak relevan dan akan dihapus di versi berikutnya.
              </span>
              <span className="block mt-2 font-medium">
                ✅ Gunakan: Policy Balance per policy (otomatis = harga HP)
              </span>
            </p>
          </div>
        </div>
      </div>

      {/* Stats Cards - DEPRECATED */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 opacity-50">
        <div className="bg-gradient-to-br from-gray-400 to-gray-500 rounded-xl shadow-lg p-6 text-white relative">
          <div className="absolute top-2 right-2 bg-red-500 text-white text-xs px-2 py-1 rounded">DEPRECATED</div>
          <p className="text-white/80 text-sm line-through">Total Wallets</p>
          <h3 className="text-3xl font-bold mt-2 line-through">
            {stats?.wallet_count || 0}
          </h3>
        </div>
        <div className="bg-gradient-to-br from-gray-400 to-gray-500 rounded-xl shadow-lg p-6 text-white relative">
          <div className="absolute top-2 right-2 bg-red-500 text-white text-xs px-2 py-1 rounded">DEPRECATED</div>
          <p className="text-white/80 text-sm line-through">Total Balance</p>
          <h3 className="text-3xl font-bold mt-2 line-through">
            {formatCurrency(stats?.total_balance || 0)}
          </h3>
        </div>
        <div className="bg-gradient-to-br from-gray-400 to-gray-500 rounded-xl shadow-lg p-6 text-white relative">
          <div className="absolute top-2 right-2 bg-red-500 text-white text-xs px-2 py-1 rounded">DEPRECATED</div>
          <p className="text-white/80 text-sm line-through">Total Top-Up</p>
          <h3 className="text-3xl font-bold mt-2 line-through">
            {formatCurrency(stats?.total_topup || 0)}
          </h3>
        </div>
        <div className="bg-gradient-to-br from-gray-400 to-gray-500 rounded-xl shadow-lg p-6 text-white relative">
          <div className="absolute top-2 right-2 bg-red-500 text-white text-xs px-2 py-1 rounded">DEPRECATED</div>
          <p className="text-white/80 text-sm line-through">Total Spent</p>
          <h3 className="text-3xl font-bold mt-2 line-through">
            {formatCurrency(stats?.total_spent || 0)}
          </h3>
        </div>
      </div>

      {/* Search */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <div className="relative">
          <input
            type="text"
            placeholder="Search by user email or name..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
          />
          {isFetching && (
            <div className="absolute right-3 top-3">
              <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-indigo-600"></div>
            </div>
          )}
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={10} columns={5} />
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Balance</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total Top-Up</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total Spent</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {data?.results?.map((wallet) => (
                    <tr key={wallet.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{wallet.user_name}</div>
                        <div className="text-sm text-gray-500">{wallet.user_email}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900">
                        {formatCurrency(wallet.balance)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatCurrency(wallet.total_topup)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {formatCurrency(wallet.total_spent)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button className="text-indigo-600 hover:text-indigo-900">View History</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            <div className="bg-gray-50 px-6 py-4 flex items-center justify-between border-t">
              <div className="text-sm text-gray-700">
                Page {page} of {Math.ceil((data?.count || 0) / 50)}
              </div>
              <div className="flex gap-2">
                <button
                  onClick={prevPage}
                  disabled={!data?.previous || isFetching}
                  className="px-4 py-2 border rounded-lg text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                <button
                  onClick={nextPage}
                  disabled={!data?.next || isFetching}
                  className="px-4 py-2 border rounded-lg text-sm font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default WalletsPage;
