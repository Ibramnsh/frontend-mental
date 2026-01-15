import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';
import 'auth_service.dart';

enum ChatMode { listening, solution }

class ChatService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 1. Buat Sesi Baru
  static Future<String?> createSession() async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/session'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['session']['_id'];
    }
    return null;
  }

  // 2. Ambil Daftar Sesi
  static Future<List<dynamic>> getSessions() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/sessions'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['sessions'];
    }
    return [];
  }

  // 3. Ambil Pesan per Sesi
  static Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/session/$sessionId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> chats = data['messages'] ?? [];
      return chats.map((c) => ChatMessage.fromJson(c)).toList();
    }
    return [];
  }

  // 4. Kirim Pesan (Wajib bawa sessionId)
  static Future<Map<String, dynamic>> sendMessage(
    String message,
    ChatMode mode,
    String sessionId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chat/message'),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'mode': mode == ChatMode.listening ? 'listening' : 'solution',
          'session_id': sessionId, // Penting!
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userMsgObj = ChatMessage(
          id: 'temp_user',
          message: message,
          isUser: true,
          timestamp: DateTime.now(),
        );

        final aiMsgObj = ChatMessage(
          id: data['chatId'] ?? 'temp_ai',
          message: data['reply'],
          isUser: false,
          timestamp: DateTime.now(),
        );

        return {
          'success': true,
          'userMessage': userMsgObj,
          'aiResponse': aiMsgObj,
        };
      } else {
        return {'success': false, 'error': data['error']};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  // 5. Hapus Sesi Chat
  static Future<bool> deleteSession(String sessionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/chat/session/$sessionId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }
}
