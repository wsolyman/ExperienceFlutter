import 'package:flutter/material.dart';
const primaryColor = Color(0xff577bff);
//const primaryColor = Colors.blue;
const white = Colors.white;
const black = Colors.black;
//const serverUrl = 'https://10.0.2.2:7073/API/';
 const serverUrl = 'https://expertwaqf.org/api/';
//const serverUrl = 'http://restme.eu5.net/service/';
class AppColors {
  static const Color primaryBlue = Color(0xFF0B7780);
  static const Color background = Color(0xFFF7F9FC);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color dotInactive = Color(0xFFD1D5DB);
  Widget _buildLoadingImage() {
    return Image.asset(
      // 'assets/images/loading.gif', // Your loading GIF or image
      'assets/images/loginlogo.png',
      width: 120,
      height: 120,
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
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

final Map<String, String> englishToArabicDays = {
  'Sunday': 'الأحد',
  'Monday': 'الإثنين',
  'Tuesday': 'الثلاثاء',
  'Wednesday': 'الأربعاء',
  'Thursday': 'الخميس',
  'Friday': 'الجمعة',
  'Saturday': 'السبت',
};
String formatDateNoTime(DateTime dateTime) {
  return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}
class InnerTopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // start top-left (with rounded feel)
    path.moveTo(0, 24);

    // top-left curve
    path.quadraticBezierTo(0, 0, 24, 0);

    // top line
    path.lineTo(size.width - 24, 0);

    // top-right curve
    path.quadraticBezierTo(size.width, 0, size.width, 24);

    // go down
    path.lineTo(size.width, size.height - 30);

    // inner bottom curve
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 25,
      0,
      size.height - 30,
    );

    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;

}
Widget buildStarRating({
  required double rating,
  required bool isClickable,
  required ValueChanged<int>? onRated,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (index) {
      final starIndex = index + 1;
      return InkWell(
        onTap: isClickable
            ? () {
          if (onRated != null) onRated(starIndex);
        }
            : null,
        child: Icon(
          Icons.star,
          size: 18,
          color: rating >= starIndex
              ? Colors.amber
              : Colors.grey.shade300,
        ),
      );
    }),
  );
}
class BadgedIconButton extends StatelessWidget {
  final IconData icon;
  final int? badgeCount;
  final VoidCallback onPressed;
  final String tooltip;

  const BadgedIconButton({
    Key? key,
    required this.icon,
    this.badgeCount,
    required this.onPressed,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Clickable area
          Positioned.fill(
            child: IconButton(
              icon: Icon(icon),
              onPressed: onPressed,
              tooltip: tooltip,
              padding: EdgeInsets.zero,
            ),
          ),
          // Badge (non-interactive)
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              right: 4,
              top: 4,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}






