import 'package:flutter/material.dart';
import '../constant.dart';
import '../service/SmartArabicText.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  SmartArabicText(
          text: 'الشروط والأحكام',
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
                  'مرحبًا بكم في تطبيق وقف الخبرة، وهو منصة رقمية تهدف إلى تمكين '
                      'الخبراء والمبدعين من وقف منتجاتهم وخبراتهم وإتاحتها ليصرف ريعها '
                      'لوقف الخبرة حسب صك الوقفية رقم ٤٢١٣٧٩١١٨ ووفق ضوابط محددة. '
                      'ويُعد استخدامك للتطبيق بمثابة موافقتك على الشروط والأحكام التالية:',
                ),

                _SectionTitle('1. التعريفات'),
                _Bullet(
                  '• المنصة/التطبيق: تطبيق وقف الخبرة والمنصة الرقمية التابعة له.\n'
                      '• إدارة الوقف: الجهة المشرفة والمسؤولة عن تقييم واعتماد ونشر المنتجات الموقوفة.\n'
                      '• الخبير/المساهم: كل شخص يقوم بتسجيل حساب ووقف منتج أو خبرة عبر المنصة.\n'
                      '• المنتج الموقوف: (كتاب، بحث، أداة، برنامج، دورة، استشارة أو أي محتوى معرفي آخر).\n'
                      '• المستخدم/المستفيد: كل شخص يقوم بالاستفادة من المنتجات الرقمية المعروضة.',
                ),

                _SectionTitle('2. شروط التسجيل'),
                _Bullet(
                  '• يشترط التسجيل باستخدام بيانات صحيحة وكاملة.\n'
                      '• يلتزم الخبير بتقديم معلومات حقيقية عن هويته وخبرته.\n'
                      '• لإدارة الوقف الحق في قبول أو رفض أي طلب تسجيل دون إبداء الأسباب.',
                ),

                _SectionTitle('3. شروط وقف المنتجات والخبرات'),
                _Bullet(
                  '• يشترط أن يكون المنتج ملكًا للخبير ملكية فكرية كاملة أو يمتلك حق التصرف فيه.\n'
                      '• يشترط أن يكون المحتوى:\n'
                      '  - لا يخالف الأنظمة في المملكة العربية السعودية والقيم والضوابط الشرعية.\n'
                      '  - خاليًا من حقوق نشر للغير.\n'
                      '  - مناسبًا للنشر والاستخدام العام.\n'
                      '• يحق لإدارة الوقف:\n'
                      '  - تقييم المنتج.\n'
                      '  - تسعيره.\n'
                      '  - مراجعته وتعديله عند الحاجة.\n'
                      '  - رفض أو تعليق نشر أي منتج لا يحقق المعايير.',
                ),

                _SectionTitle('4. طبيعة الوقف'),
                _Bullet(
                  '• جميع المنتجات والخبرات الموقوفة تصبح أصولًا وقفية رقمية تُدار لصالح وقف الخبرة.\n'
                      '• يقر الخبير بأن الوقف تنازل غير مسترد ولا يحق له المطالبة بإلغاء الوقف أو الحصول على عوائد مالية.',
                ),

                _SectionTitle('5. استخدام المحتوى'),
                _Bullet(
                  '• يحق للمستفيدين تحميل أو استخدام المنتجات وفق رخصة الاستخدام المحددة داخل المنصة.\n'
                      '• يمنع:\n'
                      '  - إعادة بيع المحتوى.\n'
                      '  - التعديل عليه دون إذن خطي من إدارة الوقف.\n'
                      '  - نشره خارج المنصة دون موافقة إدارة الوقف.',
                ),

                _SectionTitle('6. مسؤوليات المستخدم'),
                _Bullet(
                  '• يلتزم المستخدم بعدم إساءة استخدام المنصة.\n'
                      '• يلتزم الخبير بعدم تقديم محتوى مضلل أو منقول أو مخالف.\n'
                      '• يلتزم جميع المستخدمين باحترام حقوق النشر.',
                ),

                _SectionTitle('7. مسؤوليات إدارة الوقف'),
                _Bullet(
                  '• إدارة المنتجات والخبرات وفق أحكام الوقف المعتمدة.\n'
                      '• حفظ البيانات وفق أعلى مستوى من السرية.\n'
                      '• توفير المنصة وتشغيلها بأفضل أداء ممكن.\n'
                      '• لا تضمن توفر الخدمة بشكل دائم بسبب الأعطال التقنية الخارجة عن الإرادة.',
                ),

                _SectionTitle('8. سياسة الدفع والاستخدام'),
                _Bullet(
                  '• جميع العوائد الناتجة عن المنتجات الرقمية تعود لوقف الخبرة فقط.\n'
                      '• قد تتطلب بعض المنتجات رسومًا رمزية تُحوَّل بالكامل للوقف.\n'
                      '• لا تُعاد الرسوم بعد إتمام العملية لارتباطها بالوقف.',
                ),

                _SectionTitle('9. الملكية الفكرية'),
                _Bullet(
                  '• جميع الحقوق محفوظة لوقف الخبرة.\n'
                      '• تصميم التطبيق وواجهاته وخدماته محمية بموجب قوانين الملكية الفكرية.',
                ),

                _SectionTitle('10. إيقاف الحساب'),
                _Bullet(
                  '• يحق لإدارة الوقف إيقاف أي حساب في الحالات التالية:\n'
                      '  - مخالفة الشروط.\n'
                      '  - تقديم معلومات مضللة.\n'
                      '  - استخدام غير مشروع أو مسيء.',
                ),

                _SectionTitle('11. التعديل على الشروط'),
                _Bullet(
                  '• يحق لإدارة الوقف تحديث الشروط والأحكام في أي وقت، وسيتم إشعار المستخدمين بالتعديلات عند الضرورة.',
                ),

                _SectionTitle('12. التواصل'),
                _Bullet(
                  'للاستفسارات:\n'
                      '[البريد الإلكتروني (info@wafrh.org) –  (+966 55 933 0058) رقم التواصل]',
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
