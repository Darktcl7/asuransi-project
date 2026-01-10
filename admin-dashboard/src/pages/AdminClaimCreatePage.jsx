// pages/AdminClaimCreatePage.jsx
import { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Search, AlertCircle, CheckCircle, Loader, User, FileText, Shield } from 'lucide-react';
import api from '../api/axios';
import { useToast } from '../components/Toast';
import { useNavigate } from 'react-router-dom';

const DAMAGE_TYPES = [
    'Layar Pecah',
    'Layar Retak',
    'Kerusakan LCD',
    'Baterai Rusak',
    'Masalah Pengisian Daya',
    'Kerusakan Akibat Air',
    'Tombol Tidak Berfungsi',
    'Speaker/Mikrofon Rusak',
    'Kamera Rusak',
    'Motherboard Rusak',
    'Kerusakan Lainnya',
];

const AdminClaimCreatePage = () => {
    const toast = useToast();
    const navigate = useNavigate();

    // Search state
    const [searchQuery, setSearchQuery] = useState('');
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(false);

    // Selected state
    const [selectedUser, setSelectedUser] = useState(null);
    const [userPolicies, setUserPolicies] = useState([]);
    const [selectedPolicy, setSelectedPolicy] = useState(null);
    const [loadingPolicies, setLoadingPolicies] = useState(false);

    // Form state
    const [damageType, setDamageType] = useState('');
    const [damageDescription, setDamageDescription] = useState('');
    const [incidentDate, setIncidentDate] = useState(new Date().toISOString().split('T')[0]);
    const [reason, setReason] = useState('HP user rusak, tidak bisa akses aplikasi');
    const [photos, setPhotos] = useState([]);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [message, setMessage] = useState(null);

    // Search users
    const handleSearch = async () => {
        if (!searchQuery.trim()) return;

        setLoading(true);
        setMessage(null);
        try {
            const response = await api.get(`/admin/users/?search=${searchQuery}`);
            const results = response.data.results || response.data;
            setUsers(results);
            if (results.length === 0) {
                setMessage({ type: 'info', text: 'Tidak ada user yang ditemukan' });
            }
        } catch (error) {
            console.error('Search error:', error);
            setMessage({ type: 'error', text: 'Gagal mencari user' });
        } finally {
            setLoading(false);
        }
    };

    // Load user's active policies
    const loadUserPolicies = async (user) => {
        setSelectedUser(user);
        setSelectedPolicy(null);
        setUsers([]);
        setLoadingPolicies(true);

        try {
            // Fetch policies for this specific user
            const response = await api.get(`/admin/policies/?user=${user.id}&status=active`);
            const policies = response.data.results || response.data || [];
            setUserPolicies(policies);

            if (policies.length === 0) {
                setMessage({ type: 'warning', text: 'User ini tidak memiliki policy aktif' });
            } else {
                setMessage(null);
            }
        } catch (error) {
            console.error('Load policies error:', error);
            setMessage({ type: 'error', text: 'Gagal memuat policy user' });
            setUserPolicies([]);
        } finally {
            setLoadingPolicies(false);
        }
    };

    // Handle photo change
    const handlePhotoChange = (e) => {
        const files = Array.from(e.target.files);
        const validFiles = files.filter(file => {
            if (file.size > 10 * 1024 * 1024) {
                toast.warning(`File ${file.name} terlalu besar (max 10MB)`);
                return false;
            }
            return true;
        });
        setPhotos(prev => [...prev, ...validFiles].slice(0, 5));
    };

    const removePhoto = (index) => {
        setPhotos(prev => prev.filter((_, i) => i !== index));
    };

    // Reset all
    const handleReset = () => {
        setSelectedUser(null);
        setSelectedPolicy(null);
        setUserPolicies([]);
        setUsers([]);
        setSearchQuery('');
        setDamageType('');
        setDamageDescription('');
        setIncidentDate(new Date().toISOString().split('T')[0]);
        setReason('HP user rusak, tidak bisa akses aplikasi');
        setPhotos([]);
        setMessage(null);
    };

    // Submit claim
    const handleSubmit = async (e) => {
        e.preventDefault();

        if (!selectedUser || !selectedPolicy || !damageType || !incidentDate) {
            toast.warning('Mohon lengkapi semua field yang wajib diisi');
            return;
        }

        setIsSubmitting(true);
        setMessage(null);

        const formData = new FormData();
        formData.append('user_id', selectedUser.id);
        formData.append('policy_id', selectedPolicy.id);
        formData.append('damage_type', damageType);
        formData.append('damage_description', damageDescription);
        formData.append('incident_date', incidentDate);
        formData.append('reason', reason);

        photos.forEach(photo => {
            formData.append('photos', photo);
        });

        try {
            const response = await api.post('/admin/claims/create_for_user/', formData, {
                headers: { 'Content-Type': 'multipart/form-data' },
            });

            setMessage({
                type: 'success',
                text: `✅ ${response.data.message}\n\nClaim Number: ${response.data.data?.claim_number || 'Created'}`
            });

            toast.success('Klaim berhasil dibuat!');

            // Reset form after 2 seconds
            setTimeout(() => {
                navigate('/claims');
            }, 2000);

        } catch (error) {
            console.error('Create claim error:', error);
            const errorMsg = error.response?.data?.error || 'Gagal membuat klaim';
            setMessage({ type: 'error', text: errorMsg });
            toast.error(errorMsg);
        } finally {
            setIsSubmitting(false);
        }
    };

    return (
        <div className="p-6">
            {/* Header */}
            <div className="mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Assist User Claim</h1>
                <p className="text-gray-600 mt-1">
                    Submit a claim on behalf of a user who cannot access the app (e.g., damaged phone)
                </p>
            </div>

            {/* Message Alert */}
            {message && (
                <div className={`p-4 rounded-lg mb-6 flex items-start gap-2 ${message.type === 'success' ? 'bg-green-50 text-green-800 border border-green-200' :
                    message.type === 'warning' ? 'bg-yellow-50 text-yellow-800 border border-yellow-200' :
                        message.type === 'info' ? 'bg-blue-50 text-blue-800 border border-blue-200' :
                            'bg-red-50 text-red-800 border border-red-200'
                    }`}>
                    {message.type === 'success' ? <CheckCircle className="w-5 h-5 flex-shrink-0 mt-0.5" /> :
                        message.type === 'warning' ? <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" /> :
                            <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />}
                    <span className="whitespace-pre-line">{message.text}</span>
                </div>
            )}

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Step 1: Search & Select User */}
                <div className="bg-white rounded-lg shadow p-6">
                    <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                        <User className="w-5 h-5" />
                        1. Select User
                    </h2>

                    <div className="space-y-4">
                        {/* Search Box */}
                        <div className="flex gap-2">
                            <input
                                type="text"
                                placeholder="Search by email, name, phone..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
                                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                            />
                            <button
                                onClick={handleSearch}
                                disabled={loading}
                                className="px-4 py-2 bg-orange-500 text-white rounded-lg hover:bg-orange-600 disabled:bg-gray-400 flex items-center gap-2"
                            >
                                {loading ? <Loader className="w-5 h-5 animate-spin" /> : <Search className="w-5 h-5" />}
                            </button>
                        </div>

                        {/* Selected User Display */}
                        {selectedUser && (
                            <div className="p-4 bg-orange-50 border border-orange-200 rounded-lg">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <div className="font-medium text-gray-900">{selectedUser.full_name || 'N/A'}</div>
                                        <div className="text-sm text-gray-600">{selectedUser.email}</div>
                                        {selectedUser.phone_number && (
                                            <div className="text-xs text-gray-500 mt-1">📱 {selectedUser.phone_number}</div>
                                        )}
                                    </div>
                                    <button
                                        onClick={handleReset}
                                        className="text-sm text-orange-600 hover:text-orange-800"
                                    >
                                        Change
                                    </button>
                                </div>
                            </div>
                        )}

                        {/* User Search Results */}
                        {users.length > 0 && !selectedUser && (
                            <div className="border border-gray-200 rounded-lg max-h-80 overflow-y-auto">
                                {users.map((user) => (
                                    <div
                                        key={user.id}
                                        onClick={() => loadUserPolicies(user)}
                                        className="p-4 border-b border-gray-200 last:border-b-0 cursor-pointer hover:bg-gray-50 transition"
                                    >
                                        <div className="font-medium text-gray-900">{user.full_name || 'N/A'}</div>
                                        <div className="text-sm text-gray-600">{user.email}</div>
                                        {user.phone_number && (
                                            <div className="text-xs text-gray-500 mt-1">📱 {user.phone_number}</div>
                                        )}
                                    </div>
                                ))}
                            </div>
                        )}

                        {/* Empty State */}
                        {!selectedUser && users.length === 0 && !loading && (
                            <div className="text-center py-8 text-gray-500 text-sm">
                                🔍 Search for a user by email, name, or phone number
                            </div>
                        )}
                    </div>
                </div>

                {/* Step 2: Select Policy */}
                <div className="bg-white rounded-lg shadow p-6">
                    <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                        <Shield className="w-5 h-5" />
                        2. Select Policy
                    </h2>

                    <div className="space-y-4">
                        {loadingPolicies && (
                            <div className="flex items-center justify-center py-8">
                                <Loader className="w-6 h-6 animate-spin text-orange-500" />
                                <span className="ml-2 text-gray-600">Loading policies...</span>
                            </div>
                        )}

                        {/* Selected Policy Display */}
                        {selectedPolicy && (
                            <div className="p-4 bg-green-50 border border-green-200 rounded-lg">
                                <div className="text-xs font-semibold text-green-700 mb-1">✓ Selected Policy</div>
                                <div className="font-medium text-gray-900">{selectedPolicy.policy_number}</div>
                                <div className="text-sm text-gray-600">
                                    {selectedPolicy.device}
                                </div>
                                <div className="text-sm font-medium text-green-700 mt-2">
                                    Balance: Rp {parseFloat(selectedPolicy.policy_balance || 0).toLocaleString('id-ID')}
                                </div>
                                <div className="text-xs text-gray-500 mt-1">
                                    Tier: {selectedPolicy.tier_name} | Expires: {new Date(selectedPolicy.expiry_date).toLocaleDateString('id-ID')}
                                </div>
                            </div>
                        )}

                        {/* Policy List */}
                        {selectedUser && !selectedPolicy && userPolicies.length > 0 && (
                            <div className="border border-gray-200 rounded-lg max-h-80 overflow-y-auto">
                                {userPolicies.map((policy) => (
                                    <div
                                        key={policy.id}
                                        onClick={() => setSelectedPolicy(policy)}
                                        className="p-4 border-b border-gray-200 last:border-b-0 cursor-pointer hover:bg-gray-50 transition"
                                    >
                                        <div className="flex justify-between items-start">
                                            <div>
                                                <div className="font-medium text-gray-900">{policy.policy_number}</div>
                                                <div className="text-sm text-gray-600">
                                                    {policy.device}
                                                </div>
                                                <div className="text-xs text-gray-500 mt-1">
                                                    Tier: {policy.tier_name}
                                                </div>
                                            </div>
                                            <div className="text-right">
                                                <div className="text-sm font-medium text-green-700">
                                                    Rp {parseFloat(policy.policy_balance || 0).toLocaleString('id-ID')}
                                                </div>
                                                <div className="text-xs text-gray-500">Balance</div>
                                            </div>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}

                        {/* Empty States */}
                        {!selectedUser && (
                            <div className="text-center py-8 text-gray-500 text-sm">
                                👤 Select a user first to see their policies
                            </div>
                        )}

                        {selectedUser && !loadingPolicies && userPolicies.length === 0 && (
                            <div className="text-center py-8 text-yellow-600 text-sm">
                                ⚠️ This user has no active policies
                            </div>
                        )}
                    </div>
                </div>

                {/* Step 3: Claim Details */}
                <div className="bg-white rounded-lg shadow p-6">
                    <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
                        <FileText className="w-5 h-5" />
                        3. Claim Details
                    </h2>

                    <form onSubmit={handleSubmit} className="space-y-4">
                        {/* Damage Type */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Damage Type <span className="text-red-500">*</span>
                            </label>
                            <select
                                value={damageType}
                                onChange={(e) => setDamageType(e.target.value)}
                                required
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                            >
                                <option value="">-- Select Damage Type --</option>
                                {DAMAGE_TYPES.map((type) => (
                                    <option key={type} value={type}>{type}</option>
                                ))}
                            </select>
                        </div>

                        {/* Incident Date */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Incident Date <span className="text-red-500">*</span>
                            </label>
                            <input
                                type="date"
                                value={incidentDate}
                                onChange={(e) => setIncidentDate(e.target.value)}
                                max={new Date().toISOString().split('T')[0]}
                                required
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                            />
                        </div>

                        {/* Description */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Description
                            </label>
                            <textarea
                                value={damageDescription}
                                onChange={(e) => setDamageDescription(e.target.value)}
                                rows={2}
                                placeholder="Describe the damage..."
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                            />
                        </div>

                        {/* Reason */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Reason for Admin Submission
                            </label>
                            <input
                                type="text"
                                value={reason}
                                onChange={(e) => setReason(e.target.value)}
                                placeholder="User's phone is damaged..."
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-orange-500 focus:border-transparent"
                            />
                        </div>

                        {/* Photo Upload */}
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-2">
                                Damage Photos (Optional)
                            </label>
                            <input
                                type="file"
                                accept="image/*"
                                multiple
                                onChange={handlePhotoChange}
                                className="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-orange-100 file:text-orange-700 hover:file:bg-orange-200"
                            />

                            {photos.length > 0 && (
                                <div className="flex gap-2 mt-2 flex-wrap">
                                    {photos.map((photo, idx) => (
                                        <div key={idx} className="relative">
                                            <img
                                                src={URL.createObjectURL(photo)}
                                                alt={`Preview ${idx + 1}`}
                                                className="w-16 h-16 object-cover rounded border"
                                            />
                                            <button
                                                type="button"
                                                onClick={() => removePhoto(idx)}
                                                className="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs hover:bg-red-600"
                                            >
                                                ×
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={isSubmitting || !selectedUser || !selectedPolicy || !damageType || !incidentDate}
                            className="w-full py-3 bg-orange-500 text-white font-medium rounded-lg hover:bg-orange-600 disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center gap-2 transition-colors"
                        >
                            {isSubmitting ? (
                                <>
                                    <Loader className="w-5 h-5 animate-spin" />
                                    Submitting...
                                </>
                            ) : (
                                <>
                                    🆘 Submit Claim for User
                                </>
                            )}
                        </button>

                        {/* Helper Text */}
                        {!selectedUser && (
                            <div className="text-xs text-gray-500 text-center">
                                ⓘ Select a user first
                            </div>
                        )}
                        {selectedUser && !selectedPolicy && (
                            <div className="text-xs text-gray-500 text-center">
                                ⓘ Select a policy to continue
                            </div>
                        )}
                    </form>
                </div>
            </div>

            {/* Info Card */}
            <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h4 className="font-semibold text-blue-800 mb-2">ℹ️ How it works</h4>
                <ul className="text-sm text-blue-700 space-y-1">
                    <li>• Claims created here will have status <strong>Pending</strong> and need to be reviewed as usual.</li>
                    <li>• Claim number will have prefix <code className="bg-blue-100 px-1 rounded">CLM-ADM-</code> to indicate it was submitted by admin.</li>
                    <li>• Admin notes will record that this claim was submitted on behalf of the user.</li>
                </ul>
            </div>
        </div>
    );
};

export default AdminClaimCreatePage;
