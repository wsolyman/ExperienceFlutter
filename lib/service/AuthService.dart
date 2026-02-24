import 'dart:convert';
import 'package:experience/constant.dart';
import 'package:http/http.dart' as http;
import '../model/ApiResponse.dart';
class AuthService {
  static const String baseUrl = serverUrl;
  // إرسال طلب استعادة كلمة المرور
  static Future<ForgetPasswordresponse> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/ForgetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return ForgetPasswordresponse.fromJson(json.decode(response.body));
      } else {
        return ForgetPasswordresponse(
          status: 2,
          message: 'خطأ في الاتصال بالخادم',
         // data: null,
        );
      }
    } catch (e) {
      return ForgetPasswordresponse(
        status: 2,
        message: 'خطأ في الاتصال بالخادم',
        // data: null,
      );
    }
  }
  // التحقق من OTP
  static Future<CheckOtpresponse> verifyOtp(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/CheckOtp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return CheckOtpresponse.fromJson(json.decode(response.body));
      } else {
        return CheckOtpresponse(
          status: 2,
          resetToken: 'خطأ في الاتصال بالخادم',
        );
      }
    } catch (e) {
      return CheckOtpresponse(
        status: 2,
        resetToken: 'خطأ في الاتصال بالخادم',
      );
    }
  }

  // إعادة تعيين كلمة المرور
  static Future<ForgetPasswordresponse> resetPassword(
      String email,
      String newPassword,
      String otpToken,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/UpdatePassword/$otpToken'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'newPassword': newPassword,
          'passwordConfirm': newPassword,
        }),
      );
      if (response.statusCode == 200) {
        return ForgetPasswordresponse.fromJson(json.decode(response.body));
      } else {
        return ForgetPasswordresponse(
          status: 2,
          message: 'خطأ في الاتصال بالخادم',
          // data: null,
        );
      }
    } catch (e) {
      return  ForgetPasswordresponse(
        status: 2,
        message: 'خطأ في الاتصال بالخادم',
        // data: null,
      );
    }
  }
}