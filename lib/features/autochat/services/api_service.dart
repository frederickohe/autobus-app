import 'package:autobus/barrel.dart';

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
      print('Fetching rides from: $baseUrl/rides');
      final response = await httpClient.get(Uri.parse('$baseUrl/rides'));

      print('Rides response status: ${response.statusCode}');
      print('Rides response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Decoded data type: ${data.runtimeType}');

        if (data is Map && data.containsKey('rides')) {
          print('Found rides in response: ${data['rides'].length} rides');
          return data['rides'];
        }
        print('Data is not a map or does not contain rides key');
        return data is List ? data : [];
      } else if (response.statusCode == 401) {
        throw Exception('Session expired - unauthorized');
      } else {
        throw Exception(
          'Failed to fetch rides: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching rides: $e');
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
}
