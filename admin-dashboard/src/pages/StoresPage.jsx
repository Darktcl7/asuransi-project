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
        mutationFn: (id) => storeService.deleteStore(id),
        onSuccess: () => {
            queryClient.invalidateQueries(['stores']);
        },
    });

    // Fetch store stats
    const { data: storeStats, isLoading: statsLoading } = useQuery({
        queryKey: ['store-stats', selectedStore?.id],
        queryFn: () => storeService.getStoreStats(selectedStore.id),
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

    const handleDelete = (store) => {
        if (confirm(`Apakah Anda yakin ingin menonaktifkan toko "${store.name}"?`)) {
            deleteMutation.mutate(store.id);
        }
    };

    const handleReactivate = (store) => {
        if (confirm(`Aktifkan kembali toko "${store.name}"?`)) {
            // Reactivate by updating is_active to true
            updateMutation.mutate({
                id: store.id,
                data: { ...store, is_active: true }
            });
        }
    };

    const handlePermanentDelete = async (store) => {
        if (confirm(`PERHATIAN: Apakah Anda yakin ingin MENGHAPUS PERMANEN toko "${store.name}"?\n\nData yang akan hilang:\n- Data toko\n- Data admin toko\n- Data customer terkait\n- Data polis & klaim\n\nTindakan ini TIDAK BISA DIBATALKAN!`)) {
            try {
                // Call a new endpoint for permanent delete 
                // Using existing adminService delete but might need specific param
                await storeService.deleteStore(store.id, true); // true = permanent
                toast.success('Toko berhasil dihapus permanen');
                fetchStores();
            } catch (error) {
                toast.error(error.response?.data?.detail || 'Gagal menghapus toko permanen');
            }
        }
    };

    const handleResetData = async (store) => {
        if (window.confirm(`PERINGATAN: Anda akan MENGHAPUS SEMUA Customer, Polis, dan Klaim di toko "${store.name}".\n\nAkun admin toko TIDAK akan terhapus.\n\nLanjutkan?`)) {
            if (window.confirm(`YAKIN? Tindakan ini tidak bisa dibatalkan!`)) {
                try {
                    const res = await storeService.resetStoreData(store.id);
                    toast.success(res.message);
                    fetchStores();
                } catch (error) {
                    toast.error(error.response?.data?.message || 'Gagal reset data toko');
                }
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
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {stores.map((store) => (
                    <div key={store.id} className="bg-white rounded-lg shadow-lg overflow-hidden">
                        {/* Header */}
                        <div className={`p-4 ${store.is_active ? 'bg-gradient-to-r from-orange-500 to-orange-600' : 'bg-gray-400'}`}>
                            <div className="flex justify-between items-start">
                                <div>
                                    {/* Kode Registrasi - yang dipakai customer untuk daftar */}
                                    <p className="text-white font-mono font-bold text-lg">{store.registration_code || 'N/A'}</p>
                                    <h3 className="text-white/90 font-medium">{store.name}</h3>
                                </div>
                                <span className={`px-2 py-1 rounded-full text-xs font-medium ${store.is_active ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>
                                    {store.is_active ? 'Aktif' : 'Nonaktif'}
                                </span>
                            </div>
                        </div>

                        {/* Body */}
                        <div className="p-4">
                            <div className="space-y-2 text-sm text-gray-600">
                                {store.city && (
                                    <div className="flex items-center gap-2">
                                        <span>📍</span>
                                        <span>{store.city}</span>
                                    </div>
                                )}
                                <div className="flex items-center gap-4">
                                    <div className="flex items-center gap-1">
                                        <span>👥</span>
                                        <span>{store.user_count || 0} customers</span>
                                    </div>
                                    <div className="flex items-center gap-1">
                                        <span>👔</span>
                                        <span>{store.admin_count || 0} admins</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Footer */}
                        <div className="border-t p-3 flex gap-2">
                            <button
                                onClick={() => handleResetData(store)}
                                className="px-3 bg-yellow-50 hover:bg-yellow-100 text-yellow-600 rounded-lg text-sm font-medium transition flex items-center justify-center"
                                title="Reset Data (Hapus Customer & Polis)"
                            >
                                ♻
                            </button>
                            <button
                                onClick={() => handleViewStats(store)}
                                className="flex-1 bg-blue-50 hover:bg-blue-100 text-blue-600 py-2 rounded-lg text-sm font-medium transition"
                            >
                                📊 Stats
                            </button>
                            <button
                                onClick={() => handleEdit(store)}
                                className="flex-1 bg-orange-50 hover:bg-orange-100 text-orange-600 py-2 rounded-lg text-sm font-medium transition"
                            >
                                ✏️ Edit
                            </button>
                            {store.is_active ? (
                                <button
                                    onClick={() => handleDelete(store)}
                                    className="flex-1 bg-red-50 hover:bg-red-100 text-red-600 py-2 rounded-lg text-sm font-medium transition"
                                >
                                    🗑️ Hapus
                                </button>
                            ) : (
                                <>
                                    <button
                                        onClick={() => handleReactivate(store)}
                                        className="flex-1 bg-green-50 hover:bg-green-100 text-green-600 py-2 rounded-lg text-sm font-medium transition"
                                    >
                                        ✅ Aktif
                                    </button>
                                    <button
                                        onClick={() => handlePermanentDelete(store)}
                                        className="flex-1 bg-gray-50 hover:bg-red-50 text-red-600 py-2 rounded-lg text-sm font-medium transition border border-red-100"
                                        title="Hapus Permanen"
                                    >
                                        ❌ Destroy
                                    </button>
                                </>
                            )}
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
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
                    <div className="bg-white rounded-2xl shadow-2xl w-full max-w-2xl">
                        {/* Modal Header */}
                        <div className="p-6 border-b bg-gradient-to-r from-orange-500 to-orange-600 rounded-t-2xl">
                            <div className="flex justify-between items-center">
                                <div>
                                    <p className="text-white/80 text-sm">{selectedStore.code}</p>
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
                        <div className="p-6">
                            {statsLoading ? (
                                <div className="text-center py-8">
                                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-orange-500 mx-auto"></div>
                                    <p className="mt-2 text-gray-600">Loading statistics...</p>
                                </div>
                            ) : storeStats ? (
                                <div className="grid grid-cols-3 gap-6">
                                    {/* Users Stats */}
                                    <div className="bg-blue-50 rounded-xl p-4">
                                        <h3 className="text-blue-800 font-bold mb-3">👥 Users</h3>
                                        <div className="space-y-2 text-sm">
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Total Customers</span>
                                                <span className="font-bold">{storeStats.users?.total_customers || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Verified</span>
                                                <span className="font-bold text-green-600">{storeStats.users?.verified_customers || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Staff</span>
                                                <span className="font-bold">{storeStats.users?.total_staff || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Admins</span>
                                                <span className="font-bold">{storeStats.users?.total_admins || 0}</span>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Policies Stats */}
                                    <div className="bg-green-50 rounded-xl p-4">
                                        <h3 className="text-green-800 font-bold mb-3">📋 Policies</h3>
                                        <div className="space-y-2 text-sm">
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Total</span>
                                                <span className="font-bold">{storeStats.policies?.total || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Active</span>
                                                <span className="font-bold text-green-600">{storeStats.policies?.active || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Pending</span>
                                                <span className="font-bold text-orange-600">{storeStats.policies?.pending || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Expired</span>
                                                <span className="font-bold text-gray-600">{storeStats.policies?.expired || 0}</span>
                                            </div>
                                        </div>
                                    </div>

                                    {/* Claims Stats */}
                                    <div className="bg-orange-50 rounded-xl p-4">
                                        <h3 className="text-orange-800 font-bold mb-3">🎫 Claims</h3>
                                        <div className="space-y-2 text-sm">
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Total</span>
                                                <span className="font-bold">{storeStats.claims?.total || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Pending</span>
                                                <span className="font-bold text-orange-600">{storeStats.claims?.pending || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Approved</span>
                                                <span className="font-bold text-green-600">{storeStats.claims?.approved || 0}</span>
                                            </div>
                                            <div className="flex justify-between">
                                                <span className="text-gray-600">Completed</span>
                                                <span className="font-bold text-blue-600">{storeStats.claims?.completed || 0}</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            ) : (
                                <p className="text-center text-gray-600">No statistics available</p>
                            )}
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default StoresPage;
