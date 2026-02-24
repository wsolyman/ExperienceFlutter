import 'dart:convert';
import 'package:experience/model/Expert.dart';
import 'package:http/http.dart' as http;
import '../model/Exprience.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ApiService {
  final String baseUrl;
  ApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchExperiences(int pageNumber, {int? categoryId ,int? userid ,int? isapproved,String? search,int? pageSize,int? currentuserId }) async {
    try {
      final queryParameters = {
        'pageNumber': pageNumber.toString(),
        if (categoryId != null) 'categoryId': categoryId.toString(),
        if (userid != null) 'userid': userid.toString(),
        if (isapproved != null) 'isapproved': "true",
        if (search != null) 'search': search.toString(),
        if (currentuserId != null) 'UserId__neq': currentuserId.toString(),
        if (pageSize != null) 'pageSize': pageSize.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final List experiencesJson = jsonBody['data'];
        final totalCount = jsonBody['totalCount'];
        final pageSize = jsonBody['pageSize'];
        final hasNextPage = jsonBody['hasNextPage'];

        final experiences = experiencesJson
            .map((e) => Experience.fromJson(e))
            .toList();

        return {
          'experiences': experiences,
          'totalCount': totalCount,
          'pageSize': pageSize,
          'hasNextPage': hasNextPage,
        };
      } else {
        throw Exception('Failed to load experiences');
      }
    }catch (e) {
      // Code to handle the exception (e.g., show an error message in the UI)
      print('Exception caught: $e');
      // Update UI with error message
      throw Exception('Failed to load experiences');

    }
  }
  Future<Map<String, dynamic>> fetchExpert(int pageNumber, {int? FieldId ,String? search}) async {
    try {
      final queryParameters = {
        'pageNumber': pageNumber.toString(),
          if (FieldId != null) 'fieldId': FieldId.toString(),
        if (search != null) 'search': search.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        final jsonData = jsonDecode(response.body);
        final result = Expert.fromJson(jsonData);
        final totalCount = jsonBody['totalCount'];
        final pageSize = jsonBody['pageSize'];
        final hasNextPage = jsonBody['hasNextPage'];
        final experts = result.data;
        return {
          'experts': experts,
          'totalCount': totalCount,
          'pageSize': pageSize,
          'hasNextPage': hasNextPage,
        };
      } else {
        throw Exception('Failed to load experiences');
      }
    }catch (e) {
      // Code to handle the exception (e.g., show an error message in the UI)
      print('Exception caught: $e');
      // Update UI with error message
      throw Exception('Failed to load experiences');

    }
  }
}
Widget _buildLoadingImage() {
  return Image.asset(
    'assets/images/loading.gif', // Your loading GIF or image
    width: 80,
    height: 80,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stackTrace) {
      return _buildFallbackLoading();
    },
  );
}
Widget _buildFallbackLoading() {
  // Fallback loading animation using Flutter built-in
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: const Color(0xFF028F9A).withOpacity(0.1),
      shape: BoxShape.circle,
    ),
    child: const Center(
      child: Icon(
        Icons.autorenew,
        size: 40,
        color: Color(0xFF028F9A),
      ),
    ),
  );
}

