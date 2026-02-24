import 'package:experience/constant.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'ExpienceRegister.dart';
import 'RegisterScreen.dart';
class WelcomeRegistrationPage extends StatefulWidget {
  @override
  _WelcomeRegistrationPageState createState() =>
      _WelcomeRegistrationPageState();
}

class _WelcomeRegistrationPageState extends State<WelcomeRegistrationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideUpAnimation;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    _fadeInAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    _slideUpAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildOptionCard({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return  Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            splashColor: color.withOpacity(0.2),
            child: Container(
              decoration: ShapeDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.03, 0.50),
                  radius: 1.14,
                  colors: [const Color(0xFF028F9B), const Color(0xFF07636A)],
                ),
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 1, color: Colors.white),
                  borderRadius: BorderRadius.circular(29),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  )
                ],
              ),
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                    SvgPicture.asset(
                      'assets/icons/'+ icon ,
                      height: 46,
                      width: 49,

                    ),

                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFFF1B147),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 2.07,
                            letterSpacing: -0.50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
                ],
              ),
            ),
          ),


    );
  }

  void _navigateToExpertRegistration() {
    // Navigate to expert registration page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>Directionality( // add this
          textDirection: TextDirection.rtl, // set this property
          child: ExpienceRegister()),
      ),
    );
  }

  void _navigateToClientRegistration() {
    // Navigate to client registration page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>Directionality( // add this
          textDirection: TextDirection.rtl, // set this property
          child: Registerscreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        elevation: 0,

        title:
        SmartArabicText(
          text: 'أهلا بك في صفحة التسجيل',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),

      body:Container(
    decoration: const BoxDecoration(
    image: DecorationImage(
        image: AssetImage('assets/images/Background.jpg'),
    fit: BoxFit.cover,
    ),
    ),
    child:   Padding(
          padding: const EdgeInsets.symmetric(vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تطبيق وقف الخبرة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'اختر طريقة التسجيل المناسبة لك للبدء بالاستفادة من خدماتنا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,

                ),
              ),
              SizedBox(height: 40),

              _buildOptionCard(
                icon: 'expert.svg',
                title: 'التسجيل كخبير',
                description: 'سجّل كخبير وأوقف خبرتك، واصنع أثرًا مستدامًا.',
                onTap: _navigateToExpertRegistration,
                color: Colors.white,
              ),

              _buildOptionCard(
                icon: 'client.svg',
                title: 'التسجيل كعميل',
                description: 'سجّل كعميل وابدأ رحلتك مع منتجاتنا.',
                onTap: _navigateToClientRegistration,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}