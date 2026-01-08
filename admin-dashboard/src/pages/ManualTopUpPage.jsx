// src/pages/ManualTopUpPage.jsx
import { useState, useEffect } from 'react';
import { 
  Search, 
  DollarSign, 
  User, 
  AlertCircle,
  CheckCircle,
  Loader
} from 'lucide-react';
import api from '../api/axios';

export default function ManualTopUpPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [amount, setAmount] = useState('');
  const [paymentMethod, setPaymentMethod] = useState('admin_topup');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState(null);

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

  // Handle top-up submission
  const handleTopUp = async (e) => {
    e.preventDefault();
    
    if (!selectedUser) {
      setMessage({ type: 'error', text: 'Pilih user terlebih dahulu' });
      return;
    }

    if (!amount || parseInt(amount) <= 0) {
      setMessage({ type: 'error', text: 'Masukkan jumlah yang valid' });
      return;
    }

    setSubmitting(true);
    setMessage(null);

    try {
      // Create top-up transaction for the user
      // Send as string to avoid JavaScript number precision issues
      const response = await api.post('/admin/topups/', {
        user: selectedUser.id,
        amount: amount, // Send as string, backend will convert to Decimal
        payment_method: paymentMethod,
        notes: notes || `Manual top-up by admin`,
        status: 'completed' // Auto-complete for admin top-ups
      });

      setMessage({ 
        type: 'success', 
        text: `Berhasil top-up Rp ${parseInt(amount).toLocaleString('id-ID')} ke ${selectedUser.email}` 
      });

      // Reset form
      setAmount('');
      setNotes('');
      setSelectedUser(null);
      setUsers([]);
      setSearchQuery('');

    } catch (error) {
      console.error('Top-up error:', error);
      console.error('Error response:', error.response?.data);
      setMessage({ 
        type: 'error', 
        text: error.response?.data?.error || error.response?.data?.message || 'Gagal melakukan top-up' 
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-800">Manual Top-Up</h1>
        <p className="text-gray-600 mt-1">Top-up saldo user secara manual</p>
      </div>

      {/* Message Alert */}
      {message && (
        <div className={`p-4 rounded-lg mb-6 flex items-center gap-2 ${
          message.type === 'success' 
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

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* User Search */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <User className="w-5 h-5" />
            Cari User
          </h2>

          <div className="space-y-4">
            {/* Search Box */}
            <div className="flex gap-2">
              <input
                type="text"
                placeholder="Cari email atau nama..."
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
                Cari
              </button>
            </div>

            {/* User List */}
            {users.length > 0 && (
              <div className="border border-gray-200 rounded-lg max-h-96 overflow-y-auto">
                {users.map((user) => (
                  <div
                    key={user.id}
                    onClick={() => setSelectedUser(user)}
                    className={`p-4 border-b border-gray-200 last:border-b-0 cursor-pointer hover:bg-gray-50 transition ${
                      selectedUser?.id === user.id ? 'bg-indigo-50 border-l-4 border-l-indigo-600' : ''
                    }`}
                  >
                    <div className="font-medium text-gray-900">{user.email}</div>
                    <div className="text-sm text-gray-600">
                      {user.first_name} {user.last_name}
                    </div>
                    <div className="text-sm text-gray-500">
                      Phone: {user.phone_number || '-'}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* Top-Up Form */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold mb-4 flex items-center gap-2">
            <DollarSign className="w-5 h-5" />
            Form Top-Up
          </h2>

          <form onSubmit={handleTopUp} className="space-y-4">
            {/* Selected User */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                User Dipilih
              </label>
              <div className={`p-3 rounded-lg border ${
                selectedUser 
                  ? 'bg-indigo-50 border-indigo-200' 
                  : 'bg-gray-50 border-gray-200'
              }`}>
                {selectedUser ? (
                  <div>
                    <div className="font-medium text-gray-900">{selectedUser.email}</div>
                    <div className="text-sm text-gray-600">
                      {selectedUser.first_name} {selectedUser.last_name}
                    </div>
                  </div>
                ) : (
                  <div className="text-gray-500 text-sm">Belum ada user dipilih</div>
                )}
              </div>
            </div>

            {/* Amount */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Jumlah Top-Up (Rp)
              </label>
              <input
                type="text"
                value={amount}
                onChange={(e) => {
                  // Only allow numbers
                  const value = e.target.value.replace(/[^0-9]/g, '');
                  setAmount(value);
                }}
                placeholder="100000"
                required
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              />
              {amount && (
                <div className="mt-1 text-sm text-gray-600">
                  = Rp {parseInt(amount).toLocaleString('id-ID')}
                </div>
              )}
            </div>

            {/* Payment Method */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Metode Pembayaran
              </label>
              <select
                value={paymentMethod}
                onChange={(e) => setPaymentMethod(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              >
                <option value="admin_topup">Admin Top-Up</option>
                <option value="bank_transfer">Bank Transfer</option>
                <option value="cash">Cash</option>
                <option value="ewallet">E-Wallet</option>
              </select>
            </div>

            {/* Notes */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Catatan (Opsional)
              </label>
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Catatan admin..."
                rows="3"
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
              />
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={submitting || !selectedUser}
              className="w-full py-3 bg-indigo-600 text-white font-medium rounded-lg hover:bg-indigo-700 disabled:bg-gray-400 disabled:cursor-not-allowed flex items-center justify-center gap-2"
            >
              {submitting ? (
                <>
                  <Loader className="w-5 h-5 animate-spin" />
                  Processing...
                </>
              ) : (
                <>
                  <DollarSign className="w-5 h-5" />
                  Top-Up Sekarang
                </>
              )}
            </button>
          </form>
        </div>
      </div>

      {/* Quick Amount Buttons */}
      <div className="mt-6 bg-white rounded-lg shadow p-6">
        <h3 className="text-sm font-medium text-gray-700 mb-3">Quick Amount:</h3>
        <div className="flex flex-wrap gap-2">
          {[50000, 100000, 200000, 500000, 1000000, 2000000].map((amt) => (
            <button
              key={amt}
              onClick={() => setAmount(amt.toString())}
              className="px-4 py-2 bg-gray-100 hover:bg-indigo-100 text-gray-700 hover:text-indigo-700 rounded-lg transition"
            >
              Rp {amt.toLocaleString('id-ID')}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
