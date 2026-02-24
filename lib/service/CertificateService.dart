// service/CertificateService.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:experience/model/Certificate.dart';
import 'package:experience/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificateService {
  final String baseUrl = serverUrl;

  Future<List<Certificate>> fetchCertificates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token').toString() ?? '';

      if (token.isEmpty) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final response = await http.get(
        Uri.parse('${baseUrl}Experiences/Certificates'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Certificate.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى');
      } else {
        throw Exception('فشل تحميل الشهادات');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل الشهادات: $e');
    }
  }

  // Optional: Download PDF and save to device
  Future<String> downloadCertificate(String url, String fileName) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Here you would typically save the file using path_provider
        // For now, we'll just return the URL for viewing
        return url;
      } else {
        throw Exception('فشل تحميل ملف الشهادة');
      }
    } catch (e) {
      throw Exception('خطأ في تحميل الملف: $e');
    }
  }
}