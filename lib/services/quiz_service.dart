import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class QuizService {
  static Future<bool> submitQuizResult(int score, String category) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quiz/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'score': score,
          'result_category': category,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Quiz submit error: $e");
      return false;
    }
  }
}
