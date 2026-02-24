import 'package:experience/service/NotificationService.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'LoginScreen.dart';
import 'MainWrapper.dart';
import 'SplashScreen.dart';
import 'constant.dart';
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('🔔 Background message: ${message.messageId}');
}

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   debugPrint('Handling a background message: ${message.messageId}');
// }
void main() async  {
   //WidgetsFlutterBinding.ensureInitialized();
   //await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );
  // Initialize notifications
 // final notificationService = NotificationService();
  //await notificationService.initialize();
  // const method = int.fromEnvironment('method', defaultValue: 1);
  //await NotificationService.initialize();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
  //runApp(NotificationWidget());
}
class NotificationWidget extends StatefulWidget {
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}
class _NotificationWidgetState extends State<NotificationWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked! ${message.messageId}');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Waiting for messages'),
    );
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  MaterialColor buildMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
       return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return  MaterialApp(
          title: 'المنصة الرقمية للمعرفة الموقوفة',
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              // يمنع الخط من التجاوز عن 1.2 ضعف الحجم الأصلي مهما فعل المستخدم في الإعدادات
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.1), // أو حدده بـ 1.1 لمرونة بسيطة
              ),
              child: child!,
            );
          },
          locale: const Locale('ar', 'SA'),  // اللغة العربية
          supportedLocales: const [
            Locale('ar', 'SA'),
          ],
          localizationsDelegates: const [
            // Built-in localization of basic text for Material widgets
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            primarySwatch: buildMaterialColor(AppColors.primaryBlue),
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'NotoKufiArabic',
           // textTheme: ArabicTextTheme.getTheme(),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryBlue, // Sets the background color of all AppBars
              foregroundColor: Colors.white, // Sets the default color for icons and text
            ),

          ),
          home: SplashScreen(),
        );
      },
      child: const OnboardingScreen(),
    );
  }
}
class ArabicTextTheme {
  static TextTheme getTheme() {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        height: 1.8, // Higher for Arabic
        letterSpacing: 0,
      ),
      displayMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        height: 1.8,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        height: 1.7,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        height: 1.7,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        height: 1.8, // Extra line height for Arabic
        letterSpacing: 0,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.8,
        letterSpacing: 0,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.7,
        letterSpacing: 0,
      ),
    );
  }
}
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(

      description: 'حيث تُحَوَّل المعرفة إلى صدقة جارية',
    ),
    OnboardingData(

      description: 'منصة رقمية تربط الخبراء بالمستفيدين بمنظومة وقفية متكاملة',
    ),
    OnboardingData(

      description: 'أوقف كتبك ودوراتك واستشاراتك... واجعل عطاءك أثراً لا ينقطع',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MainWrapper(
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color(0xFF06B6D4),
              Color(0xFF0D9488),
              AppColors.primaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.06),
              /// ---------- LOGO ----------
              Container(
                width: size.width * 0.35,
                height: size.width * 0.35,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: size.width * 0.35,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
             Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'المنصة الرقمية للمعرفة الموقوفة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.065,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

          ],
        ),
      ),

              /// ---------- CONTENT ----------
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (_, index) {
                    return _buildTextPage(_pages[index], size);
                  },
                ),
              ),
              const Text(
                "Developed and managed by",
                style: TextStyle(
                  color: Colors.white,
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
                    "assets/images/alkafaa.png",
                    height: 40,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      "alkafaa lilistisharat Company educational\n waltarbawiya sharikat shakhs wahid",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              /// ---------- DOTS ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (index) => _buildDot(index == _currentPage),
                ),
              ),

              SizedBox(height: size.height * 0.03),

              /// ---------- NEXT BUTTON ----------
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue,
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'ابدأ الآن'
                          : 'التالي',
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              /// ---------- SKIP ----------
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: const Text(
                  'تخطي والبدء',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    ));
  }

  /// ---------- TEXT PAGE ----------
  Widget _buildTextPage(OnboardingData data, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.05,
              color: Colors.white.withOpacity(0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 14 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


/// ---------- DATA MODEL ----------
class OnboardingData {

  final String description;
  OnboardingData({
    required this.description,
  });
}










