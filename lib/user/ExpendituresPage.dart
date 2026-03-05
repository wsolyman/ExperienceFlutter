// expenditures_page.dart
import 'package:flutter/material.dart';
import '../constant.dart';
import '../service/SmartArabicText.dart';

class ExpendituresPage extends StatelessWidget {
  const ExpendituresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: SmartArabicText(
          text: 'مصارف الوقف',
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: 24,
            ),
            child: Column(
              children: [
                // Main Title Section with Description
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      SmartArabicText(
                        text: 'مصـــــارف الوقـــــف',
                        baseSize: isTablet ? 14 :12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 10),
                      // Decorative line
                      Container(
                        width: 80,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Description text
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                        ),
                        child: SmartArabicText(
                          text: 'تُخصص عوائد الوقف بما يحقق أهدافه ويعظم أثره التنموي والمعرفي، وذلك من خلال المصارف التالية:',
                          baseSize: isTablet ? 14 : 12,
                          color: AppColors.textGrey,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                // Three Cards Row
                isTablet
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildExpenditureCard(
                        context: context,
                        imagePath: 'assets/images/expend-1.jpg',
                        title: 'رغبة الواقف',
                        description: 'أوجه الصرف التي يرغب الخبراء الواقفون أن تكون مخصصة لعوائد منتجاتهم، وبما يتوافق مع أهداف وقف الخبرة ومصارفه ويحقق نموه ومضاعفة أثره.',
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: _buildExpenditureCard(
                        context: context,
                        imagePath: 'assets/images/expend-2.png',
                        title: 'بناء الإنسان',
                        description: 'البرامج التدريبية والمنتجات التطويرية التي تنمي مهارات الشباب بما يعود عليهم وعلى أسرهم ومجتمعاتهم وأوطانهم والإنسانية بالنفع والخير.',
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: _buildExpenditureCard(
                        context: context,
                        imagePath: 'assets/images/expend-3.png',
                        title: 'تطوير المنشآت',
                        description: 'البرامج التدريبية والمنتجات التطويرية التي تسهم في رفع كفاءة المنشآت بما يحقق النفع العام للمجتمع وفق أعلى معايير الابتكار والجودة والتميز.',
                        isTablet: isTablet,
                      ),
                    ),
                  ],
                )
                    : Column(
                  children: [
                    _buildExpenditureCard(
                      context: context,
                      imagePath: 'assets/images/expend-1.jpg',
                      title: 'رغبة الواقف',
                      description: 'أوجه الصرف التي يرغب الخبراء الواقفون أن تكون مخصصة لعوائد منتجاتهم، وبما يتوافق مع أهداف وقف الخبرة ومصارفه ويحقق نموه ومضاعفة أثره.',
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20),
                    _buildExpenditureCard(
                      context: context,
                      imagePath: 'assets/images/expend-2.png',
                      title: 'بناء الإنسان',
                      description: 'البرامج التدريبية والمنتجات التطويرية التي تنمي مهارات الشباب بما يعود عليهم وعلى أسرهم ومجتمعاتهم وأوطانهم والإنسانية بالنفع والخير.',
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20),
                    _buildExpenditureCard(
                      context: context,
                      imagePath: 'assets/images/expend-3.png',
                      title: 'تطوير المنشآت',
                      description: 'البرامج التدريبية والمنتجات التطويرية التي تسهم في رفع كفاءة المنشآت بما يحقق النفع العام للمجتمع وفق أعلى معايير الابتكار والجودة والتميز.',
                      isTablet: isTablet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenditureCard({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    required bool isTablet,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Container
          Container(
            width: isTablet ? 120 : 100,
            height: isTablet ? 120 : 100,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image doesn't exist
                  return Container(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: AppColors.primaryBlue.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SmartArabicText(
              text: title,
              baseSize: isTablet ? 18 : 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Description
          SmartArabicText(
            text: description,
            baseSize: isTablet ? 14 : 12,
            color: AppColors.textGrey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}