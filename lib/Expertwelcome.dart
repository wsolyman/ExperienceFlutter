import 'dart:io';

import 'package:experience/LoginScreen.dart';
import 'package:experience/Myexperience.dart';
import 'package:experience/Myrequests.dart';
import 'package:experience/constant.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ExpienceRegister.dart';
import 'HomeScreen.dart';
import 'RegisterScreen.dart';

class Expertwelcome extends StatefulWidget {
  @override
  _ExpertwelcomeState createState() =>
      _ExpertwelcomeState();
}

class _ExpertwelcomeState extends State<Expertwelcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideUpAnimation;

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logined') ?? false;
    final experiencefield=prefs.getInt('fieldId');
    if (isLoggedIn) {
      if(experiencefield! >0)
        {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => Myexperience()),);
        }
      else if(experiencefield!<0)
        {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => Myrequests()),);
        }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  //  _checkLoginStatus();
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
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return SlideTransition(
      position: _slideUpAnimation,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            splashColor: color.withOpacity(0.2),
            child: Container(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(icon, size: 38, color: color),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SmartArabicText(
                          text:title,
                          baseSize:12,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),

                        SizedBox(height: 8),
                        SmartArabicText(
                          text: description,
                          baseSize:10,
                          color: Colors.grey

                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: color, size: 22),
                ],
              ),
            ),
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
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 0,userid: 0,)), // Replace with your home page
                  (route) => false,
            );
          },
        ),
        title:
        SmartArabicText(
          text: 'أهلا بك في صفحة التسجيل كخبير',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeInAnimation,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SmartArabicText(
                  text: 'تطبيق وقف الخبرة',
                  baseSize:12,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),
                SmartArabicText(
                  text:  'اذا كان لديك خبره يمكنك ارسال طلب تسجيل كخبير و سوف يتم الموافقه عليه من قبل الإدارة و لكي تتمكن من إضافة الخبرة الخاصة بك',
                  baseSize:10,
                  color: Colors.grey,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40),


                _buildOptionCard(
                  icon: Icons.support_agent_outlined,
                  title: 'التسجيل كخبير',
                  description: 'يمكنك التسجيل كخبير ووقف خبرتك في المجال الخاص بك',
                  onTap: _navigateToExpertRegistration,
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}