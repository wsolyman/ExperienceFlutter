import 'package:experience/service/SmartArabicText.dart';
import 'package:flutter/material.dart';

import 'constant.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<String> texts = [
    'حيث تُحَوَّل المعرفة إلى صدقة جارية',
    'شارك خبرتك لتصنع أثرًا مستدامًا',
    'منصة رقمية لوقف المعرفة',
  ];

  void nextPage() {
    if (currentPage < texts.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      // TODO: Navigate to Home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),

              /// Logo
              Image.asset(
                'assets/logo.png',
                height: 110,
              ),

              const SizedBox(height: 30),

              /// Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: SmartArabicText(
                  text: 'المنصة الرقمية للمعرفة الموقوفة',
                  baseSize:15,
                  textAlign: TextAlign.center,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// ---------- Animated Pages ----------
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: texts.length,
                  onPageChanged: (index) {
                    setState(() => currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = (_pageController.page! - index);
                          value = (1 - value.abs()).clamp(0.0, 1.0);
                        }

                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(40 * (1 - value), 0),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child:
                        SmartArabicText(
                          text: texts[index],
                          baseSize:14,
                          color: AppColors.textGrey,
                        ),

                      ),
                    );
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
              const SizedBox(height: 12),
              /// ---------- Progress Dots ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  texts.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: currentPage == index ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? AppColors.primaryBlue
                          : AppColors.dotInactive,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              /// ---------- Next Button ----------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: nextPage,
                    child: Text(
                      currentPage == texts.length - 1
                          ? 'ابدأ الآن'
                          : 'التالي',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// ---------- Skip ----------
              TextButton(
                onPressed: () {
                  // TODO: Navigate to Home
                },
                child: const Text(
                  'تخطي والبدء',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
