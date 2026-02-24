import 'package:flutter/material.dart';
import '../constant.dart';
import '../service/AuthService.dart';
import '../service/SmartArabicStyle.dart';
import '../service/SmartArabicText.dart';
import '../utils/loading_widget.dart';
import '../utils/validators.dart';
import 'OtpVerificationScreen.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final response = await AuthService.forgotPassword(_emailController.text);

    setState(() {
      _isLoading = false;
    });

    if (response.status==1) {
      setState(() {
        _successMessage = 'تم ارسال رمز التحقق لبريدك الاليكتروني بنجاح';
      });
      // الانتقال إلى شاشة التحقق من OTP بعد ثانيتين
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: _emailController.text,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'بريدك الاليكتروني غير صحيح او غير مسجل لدينا';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SmartArabicText(
          text: 'استعادة كلمة المرور',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'أدخل بريدك الإلكتروني',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'سنرسل إليك كود التحقق لإعادة تعيين كلمة المرور',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  hint: 'example@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validatorMsg: 'يرجى إدخال بريد إلكتروني صالح',
                  emailValidation: true),

              const SizedBox(height: 20),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
              width: 600,
              height: 56,
                child:  ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
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
                    width: 320,height: 56,

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
                    child: _isLoading
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmallLoadingWidget(),
                        SizedBox(width: 8),
                        Text('جاري المعالجة...'),
                      ],
                    )
                        : const Center(
                      child: Text(
                        'إرسال كود التحقق',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    ));
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
}