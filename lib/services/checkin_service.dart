import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/daily_checkin.dart';
import 'auth_service.dart';

class CheckinService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- MAIN METHOD: SUBMIT CHECK-IN (Unified) ---
  static Future<Map<String, dynamic>> submitCheckin(
      DailyCheckin checkin) async {
    final headers = await _getHeaders();

    // Debugging: Print apa yang dikirim ke server
    print("Sending Checkin Payload: ${jsonEncode(checkin.toJson())}");

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/checkin'),
        headers: headers,
        // Mengirim seluruh object checkin (termasuk journalEntry)
        body: jsonEncode(checkin.toJson()),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'checkin': DailyCheckin.fromJson(data['checkin']),
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ??
              'Check-in failed with status ${response.statusCode}'
        };
      }
    } catch (e) {
      print("Checkin Error: $e");
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // --- GET TODAY'S CHECK-IN ---
  static Future<DailyCheckin?> getTodayCheckin() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/checkin/today'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DailyCheckin.fromJson(data['checkin']);
      }
    } catch (e) {
      print("Error fetching today's checkin: $e");
    }
    return null;
  }

  // --- GET HISTORY (CHART) ---
  static Future<List<DailyCheckin>> getHistory({int days = 7}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/checkin/history?days=$days'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['history'];
        return data.map((json) => DailyCheckin.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching history: $e");
    }
    return [];
  }

  // --- GET JOURNAL PROMPT ---
  static Future<String> getJournalPrompt() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/checkin/prompts'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['prompt'];
      }
    } catch (e) {
      print("Error fetching prompt: $e");
    }
    return "Apa yang kamu rasakan saat ini?"; // Fallback default
  }

  // --- GET TOOLBOX ---
  static Future<List<dynamic>> getTools() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/checkin/tools'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['tools'];
      }
    } catch (e) {
      print("Error fetching tools: $e");
    }
    return [];
  }

  // --- GET LAST CHECK-IN (Optional) ---
  static Future<DailyCheckin?> getLastCheckin() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/checkin/last'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DailyCheckin.fromJson(data['checkin']);
      }
    } catch (e) {
      print("Error fetching last checkin: $e");
    }
    return null;
  }
}
