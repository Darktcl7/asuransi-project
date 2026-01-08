import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/password-reset/request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': _identifierController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success - OTP sent
        if (mounted) {
          // Show success message
          SnackbarHelper.showSuccess(
            context,
            data['message'] ?? 'Kode OTP telah dikirim',
          );

          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOTPScreen(
                identifier: _identifierController.text.trim(),
                method: data['method'] ?? 'email',
                sentTo: data['sent_to'] ?? '',
              ),
            ),
          );
        }
      } else if (response.statusCode == 501) {
        // SMS not implemented
        if (mounted) {
          SnackbarHelper.showWarning(
            context,
            data['error'] ?? 'SMS OTP belum tersedia',
          );
          if (data['suggestion'] != null) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                SnackbarHelper.showInfo(context, data['suggestion']);
              }
            });
          }
        }
      } else {
        // Error
        if (mounted) {
          SnackbarHelper.showError(
            context,
            data['error'] ?? 'Gagal mengirim OTP',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context,
          'Terjadi kesalahan: ${e.toString()}',
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
            Text('😊 ', style: TextStyle(fontSize: 18)),
            const Text('Lupa Password'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              
              // Icon & Title
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 64,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masukkan email atau nomor HP Anda\nuntuk menerima kode verifikasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Identifier Input
              TextFormField(
                controller: _identifierController,
                decoration: InputDecoration(
                  labelText: 'Email atau Nomor HP',
                  hintText: 'user@email.com atau 08123456789',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                  helperText: 'Kode OTP akan dikirim ke email Anda',
                  helperStyle: const TextStyle(fontSize: 11),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email atau nomor HP wajib diisi';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Send OTP Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Kode OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kode OTP akan dikirim ke email Anda. Kode berlaku selama 10 menit.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Back to Login
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Kembali ke Login',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
