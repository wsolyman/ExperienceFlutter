import 'dart:convert';
import 'dart:ffi';

import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'SkeletonBox.dart';
import 'constant.dart';
import 'model/order.dart';
class myordersdetails extends StatefulWidget {

  const myordersdetails({Key? key, required this.order}) : super(key: key);
  final Order order ;
  @override
  _myordersdetailsState createState() => _myordersdetailsState();
}

class _myordersdetailsState extends State<myordersdetails> {
  final ScrollController _scrollController = ScrollController();
   List<OrderItem> myorderitems=[];
   bool isevaluted=false;
  @override
  void initState() {
    super.initState();
    myorderitems=widget.order.orderItems;
  }

  Widget _buildConsultingSessions(
      List<ExperienceSession>? sessions
      ) {
    if (sessions == null || sessions.isEmpty) {
    return const Center(
        child: Text(
          'لا توجد جلسات اة',
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
  var url = serverUrl + 'api/Evaluations';
  Future<void> sendRating(
       int itemid,
      int rating,
      ) async {
    Map<String, dynamic> data = {
      'eval': rating,
      'itemid': itemid,
    };
    setState(() {
      isevaluted=true;
    });
    try {
      SharedPreferences userpref = await SharedPreferences.getInstance();
      final prefs = await SharedPreferences.getInstance();
      String _token = prefs.getString('token')??'';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var decodedData = json.decode(response.body);
        setState(() {
          isevaluted=false;
        });
        showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text("رسالة تقييم"),
                content: Text('تم تقييم الخبرة بنجاح'),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
                    onPressed: () {
                      Navigator.of(context).pop();

                    },
                    child: Text("إغلاق" , style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),),
                  ),
                ],
              );
            });

      } else if (response.statusCode == 400)
      {
        setState(() {
          isevaluted=false;
        });
        var decodedData = json.decode(response.body);
        var errorMessage = decodedData["errors"][0];
        showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text("رسالة خطأ"),
                content: Text(errorMessage),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
                    onPressed: () {
                      Navigator.of(context).pop();

                    },
                    child: Text("إغلاق" , style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),),
                  ),
                ],
              );
            });

      } else
      {
        setState(() {
          isevaluted=false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاتصال بالخادم')), );
      }
    } catch (e) {
      setState(() {
        isevaluted=false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في الاتصال بالخادم')),
      );
    } finally {
      setState(() {
        isevaluted=false;
      });
    }
  }
  Future<void> _launchURL(String url) async {
    // Ensure URL has proper format
    String zoomUrl = url;
    if (!zoomUrl.startsWith('http://') && !zoomUrl.startsWith('https://')) {
      zoomUrl = 'https://$zoomUrl';
    }

    if (await canLaunch(zoomUrl)) {
      await launch(zoomUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن فتح رابط الزووم'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Widget buildExperienceListTile(Experience exp,List<ExperienceSession>?  experienceSession, int index  ) {
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
                /// ---------- Row 1 : title + price ----------
                /// ---------- Row 1 : title + price + delete ----------
                Row(
                  children: [
                    Expanded(
                      child: SmartArabicText(
                        text:exp.exprienceName ?? "",
                        baseSize:12,
                        color: Color(0xFF0B7780),

                      ),
                    ),
                    const SizedBox(width: 6),

                    /// Price
                    SmartArabicText(
                      text:  exp.price == 0 ? 'مجاني' : '${exp.price} ر.س',
                      baseSize:10,
                      color: Color(0xFF0B7780),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                /// ---------- Field ----------
                SmartArabicText(
                  text:  exp.field!.exprienceFieldTitle ?? "",
                  baseSize:10,
                  color: Colors.grey.shade600,

                ),

                const SizedBox(height: 8),

                /// ---------- Owner + Rating ----------
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RatingStars(
                          value:  myorderitems[index].evaluation,
                          onValueChanged: (v) {
                             sendRating(
                            myorderitems[index].orderItemId,
                            v.toInt()
                            );
                            setState(() {
                              myorderitems[index].isEvaluated = true;
                              myorderitems[index].evaluation = v;
                            });
                          },
                          starBuilder: (index, color) => Icon(
                            Icons.star,
                            color: color,
                          ),
                          starCount: 5,
                          starSize: 20,
                          valueLabelColor: const Color(0xff9b9b9b),
                          valueLabelTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              fontSize: 12.0),
                          valueLabelRadius: 10,
                          maxValue: 5,
                          starSpacing: 2,
                          maxValueVisibility: true,
                          valueLabelVisibility: true,
                          animationDuration: Duration(milliseconds: 1000),
                          valueLabelPadding:
                          const EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                          valueLabelMargin: const EdgeInsets.only(right: 8),
                          starOffColor: const Color(0xffe7e8ea),
                          starColor: Colors.yellow,
                        ),


                        Icon(Icons.person_outline,
                            size: 16, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        SmartArabicText(
                          text: exp.user != null ? exp.user!.fullName??'' : '',
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
                  alignment: Alignment.centerRight,
                  child: Chip(
                    label:  SmartArabicText(
                      text: exp.category?.categoryName ?? "",
                      baseSize:10,
                      color: Colors.white,
                    ),
                    backgroundColor: AppColors.primaryBlue,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ),
                exp.category!.categoryId == 1?
                Align(
                  alignment: Alignment.center,
                  child: Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text(
                      'إستعراض المحتوي',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: ()
                    {
                    _launchURL(exp.deliveryLink ?? '');
                    }

                  ),
                ),
                ):  const SizedBox(height: 12),
                exp.category!.categoryId==2 ? _buildConsultingSessions(experienceSession) : const SizedBox(height: 12),

              ],
            ),
          ),
        ),
      ),
    );
  }
  void showExperienceDetails(BuildContext context, Experience experience ,List<ExperienceSession>?  experienceSession) {
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                  ),
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
  Widget _buildTrainingFields(Experience exp) {
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
  Widget _buildCreativeFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('نوع العمل:', exp.trainningType!.trainningType ?? ''),
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
        _buildReviewItem('صيغة الملفات:', exp.filesFormate ?? ''),
        _buildReviewItem('نوع الترخيص:', exp.licienseType!.liciensyTypeTitle ??''),
      //  _buildReviewItem('رابط الملفات:',exp.deliveryLink ?? ''),
      ],
    );
  }
  Widget _buildTechnicalFields(Experience exp) {
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
  Widget _buildTimeFields(Experience exp) {
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
  Widget _buildConsultFields(Experience exp) {
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
  Widget _buildknowledgeFields(Experience exp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewItem('مدة الوقف:', exp.period!.expriencePeriod1 ?? ''),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        SmartArabicText(
          text: 'تفاصيل الطلب',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body:
      isevaluted
          ? FullScreenLoading(
      message: 'جاري التقييم...',
      withScaffold: true,
    ) :
      Column(
        children: [

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: myorderitems.length ,
              itemBuilder: (context, index) {
                /// Skeleton First Load
                final exp = myorderitems[index].experience;
                final itemsessions = myorderitems[index].experienceSession;
                if (index < myorderitems.length) {
                  return buildExperienceListTile(
                    exp,itemsessions,index
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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



