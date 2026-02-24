import 'package:experience/constant.dart';
import 'package:flutter/material.dart';
import '../service/AuthService.dart';
import '../service/SmartArabicText.dart';
import '../utils/loading_widget.dart';
import '../utils/validators.dart';
import 'NewPasswordScreen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _otpToken;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await AuthService.verifyOtp(
      widget.email,
      _otpController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (response.status==1) {
      // حفظ token للاستخدام في الخطوة التالية
      _otpToken = response.resetToken;
      // الانتقال إلى شاشة إدخال كلمة المرور الجديدة
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(
            email: widget.email,
            otpToken: _otpToken!,
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'الركز المدخل غير صحيح او صلاحية رمز التأكد انتهت';
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await AuthService.forgotPassword(widget.email);
    setState(() {
      _isLoading = false;
    });

    if (response.status==1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال كود جديد إلى بريدك الإلكتروني'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'حدث خطأ في الإرسال';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SmartArabicText(
          text: 'التحقق من الرمز',
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
                'أدخل كود التحقق',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'تم إرسال كود التحقق إلى ${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 10,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '0000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: Validators.validateOtp,
              ),
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
              const SizedBox(height: 20),
              SizedBox(
                width: 600,
                height: 56,
                child:  ElevatedButton(
                  onPressed: _isLoading ? null :  _verifyOtp,
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
                        'تحقق',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _isLoading ? null : _resendOtp,
                child: const Text('إعادة إرسال الكود'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}