import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/firebase_constants.dart';

class VerificationService {
  final http.Client _client;

  VerificationService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> sendVerificationCode({
    required String householdId,
    required String email,
  }) async {
    final uri = Uri.parse(FirebaseConstants.googleVerificationWebApp).replace(
      queryParameters: {
        'action': 'sendverificationcode',
        'householdId': householdId.trim().toUpperCase(),
        'email': email.trim().toLowerCase(),
        '_': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final data = _parseResponse(response.body);
        if (data['success'] == false) {
          throw Exception(data['message'] ?? data['error'] ?? 'Could not send verification code.');
        }
        return data;
      } else {
        throw Exception('Verification service error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Could not connect to the verification service. Check your internet connection.');
    }
  }

  Future<bool> verifyVerificationCode({
    required String householdId,
    required String email,
    required String code,
  }) async {
    final uri = Uri.parse(FirebaseConstants.googleVerificationWebApp).replace(
      queryParameters: {
        'action': 'verifyverificationcode',
        'householdId': householdId.trim().toUpperCase(),
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
        '_': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 25));

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final data = _parseResponse(response.body);
        if (data['success'] == false) {
          throw Exception(data['message'] ?? data['error'] ?? 'Invalid verification code.');
        }
        return true;
      } else {
        throw Exception('Verification service error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Verification failed. Please try again.');
    }
  }

  Map<String, dynamic> _parseResponse(String body) {
    try {
      // Direct JSON response
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      // If wrapped in jsonp callback, e.g. callback({...})
      final match = RegExp(r'^[a-zA-Z0-9_$]+\((.*)\);?$').firstMatch(body.trim());
      if (match != null) {
        return jsonDecode(match.group(1)!) as Map<String, dynamic>;
      }
      return {'success': false, 'message': 'Invalid response from verification service.'};
    }
  }
}
