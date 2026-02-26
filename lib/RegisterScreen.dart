// ==================== Register Screen ====================
import 'package:experience/service/CallAPI.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'HomeScreen.dart';
import 'constant.dart';
import 'main.dart';
import 'model/lookups.dart';
class Registerscreen extends StatefulWidget {
  @override
  _RegisterscreenState createState() => _RegisterscreenState();
}
class _RegisterscreenState extends State<Registerscreen> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int? selectedcityid;
  final _formKeyStep1 = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedCity;
  var url = serverUrl + 'auth/register';
  Future<void> _Register() async {
    if (!_formKeyStep1.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      'email': _emailController.text.toString(),
      'password': _passwordController.text.toString(),
      'fullName': _fullNameController.text.toString(),
      'phone': _phoneController.text.toString(),
      'cityid': _selectedCity.toString(),
      'typeId': 2
    };
    try {
      var url = serverUrl + 'auth/register';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);
        SharedPreferences userpref = await SharedPreferences.getInstance();
        String fullname = decodedData['userName'].toString();
        double totalEvaluations= decodedData['totalEvaluations'];
        userpref.setDouble('totalEvaluations', totalEvaluations);
        String email = decodedData['email'].toString();
        String phone = decodedData['phone'].toString();
        String userTypeId=decodedData['userTypeId'].toString();
        String token = decodedData['token'].toString();
        int cartItemsCount=decodedData['cartItemsCount'];
        int userId=decodedData['userId'];
        int field=decodedData['fieldId'];
        userpref.setString("token", token);
        userpref.setString("email", email);
        userpref.setString("password", _passwordController.text.trim());
        userpref.setString("fullname", fullname);
        userpref.setString("userTypeId", userTypeId);
        userpref.setString("email", email);
        userpref.setString("phone", phone);
        userpref.setBool('logined', true);
        userpref.setInt('fieldId', field);
        userpref.setInt('userId', userId);
        userpref.setInt('cartItemsCount', cartItemsCount);
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex:0,userid: 0,)));
      } else if (response.statusCode == 400)
      {
        var decodedData = json.decode(response.body);
       var errorMessage = decodedData["errors"][0];
        showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text("رسالة خطأ"),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("إغلاق" , style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),),
                  ),
                ],
              );
            });

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
        isLoading = false;
      });
    }
  }

  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    loadcities();
  }
  bool isLoading = true;
  final CallAPI api = CallAPI();
  List<City> cities = [];
  Future<void> loadcities() async {
    final result = await api.getList<City>(
      baseUrl: serverUrl,
      endpoint: 'Lookups/cities',
      fromJson: (json) => City.fromJson(json),
    );
    if (result.success) {
      setState(() {
        cities = result.data!;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.error}')),
      );
    }
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
                    validatorMsg: 'يرجى إدخال الاسم الكامل'),
                SizedBox(height: 20),
                _buildTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'example@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    validatorMsg: 'يرجى إدخال بريد إلكتروني صالح',
                    emailValidation: true),
                SizedBox(height: 20),
                _buildTextField(
                    controller: _phoneController,
                    label: 'رقم الجوال',
                    hint: '05XXXXXXXX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    validatorMsg: 'يرجى إدخال رقم جوال صالح',
                    phoneValidation: true),
                SizedBox(height: 20),
                _buildPasswordField(),
                SizedBox(height: 20),
                _buildConfirmPasswordField(),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: _dropdownDecoration('المدينة', Icons.location_city),
                  hint: Text('اختر المدينة'),
                  value: _selectedCity,
                  items: cities.map((city) {
                    return DropdownMenuItem(
                      value: city.id.toString(),
                      child: Text(city.cityName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء اختيار المدينة";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _Register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      backgroundColor:  AppColors.primaryBlue,
                      shadowColor:  Colors.white, // same shadow as previous style

                    ),
                    child:
                    SmartArabicText(
                      text: 'تسجيل',
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
    TextDirection textDirection=TextDirection.rtl,
    TextAlign textAlign=TextAlign.right,
    bool emailValidation = false,
    bool phoneValidation = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection, // إضافة اتجاه النص من اليمين لليسار
      textAlign: textAlign, // محاذاة النص لليمين
      style: const TextStyle(
        fontSize: 14, // تكبير حجم النص المدخل
        color: Colors.black,
      ),

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        // تكبير حجم الـ hint والـ label
        hintStyle: SmartArabicTextStyle.create(
          color: AppColors.primaryBlue.withOpacity(0.6),
          baseSize: 14, // زيادة حجم الخط
          context: context,
        ),

        labelStyle: SmartArabicTextStyle.create(
          color: AppColors.primaryBlue.withOpacity(0.6),
          baseSize: 12, // زيادة حجم الخط
          context: context,
        ),

        // تكبير حجم النص في حالة الخطأ
        errorStyle: const TextStyle(
          fontSize: 12,
          height: 1.2,
          color: Colors.red,
        ),

        // السماح بثلاثة أسطر للخطأ
        errorMaxLines: 3,

        prefixIcon: Icon(icon, color: primaryBlue, size: 24), // تكبير حجم الأيقونة

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

        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
        if (phoneValidation && !RegExp(r'^05\d{8}$').hasMatch(value)) {
          return validatorMsg ??
              'يرجى إدخال رقم جوال صالح يبدأ بـ 05 ويتكون من 10 أرقام';
        }
        return null;
      },
    );
  }
  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
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
    );
  }
  bool _obscurePassword = true;
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        hintText: 'أدخل كلمة المرور',
        hintStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6), baseSize: 12, context: context),
        labelStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6), baseSize: 12, context: context),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // إضافة constraints لمساحة الخطأ
        errorMaxLines: 3,
        errorStyle: const TextStyle(
          fontSize: 12,
          height: 1.2, // تباعد الأسطر
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'يرجى إدخال كلمة المرور';
        }

        final regex = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
        );

        if (!regex.hasMatch(value)) {
          return 'يجب أن تحتوي على ٦ أحرف على الأقل، حرف كبير وصغير، رقم، رمز خاص';
        }
        return null;
      },
    );
  }
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        hintText: 'أعد إدخال كلمة المرور',
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
          return 'يرجى تأكيد كلمة المرور';
        }
        if (value != _passwordController.text) {
          return 'كلمتا المرور غير متطابقتين';
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
          text: 'التسجيل كعميل',
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