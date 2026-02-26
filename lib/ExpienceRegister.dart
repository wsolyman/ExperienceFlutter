import 'dart:io';

import 'package:experience/HomeScreen.dart';
import 'package:experience/constant.dart';
import 'package:experience/service/CallAPI.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Myrequests.dart';
import 'main.dart';
import 'model/lookups.dart';

class ExpienceRegister extends StatefulWidget {
  @override
  _ExpienceRegister createState() => _ExpienceRegister();
}
class _ExpienceRegister extends State<ExpienceRegister>
    with SingleTickerProviderStateMixin {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  int _currentStep = 1;

  // Step 1 fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedCity;

  // Step 2 fields
  String? _selectedMainField;
  String? _selectedQualification;
  String? _selectedExperienceYears;
  final TextEditingController _currentJobController = TextEditingController();

  // CV file (picked file)
  File? _cvFile;
  String? _cvFileName;
  // Terms checkbox
  bool _acceptedTerms = false;
  // For review display
  Map<String, String> _reviewData = {};
  bool _isSubmitting = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int? selectedcityid;
  @override
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
  List<ExperienceField> Experiencefields = [];
  List<EducationLevel> EducationLevels = [];
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

  Future<void> loadFields() async {
    final result = await api.getList<ExperienceField>(
      baseUrl: serverUrl,
      endpoint: 'Experiences/fields',
      fromJson: (json) => ExperienceField.fromJson(json),
    );
    if (result.success) {
      setState(() {
        Experiencefields = result.data!;
        loadeducationlevel();
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
  Future<void> loadeducationlevel() async {
    final result = await api.getList<EducationLevel>(
      baseUrl: serverUrl,
      endpoint: 'Lookups/educationLevels',
      fromJson: (json) => EducationLevel.fromJson(json),
    );
    if (result.success) {
      setState(() {
        EducationLevels = result.data!;
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
  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentJobController.dispose();
     _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_formKeyStep1.currentState?.validate() ?? false) {
        loadFields();
        _goToStep(2);
      }
    } else if (_currentStep == 2) {
      if (_formKeyStep2.currentState?.validate() ?? false) {
        _populateReviewData();
        _goToStep(3);
      } else if(_currentStep==3)
        {
          if (_acceptedTerms) {

          } else  {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('يرجى الموافقة على الشروط والأحكام')),
            );
          }
        }
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      _goToStep(_currentStep - 1);
    }
  }

  void _goToStep(int step) {
    _animationController.reverse().then((value) {
      setState(() {
        _currentStep = step;
      });
      _animationController.forward();
    });
  }

  void _populateReviewData() {
    _reviewData = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'city': _selectedCity ?? '',
      'mainField': _selectedMainField ?? '',
      'qualification': _selectedQualification ?? '',
      'experience': _selectedExperienceYears ?? '',
      'currentJob': _currentJobController.text.isEmpty
          ? 'غير محدد'
          : _currentJobController.text,
      'cvFileName': _cvFileName ?? 'لم يتم الرفع',
    };
  }

  Future<void> _pickCVFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: false,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5 MB

      if (fileSize > maxSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حجم الملف أكبر من 5 ميغابايت')),
        );
        return;
      }

      setState(() {
        _cvFile = file;
        _cvFileName = result.files.single.name;
      });
    }
  }

  Future<void> _sendDataToBackend() async {
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى رفع ملف السيرة الذاتية')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    var url=serverUrl+'auth/expert-register';
    final uri = Uri.parse(url);

    final request = http.MultipartRequest('POST', uri);

    // Add text fields
    request.fields['Email'] = _emailController.text.trim();
    request.fields['password'] = _passwordController.text.trim();
    request.fields['fullName'] = _fullNameController.text.trim();
    request.fields['phone'] = _phoneController.text.trim();
    request.fields['cityId'] = _selectedCity ?? '';
    request.fields['typeId'] = '3';
    request.fields['fieldId'] = _selectedMainField ?? '';
    request.fields['EducationLevelId'] = _selectedQualification ?? '';
    request.fields['experienceYears'] = _selectedExperienceYears ?? '';
    request.fields['workCompany'] = _currentJobController.text.trim();
    // Detect mime type
    final mimeType = lookupMimeType(_cvFile!.path) ?? 'application/octet-stream';
    final multipartFile = await http.MultipartFile.fromPath(
      'cvFile',
      _cvFile!.path,
      contentType: http.MediaType.parse(mimeType),
      filename: _cvFileName,
    );
    request.files.add(multipartFile);
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
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
        showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text("رسالة تسجيل"),
                content: Text('تم التسجيل كخبير بنجاح و سيتم مراجعة البيانات المرسلة و تأكيدها من قبل الإدارة في اقرب وقت'),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 0,userid: 0,)));
                    },
                    child: Text("إغلاق" , style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),),
                  ),
                ],
              );
            });


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

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإرسال، يرجى المحاولة لاحقاً')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الاتصال بالخادم')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _submitForm() {
    _sendDataToBackend();
  }

  Widget _buildProgressSteps() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepCircle(1, 'المعلومات الشخصية'),
          _buildStepLine(),
          _buildStepCircle(2, 'المجال والخبرة'),
          _buildStepLine(),
          _buildStepCircle(3, 'التأكيد'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool active = _currentStep == step;
    return Column(
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 400),
          width: active ? 38 : 32,
          height: active ? 38 : 32,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Color(0xFF3FC2CD),
            shape: BoxShape.circle,
            boxShadow: active
                ? [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.6),
                blurRadius: 8,
                offset: Offset(0, 3),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: SmartArabicText(
            text: step.toString(),
            baseSize:12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

        ),
        SizedBox(height: 6),
        SmartArabicText(
          text: label,
          baseSize:10,
          color: const Color(0xFF717070),
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 4,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.3)],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    if (isLoading) {
      return const FullScreenLoading(
        message: 'جاري تحميل البيانات...',
        withScaffold: true,
      );
    }
    return  SingleChildScrollView(child: Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                SmartArabicText(
                  text: 'المعلومات الشخصية',
                  baseSize:12,
                  color: Color(0xFF0B7780),
                  fontWeight: FontWeight.w700,
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
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
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
                  hint: const Text('اختر المدينة'),
                  value: _selectedCity,
                  icon: const Icon(Icons.keyboard_arrow_down, color: primaryBlue),
                  dropdownColor: Colors.white,
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city.id.toString(),
                      child: Text(city.cityName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCity = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار المدينة';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                      backgroundColor:  AppColors.primaryBlue,
                      shadowColor:  Colors.white, // same shadow as previous style
                    ),
                    child: SmartArabicText(
                        text: 'التالي',
                        baseSize:12,
                        color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
    ),
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
  bool _confirmobscurePassword = true;

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
  Widget _buildStep2() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return
      SingleChildScrollView(child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKeyStep2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmartArabicText(
                  text: 'المجال والخبرة',
                  baseSize:12,
                  color: Color(0xFF0B7780),
                  fontWeight: FontWeight.w700,
                ),

                SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: _selectedMainField,
                  decoration:
                  _dropdownDecoration('مجال التخصص الرئيسي', Icons.work_outline),
                  hint: Text('اختر مجال التخصص'),
                  items: Experiencefields.map((Experiencefield) {
                    return DropdownMenuItem(
                      value: Experiencefield.id.toString(),
                      child: Text(Experiencefield.experienceFieldTitle),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedMainField = val),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'يرجى اختيار المجال' : null,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedQualification,
                  decoration:
                  _dropdownDecoration('المؤهل العلمي', Icons.school_outlined),
                  hint: Text('اختر المؤهل العلمي'),
                  items: EducationLevels.map((EducationLevel) {
                    return DropdownMenuItem(
                      value: EducationLevel.id.toString(),
                      child: Text(EducationLevel.educationLevel1),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedQualification = val),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'يرجى اختيار المؤهل' : null,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedExperienceYears,
                  decoration:
                  _dropdownDecoration('سنوات الخبرة', Icons.history_outlined),
                  hint: Text('اختر سنوات الخبرة'),
                  items: [
                    'أقل من سنة',
                    '1-3 سنوات',
                    '3-5 سنوات',
                    '5-10 سنوات',
                    'أكثر من 10 سنوات'
                  ].map((exp) =>
                      DropdownMenuItem(value: exp, child: Text(exp))).toList(),
                  onChanged: (val) => setState(() => _selectedExperienceYears = val),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'يرجى اختيار سنوات الخبرة' : null,
                ),
                SizedBox(height: 20),
                _buildTextField(
                    controller: _currentJobController,
                    label: 'جهة العمل الحالية (اختياري)',
                    hint: 'اسم الجهة أو الشركة',
                    icon: Icons.business_outlined,
                    requiredField: false),
                SizedBox(height: 10),
                Text(
                  'السيرة الذاتية (PDF, DOC, DOCX - الحد الأقصى 5MB)',
                  style: TextStyle(
                    color: const Color(0xFF717070),
                    fontSize: 12,
                    fontFamily: 'Noto Kufi Arabic',
                    fontWeight: FontWeight.w700,
                    height: 2.17,
                    letterSpacing: -0.50,
                  ),
                ),
                SizedBox(height: 10),
                OutlinedButton.icon(
                  icon: Icon(Icons.upload_file),

                  label: Text(_cvFileName ?? 'رفع السيرة الذاتية' ,style: TextStyle(
                      color: const Color(0xFF717070),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 2,
                  letterSpacing: -0.50,
                ),
                  ),

                  onPressed: _pickCVFile,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14 ,horizontal: 7),
                    side: const BorderSide(
                      color: Color(0xFF0B7780), // border color
                      width: 1.0,
                    ),
                  ),
                ),
                if (_cvFileName != null) ...[
                  SizedBox(height: 12),
                  Text('ملف مرفوع: $_cvFileName',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text(
                    'سيتم مراجعة السيرة الذاتية من قبل إدارة المنصة قبل تفعيل حسابك',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _prevStep,
                        child:
                        SmartArabicText(
                          text: 'السابق',
                          baseSize:12,
                          color: Color(0xFF0B7780),
                         fontWeight: FontWeight.w700,),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        child:
                        SmartArabicText(
                        text: 'التالي',
    baseSize:12,
                          color: Colors.white,
    fontWeight: FontWeight.w700,),

                        style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    elevation: 4,
    backgroundColor:  AppColors.primaryBlue,
    shadowColor:  Colors.white, // same shadow as previous style

    ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
         );
  }
  Widget _buildStep3() {
    return SingleChildScrollView (child:  Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmartArabicText(
                  text: 'مراجعة البيانات',
                  baseSize:12,
                  color: Color(0xFF0B7780),
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: 24),
                _buildReviewItem('الاسم الكامل', _reviewData['fullName'] ?? ''),
                _buildReviewItem('البريد الإلكتروني', _reviewData['email'] ?? ''),
                _buildReviewItem('رقم الجوال', _reviewData['phone'] ?? ''),
                _buildReviewItem('المدينة', cities
                    .firstWhere((p) => p.id.toString() == _reviewData['city'].toString())
                    .cityName ?? ''),
                _buildReviewItem('مجال التخصص', Experiencefields
                    .firstWhere((p) => p.id.toString() == _reviewData['mainField'].toString())
                    .experienceFieldTitle ?? ''),
                _buildReviewItem('المؤهل العلمي', EducationLevels
                    .firstWhere((p) => p.id.toString() == _reviewData['qualification'].toString())
                    .educationLevel1 ??''),
                _buildReviewItem('سنوات الخبرة', _reviewData['experience'] ?? ''),
                _buildReviewItem('جهة العمل الحالية', _reviewData['currentJob'] ?? ''),

                SizedBox(height: 24),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppColors.primaryBlue, fontSize:13),
                      children: [
                        TextSpan(text: 'أوافق على '),
                        TextSpan(
                          text: 'شروط وأحكام',
                          style: TextStyle(
                            color: Color(0xFF9E855D),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(
                            text:
                            ' التسجيل كخبير وأقر بصحة المعلومات المقدمة'),
                      ],
                    ),
                  ),
                  value: _acceptedTerms,
                  onChanged: (val) {
                    setState(() {
                      _acceptedTerms = val ?? false;
                    });
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                onPressed: _prevStep,
                  child:SmartArabicText(
                    text: 'السابق',
                    baseSize:12,
                    color: Color(0xFF0B7780),
                    fontWeight: FontWeight.w700,),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),

                  ),
                ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _isSubmitting
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : Icon(Icons.check,color: Colors.white,),
                        label: SmartArabicText(
                          text: 'تأكيد التسجيل',
                          baseSize:12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        onPressed:
                        _acceptedTerms && !_isSubmitting ? _submitForm : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          backgroundColor:  AppColors.primaryBlue,
                          shadowColor:  Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    ),
    );
  }
  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
              child: SmartArabicText(
                text: label,
                baseSize:12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),

            ),
          const SizedBox(width: 15), // <-- add horizontal spacing here
          Expanded(
            flex: 5,
            child:
            SmartArabicText(
              text: value,
              baseSize:10,
              color: Color(0xFF0B7780),
              fontWeight: FontWeight.w500,
            ),

          ),
        ],
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


  @override
  Widget build(BuildContext context) {
    Widget stepContent;
    switch (_currentStep) {
      case 1:
        stepContent = _buildStep1();
        break;
      case 2:
        stepContent = _buildStep2();
        break;
      case 3:
        stepContent = _buildStep3();
        break;
      default:
        stepContent = Center(child: Text('خطأ في التنقل بين الخطوات'));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title:
        SmartArabicText(
          text: 'التسجيل كخبير',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 6,
        shadowColor: Colors.blueAccent.withOpacity(0.5),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(child: Column(
            children: [
              SizedBox(height: 16),
              _buildProgressSteps(),
              Divider(height: 24, thickness: 2, indent: 48, endIndent: 48),
              Expanded(child:
              stepContent),
            ],
          ),
      ),
      ),
    );
  }
}