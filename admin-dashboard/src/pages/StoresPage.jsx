// pages/StoresPage.jsx
/**
 * Stores Management Page - Super Admin Only
 * 
 * Features:
 * - List all stores
 * - Create new store
 * - Edit store
 * - View store statistics
 * - Deactivate store
 */
import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { storeService } from '../services/storeService';
import { authService } from '../services/authService';

const StoresPage = () => {
    const queryClient = useQueryClient();
    const [showModal, setShowModal] = useState(false);
    const [showStatsModal, setShowStatsModal] = useState(false);
    const [selectedStore, setSelectedStore] = useState(null);
    const [searchQuery, setSearchQuery] = useState('');
    const [statsFilter, setStatsFilter] = useState({
        start_date: new Date(new Date().setDate(new Date().getDate() - 30)).toISOString().split('T')[0],
        end_date: new Date().toISOString().split('T')[0],
        period: 'day',
    });
    const [showConfirmModal, setShowConfirmModal] = useState({
        show: false,
        type: '', // 'deactivate', 'reactivate', 'permanent_delete', 'reset_data'
        store: null
    });
    const [confirmPassword, setConfirmPassword] = useState('');
    const [formData, setFormData] = useState({
        code: '',
        name: '',
        registration_code: '', // Kode untuk customer daftar
        address: '',
        city: '',
        province: '',
        postal_code: '',
        phone: '',
        email: '',
    });

    // Check if user is Super Admin
    const isSuperAdmin = authService.isSuperAdmin();

    // Fetch stores
    const { data: storesData, isLoading, error } = useQuery({
        queryKey: ['stores', searchQuery],
        queryFn: () => storeService.getStores({ search: searchQuery }),
        enabled: isSuperAdmin,
    });

    // Create store mutation
    const createMutation = useMutation({
        mutationFn: (data) => storeService.createStore(data),
        onSuccess: () => {
            queryClient.invalidateQueries(['stores']);
            setShowModal(false);
            resetForm();
        },
    });

    // Update store mutation
    const updateMutation = useMutation({
        mutationFn: ({ id, data }) => storeService.updateStore(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries(['stores']);
            setShowModal(false);
            resetForm();
        },
    });

    // Delete (deactivate) store mutation
    const deleteMutation = useMutation({
        mutationFn: ({ id, password }) => storeService.deleteStore(id, false, password),
        onSuccess: () => {
            queryClient.invalidateQueries(['stores']);
        },
    });

    // Fetch store stats
    const { data: storeStats, isLoading: statsLoading } = useQuery({
        queryKey: ['store-stats', selectedStore?.id, statsFilter],
        queryFn: () => storeService.getStoreStats(selectedStore.id, statsFilter),
        enabled: !!selectedStore && showStatsModal,
    });

    const resetForm = () => {
        setFormData({
            code: '',
            name: '',
            registration_code: '',
            address: '',
            city: '',
            province: '',
            postal_code: '',
            phone: '',
            email: '',
        });
        setSelectedStore(null);
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        if (selectedStore) {
            updateMutation.mutate({ id: selectedStore.id, data: formData });
        } else {
            createMutation.mutate(formData);
        }
    };

    const handleEdit = (store) => {
        setSelectedStore(store);
        setFormData({
            code: store.code,
            name: store.name,
            registration_code: store.registration_code || '',
            address: store.address || '',
            city: store.city || '',
            province: store.province || '',
            postal_code: store.postal_code || '',
            phone: store.phone || '',
            email: store.email || '',
        });
        setShowModal(true);
    };

    const handleViewStats = (store) => {
        setSelectedStore(store);
        setShowStatsModal(true);
    };

    const handleDeactivate = (store) => {
        setShowConfirmModal({
            show: true,
            type: 'deactivate',
            store: store
        });
    };

    const handleReactivate = (store) => {
        setShowConfirmModal({
            show: true,
            type: 'reactivate',
            store: store
        });
    };

    const handlePermanentDelete = (store) => {
        setShowConfirmModal({
            show: true,
            type: 'permanent_delete',
            store: store
        });
    };

    const handleResetData = (store) => {
        setShowConfirmModal({
            show: true,
            type: 'reset_data',
            store: store
        });
    };

    const executeAction = async () => {
        const { type, store } = showConfirmModal;
        if (!store) return;

        // Check password for critical actions
        const isCritical = ['deactivate', 'reset_data', 'permanent_delete'].includes(type);
        if (isCritical && !confirmPassword) {
            toast.warning('Silakan masukkan password Anda untuk melanjutkan.');
            return;
        }

        try {
            if (type === 'deactivate') {
                await deleteMutation.mutateAsync({ id: store.id, password: confirmPassword });
                toast.success(`Toko ${store.name} dinonaktifkan`);
            } else if (type === 'reactivate') {
                await updateMutation.mutateAsync({
                    id: store.id,
                    data: { ...store, is_active: true }
                });
                toast.success(`Toko ${store.name} diaktifkan kembali`);
            } else if (type === 'permanent_delete') {
                await storeService.deleteStore(store.id, true, confirmPassword);
                toast.success('Toko berhasil dihapus permanen');
                queryClient.invalidateQueries(['stores']);
            } else if (type === 'reset_data') {
                const res = await storeService.resetStoreData(store.id, confirmPassword);
                toast.success(res.message);
                queryClient.invalidateQueries(['stores']);
            }
        } catch (error) {
            console.error('Action failed:', error);
            const msg = error.response?.data?.error || error.response?.data?.detail || error.response?.data?.message || 'Gagal mengeksekusi perintah';
            toast.error(msg);
            if (msg.toLowerCase().includes('password')) {
                return; // Keep modal open if password wrong
            }
        } finally {
            if (!isCritical || !showConfirmModal.show) {
                setShowConfirmModal({ show: false, type: '', store: null });
                setConfirmPassword('');
            } else {
                // If it was a critical action and it failed without returning early, 
                // we might want to close it, but usually standard error handling should suffice.
                // Let's reset password regardless on success.
                setShowConfirmModal({ show: false, type: '', store: null });
                setConfirmPassword('');
            }
        }
    };

    // Not Super Admin - show access denied
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
                    <p className="mt-4 text-gray-600">Loading stores...</p>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div className="bg-red-50 p-4 rounded-lg">
                <p className="text-red-600">Error loading stores: {error.message}</p>
            </div>
        );
    }

    const stores = storesData?.results || [];

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Manajemen Toko</h1>
                    <p className="text-gray-600">Kelola semua toko/cabang</p>
                </div>
                <button
                    onClick={() => {
                        resetForm();
                        setShowModal(true);
                    }}
                    className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 transition"
                >
                    <span>➕</span>
                    Tambah Toko
                </button>
            </div>

            {/* Search */}
            <div className="bg-white rounded-lg shadow p-4">
                <input
                    type="text"
                    placeholder="Cari toko berdasarkan kode, nama, atau kota..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                />
            </div>

            {/* Stores Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
                {stores.map((store) => (
                    <div key={store.id} className="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-100 flex flex-col hover:shadow-2xl transition-all duration-300">
                        {/* Status Banner */}
                        <div className={`h-2 ${store.is_active ? 'bg-orange-500' : 'bg-gray-400'}`}></div>

                        {/* Header Section */}
                        <div className="p-6 pb-0">
                            <div className="flex justify-between items-start mb-4">
                                <div>
                                    <div className="flex items-center gap-2 mb-1">
                                        <span className="bg-orange-100 text-orange-700 font-mono font-bold px-2 py-0.5 rounded text-sm tracking-wider">
                                            {store.registration_code || '---'}
                                        </span>
                                        <span className={`flex h-2 w-2 rounded-full ${store.is_active ? 'bg-green-500 animate-pulse' : 'bg-red-500'}`}></span>
                                    </div>
                                    <h3 className="text-xl font-extrabold text-gray-900 leading-tight">{store.name}</h3>
                                    <div className="flex items-center text-gray-500 text-sm mt-1">
                                        <span className="mr-1">📍</span> {store.city || 'Lokasi tidak diatur'}
                                    </div>
                                </div>
                                <div className="text-right">
                                    <span className={`inline-block px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider ${store.is_active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}`}>
                                        {store.is_active ? 'Operasional' : 'Nonaktif'}
                                    </span>
                                </div>
                            </div>
                        </div>

                        {/* Stats Visualization */}
                        <div className="px-6 py-4 flex-1">
                            <div className="grid grid-cols-2 gap-3 mb-6">
                                <div className="bg-gray-50 p-4 rounded-xl border border-gray-100 hover:bg-orange-50 transition group">
                                    <p className="text-gray-500 text-[10px] font-bold uppercase tracking-widest mb-1 group-hover:text-orange-600">Total Customer</p>
                                    <div className="flex items-end gap-2">
                                        <p className="text-2xl font-black text-gray-800">{store.user_count || 0}</p>
                                        <span className="text-gray-400 text-xs mb-1">Users</span>
                                    </div>
                                </div>
                                <div className="bg-gray-50 p-4 rounded-xl border border-gray-100 hover:bg-blue-50 transition group">
                                    <p className="text-gray-500 text-[10px] font-bold uppercase tracking-widest mb-1 group-hover:text-blue-600">Staff & Admin</p>
                                    <div className="flex items-end gap-2">
                                        <p className="text-2xl font-black text-gray-800">{store.admin_count || 0}</p>
                                        <span className="text-gray-400 text-xs mb-1">People</span>
                                    </div>
                                </div>
                            </div>

                            {/* Main Action */}
                            <button
                                onClick={() => handleViewStats(store)}
                                className="w-full bg-gray-900 hover:bg-gray-800 text-white py-3 rounded-xl font-bold flex items-center justify-center gap-2 transition-all transform active:scale-95 shadow-lg shadow-gray-200"
                            >
                                <span className="text-lg">📊</span>
                                Lihat Dashboard Toko
                            </button>
                        </div>

                        {/* Management Zone - Grouped and clearly labeled */}
                        <div className="bg-gray-50/50 border-t border-gray-100 p-4 pt-4">
                            <p className="text-[10px] font-bold text-gray-400 uppercase tracking-widest mb-3 px-2">Store Management</p>
                            <div className="flex flex-wrap gap-2 px-1">
                                <button
                                    onClick={() => handleEdit(store)}
                                    className="flex-1 min-w-[80px] bg-white hover:bg-orange-50 text-orange-600 border border-orange-100 py-2 rounded-lg text-xs font-bold transition flex items-center justify-center gap-1.5 shadow-sm"
                                >
                                    <span>✏️</span> Edit
                                </button>

                                <button
                                    onClick={() => handleResetData(store)}
                                    className="flex-1 min-w-[80px] bg-white hover:bg-yellow-50 text-yellow-600 border border-yellow-100 py-2 rounded-lg text-xs font-bold transition flex items-center justify-center gap-1.5 shadow-sm"
                                    title="Hapus data transaksi (Customer & Polis)"
                                >
                                    <span>♻️</span> Reset
                                </button>

                                {store.is_active ? (
                                    <button
                                        onClick={() => handleDeactivate(store)}
                                        className="flex-1 min-w-[80px] bg-white hover:bg-red-50 text-red-600 border border-red-100 py-2 rounded-lg text-xs font-bold transition flex items-center justify-center gap-1.5 shadow-sm"
                                    >
                                        <span>🔒</span> Tutup
                                    </button>
                                ) : (
                                    <>
                                        <button
                                            onClick={() => handleReactivate(store)}
                                            className="flex-1 min-w-[80px] bg-white hover:bg-green-50 text-green-600 border border-green-100 py-2 rounded-lg text-xs font-bold transition flex items-center justify-center gap-1.5 shadow-sm"
                                        >
                                            <span>🔓</span> Buka
                                        </button>
                                        <button
                                            onClick={() => handlePermanentDelete(store)}
                                            className="flex-1 min-w-[100px] bg-red-600 hover:bg-red-700 text-white py-2 rounded-lg text-xs font-bold transition flex items-center justify-center gap-1.5 shadow-md"
                                        >
                                            <span>🔥</span> Destroy
                                        </button>
                                    </>
                                )}
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            {stores.length === 0 && (
                <div className="bg-white rounded-lg shadow p-12 text-center">
                    <div className="text-6xl mb-4">🏪</div>
                    <h3 className="text-xl font-bold text-gray-800 mb-2">Belum Ada Toko</h3>
                    <p className="text-gray-600 mb-4">Klik tombol "Tambah Toko" untuk membuat toko baru</p>
                </div>
            )}

            {/* Create/Edit Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto">
                        {/* Modal Header */}
                        <div className="p-6 border-b">
                            <h2 className="text-xl font-bold text-gray-800">
                                {selectedStore ? 'Edit Toko' : 'Tambah Toko Baru'}
                            </h2>
                        </div>

                        {/* Modal Body */}
                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">
                                        Kode Toko *
                                        <span className="text-gray-500 font-normal ml-1">(untuk customer daftar)</span>
                                    </label>
                                    <input
                                        type="text"
                                        value={formData.registration_code}
                                        onChange={(e) => {
                                            const val = e.target.value.toUpperCase();
                                            setFormData({ ...formData, code: val, registration_code: val });
                                        }}
                                        placeholder="KUA001"
                                        maxLength={10}
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500 font-mono text-lg"
                                        required
                                    />
                                    <p className="text-xs text-gray-500 mt-1">Kode pendek yang diberikan ke customer. Contoh: KUA001, OSP001</p>
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Nama Toko *</label>
                                    <input
                                        type="text"
                                        value={formData.name}
                                        onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                        placeholder="Smile - Cabang Jakarta"
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                                        required
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Alamat</label>
                                <textarea
                                    value={formData.address}
                                    onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                                    placeholder="Jl. Contoh No. 123"
                                    className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                                    rows={2}
                                />
                            </div>

                            <div className="grid grid-cols-3 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Kota</label>
                                    <input
                                        type="text"
                                        value={formData.city}
                                        onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                                        placeholder="Jakarta"
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Provinsi</label>
                                    <input
                                        type="text"
                                        value={formData.province}
                                        onChange={(e) => setFormData({ ...formData, province: e.target.value })}
                                        placeholder="DKI Jakarta"
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Kode Pos</label>
                                    <input
                                        type="text"
                                        value={formData.postal_code}
                                        onChange={(e) => setFormData({ ...formData, postal_code: e.target.value })}
                                        placeholder="12345"
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                                    />
                                </div>
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Telepon</label>
                                    <input
                                        type="text"
                                        value={formData.phone}
                                        onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                                        placeholder="021-1234567"
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                                    <input
                                        type="email"
                                        value={formData.email}
                                        onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                        placeholder="store@smile.com"
                                        className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-orange-500"
                                    />
                                </div>
                            </div>

                            {/* Buttons */}
                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => {
                                        setShowModal(false);
                                        resetForm();
                                    }}
                                    className="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 py-2 rounded-lg font-medium transition"
                                >
                                    Batal
                                </button>
                                <button
                                    type="submit"
                                    disabled={createMutation.isPending || updateMutation.isPending}
                                    className="flex-1 bg-orange-500 hover:bg-orange-600 text-white py-2 rounded-lg font-medium transition disabled:opacity-50"
                                >
                                    {createMutation.isPending || updateMutation.isPending ? 'Menyimpan...' : 'Simpan'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}

            {/* Stats Modal */}
            {showStatsModal && selectedStore && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
                    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
                        {/* Modal Header */}
                        <div className="p-6 border-b bg-gradient-to-r from-orange-500 to-orange-600 sticky top-0 z-10">
                            <div className="flex justify-between items-center">
                                <div>
                                    <p className="text-white/80 text-sm font-mono">{selectedStore.registration_code || selectedStore.code}</p>
                                    <h2 className="text-xl font-bold text-white">{selectedStore.name}</h2>
                                </div>
                                <button
                                    onClick={() => {
                                        setShowStatsModal(false);
                                        setSelectedStore(null);
                                    }}
                                    className="text-white hover:bg-white/20 p-2 rounded-lg transition"
                                >
                                    ✕
                                </button>
                            </div>
                        </div>

                        {/* Modal Body */}
                        <div className="p-6 space-y-8">
                            {/* Filter Bar */}
                            <div className="bg-gray-50 p-4 rounded-xl border border-gray-100 flex flex-wrap gap-4 items-end">
                                <div className="space-y-1">
                                    <label className="text-[10px] font-bold text-gray-500 uppercase">Dari Tanggal</label>
                                    <input
                                        type="date"
                                        value={statsFilter.start_date}
                                        onChange={(e) => setStatsFilter({ ...statsFilter, start_date: e.target.value })}
                                        className="block w-full text-sm border-gray-300 rounded-lg focus:ring-orange-500"
                                    />
                                </div>
                                <div className="space-y-1">
                                    <label className="text-[10px] font-bold text-gray-500 uppercase">Sampai Tanggal</label>
                                    <input
                                        type="date"
                                        value={statsFilter.end_date}
                                        onChange={(e) => setStatsFilter({ ...statsFilter, end_date: e.target.value })}
                                        className="block w-full text-sm border-gray-300 rounded-lg focus:ring-orange-500"
                                    />
                                </div>
                                <button
                                    onClick={() => setStatsFilter({
                                        start_date: new Date(new Date().setDate(new Date().getDate() - 30)).toISOString().split('T')[0],
                                        end_date: new Date().toISOString().split('T')[0],
                                        period: 'day'
                                    })}
                                    className="text-xs text-orange-600 hover:text-orange-700 font-medium px-2 py-2"
                                >
                                    Reset
                                </button>
                            </div>

                            {statsLoading ? (
                                <div className="text-center py-20">
                                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-orange-500 mx-auto"></div>
                                    <p className="mt-4 text-gray-600">Loading detailed statistics...</p>
                                </div>
                            ) : storeStats ? (
                                <div className="space-y-8">
                                    {/* Row 1: Key Performance Indicators */}
                                    <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                                        <div className="bg-orange-50 border border-orange-100 p-4 rounded-xl">
                                            <p className="text-orange-600 text-xs font-bold uppercase tracking-wider">Periode Ini (Polis)</p>
                                            <p className="text-2xl font-bold text-orange-700">{storeStats.range_summary?.policy_count || 0}</p>
                                            <p className="text-xs text-orange-600/70 mt-1">
                                                Rp {(storeStats.range_summary?.policy_revenue || 0).toLocaleString('id-ID')}
                                            </p>
                                        </div>
                                        <div className="bg-blue-50 border border-blue-100 p-4 rounded-xl">
                                            <p className="text-blue-600 text-xs font-bold uppercase tracking-wider">Total Customer</p>
                                            <p className="text-2xl font-bold text-blue-700">{storeStats.users?.total_customers || 0}</p>
                                            <p className="text-xs text-blue-600/70 mt-1">{storeStats.users?.verified_customers || 0} Terverifikasi</p>
                                        </div>
                                        <div className="bg-green-50 border border-green-100 p-4 rounded-xl">
                                            <p className="text-green-600 text-xs font-bold uppercase tracking-wider">Total Polis</p>
                                            <p className="text-2xl font-bold text-green-700">{storeStats.policies?.total || 0}</p>
                                            <p className="text-xs text-green-600/70 mt-1">{storeStats.policies?.active || 0} Aktif</p>
                                        </div>
                                        <div className="bg-purple-50 border border-purple-100 p-4 rounded-xl">
                                            <p className="text-purple-600 text-xs font-bold uppercase tracking-wider">Total Klaim</p>
                                            <p className="text-2xl font-bold text-purple-700">{storeStats.claims?.total || 0}</p>
                                            <p className="text-xs text-purple-600/70 mt-1">{storeStats.claims?.completed || 0} Selesai</p>
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                                        {/* Dynamic Recap Table */}
                                        <div className="space-y-4">
                                            <h3 className="font-bold text-gray-800 flex items-center gap-2">
                                                <span>📊</span> Rekap {statsFilter.period === 'day' ? 'Harian' :
                                                    statsFilter.period === 'week' ? 'Mingguan' :
                                                        statsFilter.period === 'month' ? 'Bulanan' : 'Tahunan'}
                                            </h3>
                                            <div className="bg-white border rounded-xl overflow-hidden">
                                                <table className="w-full text-sm">
                                                    <thead className="bg-gray-50 text-gray-600">
                                                        <tr>
                                                            <th className="px-4 py-2 text-left font-semibold">Periode</th>
                                                            <th className="px-4 py-2 text-center font-semibold">Polis</th>
                                                            <th className="px-4 py-2 text-right font-semibold">Omzet (IDR)</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody className="divide-y">
                                                        {storeStats.recap?.length > 0 ? (
                                                            storeStats.recap.map((bucket, idx) => (
                                                                <tr key={idx} className="hover:bg-gray-50">
                                                                    <td className="px-4 py-2 font-medium">
                                                                        {(() => {
                                                                            const d = new Date(bucket.bucket);
                                                                            if (statsFilter.period === 'month') return d.toLocaleDateString('id-ID', { month: 'long', year: 'numeric' });
                                                                            if (statsFilter.period === 'year') return d.getFullYear();
                                                                            if (statsFilter.period === 'week') return `Minggu ${d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short' })}`;
                                                                            return d.toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
                                                                        })()}
                                                                    </td>
                                                                    <td className="px-4 py-2 text-center">{bucket.count}</td>
                                                                    <td className="px-4 py-2 text-right font-mono text-xs">
                                                                        {(bucket.revenue || 0).toLocaleString('id-ID')}
                                                                    </td>
                                                                </tr>
                                                            ))
                                                        ) : (
                                                            <tr>
                                                                <td colSpan="3" className="px-4 py-8 text-center text-gray-400">Tidak ada data untuk periode ini</td>
                                                            </tr>
                                                        )}
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>

                                        {/* Top Models Distribution */}
                                        <div className="space-y-4">
                                            <h3 className="font-bold text-gray-800 flex items-center gap-2">
                                                <span>📱</span> Top 5 Tipe Handphone
                                            </h3>
                                            <div className="space-y-3">
                                                {storeStats.phone_distribution?.length > 0 ? (
                                                    storeStats.phone_distribution.map((item, idx) => (
                                                        <div key={idx} className="space-y-1">
                                                            <div className="flex justify-between text-sm">
                                                                <span className="text-gray-700 font-medium">
                                                                    {item.device_package__device_brand} {item.device_package__device_model}
                                                                </span>
                                                                <span className="text-gray-500">{item.count} unit</span>
                                                            </div>
                                                            <div className="w-full bg-gray-100 rounded-full h-2">
                                                                <div
                                                                    className="bg-orange-500 h-2 rounded-full transition-all duration-500"
                                                                    style={{ width: `${(item.count / storeStats.policies.total) * 100}%` }}
                                                                ></div>
                                                            </div>
                                                        </div>
                                                    ))
                                                ) : (
                                                    <div className="bg-gray-50 rounded-xl p-8 text-center text-gray-400">
                                                        Belum ada data distribusi HP
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    </div>

                                    {/* Claims Detailed View */}
                                    <div className="bg-gray-50 rounded-2xl p-6">
                                        <h3 className="font-bold text-gray-800 mb-4 flex items-center gap-2">
                                            <span>🛠️</span> Status Klaim Terkini
                                        </h3>
                                        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
                                            <div className="bg-white p-3 rounded-lg border text-center">
                                                <p className="text-gray-500 text-[10px] uppercase font-bold">Pending</p>
                                                <p className="text-xl font-bold text-orange-600">{storeStats.claims?.filtered_pending || 0}</p>
                                            </div>
                                            <div className="bg-white p-3 rounded-lg border text-center">
                                                <p className="text-gray-500 text-[10px] uppercase font-bold">Disetujui</p>
                                                <p className="text-xl font-bold text-blue-600">{storeStats.claims?.filtered_approved || 0}</p>
                                            </div>
                                            <div className="bg-white p-3 rounded-lg border text-center">
                                                <p className="text-gray-500 text-[10px] uppercase font-bold">Progress</p>
                                                <p className="text-xl font-bold text-cyan-600">{storeStats.claims?.filtered_in_progress || 0}</p>
                                            </div>
                                            <div className="bg-white p-3 rounded-lg border text-center">
                                                <p className="text-gray-500 text-[10px] uppercase font-bold">Selesai</p>
                                                <p className="text-xl font-bold text-green-600">{storeStats.claims?.filtered_completed || 0}</p>
                                            </div>
                                            <div className="bg-white p-3 rounded-lg border text-center">
                                                <p className="text-gray-500 text-[10px] uppercase font-bold">Ditolak</p>
                                                <p className="text-xl font-bold text-red-600">{storeStats.claims?.filtered_rejected || 0}</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            ) : (
                                <p className="text-center text-gray-600 py-12">No detailed statistics available for this store.</p>
                            )}
                        </div>
                    </div>
                </div>
            )}
            {/* Action Confirmation Modal */}
            {showConfirmModal.show && (
                <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-[60] p-4 animate-fadeIn">
                    <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden animate-scaleIn">
                        <div className={`p-6 text-center ${showConfirmModal.type === 'permanent_delete' ? 'bg-red-50' :
                            showConfirmModal.type === 'reset_data' ? 'bg-yellow-50' :
                                showConfirmModal.type === 'deactivate' ? 'bg-orange-50' : 'bg-green-50'}`}>
                            <div className="w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-4 bg-white shadow-sm text-4xl">
                                {showConfirmModal.type === 'permanent_delete' ? '🔥' :
                                    showConfirmModal.type === 'reset_data' ? '♻️' :
                                        showConfirmModal.type === 'deactivate' ? '🔒' : '🔓'}
                            </div>
                            <h3 className="text-xl font-bold text-gray-900 mb-2">
                                {showConfirmModal.type === 'permanent_delete' ? 'Hapus Permanen?' :
                                    showConfirmModal.type === 'reset_data' ? 'Reset Data Toko?' :
                                        showConfirmModal.type === 'deactivate' ? 'Tutup Operasional?' : 'Buka Kembali Toko?'}
                            </h3>
                            <p className="text-sm text-gray-600">
                                {showConfirmModal.type === 'permanent_delete' ? (
                                    <>Tindakan ini akan menghapus <strong>semua data terkait</strong> toko <strong>{showConfirmModal.store.name}</strong> dan tidak bisa dibatalkan!</>
                                ) : showConfirmModal.type === 'reset_data' ? (
                                    <>Anda akan menghapus <strong>semua customer dan transaksi</strong> di toko <strong>{showConfirmModal.store.name}</strong>. Data admin tetap ada.</>
                                ) : showConfirmModal.type === 'deactivate' ? (
                                    <>Toko <strong>{showConfirmModal.store.name}</strong> akan ditangguhkan dan tidak dapat melayani pendaftaran baru.</>
                                ) : (
                                    <>Aktifkan kembali operasional toko <strong>{showConfirmModal.store.name}</strong>?</>
                                )}
                            </p>
                        </div>
                        <div className="p-6 flex flex-col gap-4">
                            {['deactivate', 'reset_data', 'permanent_delete'].includes(showConfirmModal.type) && (
                                <div className="space-y-2">
                                    <label className="text-xs font-bold text-gray-500 uppercase tracking-widest pl-1">
                                        Konfirmasi Password Anda
                                    </label>
                                    <input
                                        type="password"
                                        value={confirmPassword}
                                        onChange={(e) => setConfirmPassword(e.target.value)}
                                        placeholder="Ketik password login Anda..."
                                        className="w-full px-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:ring-2 focus:ring-indigo-500 outline-none transition-all font-medium"
                                        autoFocus
                                    />
                                </div>
                            )}
                            <button
                                onClick={executeAction}
                                className={`w-full py-3 rounded-xl font-bold transition shadow-lg ${showConfirmModal.type === 'permanent_delete' ? 'bg-red-600 hover:bg-red-700 text-white' :
                                    showConfirmModal.type === 'reset_data' ? 'bg-yellow-500 hover:bg-yellow-600 text-white' :
                                        showConfirmModal.type === 'deactivate' ? 'bg-orange-500 hover:bg-orange-600 text-white' :
                                            'bg-green-600 hover:bg-green-700 text-white'
                                    }`}
                            >
                                Ya, Lanjutkan
                            </button>
                            <button
                                onClick={() => {
                                    setShowConfirmModal({ show: false, type: '', store: null });
                                    setConfirmPassword('');
                                }}
                                className="w-full py-3 rounded-xl font-bold text-gray-500 hover:bg-gray-100 transition"
                            >
                                Batalkan
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default StoresPage;
