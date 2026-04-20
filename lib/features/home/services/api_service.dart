import 'package:autobus/barrel.dart';
import 'dart:developer';

class ApiService {
  final SessionAwareHttpClient httpClient;
  final String baseUrl;

  ApiService({required this.httpClient, String? baseUrl})
    : baseUrl = baseUrl?.isNotEmpty == true
          ? baseUrl!
          : '${AppConfig.backendUrl}/api/v1';

  /// Get current user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await httpClient.get(Uri.parse('$baseUrl/user/me'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  /// Get all rides/buses
  Future<List<dynamic>> getRides() async {
    try {
      debugPrint('Fetching rides from: $baseUrl/rides');
      final response = await httpClient.get(Uri.parse('$baseUrl/rides'));

      debugPrint('Rides response status: ${response.statusCode}');
      debugPrint('Rides response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Decoded data type: ${data.runtimeType}');

        if (data is Map && data.containsKey('rides')) {
          debugPrint('Found rides in response: ${data['rides'].length} rides');
          return data['rides'];
        }
        debugPrint('Data is not a map or does not contain rides key');
        return data is List ? data : [];
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - unauthorized');
      } else {
        throw Exception(
          'Failed to fetch rides: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching rides: $e');
      throw Exception('Error fetching rides: $e');
    }
  }

  /// Get ride details by ID
  Future<Map<String, dynamic>> getRideDetails(String rideId) async {
    try {
      final response = await httpClient.get(
        Uri.parse('$baseUrl/rides/$rideId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        throw Exception('Ride not found');
      } else {
        throw Exception('Failed to fetch ride details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ride details: $e');
    }
  }

  /// Create a new booking
  Future<Map<String, dynamic>> createBooking({
    required String rideId,
    required int seats,
    required String pickupLocation,
    required String dropoffLocation,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ride_id': rideId,
          'seats': seats,
          'pickup_location': pickupLocation,
          'dropoff_location': dropoffLocation,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Invalid booking details');
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  /// Get user bookings
  Future<List<dynamic>> getUserBookings() async {
    try {
      final response = await httpClient.get(Uri.parse('$baseUrl/bookings'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('bookings')) {
          return data['bookings'];
        }
        return data is List ? data : [];
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to fetch bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  /// Cancel a booking
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/bookings/$bookingId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        throw Exception('Failed to cancel booking: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error canceling booking: $e');
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;

      final response = await httpClient.put(
        Uri.parse('$baseUrl/user/me'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Invalid profile data');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Get available rides with filters
  Future<List<dynamic>> searchRides({
    required String departure,
    required String destination,
    required DateTime date,
  }) async {
    try {
      final response = await httpClient.get(
        Uri.parse(
          '$baseUrl/rides/search?departure=$departure&destination=$destination&date=${date.toIso8601String().split('T')[0]}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('rides')) {
          return data['rides'];
        }
        return data is List ? data : [];
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to search rides: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching rides: $e');
    }
  }

  Future<String?> initializePaystackTransaction({
    required String email,
    required double amount,
  }) async {
    final token = await TokenService().getAccessToken();
    debugPrint('initializePaystack: token exists — ${token != null}');
    debugPrint('initializePaystack: token — $token');

    final body = json.encode({
      'email': email,
      'amount': (amount * 100).toInt(),
      'reference': DateTime.now().millisecondsSinceEpoch.toString(),
      'callback_url': AppConfig.paystackCallbackUrl,
    });

    debugPrint(
      'initializePaystack: POST $baseUrl/paystack/transaction/initialize',
    );
    debugPrint('initializePaystack: body — $body');

    final response = await httpClient.post(
      Uri.parse('$baseUrl/paystack/transaction/initialize'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    debugPrint('initializePaystack: status — ${response.statusCode}');
    debugPrint('initializePaystack: response — ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['access_code'] as String?;
    }
    return null;
  }

  Future<bool> verifyPaystackTransaction(String reference) async {
    debugPrint(
      'verifyPaystack: GET $baseUrl/paystack/transaction/verify/$reference',
    );

    final response = await httpClient.get(
      Uri.parse('$baseUrl/paystack/transaction/verify/$reference'), // fix
    );

    debugPrint('verifyPaystack: status — ${response.statusCode}');
    debugPrint('verifyPaystack: response — ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['status'] == true || data['status'] == 'success';
    }
    return false;
  }

  Future<bool> subscribeToPlan({
    required String planId,
    required String billingId,
    required String reference,
  }) async {
    final body = {
      'plan_id': planId,
      'billing_id': billingId,
      'reference': reference,
    };

    log('subscribeToPlan: POST /api/v1/subscription/subscribe');
    log('subscribeToPlan: request body — $body');

    final response = await httpClient.post(
      Uri.parse('$baseUrl/subscription/subscribe'),
      body: body,
    );

    log('subscribeToPlan: status — ${response.statusCode}');
    log('subscribeToPlan: response — ${response.body}');

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<SubscriptionPlan>> getSubscriptionPlans() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/subscription/plans'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final plans = (data['plans'] as List)
          .map((e) => SubscriptionPlan.fromJson(e as Map<String, dynamic>))
          .where((p) => p.isActive)
          .toList();
      return plans;
    }
    return [];
  }

  /// Get total revenue
  Future<double> getTotalRevenue() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/payment/revenue'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as num).toDouble();
    }
    return 0.0;
  }

  /// Get financial transaction history
  Future<List<Map<String, dynamic>>> getFinancials({
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/user/me/financials?page=$page&page_size=$pageSize'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  /// Get connected social media accounts
  Future<List<Map<String, dynamic>>> getSocialAccounts() async {
    final response = await httpClient.get(
      Uri.parse('$baseUrl/social/accounts'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accounts = data['accounts'] as List? ?? [];
      return List<Map<String, dynamic>>.from(accounts);
    }
    return [];
  }

  /// Publish a post to connected social accounts
  Future<Map<String, dynamic>> publishSocialPost({
    required List<String> accountIds,
    required String content,
    List<String> mediaUrls = const [],
    String? scheduleTime,
    List<String> hashtags = const [],
  }) async {
    final body = <String, dynamic>{
      'account_ids': accountIds,
      'content': content,
      if (mediaUrls.isNotEmpty)
        'media_urls': mediaUrls
            .map((u) => {'url': u, 'type': 'image'})
            .toList(),
      if (scheduleTime != null) 'schedule_time': scheduleTime,
      if (hashtags.isNotEmpty) 'hashtags': hashtags,
    };

    final response = await httpClient.post(
      Uri.parse('$baseUrl/social/post'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(
      'Failed to publish: ${response.statusCode} ${response.body}',
    );
  }

  Future<String> generateAgentContent({
    required String userId,
    required String prompt,
    String agentName = 'marketing',
  }) async {
    final response = await httpClient.post(
      Uri.parse('$baseUrl/agent/command'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userid': userId,
        'message': prompt,
        'agent_name': agentName,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['response'] ?? data['message'] ?? data['reply'] ?? '')
          .toString();
    }
    throw Exception('Agent error: ${response.statusCode}');
  }
}
