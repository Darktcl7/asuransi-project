import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/adminService';
import { TableSkeleton } from '../components/LoadingSkeleton';
import { Plus, Edit2, Trash2, X } from 'lucide-react';

const DevicesPage = () => {
  const queryClient = useQueryClient();
  const [selectedCategory, setSelectedCategory] = useState('');
  const [search, setSearch] = useState('');
  const [showModal, setShowModal] = useState(false);
  const [editDevice, setEditDevice] = useState(null);

  // Fetch devices
  const { data: devices, isLoading } = useQuery({
    queryKey: ['devices', selectedCategory, search],
    queryFn: () => adminService.getDevices({ category: selectedCategory, search }),
    staleTime: 30000,
  });

  // Fetch categories
  const { data: categories } = useQuery({
    queryKey: ['device-categories'],
    queryFn: () => adminService.getDeviceCategories(),
    staleTime: 300000,
  });

  // Create/Update mutation
  const saveMutation = useMutation({
    mutationFn: (device) => {
      if (device.id) {
        return adminService.updateDevice(device.id, device);
      }
      return adminService.createDevice(device);
    },
    onSuccess: () => {
      queryClient.invalidateQueries(['devices']);
      setShowModal(false);
      setEditDevice(null);
    },
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id) => adminService.deleteDevice(id),
    onSuccess: () => {
      queryClient.invalidateQueries(['devices']);
    },
  });

  const handleEdit = (device) => {
    setEditDevice(device);
    setShowModal(true);
  };

  const handleDelete = (id) => {
    if (window.confirm('Are you sure you want to delete this device?')) {
      deleteMutation.mutate(id);
    }
  };

  const formatCurrency = (value) => {
    return `Rp ${Number(value).toLocaleString('id-ID')}`;
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold text-gray-800">Device Management</h2>
          <p className="text-gray-600">Manage handphone, elektronik, laptop, dll</p>
        </div>
        <button
          onClick={() => {
            setEditDevice(null);
            setShowModal(true);
          }}
          className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg flex items-center gap-2"
        >
          <Plus className="w-5 h-5" />
          Add Device
        </button>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-xl shadow-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Category Filter */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Filter by Category</label>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
            >
              <option value="">All Categories</option>
              {categories?.map((cat) => (
                <option key={cat.value} value={cat.value}>
                  {cat.label}
                </option>
              ))}
            </select>
          </div>

          {/* Search */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Search</label>
            <input
              type="text"
              placeholder="Search by brand or model..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
            />
          </div>
        </div>
      </div>

      {/* Table */}
      <div className="bg-white rounded-xl shadow-lg overflow-hidden">
        {isLoading ? (
          <TableSkeleton rows={10} columns={6} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Category</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Brand</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Model</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Variant</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Color</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Price</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {devices?.map((device) => (
                  <tr key={device.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                        {device.category_display}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {device.device_brand}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {device.device_model}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {device.device_variant || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      {device.device_color || '-'}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900">
                      {formatCurrency(device.device_value)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                        device.is_active ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'
                      }`}>
                        {device.is_active ? 'Active' : 'Inactive'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm">
                      <div className="flex gap-2">
                        <button
                          onClick={() => handleEdit(device)}
                          className="text-indigo-600 hover:text-indigo-900"
                        >
                          <Edit2 className="w-4 h-4" />
                        </button>
                        <button
                          onClick={() => handleDelete(device.id)}
                          className="text-red-600 hover:text-red-900"
                        >
                          <Trash2 className="w-4 h-4" />
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

      {/* Add/Edit Modal */}
      {showModal && (
        <DeviceModal
          device={editDevice}
          categories={categories}
          onSave={(device) => saveMutation.mutate(device)}
          onClose={() => {
            setShowModal(false);
            setEditDevice(null);
          }}
          isLoading={saveMutation.isLoading}
        />
      )}
    </div>
  );
};

// Device Modal Component
const DeviceModal = ({ device, categories, onSave, onClose, isLoading }) => {
  const [formData, setFormData] = useState({
    device_category: device?.device_category || 'handphone',
    device_brand: device?.device_brand || '',
    device_model: device?.device_model || '',
    device_variant: device?.device_variant || '',
    device_color: device?.device_color || '',
    device_value: device?.device_value || '',
    is_active: device?.is_active ?? true,
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    const payload = device ? { ...formData, id: device.id } : formData;
    onSave(payload);
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full mx-4 max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="flex justify-between items-center p-6 border-b">
          <h3 className="text-xl font-bold text-gray-800">
            {device ? 'Edit Device' : 'Add New Device'}
          </h3>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Form */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Category */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Category *
            </label>
            <select
              value={formData.device_category}
              onChange={(e) => setFormData({ ...formData, device_category: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
              required
            >
              {categories?.map((cat) => (
                <option key={cat.value} value={cat.value}>
                  {cat.label}
                </option>
              ))}
            </select>
          </div>

          {/* Brand */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Brand *
            </label>
            <input
              type="text"
              value={formData.device_brand}
              onChange={(e) => setFormData({ ...formData, device_brand: e.target.value })}
              placeholder="e.g., Samsung, Apple, HP, Canon"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>

          {/* Model */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Model *
            </label>
            <input
              type="text"
              value={formData.device_model}
              onChange={(e) => setFormData({ ...formData, device_model: e.target.value })}
              placeholder="e.g., Galaxy A54, iPhone 14 Pro, Thinkpad X1"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>

          {/* Variant */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Variant (Optional)
            </label>
            <input
              type="text"
              value={formData.device_variant}
              onChange={(e) => setFormData({ ...formData, device_variant: e.target.value })}
              placeholder="e.g., 8+256, 12+512, 16+1TB"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
            />
            <p className="text-xs text-gray-500 mt-1">Format: RAM+Storage (contoh: 8+256)</p>
          </div>

          {/* Color */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Warna (Optional)
            </label>
            <input
              type="text"
              value={formData.device_color}
              onChange={(e) => setFormData({ ...formData, device_color: e.target.value })}
              placeholder="e.g., Hitam, Putih, Biru, Silver"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          {/* Price */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Price (Rp) *
            </label>
            <input
              type="number"
              value={formData.device_value}
              onChange={(e) => setFormData({ ...formData, device_value: e.target.value })}
              placeholder="e.g., 4999000"
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500"
              required
            />
          </div>

          {/* Status */}
          <div className="flex items-center">
            <input
              type="checkbox"
              checked={formData.is_active}
              onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
            />
            <label className="ml-2 text-sm text-gray-700">
              Active (device available for policy creation)
            </label>
          </div>

          {/* Buttons */}
          <div className="flex gap-3 pt-4">
            <button
              type="submit"
              disabled={isLoading}
              className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-lg font-medium disabled:opacity-50"
            >
              {isLoading ? 'Saving...' : device ? 'Update Device' : 'Create Device'}
            </button>
            <button
              type="button"
              onClick={onClose}
              className="flex-1 bg-gray-200 hover:bg-gray-300 text-gray-800 px-4 py-2 rounded-lg font-medium"
            >
              Cancel
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default DevicesPage;
