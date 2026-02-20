// lib/screens/admin/admin_stores_screen.dart

import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';

class AdminStoresScreen extends StatefulWidget {
  const AdminStoresScreen({super.key});

  @override
  State<AdminStoresScreen> createState() => _AdminStoresScreenState();
}

class _AdminStoresScreenState extends State<AdminStoresScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _stores = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      print('DEBUG: Token loaded, fetching stores...');
      final stores = await _apiService.getAdminStores(search: _searchQuery);
      print('DEBUG: Got ${stores.length} stores');
      setState(() {
        _stores = stores;
      });
    } catch (e) {
      print('DEBUG STORE ERROR: $e');
      SnackbarHelper.showError(context, 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Manajemen Toko', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => _showStoreForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _stores.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchStores,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _stores.length,
                          itemBuilder: (context, index) {
                            final store = _stores[index];
                            return _buildEnhancedStoreCard(store);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _fetchStores();
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Cari nama atau kode toko...',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          fillColor: Colors.white.withOpacity(0.2),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStoreCard(Map<String, dynamic> store) {
    final bool isActive = store['is_active'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: isActive ? Colors.indigo.shade50 : Colors.red.shade50,
              child: Icon(Icons.store, color: isActive ? Colors.indigo : Colors.red),
            ),
            title: Text(
              store['name'] ?? 'Toko Tanpa Nama',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('Kode Toko: ${store['code'] ?? '-'} | ${store['city'] ?? '-'}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                isActive ? 'AKTIF' : 'NONAKTIF',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.dashboard_outlined, size: 18),
                    label: const Text('DASHBOARD'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/admin-store-detail', arguments: store);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.indigo),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.settings_outlined, size: 18),
                    label: const Text('KELOLA'),
                    onPressed: () => _showStoreActions(store),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreActions(Map<String, dynamic> store) {
    final bool isActive = store['is_active'] ?? false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              Text(store['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Kode: ${store['code'] ?? '-'}', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              const SizedBox(height: 20),
              _buildActionTile(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                title: 'Edit Informasi Toko',
                onTap: () {
                  Navigator.pop(context);
                  _showStoreForm(store: store);
                },
              ),
              _buildActionTile(
                icon: isActive ? Icons.power_settings_new : Icons.play_circle_outline,
                color: isActive ? Colors.orange : Colors.green,
                title: isActive ? 'Non-aktifkan Toko' : 'Aktifkan Kembali',
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    title: isActive ? 'Non-aktifkan Toko' : 'Aktifkan Toko',
                    message: 'Aplikasi di toko ini tidak akan bisa digunakan jika dinonaktifkan.',
                    isDanger: isActive,
                    onConfirm: (password) async {
                      try {
                        await _apiService.updateAdminStore(store['id'], {
                          'is_active': !isActive,
                          'password': password,
                        });
                        SnackbarHelper.showSuccess(context, 'Status toko berhasil diubah');
                        _fetchStores();
                      } catch (e) {
                        SnackbarHelper.showError(context, 'Gagal: $e');
                      }
                    },
                  );
                },
              ),
              _buildActionTile(
                icon: Icons.refresh_rounded,
                color: Colors.purple,
                title: 'Reset Data (Hapus Customer)',
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    title: 'RESET DATA TOKO',
                    message: 'PERINGATAN: Semua data CUSTOMER di toko ini akan dihapus secara permanen!',
                    isDanger: true,
                    onConfirm: (password) async {
                      try {
                        await _apiService.resetStoreData(store['id'], password: password);
                        SnackbarHelper.showSuccess(context, 'Data toko berhasil di-reset');
                        _fetchStores();
                      } catch (e) {
                        SnackbarHelper.showError(context, 'Gagal: $e');
                      }
                    },
                  );
                },
              ),
              const Divider(indent: 20, endIndent: 20),
              _buildActionTile(
                icon: Icons.delete_forever_outlined,
                color: Colors.red,
                title: 'Hapus Toko Permanen',
                onTap: () {
                  Navigator.pop(context);
                  _confirmAction(
                    title: 'HAPUS PERMANEN',
                    message: 'Apakah Anda yakin ingin menghapus toko ini dari sistem selamanya?',
                    isDanger: true,
                    onConfirm: (password) async {
                      try {
                        await _apiService.deleteAdminStore(store['id'], password: password, permanent: true);
                        SnackbarHelper.showSuccess(context, 'Toko telah dihapus permanen');
                        _fetchStores();
                      } catch (e) {
                        SnackbarHelper.showError(context, 'Gagal: $e');
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({required IconData icon, required Color color, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: color == Colors.red ? Colors.red : Colors.black87)),
      onTap: onTap,
    );
  }

  void _showStoreForm({Map<String, dynamic>? store}) {
    final isEdit = store != null;
    final nameController = TextEditingController(text: store?['name'] ?? '');
    final codeController = TextEditingController(text: store?['code'] ?? '');

    final addressController = TextEditingController(text: store?['address'] ?? '');
    final cityController = TextEditingController(text: store?['city'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.add_business, color: Colors.indigo, size: 24),
            const SizedBox(width: 8),
            Text(isEdit ? 'Edit Toko' : 'Tambah Toko Baru', style: const TextStyle(fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildFormField(nameController, 'Nama Toko', Icons.store),
              const SizedBox(height: 12),
              _buildFormField(codeController, 'Kode Toko', Icons.vpn_key_outlined),
              const SizedBox(height: 12),
              _buildFormField(cityController, 'Kota', Icons.location_city),
              const SizedBox(height: 12),
              _buildFormField(addressController, 'Alamat Lengkap', Icons.location_on, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: Icon(isEdit ? Icons.save : Icons.add, size: 18),
            label: Text(isEdit ? 'Simpan' : 'Tambah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                SnackbarHelper.showError(context, 'Nama toko wajib diisi');
                return;
              }
              try {
                final data = {
                  'name': nameController.text.trim(),
                  'code': codeController.text.trim(),
                  'address': addressController.text.trim(),
                  'city': cityController.text.trim(),
                };
                if (isEdit) {
                  await _apiService.updateAdminStore(store['id'], data);
                  SnackbarHelper.showSuccess(context, 'Toko berhasil diperbarui');
                } else {
                  await _apiService.createAdminStore(data);
                  SnackbarHelper.showSuccess(context, 'Toko berhasil ditambahkan');
                }
                Navigator.pop(context);
                _fetchStores();
              } catch (e) {
                SnackbarHelper.showError(context, 'Gagal: $e');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(TextEditingController controller, String label, IconData icon, {bool enabled = true, int maxLines = 1}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: !enabled,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }

  void _confirmAction({required String title, required String message, required Function(String password) onConfirm, bool isDanger = false}) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: TextStyle(color: isDanger ? Colors.red : Colors.indigo, fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            const Text('Masukkan Password Admin untuk konfirmasi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password Admin',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger ? Colors.red : Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (passwordController.text.trim().isEmpty) {
                SnackbarHelper.showError(context, 'Password wajib diisi');
                return;
              }
              Navigator.pop(context);
              onConfirm(passwordController.text);
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('Tidak ada toko ditemukan'));
  }
}
