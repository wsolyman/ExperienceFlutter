import 'dart:convert';
import 'package:experience/LoginScreen.dart';
import 'package:experience/Myexperience.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'constant.dart';
import 'model/UserRequest.dart';
class Myrequests extends StatefulWidget {
  @override
  _MyrequestsState createState() => _MyrequestsState();
}

class _MyrequestsState extends State<Myrequests>
    with SingleTickerProviderStateMixin {
  List<UserRequest> _requests = [];
  bool _isLoading = true;
  String? _error;
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _fetchRequests();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _redirecttomyexperience( int fieldid)
  async {
    setState(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) =>LoginScreen()),
            (route) => false,
      );
    });
  }
  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token')??'';
    var murl = serverUrl + 'Auth/expert-requsts';
    try {
      final response = await http.get(
        Uri.parse(murl),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'}
      );
     // final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _requests = jsonList
              .map((jsonItem) => UserRequest.fromJson(jsonItem))
              .toList();
          _isLoading = false;
          _animationController.forward();
        });
      } else {
        setState(() {
          _error = 'فشل تحميل الطلبات: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ أثناء تحميل الطلبات';
        _isLoading = false;
      });
    }
  }
  Color _statusColor(int status) {
    switch (status) {
      case 1: // تحت المراجعة
        return Colors.orange.shade300;
      case 2: // مقبول
        return Colors.green.shade400;
      case 3: // مرفوض
        return Colors.red.shade400;
      default:
        return Colors.grey.shade300;
    }
  }

  String _statusText(int status) {
    switch (status) {
      case 1:
        return 'تحت المراجعة';
      case 2:
        return 'مقبول';
      case 3:
        return 'مرفوض';
      default:
        return 'غير معروف';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const FullScreenLoading(
        message: 'جاري تحميل البيانات...',
        withScaffold: true,
      );
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(fontSize: 18, color: Colors.red)));
    }
    return
      Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: SmartArabicText(
              text: 'طلب التسجيل كخبير',
              baseSize:12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          body:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          (index / _requests.length),
                          1.0,
                          curve: Curves.easeIn,
                        ),
                      ),
                      child: Card(
                        elevation: 6,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _statusColor(request.requestStatus), width: 2),
                            gradient: LinearGradient(
                              colors: [
                                _statusColor(request.requestStatus).withOpacity(0.3),
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'المجال: ${request.fieldTitle}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                              SizedBox(height: 6),
                              SmartArabicText(
                                text: 'سنوات الخبرة: ${request.experienceYears}', textAlign: TextAlign.right,
                                baseSize:10,

                              ),

                              SizedBox(height: 6),
                              SmartArabicText(
                                text: 'المستوى التعليمي: ${request.educationLeveltitle}', textAlign: TextAlign.right,
                                baseSize:10,

                              ),

                              SizedBox(height: 6),
                              SmartArabicText(
                                text: 'المدينة: ${request.cityName}', textAlign: TextAlign.right,
                                baseSize:10,

                              ),
                              SizedBox(height: 6),
                              SmartArabicText(
                                  text: 'حالة الطلب: ${_statusText(request.requestStatus)}',
                                  baseSize:10,
                                  color: _statusColor(request.requestStatus)
                              ),

                              if (request.statuscomment.isNotEmpty && request.statuscomment != 'لا يوجد تعليق') ...[
                                SizedBox(height: 6),
                                SmartArabicText(
                                  text: 'تعليق: ${request.statuscomment}', textAlign: TextAlign.right,
                                  baseSize:10,

                                ),

                              ],
                              SizedBox(height: 8),
                              if(request.requestStatus==2)
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      _redirecttomyexperience(request.fieldid);
                                    },
                                    icon: Icon(Icons.ten_mp_rounded, color: Colors.blue),

                                    label:SmartArabicText(
                                      text: 'تسجيل الخروج و الدخول كخبير',
                                      baseSize:10,
                                      color: Colors.blue,

                                    ),

                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 0,userid: 0,)),
                          (route) => false,
                    );
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
                    text: 'الصفحة الرئيسية',
                    baseSize:12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),

                ),
              ),
            ],
          ),

    );
  }
}

