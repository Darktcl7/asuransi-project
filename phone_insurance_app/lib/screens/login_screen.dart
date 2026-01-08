// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/biometric_service.dart';
import '../utils/snackbar_helper.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final BiometricService _biometricService = BiometricService();
  
  // Controller for email OR phone number
  final _identifierController = TextEditingController(); 
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  Future<void> _saveCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  Future<Map<String, String>?> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');
      
      if (email != null && password != null) {
        return {'email': email, 'password': password};
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      // Panggil API Service Login (support email OR phone)
      await _apiService.login(
        identifier: _identifierController.text.trim(), 
        password: _passwordController.text,
      );

      // Save credentials untuk biometric login
      await _saveCredentials(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      // Jika sukses, navigasi ke Dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context, 
          'Login Gagal: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loginWithBiometric() async {
    // Show loading
    setState(() => _isLoading = true);
    
    try {
      // Authenticate dengan fingerprint
      final authenticated = await _biometricService.authenticate(
        reason: 'Login ke Smile by SPC',
      );
      
      if (!authenticated) {
        if (mounted) {
          SnackbarHelper.showError(context, 'Autentikasi gagal');
          setState(() => _isLoading = false);
        }
        return;
      }

      // Load saved credentials
      final credentials = await _loadCredentials();
      
      if (credentials == null) {
        if (mounted) {
          SnackbarHelper.showWarning(
            context, 
            'Belum ada kredensial tersimpan. Login manual terlebih dahulu.',
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Login dengan saved credentials
      await _apiService.login(
        identifier: credentials['email']!,
        password: credentials['password']!,
      );

      // Navigate ke dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Login gagal: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('😊 ', style: TextStyle(fontSize: 20)),
            const Text('Smile by SPC'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Smile
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '😊',
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Brand Name
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Smile',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade600,
                        ),
                      ),
                      TextSpan(
                        text: ' by ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextSpan(
                        text: 'SPC',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Insurance Protection',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo.shade600,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk ke akun Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Email or Phone Number Field
                TextFormField(
                  controller: _identifierController,
                  decoration: InputDecoration(
                    labelText: 'Email atau Nomor HP',
                    hintText: 'contoh: user@email.com atau 08123456789',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person),
                    helperText: 'Masukkan email atau nomor HP Anda',
                    helperStyle: const TextStyle(fontSize: 11),
                  ),
                  keyboardType: TextInputType.text, // Accept both email and phone
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email atau nomor HP wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'Password wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Biometric Login (tampil jika device support)
                if (_biometricAvailable) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'atau',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : _loginWithBiometric,
                          icon: const Icon(Icons.fingerprint, size: 48),
                          color: Colors.indigo,
                          tooltip: 'Login dengan Biometric',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Login dengan Fingerprint',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}