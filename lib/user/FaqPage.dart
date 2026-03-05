// faq_page.dart
import 'package:flutter/material.dart';
import '../constant.dart';
import '../service/SmartArabicText.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SmartArabicText(
          text: 'الاسئلة الشائعة',
          baseSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SmartArabicText(
                text: 'صفحة الاسئلة الشائعة - قيد الإنشاء',
                baseSize: 12,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}