// CertificatesScreen.dart
import 'package:experience/constant.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:experience/service/CertificateService.dart';
import 'package:experience/model/Certificate.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../service/SmartArabicText.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({Key? key}) : super(key: key);

  @override
  _CertificatesScreenState createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  List<Certificate> certificates = [];
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  final CertificateService certificateService = CertificateService();

  // PDF Viewer
  bool isPdfViewerVisible = false;
  String currentPdfUrl = '';

  @override
  void initState() {
    super.initState();

    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    try {
      setState(() {
        isLoading = true;
        isError = false;
      });

      final loadedCertificates = await certificateService.fetchCertificates();

      setState(() {
        certificates = loadedCertificates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }
  Future<void> _downloadCertificate(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يوجد رابط للشهادة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if URL is valid
    String pdfUrl = url;
    if (!pdfUrl.startsWith('http://') && !pdfUrl.startsWith('https://')) {
      pdfUrl = 'https://$pdfUrl';
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF0B7780)),
              SizedBox(width: 20),
              Text('جاري تحميل الشهادة...'),
            ],
          ),
        ),
      );

      // Check if we can launch the URL
      if (await canLaunch(pdfUrl)) {
        Navigator.pop(context); // Close loading dialog
        // Launch the PDF URL
        _launchInBrowser(Uri.parse(pdfUrl));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم فتح الشهادة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.pop(context); // Close loading dialog
        throw Exception('لا يمكن فتح ملف الشهادة');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في فتح الشهادة: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final arabicMonths = {
        1: 'يناير',
        2: 'فبراير',
        3: 'مارس',
        4: 'أبريل',
        5: 'مايو',
        6: 'يونيو',
        7: 'يوليو',
        8: 'أغسطس',
        9: 'سبتمبر',
        10: 'أكتوبر',
        11: 'نوفمبر',
        12: 'ديسمبر',
      };
      return '${date.day} ${arabicMonths[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildCertificateCard({
    required BuildContext context,
    required Certificate certificate,
    required double screenWidth,
    required double screenHeight,
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
          // Certificate header
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Color(0xFF0B7780),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/certificate.svg',
                  height: screenHeight * 0.03,
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    certificate.experienceName,
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
          ),

          // Certificate details
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Field
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'التصنيف:',
                  value: certificate.experienceCategory,
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenHeight * 0.01),

                _buildDetailRow(
                  icon: Icons.business,
                  label: 'المجال:',
                  value: certificate.experienceField,
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenHeight * 0.01),

                // Issue Date
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'تاريخ الإصدار:',
                  value: _formatDate(certificate.issueDate),
                  screenWidth: screenWidth,
                ),

                SizedBox(height: screenHeight * 0.02),

                // Download Button
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: certificate.certificateURL.isNotEmpty
                          ? Color(0xFF27A8B3)
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/download.svg',
                      height: screenHeight * 0.025,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      'تحميل الشهادة (PDF)',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: certificate.certificateURL.isNotEmpty
                        ? () => _downloadCertificate(serverUrl+certificate.certificateURL)
                        : null,
                  ),
                ),

                if (certificate.certificateURL.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.01),
                    child: Text(
                      'لم يتم رفع الشهادة بعد',
                      style: SmartArabicTextStyle.create(
                        context: context,
                        baseSize: 12,
                        color: Colors.orange,
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

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required double screenWidth,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Color(0xFF0B7780),
          size: screenWidth * 0.05,
        ),
        SizedBox(width: screenWidth * 0.01),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: SmartArabicTextStyle.create(
                context: context,
                baseSize: 12,
                color:AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 4),
            Container(
              constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
              child: Text(
                value,
                style: SmartArabicTextStyle.create(
                  context: context,
                  baseSize: 12,
                  color: Color(0xFF0B7780),
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:SmartArabicText(
          text: 'شهاداتي',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B7780),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCertificates,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with stats
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF0B7780).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي الشهادات',
                            style: SmartArabicTextStyle.create(
                              context: context,
                              baseSize: 12,
                              color:AppColors.primaryBlue,
                            ),
                          ),
                          Text(
                            certificates.length.toString(),
                            style: SmartArabicTextStyle.create(
                              context: context,
                              baseSize: 12,
                              color: Color(0xFF0B7780),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        'assets/icons/award.svg',
                        height: screenHeight * 0.06,
                        colorFilter: ColorFilter.mode(
                          Color(0xFF0B7780),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                // Certificates list
                Expanded(
                  child: isLoading
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF0B7780),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'جاري تحميل الشهادات...',
                          style: SmartArabicTextStyle.create(
                            context: context,
                            baseSize: 10,
                            color: Color(0xFF0B7780),
                          ),
                        ),
                      ],
                    ),
                  )
                      : isError
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/error.svg',
                          height: screenHeight * 0.15,
                          colorFilter: ColorFilter.mode(
                            Colors.grey,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'حدث خطأ في تحميل الشهادات',
                          style: SmartArabicTextStyle.create(
                            context: context,
                            baseSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.1,
                          ),
                          child: Text(
                            errorMessage,
                            style: SmartArabicTextStyle.create(
                              context: context,
                              baseSize: 10,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0B7780),
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.015,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _loadCertificates,
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
                  )
                      : certificates.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/empty-certificate.svg',
                          height: screenHeight * 0.15,
                          colorFilter: ColorFilter.mode(
                            Color(0xFF0B7780).withOpacity(0.5),
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'لا توجد شهادات متاحة',
                          style: SmartArabicTextStyle.create(
                            context: context,
                            baseSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'ستظهر الشهادات هنا بعد إعتماد الخبرات',
                          style: SmartArabicTextStyle.create(
                            context: context,
                            baseSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                      : RefreshIndicator(
                    color: Color(0xFF0B7780),
                    onRefresh: _loadCertificates,
                    child: ListView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: certificates.length,
                      itemBuilder: (context, index) {
                        return _buildCertificateCard(
                          context: context,
                          certificate: certificates[index],
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
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
}