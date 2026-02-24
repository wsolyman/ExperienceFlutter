import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constant.dart';
import '../service/SmartArabicStyle.dart';
import '../service/SmartArabicText.dart';
import '../utils/loading_widget.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin{
  final _formKeyStep1 = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  //final TextEditingController _passwordController = TextEditingController();
  //final TextEditingController _confirmPasswordController = TextEditingController();
  var url = serverUrl + 'auth/UpdateUser';
  bool isLoading=false;
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullNameController.text = prefs.getString('fullname') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
    });
  }
  /// Update profile API
  Future<void> _updateProfile() async {
    if (!_formKeyStep1.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token')??'';
    setState(() => isLoading = true);
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'},
        body: jsonEncode({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        }),
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fullname', _fullNameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('phone', _phoneController.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
        );
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء التحديث')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  void initState() {
    super.initState();
    _loadProfile();
  }

  Widget _buildStep1() {
    if (isLoading) {
      return const FullScreenLoading(
        message: 'جاري تحميل البيانات...',
        withScaffold: true,
      );
    }
    return  Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المعلومات الشخصية',
              style:
              TextStyle(
                color: const Color(0xFF0B7780),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.20,
                letterSpacing: -0.50,
              ),
            ),
            SizedBox(height: 24),
            _buildTextField(
                controller: _fullNameController,
                label: 'الاسم الكامل',
                hint: 'أدخل اسمك الكامل',
                icon: Icons.person_outline,
                keyboardType: TextInputType.text,
                validatorMsg: 'يرجى إدخال الاسم الكامل'),
            SizedBox(height: 20),
            _buildTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني',
                hint: 'example@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validatorMsg: 'يرجى إدخال بريد إلكتروني صالح',
                emailValidation: true),
            SizedBox(height: 20),
            _buildTextField(
                controller: _phoneController,
                label: 'رقم الجوال',
                hint: '05XXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validatorMsg: 'يرجى إدخال رقم جوال صالح',
                phoneValidation: true),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:()
              {
                _updateProfile();
              },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  backgroundColor:  AppColors.primaryBlue,
                  shadowColor:  Colors.white, // same shadow as previous style

                ),
                child: SmartArabicText(
                  text: 'تحديث البيانات',
                  baseSize:12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

          ],
        ),
      ),

    );
  }
  static const Color primaryBlue = Color(0xFF0B7780);
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = true,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
    bool emailValidation = false,
    bool phoneValidation = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        labelStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (!requiredField) return null;
        if (value == null || value.trim().isEmpty) {
          return validatorMsg ?? 'هذا الحقل مطلوب';
        }
        if (emailValidation &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return validatorMsg ?? 'يرجى إدخال بريد إلكتروني صالح';
        }
        if (phoneValidation &&
            !RegExp(r'^05\d{8}$').hasMatch(value)) {
          return validatorMsg ??
              'يرجى إدخال رقم جوال صالح يبدأ بـ 05 ويتكون من 10 أرقام';
        }
        return null;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        SmartArabicText(
          text: 'البيانات الشخصية',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:Column(
          children: [
            SizedBox(height: 16),
            Expanded(child: _buildStep1()),
          ],
        ),),

    );
  }
}





