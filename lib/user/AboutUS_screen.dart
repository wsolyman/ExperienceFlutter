import 'package:flutter/material.dart';
import '../constant.dart';
import '../service/SmartArabicText.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: SmartArabicText(
          text: 'عن التطبيق',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body:
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:
        SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Paragraph(
                  ' تطبيق وقف الخبرة، هو منصة رقمية تهدف إلى تمكين '
                      'الخبراء والمبدعين من وقف منتجاتهم وخبراتهم وإتاحتها ليصرف ريعها '
                      'لوقف الخبرة حسب صك الوقفية رقم ٤٢١٣٧٩١١٨ ووفق ضوابط محددة. '
                      'ويُعد استخدامك للتطبيق بمثابة موافقتك على الشروط والأحكام التالية:',
                ),

                _SectionTitle('التعريف'),
                _Bullet(
                  '• المنصة/التطبيق: تطبيق وقف الخبرة والمنصة الرقمية التابعة له.\n'
                      '• إدارة الوقف: الجهة المشرفة والمسؤولة عن تقييم واعتماد ونشر المنتجات الموقوفة.\n'
                      '• الخبير/المساهم: كل شخص يقوم بتسجيل حساب ووقف منتج أو خبرة عبر المنصة.\n'
                      '• المنتج الموقوف: (كتاب، بحث، أداة، برنامج، دورة، استشارة أو أي محتوى معرفي آخر).\n'
                      '• المستخدم/المستفيد: كل شخص يقوم بالاستفادة من المنتجات الرقمية المعروضة.',
                ),

              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

/* ===== Widgets المساعدة ===== */

class _MainTitle extends StatelessWidget {
  final String text;
  const _MainTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}
