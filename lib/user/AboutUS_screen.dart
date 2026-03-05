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
          baseSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
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
                    'تطبيق وقف الخبرة، هو منصة رقمية تهدف إلى تمكين '
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

                  // Add the new accordion section here
                  _SectionTitle('أنواع الوقف المعرفي'),
                  _EndowmentAccordion(),

                  // You can add more sections here if needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// New Accordion Widget
class _EndowmentAccordion extends StatefulWidget {
  const _EndowmentAccordion();

  @override
  __EndowmentAccordionState createState() => __EndowmentAccordionState();
}

class __EndowmentAccordionState extends State<_EndowmentAccordion> {
  // Track which items are expanded
  final List<bool> _isExpanded = List.generate(6, (index) => false);

  // Endowment types data
  final List<Map<String, String>> _endowmentTypes = const [
    {
      'title': 'الوقف المعرفي',
      'icon': '📚',
      'color': '0xFF27A8B3', // Teal
      'description': 'يختص بالمواد العلمية والبحثية المكتوبة، ويشمل الكتب، البحوث العلمية، الأدلة المهنية، والمناهج التعليمية التي يتم إيقافها لتكون متاحة للمستفيدين.',
      'examples': 'كتب، بحوث علمية، أدلة مهنية، مناهج تعليمية',
    },
    {
      'title': 'الوقف الاستشاري',
      'icon': '💡',
      'color': '0xFFFFBC38', // Gold
      'description': 'يعتمد على تقديم الجهد الذهني المباشر، حيث يخصص الخبير ساعات محددة من وقته لتقديم استشارات مهنية متخصصة في مجال خبرته.',
      'examples': 'استشارات مهنية، توجيه وإرشاد، خبرات استشارية',
    },
    {
      'title': 'الوقف التدريبي',
      'icon': '🎓',
      'color': '0xFF4CAF50', // Green
      'description': 'يركز على نقل المهارات وتطوير القدرات، ويتمثل في تقديم دورات تدريبية، ورش عمل، أو برامج تطويرية متكاملة.',
      'examples': 'دورات تدريبية، ورش عمل، برامج تطويرية',
    },
    {
      'title': 'الوقف التقني',
      'icon': '💻',
      'color': '0xFF2196F3', // Blue
      'description': 'يشمل الأصول الرقمية والبرمجية، مثل التطبيقات الذكية، الأنظمة المحوسبة، والأدوات الرقمية التي تُبنى لتسهيل مهام معينة أو خدمة قطاع محدد.',
      'examples': 'تطبيقات ذكية، أنظمة محوسبة، أدوات رقمية',
    },
    {
      'title': 'الوقف الإبداعي',
      'icon': '🎨',
      'color': '0xFFE91E63', // Pink
      'description': 'يستهدف الجانب الفني والبصري، ويشمل التصميمات الجرافيكية، الأعمال الفنية، والمحتوى المرئي (مثل الفيديوهات والمواد الإبداعية).',
      'examples': 'تصميمات جرافيكية، أعمال فنية، محتوى مرئي',
    },
    {
      'title': 'الوقف الزمني',
      'icon': '⏰',
      'color': '0xFF9C27B0', // Purple
      'description': 'هو التزام بتقديم الوقت، حيث يخصص الخبير عدداً محدداً من الساعات لخدمة مشروع في مجال خبرته، مساهماً في دعم أعمالهم.',
      'examples': 'ساعات تطوعية، وقت مخصص للمشاريع',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _endowmentTypes.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          return _buildAccordionItem(index);
        },
      ),
    );
  }

  Widget _buildAccordionItem(int index) {
    final item = _endowmentTypes[index];
    final color = Color(int.parse(item['color']!));

    return Container(
      decoration: BoxDecoration(
        color: _isExpanded[index]
            ? color.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item['icon']!,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            item['title']!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          trailing: Icon(
            _isExpanded[index]
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: color,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded[index] = expanded;
            });
          },
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    item['description']!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Examples section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'أمثلة على المنتجات:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['examples']!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the existing helper widgets
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
          height: 1.5,
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
          height: 1.5,
        ),
      ),
    );
  }
}