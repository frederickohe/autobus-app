import 'package:autobus/barrel.dart';
import 'dart:developer';
import 'package:autobus/features/notifications/models/app_notification.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
    String? fullname,
    String? email,
    String? phone,
    String? profilePictureUrl,
    String? nationality,
    DateTime? dateOfBirth,
    String? gender,
    String? staffId,
    String? ghanaCard,
    // Notifications preferences
    bool? inAppNotifications,
    bool? smsNotifications,
    // Business / membership
    String? company,
    String? currentBranch,
    String? address,
    String? location,
    // Socials
    String? facebookUrl,
    String? whatsappNumber,
    String? linkedinUrl,
    String? twitterUrl,
    String? instagramUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullname != null) body['fullname'] = fullname;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (profilePictureUrl != null) {
        body['profile_picture_url'] = profilePictureUrl;
      }
      if (nationality != null) body['nationality'] = nationality;
      if (dateOfBirth != null) {
        body['date_of_birth'] = dateOfBirth.toIso8601String().split('T').first;
      }
      if (gender != null) body['gender'] = gender;
      if (staffId != null) body['staff_id'] = staffId;
      if (ghanaCard != null) body['ghana_card'] = ghanaCard;

      if (inAppNotifications != null) {
        body['in_app_notifications'] = inAppNotifications;
      }
      if (smsNotifications != null) body['sms_notifications'] = smsNotifications;

      if (company != null) body['company'] = company;
      if (currentBranch != null) body['current_branch'] = currentBranch;
      if (address != null) body['address'] = address;
      if (location != null) body['location'] = location;

      if (facebookUrl != null) body['facebook_url'] = facebookUrl;
      if (whatsappNumber != null) body['whatsapp_number'] = whatsappNumber;
      if (linkedinUrl != null) body['linkedin_url'] = linkedinUrl;
      if (twitterUrl != null) body['twitter_url'] = twitterUrl;
      if (instagramUrl != null) body['instagram_url'] = instagramUrl;

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

  /// Patch current user's notification settings.
  ///
  /// Backend: `PATCH /api/v1/user/me/notification-settings`
  /// Body: `{ "in_app_notification": true, "sms_notification": true }`
  Future<Map<String, dynamic>> patchMyNotificationSettings({
    bool? inAppNotification,
    bool? smsNotification,
  }) async {
    final body = <String, dynamic>{};
    if (inAppNotification != null) {
      body['in_app_notification'] = inAppNotification;
    }
    if (smsNotification != null) body['sms_notification'] = smsNotification;

    final response = await httpClient.patch(
      Uri.parse('$baseUrl/user/me/notification-settings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    }
    throw Exception(
      'Failed to update notification settings: ${response.statusCode} ${response.body}',
    );
  }

  /// Patch a specific user's notification settings by id.
  ///
  /// Backend: `PATCH /api/v1/user/{user_id}/notification-settings`
  Future<Map<String, dynamic>> patchUserNotificationSettings({
    required String userId,
    bool? inAppNotification,
    bool? smsNotification,
  }) async {
    final body = <String, dynamic>{};
    if (inAppNotification != null) {
      body['in_app_notification'] = inAppNotification;
    }
    if (smsNotification != null) body['sms_notification'] = smsNotification;

    final response = await httpClient.patch(
      Uri.parse('$baseUrl/user/$userId/notification-settings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    }
    throw Exception(
      'Failed to update notification settings: ${response.statusCode} ${response.body}',
    );
  }

  /// Patch current user's profile image URL only.
  ///
  /// Backend: `PATCH /api/v1/user/me/profile-image`
  /// Body: `{ "profile_picture_url": "https://..." }`
  Future<Map<String, dynamic>> patchMyProfileImage({
    required String profilePictureUrl,
  }) async {
    final response = await httpClient.patch(
      Uri.parse('$baseUrl/user/me/profile-image'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'profile_picture_url': profilePictureUrl}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    }
    throw Exception(
      'Failed to update profile image: ${response.statusCode} ${response.body}',
    );
  }

  /// Patch a specific user's profile image URL by id.
  ///
  /// Backend: `PATCH /api/v1/user/{user_id}/profile-image`
  Future<Map<String, dynamic>> patchUserProfileImage({
    required String userId,
    required String profilePictureUrl,
  }) async {
    final response = await httpClient.patch(
      Uri.parse('$baseUrl/user/$userId/profile-image'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'profile_picture_url': profilePictureUrl}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'data': decoded};
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    }
    throw Exception(
      'Failed to update profile image: ${response.statusCode} ${response.body}',
    );
  }

  /// Upload a file (image/doc) to storage service.
  ///
  /// Backend: `POST /api/v1/storage/upload` (form-data: `file`)
  /// Returns: `{ file_name, file_url }`
  Future<String> uploadFile({
    required File file,
    String? filename,
    String fieldName = 'file',
  }) async {
    final uri = Uri.parse('$baseUrl/storage/upload');
    final request = http.MultipartRequest('POST', uri);

    final multipartFile = await http.MultipartFile.fromPath(
      fieldName,
      file.path,
      filename: filename,
    );
    request.files.add(multipartFile);

    final streamed = await httpClient.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final url = (data['file_url'] ?? data['url'] ?? '').toString();
      if (url.isEmpty) {
        throw Exception('Upload succeeded but no file_url returned');
      }
      return url;
    }

    throw Exception('Upload failed: ${response.statusCode} ${response.body}');
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

  Future<PaystackInitResult?> initializePaystackTransaction({
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
      return PaystackInitResult.fromJson(data);
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
    required String phone,
  }) async {
    final body = <String, dynamic>{
      'plan_id': int.tryParse(planId) ?? planId,
      'billing_id': int.tryParse(billingId) ?? billingId,
      'reference': reference,
      'phone': phone,
    };

    log('subscribeToPlan: POST /api/v1/subscription/subscribe');
    log('subscribeToPlan: request body — $body');

    final response = await httpClient.post(
      Uri.parse('$baseUrl/subscription/subscribe'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
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

  Future<List<AppNotification>> getNotifications() async {
    final response = await httpClient.get(Uri.parse('$baseUrl/notification'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list =
          data is List
              ? data
              : (data is Map
                    ? (data['notifications'] ??
                          data['data'] ??
                          data['items'] ??
                          data['results'] ??
                          [])
                    : []);
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return const [];
    } else if (response.statusCode == 401) {
      throw Exception('Session expired');
    }
    throw Exception(
      'Failed to fetch notifications: ${response.statusCode} ${response.body}',
    );
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final items = await getNotifications();
      return items.where((n) => !n.read).length;
    } catch (_) {
      return 0;
    }
  }
}

class PaystackInitResult {
  final String authorizationUrl;
  final String accessCode;
  final String reference;

  const PaystackInitResult({
    required this.authorizationUrl,
    required this.accessCode,
    required this.reference,
  });

  factory PaystackInitResult.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      throw Exception('Invalid Paystack init response');
    }

    final authorizationUrl = (json['authorization_url'] ?? '').toString();
    final accessCode = (json['access_code'] ?? '').toString();
    final reference = (json['reference'] ?? '').toString();

    if (authorizationUrl.isEmpty || reference.isEmpty) {
      throw Exception('Missing Paystack authorization_url/reference');
    }

    return PaystackInitResult(
      authorizationUrl: authorizationUrl,
      accessCode: accessCode,
      reference: reference,
    );
  }
}
