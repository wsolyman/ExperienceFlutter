import 'dart:convert';
import 'package:experience/HomeScreen.dart';
import 'package:experience/LoginScreen.dart';
import 'package:experience/service/DatabaseHelper.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/service/apiservice.dart';
import 'package:experience/user/NotificationScreen.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'SkeletonBox.dart';
import 'constant.dart';
import 'model/Exprience.dart';
import 'model/cartmodel.dart';
class Category {
  final int id;
  final String name;
  Category(this.id, this.name);
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(json['categoryId'], json['categoryName']);
}
class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen( {Key? key, required this.userid, this.searchtext}) : super(key: key);
  final userid;
  final searchtext;
  @override
  _HomeContentScreenState createState() => _HomeContentScreenState();
}
class _HomeContentScreenState extends State<HomeContentScreen> {
  final ScrollController _scrollController = ScrollController();
  var url = '${serverUrl}Experiences';
  late final ApiService apiService = ApiService(baseUrl: url);
  List<Experience> experiences = [];
  List<Category> categories = [Category(0, 'الكل')];
  int currentPage = 0;
  bool isLoading = false;
  bool hasNextPage = true;
  int? selectedCategoryId;
  int itemcount = 0;
  int expertid = 0;
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _unreadCount = 0;
  final List<Experience> cart = [];
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logined') ?? false;
    if(widget.searchtext !=null) {
      setState(() {
        searchQuery = widget.searchtext;
        _searchController.text = widget.searchtext;
      });
    }
    else
      {
        setState(() {
          searchQuery = null;
          _searchController.clear();
        });
      }
    if (isLoggedIn) {
      final unreadCount = await _dbHelper.getUnreadCount();
      setState(() {
        itemcount = prefs.getInt('cartItemsCount') ?? 0;
        expertid=widget.userid;
        _unreadCount=unreadCount;
        prefs.setInt('expertid',0);
        fetchCategories();
        fetchExperiences();
      });
    } else {
      setState(() {
        expertid=widget.userid;
      });
      fetchCategories();
      fetchExperiences();
    }
  }
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasNextPage) {
        fetchExperiences();
      }
    });
  }
  // Replace with real API call, here using mocked data for demo
  Future<void> fetchCategories() async {
    // Static categories as per your JSON
    setState(() {
      categories.addAll([
        Category(1, 'الوقف المعرفي'),
        Category(2, 'الوقف الاستشاري'),
        Category(3, 'الوقف التدريبي'),
        Category(4, 'الوقف التقني'),
        Category(5, 'الوقف الإبداعي'),
        Category(6, 'الوقف الزمني'),
      ]);
    });
  }
  Widget _buildConsultingSessions(
    List<ExperienceSession>? sessions, {
    required Function(ExperienceSession session) onAddToCart,
    required Function(ExperienceSession session) onBuyNow,
  }) {
    if (sessions == null || sessions.isEmpty) {
      return const Center(
        child: Text('لا توجد جلسات استشارية', style: TextStyle(fontSize: 16)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SmartArabicText(
          text: 'الجلسات الاستشارية:',
          baseSize: 10,
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
                          '${englishToArabicDays[session.exprienceDay] ?? session.exprienceDay} - ${session.exprienceDate}',
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
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0x14A0B6B8),
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            color: AppColors.primaryBlue,
                          ),
                          label: const Text(
                            'اضف الي السلة',
                            style: TextStyle(
                              color: const Color(0xFF0B7780),
                              fontSize: 10,
                              fontFamily: 'Noto Kufi Arabic',
                              fontWeight: FontWeight.w600,
                              height: 2.30,
                              letterSpacing: -0.50,
                            ),
                          ),
                          onPressed: () => onAddToCart(session),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                          label: const
                          SmartArabicText(
                            text: 'اشتري الان',
                            baseSize:12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),

                          onPressed: () => onBuyNow(session),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27A8B3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  Future<void> fetchExperiences({bool reset = false}) async {
    if (isLoading || (!hasNextPage && !reset)) return;
    setState(() {
      isLoading = true;
      if (reset) {
        experiences.clear();
        currentPage = 0;
        hasNextPage = true;
      }
    });
    try {
      int isapproved = 1;
      SharedPreferences userpref = await SharedPreferences.getInstance();
      int userId=userpref.getInt('userId')??0;
      final result = await apiService.fetchExperiences(
        currentPage,
        categoryId: selectedCategoryId == 0 ? null : selectedCategoryId,
        userid: expertid == 0 ? null : expertid,
        isapproved: isapproved == 0 ? null : isapproved,
        search: searchQuery,
          currentuserId:userId
      );
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
  void onCategorySelected(int categoryId) {
    setState(() {
      expertid=0;
      searchQuery = null;
      _searchController.clear();
      selectedCategoryId = categoryId == 0 ? null : categoryId;
    });
    fetchExperiences(reset: true);
  }
  bool isAddtocardLoading = false;
  Future<void> addToCart(int experienceid, int sessionid, bool buynow) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logined') ?? false;
    if (!isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
    if (!cart.any((e) => e.exprienceId == experienceid)) {
      setState(() {
        isAddtocardLoading = true;
      });
      var data = {};
      final prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token') ?? '';
      if (sessionid == 0) {
        data = {'exprienceId': experienceid, 'quantity': 1};
      } else {
        data = {
          'exprienceId': experienceid,
          'quantity': 1,
          "cartItemsSessions": [
            {"sessionId": sessionid},
          ],
        };
      }
      try {
        var url = serverUrl + 'Carts/items';
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200) {
          if (buynow) {
            setState(() {
              isAddtocardLoading = false;
            });
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HomeScreen(selectedIndex: 4, userid: 0),
              ),
            );
          } else {
            final data = json.decode(response.body);
            Cart? cartFuture;
            cartFuture = Cart.fromJson(data['cart']);
            setState(() {
              isAddtocardLoading = false;
              itemcount = cartFuture!.cartItems.length;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تمت إضافة المنتج للسلة'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else if (response.statusCode == 500) {
          setState(() {
            isAddtocardLoading = false;
          });
          // Handle login failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل في الإضافة للسلة'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          setState(() {
            isAddtocardLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الاتصال بالخادم'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          isAddtocardLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الاتصال بالخادم'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isAddtocardLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('المنتج موجود بالفعل في السلة'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  Widget buildExperienceListTile(Experience exp, VoidCallback onTap) {
    final width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        text:exp!.exprienceName ?? "",
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
                const SizedBox(height: 6),
                /// ---------- Field ----------
                SmartArabicText(
                  text:  exp!.field!.exprienceFieldTitle ?? "",
                  baseSize:10,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline,
                            size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        SmartArabicText(
                          text: exp.user!.fullName?? '',
                          baseSize:10,
                          color: Colors.grey.shade800,
                        ),
                        const SizedBox(width: 4),
                        _buildRatingStars(exp.user.totalEvaluations ?? 0),
                      ],
                    ),

                  ],
                ),

                const SizedBox(height: 10),
                /// ---------- Category ----------
                Align(
                  alignment: Alignment.topRight,
                  child: Chip(
                    label:
                    SmartArabicText(
                      text: exp.category?.categoryName ?? "",
                      baseSize:10,
                      color: Colors.white,
                    ),
                    backgroundColor: AppColors.primaryBlue,
                    labelStyle: const TextStyle(color: Colors.white),

                  ),
                ),
                //here sessions
                if (exp.category.categoryId != 2)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0x14A0B6B8),
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(
                            Icons.add_shopping_cart,
                            color: AppColors.primaryBlue,
                          ),
                          label: const Text(
                            'اضف الي السلة',
                            style: TextStyle(
                              color: const Color(0xFF0B7780),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: () {  addToCart(exp.exprienceId, 0, false);}
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                          label: const
                          SmartArabicText(
                            text: 'اشتري الان',
                            baseSize:12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),

                          onPressed:  () {
                            addToCart(exp.exprienceId, 0, true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF27A8B3),
                          ),
                        ),
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

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < rating && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
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
                  _buildReviewItem(
                    'المجال',
                    experience.field.exprienceFieldTitle,
                  ),
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
                  if (experience.category.categoryId == 2)
                    _buildConsultingSessions(
                      experience.sessions,
                      onAddToCart: (session) {
                        Navigator.of(context).pop();
                        addToCart(
                          experience.exprienceId,
                          session.sessionId,
                          false,
                        );
                      },
                      onBuyNow: (session) {
                        addToCart(
                          experience.exprienceId,
                          session.sessionId,
                          true,
                        );
                      },
                    ),
                  SizedBox(height: 24),
                  if (experience.category.categoryId != 2)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Color(0x14A0B6B8),
                              side: const BorderSide(color: Colors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: AppColors.primaryBlue,
                            ),
                            label: SmartArabicText(
                              text: 'اضف الي السلة',
                              baseSize:10,
                              color: Color(0xFF0B7780),
                              fontWeight: FontWeight.w600,
                            ),

                            onPressed: () {
                              addToCart(experience.exprienceId, 0, false);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.flash_on,
                              color: Colors.white,
                            ),
                            label:

                            const SmartArabicText(
                              text: 'اشتري الان',
                              baseSize:12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            onPressed: () {
                              addToCart(experience.exprienceId, 0, true);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF27A8B3),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem(
          'نوع التدريب:',
          exp.trainingType!.trainningType.toString() ?? '',
        ),
        _buildReviewItem(
          'مدة الدورة:',
          exp.sessionPeriodinminutes.toString() ?? '',
        ),
        _buildReviewItem('عدد المقاعد المتاحة:', exp.noofSeats.toString() ?? ''),
       //  _buildReviewItem(
       //    'المستوى:',
       //    exp.trainingLevel!.trainingLevelTitle ?? '',
       //  ),
        _buildReviewItem(
          'طريقة التقديم:',
          exp.deliveryMethod!.deliveryMethodTitle ?? '',
        ),
        _buildReviewItem(
          'المحاور الرئيسية للدورة:',
          exp!.trainningTopics ?? '',
        ),
        _buildReviewItem(
          'المتطلبات الأساسية:',
          exp!.trainningRequirement ?? '',
        ),
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
        _buildReviewItem('لغة البرمجة/التقنية:', exp.programmingLangauge ?? ''),
        _buildReviewItem(
          'نوع الترخيص:',
          exp.licenseType!.liciensyTypeTitle ?? '',
        ),
        //_buildReviewItem('الميزات الرئيسية:', exp.  _techFeaturesController.text),
        _buildReviewItem('المتطلبات التقنية:', exp.trainningRequirement ?? ''),
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
        _buildReviewItem(
          'الوقت المتاح أسبوعياً',
          exp.availablesHoures.toString(),
        ),
        _buildReviewItem('الأيام المتاحة', exp.dayes.toString()),
        _buildReviewItem(
          'الفترات الزمنية المتاحة',
          exp.availableIntervales ?? '',
        ),
        _buildReviewItem(
          'طريقة المشاركة',
          exp.deliveryMethod!.deliveryMethodTitle,
        ),
        _buildReviewItem('نوع المشروع', exp.trainingType!.trainningType ?? ''),
      ],
    );
  }

  Widget _buildConsultFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
        _buildReviewItem(
          'مدة الجلسة الاستشارية:',
          exp.sessionPeriodinminutes.toString() ?? '',
        ),
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
  Widget _buildLoadingImage() {
    return Image.asset(
      'assets/images/loading.gif', // Your loading GIF or image
      width: 80,
      height: 80,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackLoading();
      },
    );
  }
  Widget _buildFallbackLoading() {
    // Fallback loading animation using Flutter built-in
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF028F9A).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.autorenew,
          size: 40,
          color: Color(0xFF028F9A),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SmartArabicText(
          text: 'المنتجات',
          baseSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          // Notification icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notification_important_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsScreen()),
                  );
                },
                tooltip: 'الإشعارات الحالية',
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Shopping cart icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(selectedIndex: 4, userid: 0),
                    ),
                  );
                },
              ),
              if (itemcount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      itemcount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
          ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث عن خبرة...',
                  hintStyle: (TextStyle(fontSize: 10)),
                  prefixIcon: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      searchQuery = _searchController.text.trim();
                      fetchExperiences(reset: true);
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  searchQuery = value.trim();
                  fetchExperiences(reset: true);
                },
              ),
            ),

            Container(
              height: 50,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final selected = (selectedCategoryId ?? 0) == cat.id;
                  return GestureDetector(
                    onTap: () => onCategorySelected(cat.id),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:selected ? AppColors.primaryBlue : Colors.white60,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue.withOpacity(0.5) // Border color when selected
                              : Colors.grey.shade400, // Border color when not selected
                          width: selected ? 1 : 1, // Different border width based on selection
                        ),
                      ),
                      child: Center(
                        child: SmartArabicText(
                          text: cat.name,
                          baseSize: 8,
                          color: selected ? Colors.white :AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: isAddtocardLoading
                  ?  const FullScreenLoading(
              message: 'جاري تحميل البيانات...',
              withScaffold: true,
            )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: experiences.length + (hasNextPage ? 1 : 0),
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
                        if (index < experiences.length) {
                          return buildExperienceListTile(
                            exp,
                            () => showExperienceDetails(context, exp),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget buildExperienceSkeleton() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
