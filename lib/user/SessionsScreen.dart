// SessionsScreen.dart
import 'package:experience/constant.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:experience/service/SessionService.dart';
import 'package:experience/model/Session.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
class SessionsScreen extends StatefulWidget {

  @override
  _SessionsScreenState createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  List<Session> sessions = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  int userid=0;
  final SessionService sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      List<Session> loadedSessions;
        // Load user sessions (authenticated)
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token') ?? '';
        if (token.isNotEmpty) {
          loadedSessions = await sessionService.fetchUserSessions(token);
        } else {
          // Load all sessions
          loadedSessions = await sessionService.fetchUserSessions(token);
        }
      setState(() {
        userid=prefs.getInt('userId')??0;
        sessions = loadedSessions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }
  Future<void> _launchZoomURL(String url) async {
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}/${date.month}/${date.day}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTimeRange(String fromTime, String toTime) {
    return '$fromTime - $toTime';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
           'جلساتي',
          style: SmartArabicTextStyle.create(
            context: context,
            baseSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0B7780),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF0B7780),
                      ),
                    ),
                  )
                else if (isError)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'حدث خطأ في تحميل الجلسات',
                            style: SmartArabicTextStyle.create(
                              context: context,
                              baseSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            errorMessage,
                            style: SmartArabicTextStyle.create(
                              context: context,
                              baseSize: 12,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B7780),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.08,
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _loadSessions,
                            child: Text(
                              'إعادة المحاولة',
                              style: SmartArabicTextStyle.create(
                                context: context,
                                baseSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (sessions.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/calendar.svg',
                              height: screenHeight * 0.15,
                              colorFilter: ColorFilter.mode(
                                const Color(0xFF0B7780),
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Text(
                              'لا توجد جلسات قادمة',
                              style: SmartArabicTextStyle.create(
                                context: context,
                                baseSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFF0B7780),
                        onRefresh: _loadSessions,
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            return _buildSessionCard(
                              context: context,
                              session: session,
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              onJoinPressed: () => _launchZoomURL(session.zoomURL),
                            );
                          },
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _copyPasswordToClipboard(
      BuildContext context,
      String password,
      double screenWidth,
      double screenHeight,
      ) async {
    try {
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: password));

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: screenWidth * 0.05,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    'تم نسخ كود الدخول بنجاح',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(screenWidth * 0.04),
        ),
      );

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل نسخ الكود: ${e.toString()}',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  /*Widget _buildSessionCard({
    required BuildContext context,
    required Session session,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onJoinPressed,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with day and date
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: const Color(0xFF0B7780),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.exprienceDay,
                  style: SmartArabicTextStyle.create(
                    context: context,
                    baseSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(session.exprienceDate),
                  style: SmartArabicTextStyle.create(
                    context: context,
                    baseSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Session details
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFF0B7780),
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      _formatTimeRange(session.fromTime, session.toTime),
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 12,
                        color: const Color(0xFF0B7780),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.01),

                // Price
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.amber,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      '${session.price} ر.س',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Password with copy button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      // Password label
                      Text(
                        'كود دخول الجلسة:',
                        style: SmartArabicTextStyle.create(
                          context: context,
                          baseSize: 10,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.02),

                      // Password value
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenHeight * 0.008,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  session.password,
                                  style: SmartArabicTextStyle.create(
                                    context: context,
                                    baseSize: 10,
                                    color: AppColors.textGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Copy to clipboard button
                              if (session.password.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _copyPasswordToClipboard(
                                    context,
                                    session.password,
                                    screenWidth,
                                    screenHeight,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.015),
                                    margin: EdgeInsets.only(right: screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.content_copy,
                                      size: screenWidth * 0.04,
                                      color: AppColors.primaryBlue,
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

                SizedBox(height: screenHeight * 0.02),

                // Join Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text(
                      ' انضم إلى الجلسة على زووم : ' + (userid==session.expertId ?'(كصاحب خبرة)' : '(كعميل)'),
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: session.zoomURL.isNotEmpty ? onJoinPressed : null,
                  ),
                ),

                if (session.zoomURL.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Text(
                      'لم يتم إضافة رابط زووم لهذه الجلسة بعد',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 12,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }*/
 /* Widget _buildSessionCard({
    required BuildContext context,
    required Session session,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onJoinPressed,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Session Name as Main Title
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0B7780),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                session.experiencename.isNotEmpty
                    ? session.experiencename
                    : 'جلسة بدون عنوان',
                style: SmartArabicTextStyle.create(
                  context: context,
                  baseSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Info Section
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day and Date in one row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: screenWidth * 0.04,
                          color: AppColors.primaryBlue,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          session.exprienceDay,
                          style: SmartArabicTextStyle.create(
                            context: context,
                            baseSize: 11,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _formatDate(session.exprienceDate),
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                // Time and Price in one row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: const Color(0xFF0B7780),
                          size: screenWidth * 0.045,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          _formatTimeRange(session.fromTime, session.toTime),
                          style: SmartArabicTextStyle.create(
                            context: context,
                            baseSize: 12,
                            color: const Color(0xFF0B7780),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          color: Colors.amber,
                          size: screenWidth * 0.045,
                        ),
                        SizedBox(width: screenWidth * 0.01),
                        Text(
                          '${session.price} ر.س',
                          style: SmartArabicTextStyle.create(
                            context: context,
                            baseSize: 12,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Password Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كود دخول الجلسة',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.008),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.012,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              session.password,
                              style: SmartArabicTextStyle.create(
                                context: context,
                                baseSize: 12,
                                color: AppColors.textGrey,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          if (session.password.isNotEmpty)
                            GestureDetector(
                              onTap: () => _copyPasswordToClipboard(
                                context,
                                session.password,
                                screenWidth,
                                screenHeight,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(screenWidth * 0.015),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.content_copy,
                                  size: screenWidth * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.02),

                // Join Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.video_call, size: screenWidth * 0.05),
                    label: Text(
                      'انضم إلى الجلسة على زووم ',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: session.zoomURL.isNotEmpty ? onJoinPressed : null,
                  ),
                ),

                if (userid == session.expertId || userid != session.expertId)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.008),
                    child: Text(
                      userid == session.expertId
                          ? '(كصاحب خبرة)'
                          : '(كعميل)',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: Colors.grey[600]!,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (session.zoomURL.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Text(
                      'لم يتم إضافة رابط زووم لهذه الجلسة بعد',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 12,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }*/
  Widget _buildSessionCard({
    required BuildContext context,
    required Session session,
    required double screenWidth,
    required double screenHeight,
    required VoidCallback onJoinPressed,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with session name
          Container(
            padding: EdgeInsets.all(screenWidth * 0.02),
            decoration: BoxDecoration(
              color: const Color(0xFF0B7780),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        session.experiencename.isNotEmpty
                            ? session.experiencename
                            : 'جلسة بدون عنوان',
                        style: SmartArabicTextStyle.create(
                          context: context,
                          baseSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.001),
                // Day and date row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.exprienceDay,
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDate(session.exprienceDate),
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Session details
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time with icon
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFF0B7780),
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        _formatTimeRange(session.fromTime, session.toTime),
                        style: SmartArabicTextStyle.create(
                          context: context,
                          baseSize: 12,
                          color: const Color(0xFF0B7780),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.01),

                // Price with icon
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      color: Colors.amber,
                      size: screenWidth * 0.05,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      '${session.price} ر.س',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.01),

                // Password with copy button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      // Password label
                      Text(
                        'كود دخول الجلسة:',
                        style: SmartArabicTextStyle.create(
                          context: context,
                          baseSize: 10,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.01),

                      // Password value
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  session.password,
                                  style: SmartArabicTextStyle.create(
                                    context: context,
                                    baseSize: 10,
                                    color: AppColors.textGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              // Copy to clipboard button
                              if (session.password.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _copyPasswordToClipboard(
                                    context,
                                    session.password,
                                    screenWidth,
                                    screenHeight,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.015),
                                    margin: EdgeInsets.only(right: screenWidth * 0.02),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.content_copy,
                                      size: screenWidth * 0.04,
                                      color: AppColors.primaryBlue,
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

                SizedBox(height: screenHeight * 0.02),

                // Join Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: Text(
                      ' انضم إلى الجلسة على زووم : ' + (userid==session.expertId ?'(كصاحب خبرة)' : '(كعميل)'),
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: session.zoomURL.isNotEmpty ? onJoinPressed : null,
                  ),
                ),

                if (session.zoomURL.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Text(
                      'لم يتم إضافة رابط زووم لهذه الجلسة بعد',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 12,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}