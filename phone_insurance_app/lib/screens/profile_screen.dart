import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.init();
      final userJson = await _apiService.getUserProfile();
      
      setState(() {
        _user = User.fromJson(userJson);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memuat profil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear auth token
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      
      if (mounted) {
        // Navigate to login and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda berhasil logout'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('😊 ', style: TextStyle(fontSize: 18)),
            const Text('Profil Saya'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            
            const SizedBox(height: 8),

            // User Information Section
            _buildSection(
              title: 'Informasi Pengguna',
              children: [
                _buildInfoTile(
                  icon: Icons.person,
                  label: 'Nama Lengkap',
                  value: _user?.fullName ?? '-',
                  color: Colors.indigo,
                ),
                _buildInfoTile(
                  icon: Icons.email,
                  label: 'Email',
                  value: _user?.email ?? '-',
                  color: Colors.blue,
                ),
                _buildInfoTile(
                  icon: Icons.phone,
                  label: 'Nomor Telepon',
                  value: _user?.phoneNumber ?? '-',
                  color: Colors.orange,
                ),
                _buildInfoTile(
                  icon: Icons.store,
                  label: 'Toko Terdaftar',
                  value: _user?.storeName != null 
                    ? '${_user!.storeName} (${_user!.storeCode})' 
                    : '-',
                  color: Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // App Information Section
            _buildSection(
              title: 'Tentang Aplikasi',
              children: [
                _buildActionTile(
                  icon: Icons.info_outline,
                  label: 'Tentang Smile by SPC',
                  color: Colors.orange,
                  onTap: () => _showAboutDialog(),
                ),
                _buildActionTile(
                  icon: Icons.help_outline,
                  label: 'Bantuan & FAQ',
                  color: Colors.purple,
                  onTap: () => _showHelpDialog(),
                ),
                _buildActionTile(
                  icon: Icons.description_outlined,
                  label: 'Syarat & Ketentuan',
                  color: Colors.teal,
                  onTap: () => _showTermsDialog(),
                ),
                _buildActionTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Kebijakan Privasi',
                  color: Colors.cyan,
                  onTap: () => _showPrivacyDialog(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // App Version
            _buildSection(
              title: 'Versi',
              children: [
                _buildInfoTile(
                  icon: Icons.phone_android,
                  label: 'Versi Aplikasi',
                  value: '1.0.2',
                  color: Colors.blueGrey,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'LOGOUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade500, Colors.deepOrange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.orange.shade700,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            _user?.fullName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Email
          Text(
            _user?.email ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('😊', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Text('Smile by SPC'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Versi 1.0.2',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Smile by SPC adalah aplikasi asuransi ponsel yang melindungi device Anda dari kerusakan dengan sistem klaim yang mudah dan cepat.',
              ),
              SizedBox(height: 16),
              Text(
                'Fitur Utama:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Perlindungan 3 tier (Standar, Gold, Premium)'),
              Text('• 19 device brand ternama'),
              Text('• Klaim mudah dengan approval cepat'),
              Text('• Policy balance per device'),
              SizedBox(height: 16),
              Text(
                '© 2026 Smile by SPC\nAll rights reserved.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '❓ Bagaimana cara mendapatkan polis?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Pembuatan polis dikelola oleh admin. Silakan hubungi admin untuk dibuatkan polis asuransi sesuai device Anda.'),
              SizedBox(height: 16),
              
              Text(
                '❓ Bagaimana cara ajukan klaim?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('1. Pilih "Ajukan Klaim" di dashboard\n2. Pilih polis yang aktif\n3. Isi detail kerusakan\n4. Submit dan tunggu review admin'),
              SizedBox(height: 16),
              
              Text(
                '❓ Berapa lama proses klaim?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Admin akan review klaim Anda dalam 1-2 hari kerja. Status dapat dilihat di Riwayat Klaim.'),
              SizedBox(height: 16),
              
              Text(
                '📞 Perlu bantuan lebih lanjut?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Email: chluik277@gmail.com\nWhatsApp: +62 xxx-xxxx-xxxx'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Syarat & Ketentuan'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Syarat & Ketentuan Asuransi Smile by SPC',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              
              Text(
                '1. Ketentuan Umum',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Polis berlaku untuk 365 hari sejak aktivasi\n• Device harus dalam kondisi baik saat pendaftaran\n• IMEI harus valid dan terdaftar'),
              SizedBox(height: 12),
              
              Text(
                '2. Cakupan Asuransi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Kerusakan fisik (layar, LCD, body)\n• Kerusakan komponen (baterai, kamera, port)\n• Kerusakan akibat air\n• Kehilangan (dengan bukti laporan polisi)'),
              SizedBox(height: 12),
              
              Text(
                '3. Tidak Ditanggung',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Kerusakan software\n• Kerusakan akibat modifikasi\n• Kehilangan tanpa bukti\n• Kerusakan di luar masa polis'),
              SizedBox(height: 12),
              
              Text(
                '4. Proses Klaim',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Laporan klaim maksimal 7 hari sejak kejadian\n• Admin review dalam 1-2 hari kerja\n• Potongan sesuai tier berlaku\n• Maksimal klaim sesuai tier per tahun'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Saya Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kebijakan Privasi Smile by SPC',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              
              Text(
                '1. Data yang Kami Kumpulkan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Informasi pribadi (nama, email, nomor HP, alamat)\n• Informasi device (IMEI, brand, model)\n• Riwayat transaksi dan klaim\n• Data pembayaran'),
              SizedBox(height: 12),
              
              Text(
                '2. Penggunaan Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Verifikasi identitas pengguna\n• Proses klaim dan pembayaran\n• Komunikasi terkait polis & klaim\n• Peningkatan layanan'),
              SizedBox(height: 12),
              
              Text(
                '3. Keamanan Data',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Data dienkripsi dengan standar industri\n• Akses terbatas hanya untuk authorized personnel\n• Backup data secara berkala\n• Tidak dibagikan ke pihak ketiga'),
              SizedBox(height: 12),
              
              Text(
                '4. Hak Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Akses data pribadi Anda\n• Request penghapusan data\n• Update informasi pribadi\n• Withdraw consent'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }
}
