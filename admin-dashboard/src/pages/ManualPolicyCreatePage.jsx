// src/pages/ManualPolicyCreatePage.jsx
import { useState, useEffect } from 'react';
import {
  Search,
  Shield,
  User,
  Smartphone,
  AlertCircle,
  CheckCircle,
  Loader
} from 'lucide-react';
import api from '../api/axios';

export default function ManualPolicyCreatePage() {
  const [users, setUsers] = useState([]);
  const [devices, setDevices] = useState([]);
  const [allDevices, setAllDevices] = useState([]);
  const [categories, setCategories] = useState([]);
  const [brands, setBrands] = useState([]);
  const [models, setModels] = useState([]);
  const [tiers, setTiers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [selectedCategory, setSelectedCategory] = useState('');
  const [selectedBrand, setSelectedBrand] = useState('');
  const [selectedModel, setSelectedModel] = useState('');
  const [selectedDevice, setSelectedDevice] = useState(null);
  const [imei, setImei] = useState('');
  const [purchasePrice, setPurchasePrice] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState(null);
  const [suggestedTier, setSuggestedTier] = useState(null);

  // Load tiers and devices on mount
  useEffect(() => {
    loadInitialData();
  }, []);

  const loadInitialData = async () => {
    try {
      // Load policy tiers
      const tiersResponse = await api.get('/policy-tiers/');
      setTiers(tiersResponse.data.filter(t => t.is_active));

      // Load all devices
      const devicesResponse = await api.get('/device-packages/');
      const activeDevices = devicesResponse.data.filter(d => d.is_active);
      setAllDevices(activeDevices);

      // Extract unique categories from devices
      const uniqueCategories = [...new Set(activeDevices.map(d => d.device_category))].sort();
      const categoryOptions = uniqueCategories.map(cat => ({
        value: cat,
        label: cat.charAt(0).toUpperCase() + cat.slice(1).replace('_', ' ')
      }));
      setCategories(categoryOptions);
    } catch (error) {
      console.error('Load error:', error);
    }
  };

  // Handle category selection
  const handleCategoryChange = (category) => {
    setSelectedCategory(category);
    setSelectedBrand('');
    setSelectedModel('');
    setSelectedDevice(null);
    setDevices([]);

    if (category) {
      // Get unique brands for selected category
      const filteredDevices = allDevices.filter(d => d.device_category === category);
      const uniqueBrands = [...new Set(filteredDevices.map(d => d.device_brand))].sort();
      setBrands(uniqueBrands);
    } else {
      setBrands([]);
    }
    setModels([]);
  };

  // Handle brand selection
  const handleBrandChange = (brand) => {
    setSelectedBrand(brand);
    setSelectedModel('');
    setSelectedDevice(null);
    setDevices([]);

    if (brand) {
      // Get unique models for selected category + brand
      const filteredDevices = allDevices.filter(
        d => d.device_category === selectedCategory && d.device_brand === brand
      );
      const uniqueModels = [...new Set(filteredDevices.map(d => d.device_model))].sort();
      setModels(uniqueModels);
    } else {
      setModels([]);
    }
  };

  // Handle model selection
  const handleModelChange = (model) => {
    setSelectedModel(model);
    setSelectedDevice(null);

    if (model) {
      // Show all variants of this category + brand + model
      const filteredDevices = allDevices.filter(
        d => d.device_category === selectedCategory &&
          d.device_brand === selectedBrand &&
          d.device_model === model
      );
      setDevices(filteredDevices);
    } else {
      setDevices([]);
    }
  };

  // Calculate suggested tier based on purchase price
  useEffect(() => {
    if (purchasePrice && tiers.length > 0) {
      const price = parseFloat(purchasePrice);
      if (!isNaN(price)) {
        const tier = tiers.find(
          t => price >= parseFloat(t.min_price) && price <= parseFloat(t.max_price)
        );
        setSuggestedTier(tier);
      } else {
        setSuggestedTier(null);
      }
    } else {
      setSuggestedTier(null);
    }
  }, [purchasePrice, tiers]);

  // Search users
  const handleSearch = async () => {
    if (!searchQuery.trim()) return;

    setLoading(true);
    try {
      const response = await api.get(`/admin/users/?search=${searchQuery}`);
      setUsers(response.data.results || response.data);
    } catch (error) {
      console.error('Search error:', error);
      setMessage({ type: 'error', text: 'Gagal mencari user' });
    } finally {
      setLoading(false);
    }
  };

  // Handle policy creation
  const handleCreatePolicy = async (e) => {
    e.preventDefault();

    if (!selectedUser) {
      setMessage({ type: 'error', text: 'Pilih user terlebih dahulu' });
      return;
    }

    if (!selectedDevice) {
      setMessage({ type: 'error', text: 'Pilih device terlebih dahulu' });
      return;
    }

    if (!imei || imei.length < 15) {
      setMessage({ type: 'error', text: 'IMEI harus 15 digit' });
      return;
    }

    if (!purchasePrice || parseFloat(purchasePrice) <= 0) {
      setMessage({ type: 'error', text: 'Purchase price harus valid' });
      return;
    }

    if (!suggestedTier) {
      setMessage({ type: 'error', text: 'Harga device tidak cocok dengan tier manapun' });
      return;
    }

    setSubmitting(true);
    setMessage(null);

    try {
      const response = await api.post('/admin/policies/manual-create/', {
        user_id: selectedUser.id,
        device_package_id: selectedDevice.id,
        imei_number: imei,
        purchase_price: purchasePrice,
      });

      const policyInfo = response.data.policy;
      setMessage({
        type: 'success',
        text: `✅ Berhasil membuat polis ${policyInfo.policy_number} untuk ${selectedUser.email}!\n\n` +
          `📱 Device: ${policyInfo.device}\n` +
          `🛡️ Tier: ${policyInfo.tier}\n` +
          `💰 Policy Balance: Rp ${policyInfo.purchase_price.toLocaleString()} (sesuai harga HP)\n` +
          `✅ Status: ${policyInfo.status}\n\n` +
          `ℹ️ Policy price (Rp ${policyInfo.policy_price.toLocaleString()}) TIDAK DIBAYAR - hanya info tier.`
      });

      // Reset form
      setImei('');
      setPurchasePrice('');
      setSelectedUser(null);
      setSelectedDevice(null);
      setUsers([]);
      setSearchQuery('');
      setSuggestedTier(null);

    } catch (error) {
      console.error('Policy creation error:', error);
      console.error('Error response:', error.response?.data);

      let errorMessage = 'Gagal membuat polis';
      if (error.response?.data?.error) {
        errorMessage = error.response.data.error;
      } else if (error.response?.data?.imei_number) {
        errorMessage = `IMEI Error: ${error.response.data.imei_number[0]}`;
      }

      setMessage({ type: 'error', text: errorMessage });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Create Policy (Auto Top-Up)</h1>
        <p className="text-gray-600 mt-1">Buat polis baru dengan otomatis set policy balance</p>

        {/* Info Box */}
        <div className="mt-4 bg-green-50 border border-green-200 rounded-lg p-4">
          <div className="flex gap-3">
            <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
            <div className="text-sm text-green-800">
              <p className="font-semibold mb-1">✅ Sistem Policy Balance Aktif</p>
              <p className="text-green-700">
                Ketika Anda membuat polis, sistem akan otomatis:
              </p>
              <ol className="list-decimal ml-4 mt-2 space-y-1 text-green-700">
                <li>Buat policy untuk user</li>
                <li><strong>Set policy balance = harga HP</strong> (setiap policy punya saldo sendiri)</li>
                <li>Policy price (300rb/400rb) <strong>TIDAK DIBAYAR</strong> - hanya info tier</li>
                <li>Claim akan dikurangi dari policy balance (bukan wallet)</li>
              </ol>
              <p className="mt-2 text-green-700">
                <strong>Contoh:</strong> Device Rp 5.000.000 → Policy dibuat → <strong className="text-green-700">Policy Balance: Rp 5.000.000</strong> → Claim Rp 500k → Policy Balance: Rp 4.500.000
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Message Alert */}
      {message && (
        <div className={`p-4 rounded-lg mb-6 flex items-center gap-2 ${message.type === 'success'
          ? 'bg-green-50 text-green-800 border border-green-200'
          : 'bg-red-50 text-red-800 border border-red-200'
          }`}>
          {message.type === 'success' ? (
            <CheckCircle className="w-5 h-5" />
          ) : (
            <AlertCircle className="w-5 h-5" />
          )}
          <span>{message.text}</span>
        </div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* User Search */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <User className="w-5 h-5" />
            Pilih User
          </h2>

          <div className="space-y-4">
            {/* Search Box */}
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="Cari email, nama, atau KTP..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
                className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              />
              <button
                onClick={handleSearch}
                disabled={loading}
                className="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:bg-gray-400 flex items-center gap-2"
              >
                {loading ? (
                  <Loader className="w-5 h-5 animate-spin" />
                ) : (
                  <Search className="w-5 h-5" />
                )}
              </button>
            </div>

            {/* Selected User Display */}
            {selectedUser && (
              <div className="p-3 bg-indigo-50 border border-indigo-200 rounded-lg">
                <div className="font-medium text-gray-900">{selectedUser.email}</div>
                <div className="text-sm text-gray-600">{selectedUser.full_name}</div>
                {selectedUser.ktp_number && (
                  <div className="text-xs text-gray-500 mt-1">
                    KTP: {selectedUser.ktp_number}
                  </div>
                )}
              </div>
            )}

            {/* User List */}
            {users.length > 0 && !selectedUser && (
              <div className="border border-gray-200 rounded-lg max-h-96 overflow-y-auto">
                {users.map((user) => (
                  <div
                    key={user.id}
                    onClick={() => setSelectedUser(user)}
                    className="p-4 border-b border-gray-200 last:border-b-0 cursor-pointer hover:bg-gray-50 transition"
                  >
                    <div className="font-medium text-gray-900">{user.email}</div>
                    <div className="text-sm text-gray-600">{user.full_name}</div>
                    {user.ktp_number && (
                      <div className="text-xs text-gray-500 mt-1">KTP: {user.ktp_number}</div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Device Selection */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Smartphone className="w-5 h-5" />
            Pilih Device
          </h2>

          <div className="space-y-4">
            {/* Step 1: Category Selection */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                1. Pilih Kategori
              </label>
              <select
                value={selectedCategory}
                onChange={(e) => handleCategoryChange(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              >
                <option value="">-- Pilih Kategori --</option>
                {categories.map((cat) => (
                  <option key={cat.value} value={cat.value}>
                    {cat.label}
                  </option>
                ))}
              </select>
            </div>

            {/* Step 2: Brand Selection */}
            {selectedCategory && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  2. Pilih Brand
                </label>
                <select
                  value={selectedBrand}
                  onChange={(e) => handleBrandChange(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                >
                  <option value="">-- Pilih Brand --</option>
                  {brands.map((brand) => (
                    <option key={brand} value={brand}>
                      {brand}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Step 3: Model Selection */}
            {selectedBrand && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  3. Pilih Model
                </label>
                <select
                  value={selectedModel}
                  onChange={(e) => handleModelChange(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
                >
                  <option value="">-- Pilih Model --</option>
                  {models.map((model) => (
                    <option key={model} value={model}>
                      {model}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {/* Step 4: Selected Device Display */}
            {selectedDevice && (
              <div className="p-3 bg-green-50 border border-green-200 rounded-lg">
                <div className="text-xs font-semibold text-green-700 mb-1">
                  ✓ Device Terpilih
                </div>
                <div className="font-medium text-gray-900">
                  {selectedDevice.device_brand} {selectedDevice.device_model}
                </div>
                <div className="text-sm text-gray-600">
                  {selectedDevice.device_variant} {selectedDevice.device_color && `• ${selectedDevice.device_color}`}
                </div>
                <div className="text-sm font-medium text-green-700 mt-1">
                  Rp {parseFloat(selectedDevice.device_value).toLocaleString('id-ID')}
                </div>
              </div>
            )}

            {/* Step 4: Variant List (if model selected) */}
            {selectedModel && devices.length > 0 && !selectedDevice && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  4. Pilih Variant & Warna
                </label>
                <div className="border border-gray-200 rounded-lg max-h-80 overflow-y-auto">
                  {devices.map((device) => (
                    <div
                      key={device.id}
                      onClick={() => {
                        setSelectedDevice(device);
                        setPurchasePrice(device.device_value);
                      }}
                      className="p-4 border-b border-gray-200 last:border-b-0 cursor-pointer hover:bg-gray-50 transition"
                    >
                      <div className="flex justify-between items-start">
                        <div>
                          <div className="font-medium text-gray-900">
                            {device.device_variant || 'Standard'}
                            {device.device_color && ` • ${device.device_color}`}
                          </div>
                          <div className="text-sm text-gray-600 mt-1">
                            {device.device_brand} {device.device_model}
                          </div>
                        </div>
                        <div className="text-sm font-medium text-indigo-700 text-right">
                          Rp {parseFloat(device.device_value).toLocaleString('id-ID')}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Empty State */}
            {!selectedCategory && (
              <div className="text-center py-8 text-gray-500 text-sm">
                📱 Mulai dengan memilih kategori device
              </div>
            )}
          </div>
        </div>

        {/* Policy Form */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <Shield className="w-5 h-5" />
            Detail Polis
          </h2>

          <form onSubmit={handleCreatePolicy} className="space-y-4">
            {/* IMEI */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                IMEI Number (15 digit)
              </label>
              <input
                type="text"
                value={imei}
                onChange={(e) => {
                  const value = e.target.value.replace(/[^0-9]/g, '');
                  if (value.length <= 15) setImei(value);
                }}
                placeholder="123456789012345"
                required
                maxLength={15}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              />
              <div className="mt-1 text-xs text-gray-500">
                {imei.length}/15 digit
              </div>
            </div>

            {/* Purchase Price */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Purchase Price (Rp)
              </label>
              <input
                type="text"
                value={purchasePrice}
                onChange={(e) => {
                  const value = e.target.value.replace(/[^0-9]/g, '');
                  setPurchasePrice(value);
                }}
                placeholder="5000000"
                required
                disabled={selectedDevice}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed"
              />
              {purchasePrice && (
                <div className="mt-1 text-sm text-gray-600">
                  = Rp {parseInt(purchasePrice).toLocaleString('id-ID')}
                </div>
              )}
              {selectedDevice && (
                <div className="mt-1 text-xs text-green-600">
                  ✓ Auto-filled from selected device
                </div>
              )}
            </div>

            {/* Suggested Tier Display */}
            {suggestedTier && (
              <div className="p-4 bg-indigo-50 border border-indigo-200 rounded-lg">
                <div className="text-sm font-medium text-gray-700 mb-1">
                  Tier yang Cocok:
                </div>
                <div className="text-lg font-bold text-indigo-700">
                  {suggestedTier.tier_name}
                </div>
                <div className="text-sm text-gray-600 mt-2">
                  Policy Price: Rp {parseFloat(suggestedTier.policy_price).toLocaleString('id-ID')}
                </div>
                <div className="text-sm text-gray-600">
                  Duration: 1 Year (Auto-Expire)
                </div>
                <div className="text-sm text-green-600 font-medium">
                  ✓ Unlimited Claims (Policy Balance-Based)
                </div>
              </div>
            )}

            {purchasePrice && !suggestedTier && (
              <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
                <div className="text-sm text-yellow-800">
                  ⚠️ Harga device tidak sesuai dengan tier manapun
                </div>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={submitting || !selectedUser || !selectedDevice || !imei || !purchasePrice || !suggestedTier}
              className="w-full py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center gap-2 transition-colors"
            >
              {submitting ? (
                <>
                  <Loader className="w-5 h-5 animate-spin" />
                  Creating...
                </>
              ) : (
                <>
                  <Shield className="w-5 h-5" />
                  Buat Polis Sekarang
                </>
              )}
            </button>

            {/* Button Helper Text */}
            {!selectedUser && (
              <div className="text-xs text-gray-500 text-center">
                ⓘ Pilih user terlebih dahulu
              </div>
            )}
            {selectedUser && !selectedDevice && (
              <div className="text-xs text-gray-500 text-center">
                ⓘ Pilih device terlebih dahulu
              </div>
            )}
            {selectedUser && selectedDevice && !imei && (
              <div className="text-xs text-gray-500 text-center">
                ⓘ Masukkan IMEI terlebih dahulu
              </div>
            )}
            {selectedUser && selectedDevice && imei && !suggestedTier && (
              <div className="text-xs text-yellow-600 text-center">
                ⚠️ Harga device tidak sesuai tier manapun
              </div>
            )}
          </form>
        </div>
      </div>

      {/* Tier Reference Table */}
      <div className="mt-6 bg-white rounded-lg shadow p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Referensi Tier Polis</h3>
          <div className="text-sm text-green-600 font-medium bg-green-50 px-3 py-1 rounded-full">
            ✓ Unlimited Claims (Policy Balance-Based System)
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Tier
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Price Range
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Policy Price
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Duration
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {tiers.map((tier) => (
                <tr key={tier.id}>
                  <td className="px-6 py-4 whitespace-nowrap font-medium text-gray-900">
                    {tier.tier_name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    Rp {parseFloat(tier.min_price).toLocaleString('id-ID')} -
                    Rp {parseFloat(tier.max_price).toLocaleString('id-ID')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    Rp {parseFloat(tier.policy_price).toLocaleString('id-ID')}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
                    1 Year (Auto-Expire)
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
