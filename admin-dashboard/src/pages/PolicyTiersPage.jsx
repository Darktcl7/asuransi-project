import React, { useState, useEffect } from 'react';
import { adminService } from '../services/adminService';
import { useToast } from '../components/Toast';

const PolicyTiersPage = () => {
    const toast = useToast();
    const [tiers, setTiers] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [editingTier, setEditingTier] = useState(null);

    // Form State
    const [formData, setFormData] = useState({
        tier_name: '',
        min_price: '',
        max_price: '',
        policy_price: '',
        policy_duration_days: 365,
        claim_deduction_percent: 10, // Default 10% (though unused in new system)
        max_claims_per_year: 3
    });

    useEffect(() => {
        loadData();
    }, []);

    const loadData = async () => {
        setIsLoading(true);
        try {
            const data = await adminService.getPolicyTiers();
            // Sort by min_price
            const sortedData = data.sort((a, b) => parseFloat(a.min_price) - parseFloat(b.min_price));
            setTiers(sortedData);
        } catch (error) {
            console.error('Error loading tiers:', error);
            toast.error('Gagal memuat data tier');
        } finally {
            setIsLoading(false);
        }
    };

    const handleEdit = (tier) => {
        setEditingTier(tier);
        setFormData({
            tier_name: tier.tier_name,
            min_price: tier.min_price,
            max_price: tier.max_price,
            policy_price: tier.policy_price,
            policy_duration_days: tier.policy_duration_days,
            claim_deduction_percent: tier.claim_deduction_percent,
            max_claims_per_year: tier.max_claims_per_year
        });
        setShowModal(true);
    };

    const handleAdd = () => {
        setEditingTier(null);
        setFormData({
            tier_name: '',
            min_price: '',
            max_price: '',
            policy_price: '',
            policy_duration_days: 365,
            claim_deduction_percent: 10,
            max_claims_per_year: 3
        });
        setShowModal(true);
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Apakah Anda yakin ingin menghapus tier ini?')) return;

        try {
            await adminService.deletePolicyTier(id);
            toast.success('Tier berhasil dihapus');
            loadData();
        } catch (error) {
            console.error('Error deleting tier:', error);
            toast.error('Gagal menghapus tier');
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsSubmitting(true);

        try {
            if (editingTier) {
                await adminService.updatePolicyTier(editingTier.id, formData);
                toast.success('Tier berhasil diperbarui');
            } else {
                await adminService.createPolicyTier(formData);
                toast.success('Tier berhasil ditambahkan');
            }
            setShowModal(false);
            loadData();
        } catch (error) {
            console.error('Error saving tier:', error);
            toast.error(error.response?.data?.detail || 'Gagal menyimpan data');
        } finally {
            setIsSubmitting(false);
        }
    };

    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
        }).format(amount);
    };

    return (
        <div className="p-6 max-w-7xl mx-auto">
            <div className="flex justify-between items-center mb-6">
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">Referensi Tier Polis</h1>
                    <p className="text-gray-500 mt-1">Atur harga polis berdasarkan harga device</p>
                </div>
                <button
                    onClick={handleAdd}
                    className="bg-orange-500 hover:bg-orange-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 transition-colors"
                >
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
                    </svg>
                    Tambah Tier
                </button>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center gap-3">
                        <div className="p-3 bg-blue-50 rounded-lg">
                            <span className="text-2xl">📊</span>
                        </div>
                        <div>
                            <p className="text-sm text-gray-500">Total Tiers</p>
                            <p className="text-xl font-bold text-gray-800">{tiers.length}</p>
                        </div>
                    </div>
                </div>
            </div>

            {/* Data Table */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                {isLoading ? (
                    <div className="p-8 text-center text-gray-500">Memuat data...</div>
                ) : tiers.length === 0 ? (
                    <div className="p-12 text-center">
                        <div className="text-4xl mb-3">📋</div>
                        <h3 className="text-lg font-medium text-gray-900">Belum ada data tier</h3>
                        <p className="text-gray-500 mt-1">Klik tombol tambah untuk membuat tier baru</p>
                    </div>
                ) : (
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="bg-gray-50 border-b border-gray-200">
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm w-32">Nama Tier</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Range Harga Device</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Harga Polis</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm">Durasi</th>
                                    <th className="py-4 px-6 font-semibold text-gray-600 text-sm text-right">Aksi</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100">
                                {tiers.map((tier) => (
                                    <tr key={tier.id} className="hover:bg-gray-50 transition-colors group">
                                        <td className="py-4 px-6">
                                            <span className="font-semibold text-gray-800">{tier.tier_name}</span>
                                        </td>
                                        <td className="py-4 px-6">
                                            <div className="text-sm text-gray-600">
                                                {formatCurrency(tier.min_price)} - {formatCurrency(tier.max_price)}
                                            </div>
                                        </td>
                                        <td className="py-4 px-6">
                                            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                {formatCurrency(tier.policy_price)}
                                            </span>
                                        </td>
                                        <td className="py-4 px-6 text-sm text-gray-600">
                                            {tier.policy_duration_days} Hari
                                        </td>
                                        <td className="py-4 px-6 text-right">
                                            <div className="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                                                <button
                                                    onClick={() => handleEdit(tier)}
                                                    className="p-1.5 hover:bg-blue-50 text-blue-600 rounded-lg transition-colors"
                                                    title="Edit"
                                                >
                                                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                                                    </svg>
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(tier.id)}
                                                    className="p-1.5 hover:bg-red-50 text-red-600 rounded-lg transition-colors"
                                                    title="Hapus"
                                                >
                                                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                                                    </svg>
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {/* Modal Form */}
            {showModal && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
                    <div className="bg-white rounded-xl shadow-xl w-full max-w-lg overflow-hidden animate-slideUp">
                        <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                            <h3 className="font-bold text-lg text-gray-800">
                                {editingTier ? 'Edit Tier' : 'Tambah Tier Baru'}
                            </h3>
                            <button
                                onClick={() => setShowModal(false)}
                                className="text-gray-400 hover:text-gray-600 transition-colors"
                            >
                                <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                                </svg>
                            </button>
                        </div>

                        <form onSubmit={handleSubmit} className="p-6 space-y-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Nama Tier</label>
                                <input
                                    type="text"
                                    required
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-all"
                                    placeholder="Contoh: Smile 1"
                                    value={formData.tier_name}
                                    onChange={e => setFormData({ ...formData, tier_name: e.target.value })}
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Min. Harga Device</label>
                                    <input
                                        type="number"
                                        required
                                        min="0"
                                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-all"
                                        value={formData.min_price}
                                        onChange={e => setFormData({ ...formData, min_price: e.target.value })}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Max. Harga Device</label>
                                    <input
                                        type="number"
                                        required
                                        min="0"
                                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-all"
                                        value={formData.max_price}
                                        onChange={e => setFormData({ ...formData, max_price: e.target.value })}
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Harga Polis</label>
                                <input
                                    type="number"
                                    required
                                    min="0"
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-all"
                                    value={formData.policy_price}
                                    onChange={e => setFormData({ ...formData, policy_price: e.target.value })}
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Durasi (Hari)</label>
                                    <input
                                        type="number"
                                        required
                                        min="1"
                                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-all"
                                        value={formData.policy_duration_days}
                                        onChange={e => setFormData({ ...formData, policy_duration_days: e.target.value })}
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1">Claim Deduction %</label>
                                    <input
                                        type="number"
                                        required
                                        min="0"
                                        max="100"
                                        className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition-all bg-gray-100"
                                        value={formData.claim_deduction_percent}
                                        onChange={e => setFormData({ ...formData, claim_deduction_percent: e.target.value })}
                                        title="Not used in Balance-Based system"
                                    />
                                </div>
                            </div>

                            <div className="flex gap-3 pt-4">
                                <button
                                    type="button"
                                    onClick={() => setShowModal(false)}
                                    className="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
                                >
                                    Batal
                                </button>
                                <button
                                    type="submit"
                                    disabled={isSubmitting}
                                    className="flex-1 px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors font-medium flex justify-center items-center gap-2"
                                >
                                    {isSubmitting ? (
                                        <>
                                            <div className="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                                            Menyimpan...
                                        </>
                                    ) : (
                                        'Simpan'
                                    )}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
};

export default PolicyTiersPage;
