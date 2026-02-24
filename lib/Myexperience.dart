import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddExperience.dart';
import 'Expertwelcome.dart';
import 'LoginScreen.dart';
import 'Myrequests.dart';
import 'SkeletonBox.dart';
import 'constant.dart';
import 'model/Exprience.dart';

class Myexperience extends StatefulWidget {
  @override
  _MyexperienceState createState() => _MyexperienceState();
}
class _MyexperienceState extends State<Myexperience> {
  var url = serverUrl + 'Experiences';
  late final ApiService apiService = ApiService(baseUrl: url);
  List<Experience> experiences = [];
  bool isLoading = false;
  int currentPage = 0;
  bool hasNextPage = true;
  int selectedCategoryId=0;
  List<Category> categories = []; // Populate via API or static list
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _scrollController.addListener(_scrollListener);
    fetchCategories();
    fetchExperiences();

  }
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        hasNextPage) {
      fetchExperiences();
    }
  }
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final isLoggedIn = prefs.getBool('logined') ?? false;
      final experiencefield=prefs.getInt('fieldId');
      if (isLoggedIn) {
        if(experiencefield! >0)
        {
         return;
        }
        else if(experiencefield! ==0)
        {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Myrequests()),
                (route) => false,
          );

        }
        else
        {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Expertwelcome()),
                (route) => false,
          );

        }
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
        );
      }
    });

  }
  void fetchCategories() {
    // Provide your categories here or fetch from API
    categories = [
      Category(categoryId: 0, categoryName: 'الكل',iconUrl: ''),
      Category(categoryId: 1, categoryName: 'الوقف المعرفي',iconUrl: ''),
      Category(categoryId: 2, categoryName: 'الوقف الاستشاري',iconUrl: ''),
      Category(categoryId: 3, categoryName: 'الوقف التدريبي',iconUrl: ''),
      Category(categoryId: 4, categoryName: 'الوقف التقني',iconUrl: ''),
      Category(categoryId: 5, categoryName: 'الوقف الإبداعي',iconUrl: ''),
      Category(categoryId: 6, categoryName: 'الوقف الزمني',iconUrl: ''),
    ];
  }

  Future<void> fetchExperiences({bool reset = false}) async {
    if (isLoading || !hasNextPage) return;

    setState(() {
      isLoading = true;
      if (reset) {
        experiences.clear();
        currentPage = 0;
        hasNextPage = true;
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      int userid = prefs.getInt('userId')??0;
      int isapproved=0;
      final result = await apiService.fetchExperiences(currentPage, categoryId: selectedCategoryId == 0 ? null : selectedCategoryId , userid: userid == 0 ? null : userid,isapproved: isapproved == 0 ? null : isapproved);
      final newExperiences = result['experiences'] as List<Experience>;
      setState(() {
        experiences.addAll(newExperiences);
        hasNextPage = result['hasNextPage'];
        currentPage++;
      });
    } catch (e) {
      // handle error
    } finally {
      setState(() => isLoading = false);
    }
  }
  void _onCategorySelected(int categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
    });
    fetchExperiences(reset: true);
  }

  void showExperienceDetails(BuildContext context, Experience experience) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          initialChildSize: 0.7,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    experience.exprienceName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),

                  SizedBox(height: 16),
                  _buildReviewItem('الفئة', experience.category.categoryName),
                  _buildReviewItem('المجال', experience.field.exprienceFieldTitle),
                  if (experience.category.categoryId == 1)
                    _buildknowledgeFields(experience),
                  if (experience.category.categoryId == 4)
                    _buildTechnicalFields(experience),
                  if (experience.category.categoryId == 5)
                    _buildCreativeFields(experience),
                  if (experience.category.categoryId == 6)
                    _buildTimeFields(experience),
                  if (experience.category.categoryId == 3) // الوقف التدريبي
                    _buildTrainingFields(experience),
                  if (experience.category.categoryId == 2)
                    _buildConsultFields(experience),
                  if (experience.category.categoryId == 2) // الوقف الاستشاري
                    _buildConsultingSessions(experience.sessions),
                ],
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            flex: 3,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 2.92,
                  letterSpacing: -0.50,
                ),
              ),
          ),
          const SizedBox(width: 15), // <-- add horizontal spacing here
          Expanded(
            flex: 5,
            child: Text(
                value,
                style:
                SmartArabicTextStyle.create(color: Color(0xFF717070) ,baseSize: 12,fontWeight: FontWeight.w500, context: context)
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTrainingFields(Experience exp) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('نوع التدريب:', exp.trainingType!.trainningType.toString()),
        _buildReviewItem('مدة الدورة:', exp.sessionPeriodinminutes.toString() ?? ''),
        _buildReviewItem('عدد المقاعد المتاحة:', exp.noofSeats.toString()),
        _buildReviewItem('المستوى:', exp.trainingLevel!.trainingLevelTitle ?? ''),
        _buildReviewItem('طريقة التقديم:', exp.deliveryMethod!.deliveryMethodTitle ?? ''),
        _buildReviewItem('المحاور الرئيسية للدورة:', exp!.trainningTopics ?? ''),
        _buildReviewItem('المتطلبات الأساسية:', exp!.trainningRequirement ?? ''),
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
      ],
    );
  }
  Widget _buildCreativeFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('نوع العمل:', exp.trainingType!.trainningType),
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1),
        _buildReviewItem('صيغة الملفات:', exp.filesFormate ?? ''),
        _buildReviewItem('نوع الترخيص:', exp.licenseType!.liciensyTypeTitle),
        // _buildReviewItem('رابط الملفات:',exp.deliveryLink ?? ''),
      ],
    );
  }
  Widget _buildTechnicalFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('نوع المنتج التقني:', exp.trainingType!.trainningType),
        _buildReviewItem('لغة البرمجة/التقنية:', exp.programmingLangauge ?? '' ),
        _buildReviewItem('نوع الترخيص:', exp.licenseType!.liciensyTypeTitle ?? ''),
        //_buildReviewItem('الميزات الرئيسية:', exp.  _techFeaturesController.text),
        _buildReviewItem('المتطلبات التقنية:', exp.trainningRequirement?? ''),
        // _buildReviewItem('التوثيق المتوفر:', _techDocumentation.entries.where((e) => e.value).map((e) => e.key).join(', ')),
        //_buildReviewItem('مدة الوقف:', Periods.firstWhere((p) => p.id.toString() == _techWaqfDuration.toString()).expriencePeriod1 ?? ''),
      ],
    );
  }
  Widget _buildTimeFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1),
        _buildReviewItem('الوقت المتاح أسبوعياً', exp.availablesHoures.toString()),
        _buildReviewItem('الأيام المتاحة',  exp.dayes.toString()),
        _buildReviewItem('الفترات الزمنية المتاحة', exp.availableIntervales ?? ''),
        _buildReviewItem('طريقة المشاركة', exp.deliveryMethod!.deliveryMethodTitle ),
        _buildReviewItem('نوع المشروع',exp.trainingType!.trainningType ?? ''),
      ],
    );
  }
  Widget _buildConsultFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
        _buildReviewItem('مدة الجلسة الاستشارية:', exp.sessionPeriodinminutes.toString() ?? ''),
        _buildReviewItem('الأيام المتاحة:', exp.dayes ?? ''),
        _buildReviewItem('تاريخ البداية', exp.startDate ?? ''),
        _buildReviewItem('وقت البداية', exp.startTime ?? ''),
      ],
    );
  }
  Widget _buildknowledgeFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
      ],
    );
  }
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$title: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(child: Text(value, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
  Widget _buildConsultingSessions(List<ExperienceSession>? sessions) {
    if (sessions == null || sessions.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد جلسات استشارية',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        const SmartArabicText(
          text: 'الجلسات الاستشارية:',
          baseSize:10,
          color: Color(0xFF0B7780),
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),

        ...sessions.map(
              (session) => Card(
            color: Colors.white,
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Session info
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${ englishToArabicDays[session.exprienceDay] ?? session.exprienceDay } - ${session.exprienceDate!}',
                          style: const TextStyle(color: Color(0xFF0B7780)),
                        ),
                      ),
                      Text(
                        '${session.price} ر.س',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text('من ${session.fromTime} إلى ${session.toTime}'),
                  const SizedBox(height: 12),
                  /// Action buttons

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        SmartArabicText(
          text: 'خبراتي',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Directionality(
                    textDirection: TextDirection.rtl,
                    child: AddExperience(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:
        Column(
        children: [
          /// Categories
          // SizedBox(
          //   height: 52,
          //   child: buildCategorySlider(
          //     categories,
          //     selectedCategoryId,
          //     _onCategorySelected,
          //   ),
          // ),

          /// List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: isLoading && experiences.isEmpty
                  ? 6
                  : experiences.length + (hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                /// Skeleton First Load
                if (experiences.isEmpty && isLoading) {
                  return buildExperienceSkeleton();
                }

                /// Pagination Loader
                if (index == experiences.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final exp = experiences[index];
                return buildExperienceListTile(
                  exp,
                      () => showExperienceDetails(context, exp),
                );
              },
            ),
          ),
        ],
      ),),
    );
  }

  Widget buildExperienceSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          const SkeletonBox(height: 40, width: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBox(height: 16, width: double.infinity),
                SizedBox(height: 8),
                SkeletonBox(height: 12, width: 150),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategorySlider(
      List<Category> categories,
      int? selectedCategoryId,
      Function(int) onSelect,
      ) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical:2),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];

          final isSelected =
              cat.categoryId == selectedCategoryId ||
                  (selectedCategoryId == null && cat.categoryId == 0);

          return GestureDetector(
            onTap: () => onSelect(
              cat.categoryId,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlue
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color:AppColors.primaryBlue,
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: Text(
                  cat.categoryName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildExperienceListTile(Experience exp, VoidCallback onTap) {
    final width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          elevation: 3,
          color: Colors.white,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),

          ),
          child:
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ---------- HEADER ----------
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/'+ exp!.category!.iconUrl ,
                      height: 30,
                      width: 30,
                      colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn) , // Optional color filter
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child:
                      SmartArabicText(
                        text:exp.exprienceName ?? "",
                        baseSize:12,
                        color: Color(0xFF0B7780),

                      ),

                    ),
                    const SizedBox(width: 10),
                    /// Price
                    SmartArabicText(
                      text: '${exp.price} ر.س',
                      baseSize:10,
                      color: Color(0xFF0B7780),
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(width: 6),
                    /// Delete icon
                  ],
                ),

                const SizedBox(height: 16),
                /// ---------- FOOTER ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// Price
                    Chip(
                      label:
                      SmartArabicText(
                        text: exp.category.categoryName,
                        textAlign: TextAlign.center,
                        baseSize:10,
                        color: Colors.white,
                      ),
                      backgroundColor: AppColors.primaryBlue,
                    ),

                    Chip(
                      label:
                      SmartArabicText(
                        text: exp.isApproved ? 'تم اعتماد الخبرة' : 'الخبرة تحت المراجعة',
                        baseSize:10,
                        color: Colors.white,
                      ),
                      backgroundColor: exp.isApproved ? Color(0xFF3FCD71) : Color(0xFF964B4C),
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
  static Widget _chip(String text,int tcolcor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tcolcor==0 ? const Color(0xFFD1FAE5) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child:
      SmartArabicText(
        text: text,
        baseSize:10,
        color: Color(0xff374151),
      ),
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}