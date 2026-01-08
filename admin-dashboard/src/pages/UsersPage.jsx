// pages/UsersPage.jsx
import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/adminService';
import { useDebounce, usePagination } from '../utils/hooks';
import { TableSkeleton } from '../components/LoadingSkeleton';
import { useToast } from '../components/Toast';

const UsersPage = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const { page, setPage, nextPage, prevPage, resetPage } = usePagination(1);
  const [search, setSearch] = useState('');
  const [isVerified, setIsVerified] = useState('');
  const [isExporting, setIsExporting] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [editForm, setEditForm] = useState({
    first_name: '',
    last_name: '',
    phone_number: '',
    ktp_number: '',
    address: '',
    is_verified: false,
    is_active: true,
  });

  // Debounce search untuk prevent excessive API calls
  const debouncedSearch = useDebounce(search, 500);

  // Use debounced search untuk query
  const { data, isLoading, isFetching } = useQuery({
    queryKey: ['users', page, debouncedSearch, isVerified],
    queryFn: () => adminService.getUsers({
      page,
      search: debouncedSearch,
      is_verified: isVerified,
    }),
    keepPreviousData: true,
    staleTime: 30000, // Data fresh for 30 seconds
    cacheTime: 300000, // Cache for 5 minutes
  });

  // Reset page saat filter berubah
  const handleSearchChange = (value) => {
    setSearch(value);
    if (value !== search) {
      resetPage();
    }
  };

  const handleVerifiedChange = (value) => {
    setIsVerified(value);
    resetPage();
  };

  const handleExport = async () => {
    try {
      setIsExporting(true);
      const blob = await adminService.exportUsers();

      // Create download link
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `users_${new Date().toISOString().slice(0, 10)}.xlsx`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
      toast.success('Users exported successfully!');
    } catch (error) {
      console.error('Export failed:', error);
      toast.error('Failed to export users. Please try again.');
    } finally {
      setIsExporting(false);
    }
  };

  const handleEditClick = async (user) => {
    try {
      // Fetch full user details
      const userDetail = await adminService.getUser(user.id);
      setSelectedUser(userDetail);
      setEditForm({
        first_name: userDetail.first_name || '',
        last_name: userDetail.last_name || '',
        phone_number: userDetail.phone_number || '',
        ktp_number: userDetail.ktp_number || '',
        address: userDetail.address || '',
        is_verified: userDetail.is_verified || false,
        is_active: userDetail.is_active !== undefined ? userDetail.is_active : true,
      });
    } catch (error) {
      console.error('Failed to fetch user details:', error);
      toast.error('Failed to load user details');
    }
  };

  const updateMutation = useMutation({
    mutationFn: ({ userId, data }) => adminService.updateUser(userId, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['users']);
      setSelectedUser(null);
      toast.success('User updated successfully!');
    },
    onError: (error) => {
      console.error('Update failed:', error);
      toast.error(error.response?.data?.error || 'Failed to update user');
    },
  });

  const handleUpdate = () => {
    if (!editForm.first_name || !editForm.last_name) {
      toast.warning('First name and last name are required');
      return;
    }

    updateMutation.mutate({
      userId: selectedUser.id,
      data: editForm,
    });
  };

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="relative flex-1">
            <input
              type="text"
              placeholder="Search by email, phone, or name..."
              value={search}
              onChange={(e) => handleSearchChange(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
            />
            {isFetching && (
              <div className="absolute right-3 top-3">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-indigo-600"></div>
              </div>
            )}
          </div>
          <select
            value={isVerified}
            onChange={(e) => handleVerifiedChange(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
          >
            <option value="">All Users</option>
            <option value="true">Verified Only</option>
            <option value="false">Unverified Only</option>
          </select>
          <div className="flex items-center justify-between gap-4">
            <span className="text-sm text-gray-600">
              Total: <span className="font-bold">{data?.count?.toLocaleString() || 0}</span> users
            </span>
            <button
              onClick={handleExport}
              disabled={isExporting}
              className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {isExporting ? (
                <>
                  <svg className="animate-spin h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Exporting...
                </>
              ) : (
                <>
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  Export to Excel
                </>
              )}
            </button>
          </div>
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
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Phone</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Joined</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {data?.results?.map((user) => (
                    <tr key={user.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div>
                          <div className="text-sm font-medium text-gray-900">{user.full_name}</div>
                          <div className="text-sm text-gray-500">{user.email}</div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {user.phone_number || '-'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex gap-2">
                          {user.is_verified ? (
                            <span className="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                              Verified
                            </span>
                          ) : (
                            <span className="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800">
                              Unverified
                            </span>
                          )}
                          {user.is_active ? (
                            <span className="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                              Active
                            </span>
                          ) : (
                            <span className="px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800">
                              Inactive
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {new Date(user.date_joined).toLocaleDateString()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          onClick={() => handleEditClick(user)}
                          className="text-indigo-600 hover:text-indigo-900 font-semibold"
                        >
                          ✏️ Edit
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            <div className="bg-gray-50 px-6 py-4 flex items-center justify-between border-t border-gray-200">
              <div className="text-sm text-gray-700">
                Showing page <span className="font-medium">{page}</span> of{' '}
                <span className="font-medium">{Math.ceil((data?.count || 0) / 50)}</span>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={prevPage}
                  disabled={!data?.previous || isFetching}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Previous
                </button>
                <button
                  onClick={nextPage}
                  disabled={!data?.next || isFetching}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  Next
                </button>
              </div>
            </div>
          </>
        )}
      </div>

      {/* Edit User Modal */}
      {selectedUser && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-2xl font-bold text-gray-800">Edit User</h2>
                <button
                  onClick={() => setSelectedUser(null)}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>

              <div className="space-y-4">
                {/* User Info */}
                <div className="bg-gray-50 p-4 rounded-lg">
                  <p className="text-sm text-gray-600">Email</p>
                  <p className="font-semibold">{selectedUser.email}</p>
                  <p className="text-xs text-gray-500 mt-1">User ID: {selectedUser.id}</p>
                </div>

                {/* First Name */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    First Name *
                  </label>
                  <input
                    type="text"
                    value={editForm.first_name}
                    onChange={(e) => setEditForm({ ...editForm, first_name: e.target.value })}
                    className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="John"
                  />
                </div>

                {/* Last Name */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Last Name *
                  </label>
                  <input
                    type="text"
                    value={editForm.last_name}
                    onChange={(e) => setEditForm({ ...editForm, last_name: e.target.value })}
                    className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="Doe"
                  />
                </div>

                {/* Phone Number */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Phone Number
                  </label>
                  <input
                    type="tel"
                    value={editForm.phone_number}
                    onChange={(e) => setEditForm({ ...editForm, phone_number: e.target.value })}
                    className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="081234567890"
                  />
                </div>

                {/* KTP Number */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    KTP Number (16 digits)
                  </label>
                  <input
                    type="text"
                    value={editForm.ktp_number}
                    onChange={(e) => setEditForm({ ...editForm, ktp_number: e.target.value })}
                    maxLength={16}
                    className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="3201234567891234"
                  />
                </div>

                {/* Address */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Address
                  </label>
                  <textarea
                    value={editForm.address}
                    onChange={(e) => setEditForm({ ...editForm, address: e.target.value })}
                    rows={3}
                    className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="User address"
                  />
                </div>

                {/* Checkboxes */}
                <div className="flex gap-6">
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={editForm.is_verified}
                      onChange={(e) => setEditForm({ ...editForm, is_verified: e.target.checked })}
                      className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">Verified</span>
                  </label>
                  <label className="flex items-center">
                    <input
                      type="checkbox"
                      checked={editForm.is_active}
                      onChange={(e) => setEditForm({ ...editForm, is_active: e.target.checked })}
                      className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                    />
                    <span className="ml-2 text-sm text-gray-700">Active</span>
                  </label>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3 mt-6">
                <button
                  onClick={handleUpdate}
                  disabled={updateMutation.isLoading}
                  className="flex-1 bg-indigo-600 text-white px-4 py-3 rounded-lg font-semibold hover:bg-indigo-700 disabled:opacity-50 transition"
                >
                  {updateMutation.isLoading ? 'Updating...' : '💾 Save Changes'}
                </button>
                <button
                  onClick={() => setSelectedUser(null)}
                  className="px-6 py-3 border-2 border-gray-300 rounded-lg font-semibold hover:bg-gray-50 transition"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default UsersPage;
