import 'dart:convert';

import 'package:experience/LoginScreen.dart';
import 'package:experience/OrdersPage.dart';
import 'package:experience/constant.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/user/AboutUS_screen.dart';
import 'package:experience/user/CertificatesScreen.dart';
import 'package:experience/user/ExpertProgressPage.dart';
import 'package:experience/user/NotificationScreen.dart';
import 'package:experience/user/SessionsScreen.dart';
import 'package:experience/user/help_screen.dart';
import 'package:experience/user/privacy_screen.dart';
import 'package:experience/user/profile_screen.dart';
import 'package:experience/user/terms_screen.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  String? userName;
  String? userEmail;
  int? usertypeid;
  double? totalEvaluations;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logined') ?? false;
    if (!isLoggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }  else
      {
        _loadUserData();
      }
  }
  String? profileImageUrl;
  bool isUploading = false;
  final ImagePicker _picker = ImagePicker();
  /// ---------- PICK IMAGE ----------
  Future<void> _pickAndUploadImage() async {
    final XFile? image =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image == null) return;
    setState(() => isUploading = true);
    try {
      final mimeType = lookupMimeType(image.path) ?? 'application/octet-stream';
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse( serverUrl+'Auth/UploadProfile'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'ImageFile', // backend field name
          contentType: http.MediaType.parse(mimeType),
          image.path,
        ),
      );
      final prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token')??'';
       request.headers['Authorization'] = 'Bearer $_token';
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        setState(() {
          profileImageUrl = serverUrl+data['profileUrl'];
          prefs.setString('profileImageUrl', profileImageUrl!);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isUploading = false);
    }
  }
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('fullname') ?? '';
      userEmail = prefs.getString('email') ?? '';
      usertypeid=int.parse(prefs.getString('userTypeId') ?? '0')  ?? 0;
      totalEvaluations=prefs.getDouble('totalEvaluations') ??0;
      String imageurl=prefs.getString('profileImageUrl').toString();
       imageurl== 'no image' ? profileImageUrl= null : profileImageUrl= prefs.getString('profileImageUrl').toString();

    });
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(opacity: animation, child: screen),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isRed = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      color: Colors.white,
      child: ListTile(
        onTap: onTap,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isRed ? Colors.red :  AppColors.primaryBlue,
        ),
        title:
        SmartArabicText(
          text: title,
          baseSize:12,
          textAlign: TextAlign.right,
          color: isRed ? Colors.red : Color(0xFF0B7780),
          fontWeight: FontWeight.w700,
        ),
        leading: Icon(
          icon,
          color: isRed ? Colors.red : AppColors.primaryBlue,
        ),
      ),
    );
  }
  Widget _buildRatingStars(double rating) {
    return Center(
      child:
     Row(
         mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < rating && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      })),
    );
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          title:
          SmartArabicText(
            text: 'الملف الشخصي',
            baseSize:12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primaryBlue,
          elevation: 2,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.grey[100],
        body:

        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
            Directionality(
              textDirection: TextDirection.rtl,
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Container(
                    width: size.width-50,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryBlue,
                          AppColors.primaryBlue,
                          Color(0xFF06B6D4),
                        ],
                      ),
                    ),
                    child: Column(
                children: [
                  /// ---------- AVATAR WITH BUTTON ----------
                  SizedBox(
                    width: size.width * 0.28,
                    height: size.width * 0.28,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        /// AVATAR
                        Container(
                          width: size.width * 0.28,
                          height: size.width * 0.28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEFF6FF),
                            image: profileImageUrl != null
                                ? DecorationImage(
                              image: NetworkImage(profileImageUrl!),
                              fit: BoxFit.cover,
                            )
                                : null,
                          ),
                          child: profileImageUrl == null
                              ? const Icon(
                            Icons.person_outline,
                            size: 48,
                            color: Color(0xFF2563EB),
                          )
                              : null,
                        ),
                        /// LOADING
                        if (isUploading)
                          Container(
                            width: size.width * 0.28,
                            height: size.width * 0.28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Column(
                              children: [
                                const Text('جاري تحديث البيانات...'),
                                const SizedBox(height: 16),
                                const MediumLoadingWidget(),
                              ],
                            ),
                          ),

                        /// CAMERA BUTTON ✅
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: InkWell(
                            onTap: isUploading ? null : _pickAndUploadImage,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  /// Upload Loader

                  const SizedBox(height: 12),

                  /// ---------- NAME ----------

                  SmartArabicText(
                    text: userName ?? '',
                    baseSize:10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),


                  const SizedBox(height: 4),

                  /// ---------- ROLE ----------
                  SmartArabicText(
                    text: usertypeid==3 ? 'خبير معتمد' : 'عميل',
                    baseSize:10,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  /// ---------- RATING ----------
                  usertypeid==3 ?
                  _buildRatingStars(totalEvaluations ?? 0) : const SizedBox(height:0),
                ],
              ),
            ),
                  const SizedBox(height: 8),

                  _buildMenuItem(Icons.calendar_today, 'جلساتي', () {
                    _navigateTo(context, SessionsScreen());
                  }),

              _buildMenuItem(Icons.shopping_bag, 'طلباتي', () {
                _navigateTo(context, OrdersPage());
              }),
              _buildMenuItem(Icons.person_outline, 'البيانات الشخصية',  () {
                _navigateTo(context, ProfilePage());
              }),

              _buildMenuItem(Icons.notifications_outlined, 'الإشعارات', () {
                _navigateTo(context, NotificationsScreen());
              }),
              if( usertypeid==3)
              _buildMenuItem(Icons.document_scanner, 'إصدار الشهادة الوقفية',  () {
            _navigateTo(context, CertificatesScreen());
              }) ,
              _buildMenuItem(Icons.security, 'الخصوصية والأمان', () {
                _navigateTo(context, PrivacyPolicyPage());

              }),
              _buildMenuItem(Icons.help_outline, 'المساعدة والدعم',  () {
                _navigateTo(context, ContactUsPage());
              }),
              _buildMenuItem(Icons.description, 'الشروط والأحكام', () {
                _navigateTo(context, TermsAndConditionsPage());
              }),

                _buildMenuItem(Icons.shopping_bag, 'عن التطبيق',  () {
                  _navigateTo(context, AboutPage());
                }),

              const SizedBox(height: 8),
              _buildMenuItem(Icons.logout, 'تسجيل الخروج', () {
                // Clear SharedPreferences and redirect to login or home
                _logout();
              }, isRed: true),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ]
          ),
        ),
      ),
    );
  }
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) =>LoginScreen()),
          (route) => false,
    );
  }
}

class SampleScreen extends StatelessWidget {
  final String title;
  const SampleScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        SmartArabicText(
          text: title,
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:
        Center(
        child: Text(
          '$title',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      ),
    );
  }
}