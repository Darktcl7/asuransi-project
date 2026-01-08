// pages/TopUpsPage.jsx
import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/adminService';
import { usePagination } from '../utils/hooks';
import { TableSkeleton } from '../components/LoadingSkeleton';

const TopUpsPage = () => {
  const queryClient = useQueryClient();
  const { page, nextPage, prevPage, resetPage } = usePagination(1);
  const [status, setStatus] = useState('pending');

  const { data, isLoading, isFetching } = useQuery({
    queryKey: ['topups', page, status],
    queryFn: () => adminService.getTopUps({ page, status }),
    keepPreviousData: true,
    staleTime: 30000,
    cacheTime: 300000,
  });

  const approveMutation = useMutation({
    mutationFn: (topupId) => adminService.approveTopUp(topupId),
    onSuccess: () => {
      queryClient.invalidateQueries(['topups']);
      queryClient.invalidateQueries(['dashboardStats']);
      alert('Top-up approved successfully!');
    },
    onError: (error) => {
      alert(`Error: ${error.response?.data?.error || 'Failed to approve'}`);
    },
  });

  const handleStatusChange = (value) => {
    setStatus(value);
    resetPage();
  };

  const handleApprove = (topupId) => {
    if (window.confirm('Approve this top-up request?')) {
      approveMutation.mutate(topupId);
    }
  };

  const formatCurrency = (value) => {
    return `Rp ${value.toLocaleString('id-ID')}`;
  };

  return (
    <div className="space-y-6">
      {/* Filter */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <div className="flex gap-4 items-center">
          <select
            value={status}
            onChange={(e) => handleStatusChange(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
          >
            <option value="">All Top-Ups</option>
            <option value="pending">Pending</option>
            <option value="success">Success</option>
            <option value="failed">Failed</option>
          </select>
          <span className="text-sm text-gray-600">
            Total: <span className="font-bold">{data?.count?.toLocaleString() || 0}</span> top-ups
          </span>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={10} columns={6} />
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Transaction ID</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Payment Method</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Date</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {data?.results?.map((topup) => (
                    <tr key={topup.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {topup.transaction_id}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {topup.user_email}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900">
                        {formatCurrency(topup.amount)}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {topup.payment_method}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          topup.status === 'success' ? 'bg-green-100 text-green-800' :
                          topup.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                          'bg-red-100 text-red-800'
                        }`}>
                          {topup.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {new Date(topup.created_at).toLocaleDateString()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        {topup.status === 'pending' && (
                          <button
                            onClick={() => handleApprove(topup.id)}
                            disabled={approveMutation.isLoading}
                            className="text-green-600 hover:text-green-900 disabled:opacity-50"
                          >
                            Approve
                          </button>
                        )}
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

export default TopUpsPage;
