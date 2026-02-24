import 'package:flutter/material.dart';
import '../constant.dart';
import '../service/SmartArabicText.dart';
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
        SmartArabicText(
          text: 'سياسة الخصوصية والأمان',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body:Container(
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
                  'نلتزم في وقف الخبرة وحسب نظام حماية خصوصية المستخدمين، '
                      'بتوضيح كيفية جمع بيانات المستخدمين واستخدامها وحمايتها.',
                ),

                _SectionTitle('1. البيانات التي يتم جمعها'),
                _Bullet(
                  '• بيانات شخصية: الاسم، البريد الإلكتروني، رقم الجوال.\n'
                      '• بيانات مهنية: الخبرات، المؤهلات.\n'
                      '• بيانات المنتجات الموقوفة.\n'
                      '• بيانات تقنية: نوع الجهاز، نظام التشغيل، عنوان IP.',
                ),

                _SectionTitle('2. كيفية استخدام البيانات'),
                _Bullet(
                  'نستخدم البيانات من أجل:\n'
                      '• إنشاء حساب المستخدم.\n'
                      '• إدارة المنتجات والخبرات الموقوفة.\n'
                      '• تحليل الأداء وتحسين الخدمات.\n'
                      '• التواصل مع المستخدم بشأن حسابه أو طلباته.',
                ),

                _SectionTitle('3. مشاركة البيانات'),
                _Bullet(
                  'لا نقوم بمشاركة البيانات إلا في الحالات التالية:\n'
                      '• مع الجهات المخولة نظاميًا.\n'
                      '• مع مزودي الخدمات التقنية للمنصة (وفق عقود سرية).\n'
                      '• عند الحاجة لحماية الحقوق أو الامتثال للأنظمة.',
                ),

                _SectionTitle('4. حماية البيانات'),
                _Bullet(
                  'نعتمد الإجراءات التالية:\n'
                      '• تشفير البيانات.\n'
                      '• أنظمة أمان متقدمة.\n'
                      '• حماية خارجية للخوادم.\n'
                      '• ولا نضمن حماية كاملة من الاختراقات الخارجة عن السيطرة.',
                ),

                _SectionTitle('5. حقوق المستخدم'),
                _Bullet(
                  'للمستخدم الحق في:\n'
                      '• طلب حذف بياناته.\n'
                      '• طلب تعديل معلوماته.\n'
                      '• إيقاف حسابه نهائيًا.',
                ),

                _SectionTitle('6. ملفات تعريف الارتباط (Cookies)'),
                _Paragraph(
                  'يستخدم التطبيق ملفات Cookies لتحسين تجربة المستخدم، '
                      'ويحق للمستخدم إيقافها من خلال إعدادات جهازه.',
                ),

                _SectionTitle('7. الموافقة'),
                _Paragraph(
                  'استخدامك للتطبيق يعني موافقتك الكاملة على سياسة الخصوصية والأمان.',
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

/* ===== Widgets المساعدة (نفس المثال السابق) ===== */

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
