// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer'; // Untuk log debug

class ApiService {
  // ================================================================
  // API BASE URL CONFIGURATION
  // Uncomment the appropriate line based on your environment:
  // ================================================================
  
  // For Local Development (Web/Desktop):
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // For Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // For Local Physical Device (use your computer's IP address):
  static const String baseUrl = 'http://192.168.1.4:8000/api';
  
  // ✅ PRODUCTION SERVER:
  // static const String baseUrl = 'http://148.230.97.130/api';
  
  // ================================================================
  String? _token;
  
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    log("ApiService diinisialisasi dengan token: $_token");
  }
  
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Token $_token',
  };
  
  // Auth
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    String? ktpNumber,
    required String address,
    required String storeCode, // Kode toko untuk registrasi
  }) async {
    try {
      log('Sending register request to: $baseUrl/users/register/');
      
      final body = {
        'email': email,
        'password': password,
        'password_confirm': password, // Django requires this!
        'first_name': firstName,
        'last_name': lastName,
        'phone_number': phone,
        'address': address,
        'birth_date': null, // Optional field
        'store_code': storeCode, // Kode toko untuk assign ke store
      };
      
      // Add KTP only if provided
      if (ktpNumber != null && ktpNumber.isNotEmpty) {
        body['ktp_number'] = ktpNumber;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
      
      log('Register response status: ${response.statusCode}');
      log('Register response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        String errorMessage = 'Registrasi gagal';
        
        if (error['error'] != null) {
          errorMessage = error['error'];
        } else if (error['email'] != null) {
          errorMessage = error['email'][0];
        } else if (error['message'] != null) {
          errorMessage = error['message'];
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Register error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Cek jaringan Anda.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Tidak bisa connect ke server. Pastikan Django jalan di 0.0.0.0:8000');
      }
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String identifier, // Email OR Phone number
    required String password,
  }) async {
    try {
      log('Sending login request to: $baseUrl/login/');
      log('Identifier: $identifier');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login/'), // Correct endpoint: /api/login/
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier, // Email OR Phone number
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));
      
      log('Login response status: ${response.statusCode}');
      log('Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setToken(data['token']);
        
        // Save user role and data for routing
        final prefs = await SharedPreferences.getInstance();
        if (data['user'] != null) {
          await prefs.setString('user_role', data['user']['role'] ?? 'customer');
          await prefs.setString('user_data', jsonEncode(data['user']));
        }
        
        log('Login successful! Method: ${data['login_method']}');
        return data;
      } else {
        final error = jsonDecode(response.body);
        String errorMessage = error['error'] ?? 'Login gagal';
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Login error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Cek jaringan Anda.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Tidak bisa connect ke server.');
      }
      rethrow;
    }
  }
  
  // User
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil profil');
    }
  }

  // Update Profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      log('Updating profile: $data');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/users/me/'),
        headers: _headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));
      
      log('Update profile response status: ${response.statusCode}');
      log('Update profile response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        String errorMessage = error['error'] ?? 'Gagal update profil';
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Update profile error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Cek jaringan Anda.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Tidak bisa connect ke server.');
      }
      rethrow;
    }
  }
  
  // Wallet (DIBUAT AMAN/ROBUST)
  Future<Map<String, dynamic>?> getWalletBalance() async {
    final response = await http.get(
      Uri.parse('$baseUrl/wallet/'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Django REST API mengembalikan list langsung, bukan nested dalam 'results'
      if (data is List && data.isNotEmpty) {
        return data[0]; // Kembalikan wallet jika ada
      } else {
        return null; // Kembalikan null jika user belum punya wallet
      }
    } else {
      throw Exception('Gagal mengambil saldo');
    }
  }

  // Wallet History
  Future<List<dynamic>> getWalletHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/history/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil riwayat transaksi');
      }
    } catch (e) {
      log('Get wallet history error: $e');
      rethrow;
    }
  }

  // Policies (DIBUAT AMAN/ROBUST)
  Future<List<dynamic>> getPolicies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/policies/'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Django REST API mengembalikan list langsung
      if (data is List) {
        return data;
      }
      return [];
    } else {
      throw Exception('Gagal mengambil polis');
    }
  }

  // TopUp (DARI FILE ANDA)
  Future<Map<String, dynamic>> topUp({
    required double amount,
    required String paymentMethod,
    String? proofUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/wallet/topup/'),
      headers: _headers,
      body: jsonEncode({
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_proof_url': proofUrl ?? 'https://default.com/proof.jpg',
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Top up gagal. Cek minimal Rp 100.000.');
    }
  }

  // Device Packages
  Future<List<dynamic>> getDevicePackages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/device-packages/'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      }
      return [];
    } else {
      throw Exception('Gagal mengambil daftar device');
    }
  }

  // Policy Tiers
  Future<List<dynamic>> getPolicyTiers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/policy-tiers/'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      }
      return [];
    } else {
      throw Exception('Gagal mengambil tier polis');
    }
  }

  // Create Policy
  Future<Map<String, dynamic>> createPolicy({
    required String devicePackageId,
    required String imeiNumber,
    required double purchasePrice,
  }) async {
    try {
      log('Creating policy: device=$devicePackageId, imei=$imeiNumber, price=$purchasePrice');
      
      final response = await http.post(
        Uri.parse('$baseUrl/policies/'),
        headers: _headers,
        body: jsonEncode({
          'device_package': devicePackageId,
          'imei_number': imeiNumber,
          'purchase_price': purchasePrice,
        }),
      ).timeout(const Duration(seconds: 30));
      
      log('Create policy response status: ${response.statusCode}');
      log('Create policy response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        String errorMessage = 'Gagal membuat polis';
        
        if (error['error'] != null) {
          errorMessage = error['error'];
        } else if (error['message'] != null) {
          errorMessage = error['message'];
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Create policy error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Cek jaringan Anda.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Tidak bisa connect ke server.');
      }
      rethrow;
    }
  }

  // Claims
  Future<List<dynamic>> getClaims() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/claims/'),
        headers: _headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception('Gagal mengambil daftar klaim');
      }
    } catch (e) {
      log('Get claims error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createClaim({
    required String policyId,
    required String damageType,
    required String damageDescription,
    required String incidentDate,
    required double claimAmount,
    List<File>? photos,
  }) async {
    try {
      log('Creating claim: policy=$policyId, type=$damageType, photos=${photos?.length ?? 0}');
      
      // If no photos, use simple JSON request
      if (photos == null || photos.isEmpty) {
        final response = await http.post(
          Uri.parse('$baseUrl/claims/'),
          headers: _headers,
          body: jsonEncode({
            'policy': policyId,
            'damage_type': damageType,
            'damage_description': damageDescription,
            'incident_date': incidentDate,
            'claim_amount': claimAmount,
          }),
        ).timeout(const Duration(seconds: 30));
        
        log('Create claim response status: ${response.statusCode}');
        log('Create claim response body: ${response.body}');
        
        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          return data;
        } else {
          final error = jsonDecode(response.body);
          String errorMessage = 'Gagal mengajukan klaim';
          
          if (error['error'] != null) {
            errorMessage = error['error'];
          } else if (error['message'] != null) {
            errorMessage = error['message'];
          }
          
          throw Exception(errorMessage);
        }
      }
      
      // Use multipart request for photos
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/claims/'));
      
      // Add authorization header
      if (_token != null) {
        request.headers['Authorization'] = 'Token $_token';
      }
      
      // Add form fields
      request.fields['policy'] = policyId;
      request.fields['damage_type'] = damageType;
      request.fields['damage_description'] = damageDescription;
      request.fields['incident_date'] = incidentDate;
      request.fields['claim_amount'] = claimAmount.toString();
      
      // Add photos
      for (int i = 0; i < photos.length; i++) {
        final file = photos[i];
        final fileName = 'damage_photo_$i.jpg';
        
        // Determine content type based on file extension
        String ext = file.path.split('.').last.toLowerCase();
        String mimeType = 'jpeg';
        if (ext == 'png') mimeType = 'png';
        if (ext == 'gif') mimeType = 'gif';
        if (ext == 'webp') mimeType = 'webp';
        
        request.files.add(await http.MultipartFile.fromPath(
          'photos',
          file.path,
          filename: fileName,
          contentType: MediaType('image', mimeType),
        ));
        
        log('Added photo $i: ${file.path}');
      }
      
      log('Sending multipart request with ${photos.length} photos...');
      
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      
      log('Create claim response status: ${response.statusCode}');
      log('Create claim response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        String errorMessage = 'Gagal mengajukan klaim';
        
        if (error['error'] != null) {
          errorMessage = error['error'];
        } else if (error['message'] != null) {
          errorMessage = error['message'];
        }
        
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      log('Create claim error: $e');
      log('Stack trace: $stackTrace');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Koneksi timeout. Cek jaringan Anda.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Tidak bisa connect ke server.');
      }
      rethrow;
    }
  }

  // ================================================================
  // ADMIN API - Super Admin Only
  // ================================================================
  
  // Helper: GET Request with detailed logging
  Future<dynamic> _get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    log('API GET Request: $url');
    log('API Headers: $_headers');
    
    try {
      final response = await http.get(url, headers: _headers).timeout(const Duration(seconds: 15));
      log('API Response ${response.statusCode} for $endpoint');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        log('API Setup Error Body: ${response.body}');
        throw Exception('API Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      log('API Connection Error: $e');
      rethrow;
    }
  }

  // Get Admin Dashboard Stats
  Future<Map<String, dynamic>> getAdminStats() async {
    return await _get('/admin/dashboard/') as Map<String, dynamic>;
  }

  // Get All Stores (Super Admin only)
  Future<List<dynamic>> getAdminStores({String? search, bool? isActive}) async {
    String endpoint = '/admin/stores/';
    List<String> params = [];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (isActive != null) params.add('is_active=$isActive');
    
    if (params.isNotEmpty) {
      endpoint += '?' + params.join('&');
    }

    final res = await _get(endpoint);
    // Handle pagination result
    if (res is Map && res.containsKey('results')) {
      return res['results'];
    }
    return res as List<dynamic>;
  }

  // Create Store
  Future<Map<String, dynamic>> createAdminStore(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/stores/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['error'] ?? 'Gagal membuat toko');
    }
  }

  // Update Store
  Future<Map<String, dynamic>> updateAdminStore(dynamic id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/admin/stores/$id/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['error'] ?? 'Gagal update toko');
    }
  }

  // Delete Store
  Future<void> deleteAdminStore(dynamic id, {required String password, bool permanent = false}) async {
    String url = '$baseUrl/admin/stores/$id/';
    if (permanent) url += '?permanent=true';
    
    final response = await http.delete(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode({'password': password}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['error'] ?? 'Gagal menghapus toko');
    }
  }

  // Reset Store Data
  Future<Map<String, dynamic>> resetStoreData(dynamic id, {required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/stores/$id/reset-data/'),
      headers: _headers,
      body: jsonEncode({'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['error'] ?? 'Gagal reset data toko');
    }
  }

  // Get Store Stats
  // Get Store Stats
  Future<Map<String, dynamic>> getStoreStats(dynamic id, {DateTime? startDate, DateTime? endDate}) async {
    String endpoint = '/admin/stores/$id/stats/';
    List<String> params = [];
    
    if (startDate != null) {
      params.add('start_date=${startDate.toIso8601String().substring(0, 10)}');
    }
    if (endDate != null) {
      params.add('end_date=${endDate.toIso8601String().substring(0, 10)}');
    }
    
    if (params.isNotEmpty) {
      endpoint += '?' + params.join('&');
    }
    
    return await _get(endpoint) as Map<String, dynamic>;
  }

  // Get Admin Users
  Future<List<dynamic>> getAdminUsers({String? search}) async {
    String url = '$baseUrl/admin/users/';
    if (search != null && search.isNotEmpty) url += '?search=$search';

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is Map ? data['results'] : data;
    }
    throw Exception('Gagal mengambil daftar user');
  }

  // Get Admin Policies
  Future<List<dynamic>> getAdminPolicies({String? search}) async {
    String url = '$baseUrl/admin/policies/';
    if (search != null && search.isNotEmpty) url += '?search=$search';

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is Map ? data['results'] : data;
    }
    throw Exception('Gagal mengambil daftar polis');
  }

  // Get Admin Claims
  Future<List<dynamic>> getAdminClaims({String? search}) async {
    String url = '$baseUrl/admin/claims/';
    if (search != null && search.isNotEmpty) url += '?search=$search';

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is Map ? data['results'] : data;
    }
    throw Exception('Gagal mengambil daftar klaim');
  }

  // Get Activity Logs
  // Get Activity Logs
  Future<List<dynamic>> getAdminActivityLogs() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/activity-logs/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is Map ? data['results'] : data;
    }
    throw Exception('Gagal mengambil log aktivitas');
  }

  // Get Admin Devices
  Future<List<dynamic>> getAdminDevices({String? search}) async {
    String url = '$baseUrl/admin/devices/';
    if (search != null && search.isNotEmpty) url += '?search=$search';

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is Map ? data['results'] : data;
    }
    throw Exception('Gagal mengambil daftar perangkat');
  }

  // Get Admin Tiers
  Future<List<dynamic>> getAdminTiers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/policy-tiers/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is Map ? data['results'] : data;
    }
    throw Exception('Gagal mengambil daftar tier');
  }

  // Create Admin Device
  Future<void> createAdminDevice(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/devices/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['error'] ?? 'Gagal membuat perangkat');
    }
  }

  // Create Admin Tier
  Future<void> createAdminTier(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/policy-tiers/'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['error'] ?? 'Gagal membuat tier');
    }
  }

  // Get Admin Reports / Analytics
  Future<List<dynamic>> getAdminReports({DateTime? startDate, DateTime? endDate}) async {
    String url = '$baseUrl/admin/reports/';
    List<String> params = [];
    if (startDate != null) params.add('start_date=${startDate.toIso8601String().substring(0, 10)}');
    if (endDate != null) params.add('end_date=${endDate.toIso8601String().substring(0, 10)}');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await http.get(Uri.parse(url), headers: _headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data is List ? data : (data['results'] ?? []);
    }
    throw Exception('Gagal mengambil data laporan');
  }
}