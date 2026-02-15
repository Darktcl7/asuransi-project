// pages/ClaimsPage.jsx
import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/adminService';
import { usePagination, useDebounce } from '../utils/hooks';
import { TableSkeleton } from '../components/LoadingSkeleton';
import { useToast } from '../components/Toast';

const ClaimsPage = () => {
  const queryClient = useQueryClient();
  const toast = useToast();
  const { page, nextPage, prevPage, resetPage } = usePagination(1);
  const [status, setStatus] = useState('pending');
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebounce(search, 500);
  const [selectedClaim, setSelectedClaim] = useState(null);
  const [claimAmount, setClaimAmount] = useState('');
  const [adminNotes, setAdminNotes] = useState('');
  const [isExporting, setIsExporting] = useState(false);
  const [imagePreview, setImagePreview] = useState(null); // For photo lightbox

  const { data, isLoading, isFetching } = useQuery({
    queryKey: ['claims', page, status, debouncedSearch],
    queryFn: () => adminService.getClaims({ page, status, search: debouncedSearch }),
    keepPreviousData: true,
    staleTime: 30000,
    cacheTime: 300000,
  });

  const handleStatusChange = (value) => {
    setStatus(value);
    resetPage();
  };

  const handleSearchChange = (value) => {
    setSearch(value);
    if (value !== search) resetPage();
  };

  const handleExport = async () => {
    try {
      setIsExporting(true);
      const blob = await adminService.exportClaims();

      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `claims_${new Date().toISOString().slice(0, 10)}.xlsx`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
      toast.success('Claims exported successfully!');
    } catch (error) {
      console.error('Export failed:', error);
      toast.error('Failed to export claims. Please try again.');
    } finally {
      setIsExporting(false);
    }
  };

  const approveMutation = useMutation({
    mutationFn: ({ id, data }) => adminService.approveClaim(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['claims']);
      queryClient.invalidateQueries(['dashboardStats']);
      setSelectedClaim(null);
      toast.success('Claim approved successfully!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to approve claim');
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({ id, data }) => adminService.rejectClaim(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['claims']);
      queryClient.invalidateQueries(['dashboardStats']);
      setSelectedClaim(null);
      toast.success('Claim rejected successfully!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to reject claim');
    },
  });

  const inProgressMutation = useMutation({
    mutationFn: ({ id, data }) => adminService.setClaimInProgress(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['claims']);
      setSelectedClaim(null);
      toast.success('Claim status updated to In Progress!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to update status');
    },
  });

  const completedMutation = useMutation({
    mutationFn: ({ id, data }) => adminService.setClaimCompleted(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries(['claims']);
      setSelectedClaim(null);
      toast.success('Claim marked as Completed!');
    },
    onError: (error) => {
      toast.error(error.response?.data?.error || 'Failed to complete claim');
    },
  });

  const handleApprove = () => {
    if (!claimAmount) {
      toast.warning('Please enter claim amount');
      return;
    }
    approveMutation.mutate({
      id: selectedClaim.id,
      data: { claim_amount: parseFloat(claimAmount), admin_notes: adminNotes },
    });
  };

  const handleReject = () => {
    if (!adminNotes) {
      toast.warning('Please enter rejection reason');
      return;
    }
    rejectMutation.mutate({
      id: selectedClaim.id,
      data: { admin_notes: adminNotes },
    });
  };

  const handleSetInProgress = () => {
    inProgressMutation.mutate({
      id: selectedClaim.id,
      data: { admin_notes: adminNotes },
    });
  };

  const handleSetCompleted = () => {
    completedMutation.mutate({
      id: selectedClaim.id,
      data: {
        admin_notes: adminNotes,
        payment_date: new Date().toISOString()
      },
    });
  };

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-center">
          <div className="relative">
            <input
              type="text"
              placeholder="Search by claim # or user email..."
              value={search}
              onChange={(e) => handleSearchChange(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
            />
            {isFetching && (
              <div className="absolute right-3 top-3">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-indigo-600"></div>
              </div>
            )}
          </div>
          <select
            value={status}
            onChange={(e) => handleStatusChange(e.target.value)}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
          >
            <option value="">All Claims</option>
            <option value="pending">⏳ Pending</option>
            <option value="approved">✅ Approved</option>
            <option value="in_progress">🔧 In Progress</option>
            <option value="completed">✔️ Completed</option>
            <option value="rejected">❌ Rejected</option>
          </select>
          <div className="flex items-center justify-between gap-4">
            <span className="text-sm text-gray-600">
              Total: <span className="font-bold">{data?.count?.toLocaleString() || 0}</span> claims
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
          <TableSkeleton rows={10} columns={7} />
        ) : (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Claim #</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">User</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Device</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Damage</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Amount</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {data?.results?.map((claim) => (
                    <tr key={claim.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {claim.claim_number}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{claim.user_name}</div>
                        <div className="text-sm text-gray-500">{claim.user_email}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {claim.device}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {claim.damage_type}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        Rp {claim.claim_amount.toLocaleString()}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-3 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${claim.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                          claim.status === 'approved' ? 'bg-green-100 text-green-800' :
                            claim.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                              claim.status === 'completed' ? 'bg-purple-100 text-purple-800' :
                                claim.status === 'rejected' ? 'bg-red-100 text-red-800' :
                                  'bg-gray-100 text-gray-800'
                          }`}>
                          {claim.status === 'pending' ? '⏳ Pending' :
                            claim.status === 'approved' ? '✅ Approved' :
                              claim.status === 'in_progress' ? '🔧 In Progress' :
                                claim.status === 'completed' ? '✔️ Completed' :
                                  claim.status === 'rejected' ? '❌ Rejected' :
                                    claim.status}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        {claim.status === 'pending' && (
                          <button
                            onClick={() => {
                              setSelectedClaim(claim);
                              setClaimAmount(claim.claim_amount.toString());
                              setAdminNotes('');
                            }}
                            className="text-indigo-600 hover:text-indigo-900 font-semibold"
                          >
                            Review
                          </button>
                        )}
                        {claim.status === 'approved' && (
                          <button
                            onClick={() => {
                              setSelectedClaim(claim);
                              setAdminNotes('');
                            }}
                            className="text-blue-600 hover:text-blue-900 font-semibold"
                          >
                            Update Status
                          </button>
                        )}
                        {claim.status === 'in_progress' && (
                          <button
                            onClick={() => {
                              setSelectedClaim(claim);
                              setAdminNotes('');
                            }}
                            className="text-purple-600 hover:text-purple-900 font-semibold"
                          >
                            Complete
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

      {/* Review/Update Modal */}
      {selectedClaim && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              {/* Header with Status Badge */}
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-2xl font-bold text-gray-800">
                  {selectedClaim.status === 'pending' ? 'Review Claim' : 'Update Claim Status'}
                </h2>
                <span className={`px-3 py-1 text-sm font-semibold rounded-full ${selectedClaim.status === 'pending' ? 'bg-yellow-100 text-yellow-800' :
                  selectedClaim.status === 'approved' ? 'bg-green-100 text-green-800' :
                    selectedClaim.status === 'in_progress' ? 'bg-blue-100 text-blue-800' :
                      'bg-gray-100 text-gray-800'
                  }`}>
                  {selectedClaim.status === 'pending' ? '⏳ Pending' :
                    selectedClaim.status === 'approved' ? '✅ Approved' :
                      selectedClaim.status === 'in_progress' ? '🔧 In Progress' :
                        selectedClaim.status}
                </span>
              </div>

              <div className="space-y-4 mb-6">
                {/* Claim Details */}
                <div className="bg-gray-50 p-4 rounded-lg">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <p className="text-gray-500 mb-1">Claim Number</p>
                      <p className="font-semibold">{selectedClaim.claim_number}</p>
                    </div>
                    <div>
                      <p className="text-gray-500 mb-1">User</p>
                      <p className="font-semibold">{selectedClaim.user_name}</p>
                      <p className="text-xs text-gray-500">{selectedClaim.user_email}</p>
                    </div>
                    <div>
                      <p className="text-gray-500 mb-1">Device</p>
                      <p className="font-semibold">{selectedClaim.device}</p>
                    </div>
                    <div>
                      <p className="text-gray-500 mb-1">Serial / IMEI</p>
                      <p className="font-semibold text-orange-600">{selectedClaim.imei_number || 'N/A'}</p>
                      <p className="text-xs text-gray-500">Bandingkan dengan foto/label device</p>
                    </div>
                    <div>
                      <p className="text-gray-500 mb-1">Damage Type</p>
                      <p className="font-semibold">{selectedClaim.damage_type}</p>
                    </div>
                    <div>
                      <p className="text-gray-500 mb-1">Incident Date</p>
                      <p className="font-semibold">{selectedClaim.incident_date || 'N/A'}</p>
                    </div>
                    <div className="col-span-2">
                      <p className="text-gray-500 mb-1">Description</p>
                      <p className="text-sm">{selectedClaim.damage_description || 'N/A'}</p>
                    </div>
                  </div>
                </div>

                {/* Damage Photos Gallery */}
                {selectedClaim.photos && selectedClaim.photos.length > 0 && (
                  <div className="bg-gray-50 p-4 rounded-lg">
                    <p className="text-gray-500 mb-3 font-medium">📷 Foto Kerusakan ({selectedClaim.photos.length})</p>
                    <div className="grid grid-cols-3 gap-3">
                      {selectedClaim.photos.map((photo, index) => (
                        <button
                          key={photo.id || index}
                          onClick={() => setImagePreview(photo.photo_url || photo.photo)}
                          className="block aspect-square rounded-lg overflow-hidden border-2 border-gray-200 hover:border-orange-500 transition-colors cursor-zoom-in"
                        >
                          <img
                            src={photo.photo_url || photo.photo}
                            alt={`Damage photo ${index + 1}`}
                            className="w-full h-full object-cover hover:scale-105 transition-transform"
                          />
                        </button>
                      ))}
                    </div>
                    <p className="text-xs text-gray-500 mt-2">Klik foto untuk memperbesar</p>
                  </div>
                )}

                {/* Claim Amount - Only for pending */}
                {selectedClaim.status === 'pending' && (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Biaya Perbaikan (Rp) *
                    </label>
                    <input
                      type="number"
                      value={claimAmount}
                      onChange={(e) => setClaimAmount(e.target.value)}
                      className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                      placeholder="Masukkan biaya perbaikan"
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      Jumlah ini akan dipotong dari saldo policy user
                    </p>
                  </div>
                )}

                {/* Show current amount for non-pending */}
                {selectedClaim.status !== 'pending' && (
                  <div className="bg-blue-50 p-4 rounded-lg">
                    <p className="text-sm text-gray-600 mb-1">Biaya Perbaikan</p>
                    <p className="text-2xl font-bold text-blue-700">
                      Rp {selectedClaim.claim_amount?.toLocaleString() || 0}
                    </p>
                    {selectedClaim.wallet_deducted && (
                      <p className="text-xs text-gray-600 mt-1">
                        ✅ Policy balance sudah dipotong: Rp {selectedClaim.wallet_deducted.toLocaleString()}
                      </p>
                    )}
                  </div>
                )}

                {/* Admin Notes */}
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Admin Notes
                  </label>
                  <textarea
                    value={adminNotes}
                    onChange={(e) => setAdminNotes(e.target.value)}
                    rows={3}
                    className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                    placeholder="Tambah catatan admin..."
                  />
                </div>
              </div>

              {/* Action Buttons - Different based on status */}
              <div className="flex gap-3">
                {selectedClaim.status === 'pending' && (
                  <>
                    <button
                      onClick={handleApprove}
                      disabled={approveMutation.isLoading}
                      className="flex-1 bg-green-600 text-white px-4 py-3 rounded-lg font-semibold hover:bg-green-700 disabled:opacity-50 transition"
                    >
                      {approveMutation.isLoading ? 'Processing...' : '✅ Approve & Deduct Policy Balance'}
                    </button>
                    <button
                      onClick={handleReject}
                      disabled={rejectMutation.isLoading}
                      className="flex-1 bg-red-600 text-white px-4 py-3 rounded-lg font-semibold hover:bg-red-700 disabled:opacity-50 transition"
                    >
                      {rejectMutation.isLoading ? 'Processing...' : '❌ Reject'}
                    </button>
                  </>
                )}

                {selectedClaim.status === 'approved' && (
                  <button
                    onClick={handleSetInProgress}
                    disabled={inProgressMutation.isLoading}
                    className="flex-1 bg-blue-600 text-white px-4 py-3 rounded-lg font-semibold hover:bg-blue-700 disabled:opacity-50 transition"
                  >
                    {inProgressMutation.isLoading ? 'Processing...' : '🔧 Set In Progress'}
                  </button>
                )}

                {selectedClaim.status === 'in_progress' && (
                  <button
                    onClick={handleSetCompleted}
                    disabled={completedMutation.isLoading}
                    className="flex-1 bg-purple-600 text-white px-4 py-3 rounded-lg font-semibold hover:bg-purple-700 disabled:opacity-50 transition"
                  >
                    {completedMutation.isLoading ? 'Processing...' : '✔️ Mark as Completed'}
                  </button>
                )}

                <button
                  onClick={() => setSelectedClaim(null)}
                  className="px-6 py-3 border-2 border-gray-300 rounded-lg font-semibold hover:bg-gray-50 transition"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Image Lightbox Modal */}
      {imagePreview && (
        <div
          className="fixed inset-0 z-[60] bg-black/90 flex items-center justify-center p-4"
          onClick={() => setImagePreview(null)}
        >
          <div className="relative max-w-4xl max-h-[90vh] w-full">
            {/* Close button */}
            <button
              onClick={() => setImagePreview(null)}
              className="absolute -top-12 right-0 text-white hover:text-orange-400 transition"
            >
              <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>

            {/* Image */}
            <img
              src={imagePreview}
              alt="Full size preview"
              className="w-full h-full object-contain rounded-lg shadow-2xl"
              onClick={(e) => e.stopPropagation()}
            />

            {/* Actions */}
            <div className="absolute -bottom-12 left-1/2 transform -translate-x-1/2 flex gap-4">
              <a
                href={imagePreview}
                target="_blank"
                rel="noopener noreferrer"
                className="bg-white/20 hover:bg-white/30 text-white px-4 py-2 rounded-lg flex items-center gap-2 transition"
                onClick={(e) => e.stopPropagation()}
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                </svg>
                Open Original
              </a>
              <button
                onClick={() => setImagePreview(null)}
                className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg transition"
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default ClaimsPage;

