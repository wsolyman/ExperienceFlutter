
import 'dart:convert';

import 'package:experience/LoginScreen.dart';
import 'package:experience/main.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'MainWrapper.dart';
import 'constant.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

// This splash screen checks login status then redirects accordingly
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }
  bool _isLoading=false;
  Future<void> _login( String email,String password) async {
    setState(() {
      _isLoading = true;
    });

    final data = {
      'email':email,
      'password': password,
    };

    try {
      var url = serverUrl + 'Auth/login';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);
        SharedPreferences userpref = await SharedPreferences.getInstance();
        String profileImageUrl='no image';
        decodedData['profileUrl'] !=null ?  profileImageUrl = serverUrl+decodedData['profileUrl'].toString() : profileImageUrl='profileImageUrl';
        String fullname = decodedData['userName'].toString();
        String email = decodedData['email'].toString();
        String phone = decodedData['phone'].toString();
        String userTypeId=decodedData['userTypeId'].toString();
        String token = decodedData['token'].toString();
        int cartItemsCount=decodedData['cartItemsCount'];
        int userId=decodedData['userId'];
        int field=decodedData['fieldId'];
        userpref.setString("token", token);
        userpref.setString("email", email);
        userpref.setString("password", password);
        userpref.setString("fullname", fullname);
        userpref.setString("userTypeId", userTypeId);
        userpref.setString("email", email);
        userpref.setString("phone", phone);
        userpref.setBool('logined', true);
        userpref.setInt('fieldId', field);
        userpref.setInt('userId', userId);
        userpref.setInt('cartItemsCount', cartItemsCount);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 0,userid: 0,)),
              (route) => false,
        );
      }
      else if (response.statusCode == 400)
      {
        // Handle login failure
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      }
      else
      {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      }
    }
    catch (e)
    {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
      );
    } finally {
      setState(() {
     //   _isLoading = false;
      });
    }
  }
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logined') ?? false;
    if (isLoggedIn) {
      String email= prefs.getString('email') ?? '';
      String password= prefs.getString('password') ?? '';
      _login(email,password);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
            (route) => false,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    // Simple splash UI while checking login status
    return MainWrapper( child:
      Scaffold(
      body: Center(
        child: _isLoading ?  FullScreenLoading(
        message: 'جاري تحميل البيانات...',
        withScaffold: true,
      ) : Text('يوجد مشكلة في الاتصال بالخادم اغلق التطبيق و تاكد من الاتصال بالانترنت و حاول مره آخري') ,
      ),
    ));
  }
}