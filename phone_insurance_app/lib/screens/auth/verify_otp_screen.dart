import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../services/api_service.dart';
import '../../utils/snackbar_helper.dart';
import 'reset_password_screen.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String identifier;
  final String method; // 'email' or 'sms'
  final String sentTo; // masked email or phone

  const VerifyOTPScreen({
    super.key,
    required this.identifier,
    required this.method,
    required this.sentTo,
  });

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/password-reset/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': widget.identifier,
          'otp_code': _otpController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // OTP verified successfully
        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            data['message'] ?? 'Kode OTP berhasil diverifikasi',
          );

          // Navigate to reset password screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                resetToken: data['reset_token'],
                userEmail: data['user_email'] ?? '',
              ),
            ),
          );
        }
      } else {
        // Error
        if (mounted) {
          String errorMsg = data['error'] ?? 'Verifikasi gagal';
          
          // Handle specific errors
          if (data['expired'] == true) {
            errorMsg += '\nSilakan minta kode baru.';
          } else if (data['attempts_remaining'] != null) {
            errorMsg += '\nSisa percobaan: ${data['attempts_remaining']}';
          }
          
          SnackbarHelper.showError(context, errorMsg);
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

  Future<void> _resendOTP() async {
    // Resend OTP (call forgot password API again)
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/password-reset/request/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': widget.identifier,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            'Kode OTP baru telah dikirim',
          );
        }
      } else {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Gagal mengirim ulang OTP',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Terjadi kesalahan: ${e.toString()}');
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
        title: const Text('Verifikasi OTP'),
        backgroundColor: Colors.indigo,
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
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mark_email_read,
                        size: 64,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Masukkan Kode OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kode telah dikirim ke ${widget.method == 'email' ? 'email' : 'nomor HP'}:',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.sentTo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // OTP Input
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Kode OTP',
                  hintText: '123456',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                  helperText: 'Masukkan kode 6 digit yang Anda terima',
                  helperStyle: const TextStyle(fontSize: 11),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode OTP wajib diisi';
                  }
                  if (value.length != 6) {
                    return 'Kode OTP harus 6 digit';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                          'Verifikasi OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Resend OTP
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _resendOTP,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Kirim Ulang Kode OTP'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.indigo,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kode OTP berlaku selama 10 menit. Jika tidak menerima kode, kirim ulang.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
