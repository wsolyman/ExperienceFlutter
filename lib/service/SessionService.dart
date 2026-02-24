// service/SessionService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:experience/model/Session.dart';
import 'package:experience/constant.dart';

class SessionService {
  final String baseUrl = serverUrl;


  // For authenticated requests
  Future<List<Session>> fetchUserSessions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}Auth/GetUserSessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Session.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user sessions');
      }
    } catch (e) {
      throw Exception('Error fetching user sessions: $e');
    }
  }
}