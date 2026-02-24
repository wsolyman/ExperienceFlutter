import 'package:experience/LoginScreen.dart';
import 'package:experience/constant.dart';
import 'package:flutter/material.dart';
import '../service/AuthService.dart';
import '../service/SmartArabicStyle.dart';
import '../service/SmartArabicText.dart';
import '../utils/loading_widget.dart';
import '../utils/validators.dart';
class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String otpToken;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.otpToken,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final response = await AuthService.resetPassword(
      widget.email,
      _passwordController.text,
      widget.otpToken,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.status==1) {
      setState(() {
        _successMessage = 'تم تغيير كلمة المرور بنجاح';
      });

      // الانتقال إلى شاشة تسجيل الدخول بعد 3 ثواني
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = response.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SmartArabicText(
          text: 'كلمة مرور جديدة',
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
      body:
      Container(
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
                'اختر كلمة مرور جديدة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'يجب أن تكون كلمة المرور الجديدة مختلفة عن السابقة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
             _buildPasswordField(),
              const SizedBox(height: 20),
              _buildConfirmPasswordField(),
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
                  onPressed: _isLoading ? null : _resetPassword,
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
                        'تغيير كلمة المرور',
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

  bool _confirmobscurePassword = true;
  static const Color primaryBlue = Color(0xFF0B7780);
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
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _confirmobscurePassword,
      decoration: InputDecoration(
        labelText: 'تأكيد كلمة المرور',
        hintText: 'أعد إدخال كلمة المرور',
        hintStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        labelStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        prefixIcon: const Icon(Icons.lock_outline, color: primaryBlue),
        suffixIcon: IconButton(
          icon: Icon(
            _confirmobscurePassword ? Icons.visibility_off : Icons.visibility,
            color: primaryBlue,
          ),
          onPressed: () {
            setState(() => _confirmobscurePassword = !_confirmobscurePassword);
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
}