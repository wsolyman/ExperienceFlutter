import 'dart:convert';
import 'package:experience/OrdersPage.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'SkeletonBox.dart';
import 'constant.dart';
import 'model/cartmodel.dart';
class Category {
  final int id;
  final String name;
  Category(this.id, this.name);
  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(json['categoryId'], json['categoryName']);
}
// Main Screen
class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);
  @override
  _CartScreenState createState() => _CartScreenState();
}
class _CartScreenState extends State<CartScreen> {
  final ScrollController _scrollController = ScrollController();
  Cart? cartFuture;
  bool isLoading = false;
  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'تأكيد الطلب',
            textAlign: TextAlign.right,
          ),
          content: Text(
            'هل تريد إتمام الطلب بمبلغ '+cartFuture!.totalPrice.toString() +' ر.س؟',
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  cartFuture!.cartItems.clear();
                });
                putorder(cartFuture!.cartId?? 0);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: Text('تأكيد' ,style: SmartArabicTextStyle.create(context: context,
        baseSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.w700),),
            ),
          ],
        );
      },
    );
  }
 void getCart() async {

   if (isLoading) return;
   setState(() {
     isLoading = true;
   });
    var url = serverUrl + 'carts';
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token')??'';
    final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'}
    );

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        cartFuture= Cart.fromJson(data);
        setState(() {
          isLoading = false;
        });
      } on Exception catch (ex) {
         print(ex.toString());
         setState(() {
           isLoading = false;
         });
      }
      finally{
        setState(() {
          isLoading = false;
        });
      }

    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception("Failed to load cart");
    }
  }
  @override
  void initState() {
    super.initState();
     getCart();

  }

  Widget _buildConsultingSessions(
      List<RienceSession>? sessions

      ) {
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
                          '${ englishToArabicDays[session.exprienceDay] ?? session.exprienceDay } - ${formatDateNoTime(session.exprienceDate!)}',
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

  void _confirmDelete(BuildContext context, Exprience exp ,int itemid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${exp.exprienceName}"؟'),
        actions: [
          TextButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
            onPressed: () {
              Navigator.of(context).pop();

            },
            child: Text("إلغاء" , style: SmartArabicTextStyle.create(context: context,
                baseSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700),),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
              deleteExperience(itemid);
            },
            child:  Text('حذف', style: SmartArabicTextStyle.create(context: context,
                baseSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700),),
          ),
        ],
      ),
    );
  }
  Future<void> putorder(int cartid) async {
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token')??'';
    var url1= serverUrl + 'orders/' + cartid.toString();
    final url = Uri.parse(url1);
    try {
      // 🔹 إرسال طلب DELETE للـ API
      final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'}
      );
      if (response.statusCode == 200) {
        //getCart();
        // 🔹 إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم وضع الطلب بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          cartFuture?.totalPrice!=0;
          cartFuture=null;
        });
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OrdersPage()),
              (route) => false,
        );
      } else {
        // ❌ فشل من السيرفر
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الطلب: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ❌ خطأ شبكة أو استثناء
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  Future<void> deleteExperience(int? itemid) async {
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token')??'';
    var url1= serverUrl + 'Carts/item/' + itemid.toString();
    final url = Uri.parse(url1);

    try {
      // 🔹 إرسال طلب DELETE للـ API
      final response = await http.delete(
        url,
          headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'}
      );

      if (response.statusCode == 200) {
        //getCart();
        setState(() {
          if(json.decode(response.body) !=null) {
            final data = json.decode(response.body);
            if (data['cart'] != null && data['cart'] is Map &&
                data['cart'].isNotEmpty) {
              cartFuture = Cart.fromJson(data['cart']);
             if (cartFuture?.cartItems!.length ==0){
                cartFuture = null;
              }
            } else {
              cartFuture = null; // أو Cart.empty()
            }
          }
          else
            {
              cartFuture = null;
            }
        });
        // 🔹 إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الخبرة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // ❌ فشل من السيرفر
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحذف: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // ❌ خطأ شبكة أو استثناء
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  Widget buildExperienceListTile(Exprience? exp,int? itemid,List<RienceSession> experienceSession, VoidCallback onTap) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
         // onTap: onTap,
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
                    const SizedBox(width: 6),
                    exp?.category!.categoryId==2?
                    /// Price
                    SmartArabicText(
                      text: '${experienceSession[0].price} ر.س',
                      baseSize:10,
                      color: Color(0xFF0B7780),
                    )
                     :
                    SmartArabicText(
                      text: '${exp.price} ر.س',
                      baseSize:10,
                      color: Color(0xFF0B7780),
                    ),
                    const SizedBox(width: 6),
                    /// Delete icon
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        _confirmDelete(context, exp,itemid!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                      ),
                    ),
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
                exp.category!.categoryId==2 ? _buildConsultingSessions(experienceSession) : const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showExperienceDetails(BuildContext context, Exprience? experience,int? itemid,List<RienceSession> experienceSession) {
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
                    experience?.exprienceName ?? '',
                    style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700),),
                  SizedBox(height: 16),
                  _buildReviewItem('الفئة', experience!.category!.categoryName ?? ''),
                  _buildReviewItem('المجال', experience!.field!.exprienceFieldTitle ?? ''),
                  if (experience.category?.categoryId == 1)
                    _buildknowledgeFields(experience),
                  if (experience.category?.categoryId == 4)
                    _buildTechnicalFields(experience),
                  if (experience.category?.categoryId == 5)
                    _buildCreativeFields(experience),
                  if (experience.category?.categoryId == 6)
                    _buildTimeFields(experience),
                  if (experience.category?.categoryId == 3) // الوقف التدريبي
                    _buildTrainingFields(experience),
                  if (experience.category?.categoryId == 2)
                    _buildConsultFields(experience),
                  if (experience.category!.categoryId == 2) // الوقف الاستشاري
                    _buildConsultingSessions(
                      experienceSession,
                    ),
                  SizedBox(height: 24),
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
            child: Container(
              width: 156,
              height: 31,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide( color: Color(0x3F000000)),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Noto Kufi Arabic',
                  fontWeight: FontWeight.w600,
                  height: 2.92,
                  letterSpacing: -0.50,
                ),
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
  Widget _buildTrainingFields(Exprience exp) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('نوع التدريب:', exp.trainningType!.trainningType.toString()),
        _buildReviewItem('مدة الدورة:', exp.sessionPeriodinminutes.toString() ?? ''),
        _buildReviewItem('عدد المقاعد المتاحة:', exp.noofSeats.toString()),
        _buildReviewItem('المستوى:', exp.trainninglevel!.trainingLevelTitle ?? ''),
        _buildReviewItem('طريقة التقديم:', exp.deliveryMethod!.deliveryMethodTitle ?? ''),
        _buildReviewItem('المحاور الرئيسية للدورة:', exp.trainningTopics ?? ''),
        _buildReviewItem('المتطلبات الأساسية:', exp.trainningRequirement ?? ''),
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
      ],
    );
  }
  Widget _buildCreativeFields(Exprience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('نوع العمل:', exp.trainningType!.trainningType ?? ''),
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
        _buildReviewItem('صيغة الملفات:', exp.filesFormate ?? ''),
        _buildReviewItem('نوع الترخيص:', exp.licienseType!.liciensyTypeTitle ??''),
       // _buildReviewItem('رابط الملفات:',exp.deliveryLink ?? ''),
      ],
    );
  }
  Widget _buildTechnicalFields(Exprience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('نوع المنتج التقني:', exp.trainningType!.trainningType ?? ''),
        _buildReviewItem('لغة البرمجة/التقنية:', exp.programmingLangauge ?? '' ),
        _buildReviewItem('نوع الترخيص:', exp.licienseType!.liciensyTypeTitle ?? ''),
        //_buildReviewItem('الميزات الرئيسية:', exp.  _techFeaturesController.text),
        _buildReviewItem('المتطلبات التقنية:', exp.trainningRequirement?? ''),
        // _buildReviewItem('التوثيق المتوفر:', _techDocumentation.entries.where((e) => e.value).map((e) => e.key).join(', ')),
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
      ],
    );
  }
  Widget _buildTimeFields(Exprience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
        _buildReviewItem('الوقت المتاح أسبوعياً', exp.availablesHoures.toString()),
        _buildReviewItem('الأيام المتاحة',  exp.dayes.toString()),
        _buildReviewItem('الفترات الزمنية المتاحة', exp.availableIntervales ?? ''),
        _buildReviewItem('طريقة المشاركة', exp.deliveryMethod!.deliveryMethodTitle ?? '' ),
        _buildReviewItem('نوع المشروع',exp.trainningType!.trainningType ?? ''),
      ],
    );
  }
  Widget _buildConsultFields(Exprience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
        _buildReviewItem('مدة الجلسة الاستشارية:', exp.sessionPeriodinminutes.toString() ?? ''),
        _buildReviewItem('الأيام المتاحة:', exp.dayes ?? ''),
        _buildReviewItem('تاريخ البداية', exp.startDate.toString() ?? ''),
        _buildReviewItem('وقت البداية', exp.startTime ?? ''),
      ],
    );
  }
  Widget _buildknowledgeFields(Exprience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return   FullScreenLoading(
        message: 'جاري تحميل البيانات...',
        withScaffold: true,
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:SmartArabicText(
          text: 'سلة التسوق',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {

                },
              ),
              if (cartFuture!=null )
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${cartFuture?.cartItems.length.toString()}',
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
      body:
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:
        (cartFuture==null || cartFuture!.totalPrice==0) ?
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 120,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 24),
                Text(
                  'عربة التسوق فارغة',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'لم تقم بإضافة أي خبرات إلى العربة بعد',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 600,
                  height: 56,
                  child:  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 1,userid: 0,searchtext: null)),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Ink(
                      width: 320,height: 56,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const RadialGradient(
                          center: Alignment(0.5, 0.5),
                          radius: 2.76,
                          colors: [
                            Color(0xFF028F9A),
                            Color(0xFF017781),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'تصفح الخبرات',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        )
       :
        Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: cartFuture!.cartItems.length??0,
              itemBuilder: (context, index) {
                /// Skeleton First Load
                if (cartFuture!.cartItems.isEmpty ?? true && isLoading) {
                  return buildExperienceSkeleton();
                }
                final exp = cartFuture!.cartItems[index].exprience;
                final itemid =cartFuture!.cartItems[index].cartItemId;
                final itemsessions = cartFuture!.cartItems[index].experienceSession;
                if (index < cartFuture!.cartItems.length) {
                  return buildExperienceListTile(
                    exp ,itemid,itemsessions,
                        () => showExperienceDetails(context, exp, itemid! ?? 0, itemsessions) ,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SmartArabicText(
                        text: 'المجموع الكلي :',
                        baseSize:12,
                        color: Color(0xFF0B7780),
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 16),
                      SmartArabicText(
                        text: cartFuture!.totalPrice.toString() + ' ر.س' ?? "" ,
                        baseSize:10,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showCheckoutDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const
                      SmartArabicText(
                        text: 'إتمام الطلب',
                        baseSize:12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),

                    ),
                  ),
                ],
              ),
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



