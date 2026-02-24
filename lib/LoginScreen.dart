import 'dart:ffi';

import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/user/ForgotPasswordScreen.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../HomeScreen.dart';
import '../WelcomeRegistrationPage.dart';
import '../constant.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static const _primaryColor = Color(0xFF0B7C7A);
  static const _borderColor = Color(0xFF0B7C7A);
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final data = {
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
    };

    try {
      var url = serverUrl + 'Auth/login';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);
        SharedPreferences userpref = await SharedPreferences.getInstance();
        String profileImageUrl='no image';
        decodedData['profileUrl'] !=null ?  profileImageUrl = serverUrl+decodedData['profileUrl'].toString() : profileImageUrl='no image';
        String fullname = decodedData['userName'].toString();
        String email = decodedData['email'].toString();
        String phone = decodedData['phone'].toString();
        String userTypeId=decodedData['userTypeId'].toString();
        String token = decodedData['token'].toString();
        String firebaseToken=decodedData['firebaseToken'].toString() ?? 'not registered';
        int cartItemsCount=decodedData['cartItemsCount'];
        int userId=decodedData['userId'];
        int field=decodedData['fieldId'];
        userpref.setString("token", token);
          userpref.setString("email", email);
        userpref.setString("password", _passwordController.text.trim());
        userpref.setString("firebaseToken",firebaseToken);
        userpref.setString("fullname", fullname);
        userpref.setString("userTypeId", userTypeId);
        userpref.setString("email", email);
        userpref.setString('profileImageUrl', profileImageUrl);
        userpref.setString("phone", phone);
        userpref.setBool('logined', true);
        userpref.setInt('fieldId', field);
        userpref.setInt('userId', userId);
        userpref.setInt('cartItemsCount', cartItemsCount);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 0,userid: 0,)),
              (route) => false,
        );
      } else if (response.statusCode == 400){
        // Handle login failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الدخول، تحقق من بياناتك')),
        );
      } else
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال بالخادم')), );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال بالخادم')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        hintText: 'أدخل كلمة المرور',
        hintStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        labelStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: primaryBlue,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: primaryBlue),
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
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }

        final regex = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
        );

        if (!regex.hasMatch(value)) {
          return
            'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل، وأحرف كبيرة وصغيرة، ورقم، وحرف خاص';
        }
        return null;
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:  Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 220,
                  height: 217,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child:  Image.asset(
                    'assets/images/loginlogo.png',
                    height: 110,
                  ),
                ),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                          controller: _emailController,
                          label: 'البريد الإلكتروني',
                          hint: 'example@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validatorMsg: 'يرجى إدخال بريد إلكتروني صالح',
                          emailValidation: true),
                      SizedBox(height: 20),
                      _buildPasswordField(),
                      SizedBox(height: 10),
                      SizedBox(
                        width: 320,
                        height: 20,
                        child:
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>Directionality( // add this
                                  textDirection: TextDirection.rtl, // set this property
                                  child:ForgotPasswordScreen()),
                              ),
                            );

                          },
                          child: Text(
                            ' نسيت كلمة المرور؟',
                            style: TextStyle(
                              color: const Color(0xFF0B7780),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 320,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,

                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                              side: const BorderSide(color: Colors.white, width: 1),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              gradient: const RadialGradient(
                                center: Alignment(0.5, 0.5),
                                radius: 2.76,
                                colors: [
                                  Color(0xFF028F9A),
                                  Color(0xFF017781),
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x3F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child:  _isLoading
                                ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SmallLoadingWidget(),
                                SizedBox(width: 8),
                                Text('جاري المعالجة...'),
                              ],
                            )
                                :
                            const Center(
                              child:
                              SmartArabicText(
                                text: 'تسجيل الدخول',
                                baseSize:12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                      // Register link
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),

                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SmartArabicText(
                              text: 'ليس لديك حساب؟',
                              baseSize:12,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>Directionality( // add this
                                      textDirection: TextDirection.rtl, // set this property
                                      child: WelcomeRegistrationPage()),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shadowColor: AppColors.primaryBlue
                              ),
                              child: SmartArabicText(
                                text: 'سجل الآن؟',
                                baseSize:14,
                                color:  Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      // Continue as Guest link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>Directionality( // add this
                                textDirection: TextDirection.rtl, // set this property
                                child: HomeScreen(selectedIndex: 0,userid: 0,)),
                            ),
                          );

                        },
                        child: Text(
                          'الاستمرار كضيف',
                          style: TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Developed and managed by",
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      /// ===== Second Logo With Text Beside It =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [

                          Image.asset(
                            "assets/images/alkafaadark.png",
                            height: 40,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(width: 12),

                          const Flexible(
                            child: Text(
                              "alkafaa lilistisharat Company educational \nwaltarbawiya sharikat shakhs wahid",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 10,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),


                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }
}