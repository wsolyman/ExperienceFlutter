import 'dart:convert';
import 'dart:math';
import 'package:experience/constant.dart';
import 'package:experience/service/NotificationService.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Expertwelcome.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';
import 'Myrequests.dart';
import 'SkeletonBox.dart';
import 'model/Exprience.dart';

class FirstHomeScreen extends StatefulWidget {
  @override
  _FirstHomeScreen createState() => _FirstHomeScreen();
}
class _FirstHomeScreen extends State<FirstHomeScreen> {
  bool isLoading = false;
  int products = 0;
  int experts = 0;
  double sales = 0;
  int purchaser = 0;
  List<Experience> experiences = [];
  final notificationService = NotificationService();
  var url = serverUrl + 'Experiences';
  var ststurl = serverUrl + 'Lookups/HomePageStatistics';
  late final ApiService apiService = ApiService(baseUrl: url);
  String fcmToken = '';

  Future<void> getstat() async {
    setState(() {});

    try {
      final response = await http.get(
        Uri.parse(ststurl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);
        setState(() {
          products = decodedData['products'];
          experts = decodedData['experts'];
          sales = decodedData['sales'];
          purchaser = decodedData['purchaser'];
        });
        fetchExperiences();
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال بالخادم')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال بالخادم')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال بالخادم')),
      );
    } finally {
      setState(() {});
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final isLoggedIn = prefs.getBool('logined') ?? false;
      final experiencefield = prefs.getInt('fieldId');
      if (isLoggedIn) {
        if (experiencefield! > 0) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HomeScreen(selectedIndex: 3, userid: 0),
            ),
          );
        } else if (experiencefield! == 0) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => Myrequests()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => Expertwelcome()));
        }
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  Future<void> fetchExperiences({bool reset = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      if (reset) {
        experiences.clear();
      }
    });
    try {
      int isapproved = 1;
      final result = await apiService.fetchExperiences(
        0,
        categoryId: null,
        userid: null,
        isapproved: isapproved,
        search: null,
        pageSize: 3,
      );
      final newExperiences = result['experiences'] as List<Experience>;
      setState(() {
        experiences.addAll(newExperiences);
      });
    } catch (e) {
      // handle error
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool isAddtocardLoading = false;

  void initState() {
    super.initState();
    intiatefirebase();
  }

  intiatefirebase() async {
    await notificationService.initialize();
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logined') ?? false;
    String _firebaset = prefs.getString('firebaseToken') ?? '';
    if (isLoggedIn) fcmToken = prefs.getString('fcmToken')! ?? '';
    if (_firebaset != fcmToken) updatefirbasetoken(fcmToken);
    getstat();
  }

  Future<void> updatefirbasetoken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token') ?? '';
    Map<String, dynamic> data = {'firebaseToken': fcmToken};
    try {
      var url = serverUrl + 'Auth/UpdateFirebaseToken';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);
        SharedPreferences userpref = await SharedPreferences.getInstance();
        userpref.setString("fcmToken", fcmToken);
      } else if (response.statusCode == 400) {
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
                  style: ButtonStyle(
                      backgroundColor:
                      WidgetStateProperty.all(AppColors.primaryBlue)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "إغلاق",
                    style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الاتصال بالخادم')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال بالخادم')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    final isTablet = screenWidth >= 600;

    // Responsive padding values
    final horizontalPadding = screenWidth * 0.04;
    final verticalSpacingSmall = screenHeight * 0.015;
    final verticalSpacingMedium = screenHeight * 0.025;
    final verticalSpacingLarge = screenHeight * 0.035;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section - Responsive height
                Container(
                  height: screenHeight * 0.45, // Reduced from 0.45 for better balance
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: screenHeight * 0.05,
                  ),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/cbackground.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Badge
                      const SizedBox(width: 6),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            'وقف معرفي مستدام',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacingSmall),
                      // Title
                      Text(
                        'حوّل خبرتك إلى منتجات وقفية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.065, // Slightly reduced
                          height: 1.3,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFBC38),
                        ),
                      ),
                      SizedBox(height: verticalSpacingSmall * 0.5),
                      // Description
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Text(
                          'أوقف منتجاتك المعرفية واجعل عوائدها صدقة جارية تنفع المجتمع',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white70,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      SizedBox(height: verticalSpacingMedium),
                      // Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D9488),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                        label: Text(
                          'ابدأ الآن',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          _checkLoginStatus();
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacingMedium),

                // Stats Grid - Now it's properly sized
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isTablet ? 4 : 2,
                    childAspectRatio: isTablet ? 1.3 : 1.1, // Better aspect ratio
                    crossAxisSpacing: screenWidth * 0.03,
                    mainAxisSpacing: screenHeight * 0.015,
                    children: [
                      _buildStatCard(
                        screenWidth,
                        screenHeight,
                        'shopping.svg',
                        products.toString(),
                        'إجمالي المنتجات',
                        Colors.blue,
                      ),
                      _buildStatCard(
                        screenWidth,
                        screenHeight,
                        'leadership.svg',
                        experts.toString(),
                        'الخبراء المساهمون',
                        Colors.green,
                      ),
                      _buildStatCard(
                        screenWidth,
                        screenHeight,
                        'coin.svg',
                        '$sales K',
                        'إجمالي المبيعات',
                        Colors.orange,
                      ),
                      _buildStatCard(
                        screenWidth,
                        screenHeight,
                        'financial.svg',
                        purchaser.toString(),
                        'المشترون',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacingMedium),

                // Featured Products Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المنتجات المميزة',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0B7780),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HomeScreen(selectedIndex: 1, userid: 0,searchtext: null),
                                ),
                              );
                            },
                            child: Text(
                              'عرض الكل ←',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: verticalSpacingSmall),

                      // Products List
                      isAddtocardLoading
                          ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: verticalSpacingMedium),
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : Column(
                        children: List.generate(
                          experiences.isEmpty ? 3 : experiences.length,
                              (index) {
                            if (experiences.isEmpty && isLoading) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: verticalSpacingSmall),
                                child: buildExperienceSkeleton(),
                              );
                            }
                            if (index < experiences.length) {
                              Experience exp = experiences[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: verticalSpacingMedium),
                                child: _buildProductCard(
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  icon: exp.category.iconUrl,
                                  title: exp.exprienceName,
                                  type: exp.category.categoryName,
                                  field: exp.field.exprienceFieldTitle,
                                  rating: exp.user.totalEvaluations ?? 0,
                                  sales: exp.user.itemsPurchased ?? 0,
                                  price: '${exp.price} ر.س',
                                  oldPrice: '799 ر.س',
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacingMedium),
                // CTA Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _buildCtaCard(screenWidth, screenHeight),
                ),
                SizedBox(height: verticalSpacingLarge), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildExperienceSkeleton() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          const SkeletonBox(height: 40, width: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 16, width: double.infinity),
                SizedBox(height: 8),
                SkeletonBox(height: 12, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(double screenWidth, double screenHeight, String icon,
      String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 7,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/$icon',
            height: screenHeight * 0.03,
            width: screenHeight * 0.03,
            colorFilter: const ColorFilter.mode(
              AppColors.primaryBlue,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03, vertical: screenHeight * 0.008),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              value,
              style: TextStyle(
                  fontSize: screenWidth * 0.035, color: Colors.white),
            ),
          ),
          SizedBox(height: screenHeight * 0.008),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: screenWidth * 0.032, color: Color(0xFF717070)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required double screenWidth,
    required double screenHeight,
    required String icon,
    required String title,
    required String type,
    required String field,
    required double rating,
    required int sales,
    required String price,
    String? oldPrice,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            /// Right colored bar
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: screenWidth * 0.08,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B7780),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04,
                screenHeight * 0.02,
                screenWidth * 0.12,
                screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0B7780),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: screenHeight * 0.01),

                  /// Category button
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.008,
                    ),
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF27A8B3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.032),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  /// Rating + sales
                  Row(
                    children: [
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0B7780),
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      _buildRatingStars(rating, screenWidth),
                      SizedBox(width: screenWidth * 0.02),
                      Text('($sales مبيع)',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: screenWidth * 0.032)),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  /// Price
                  Text(
                    price,
                    style: TextStyle(
                      color: Color(0xFF0B7780),
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),

            /// Back arrow (left)
            Positioned(
              left: screenWidth * 0.03,
              top: screenHeight * 0.08,
              child: GestureDetector(
                onTap: () {
                  // Add your click functionality here
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          HomeScreen(selectedIndex: 1, userid: 0,searchtext: title),
                    ),
                  );
                  // Example: Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: screenWidth * 0.04,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Color(0xFF0B7780),
                    size: screenWidth * 0.04,
                  ),
                ),
              ),
            ),

            /// Icon (right)
            Positioned(
              right: screenWidth * 0.01,
              top: screenHeight * 0.06,
              child: CircleAvatar(
                radius: screenWidth * 0.05,
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  'assets/icons/' + icon,
                  height: screenHeight * 0.035,
                  width: screenHeight * 0.035,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryBlue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaCard(double screenWidth, double screenHeight) {
    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.35),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/plant.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Opacity(
        opacity: 0.80,
        child: Container(
          decoration: ShapeDecoration(
            color: const Color(0xFF0B7780),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(29),
            ),
            shadows: [
              BoxShadow(
                color: Color(0xFF1D1B20),
                blurRadius: 2.40,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge
                Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    textAlign: TextAlign.center,
                    'لديك منتج معرفي؟',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    'أوقف منتجاتك المعرفية واجعلها مصدر دخل مستدام ينفع المجتمع',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFBC38),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D9488),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: Icon(Icons.add, size: screenWidth * 0.05),
                  label: Text(
                    'أضف منتجك الآن',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    _checkLoginStatus();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingStars(double rating, double screenWidth) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star,
              color: Colors.amber, size: screenWidth * 0.04);
        } else if (index < rating && rating % 1 != 0) {
          return Icon(Icons.star_half,
              color: Colors.amber, size: screenWidth * 0.04);
        } else {
          return Icon(Icons.star_border,
              color: Colors.amber, size: screenWidth * 0.04);
        }
      }),
    );
  }
}