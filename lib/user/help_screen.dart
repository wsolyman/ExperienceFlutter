import 'package:flutter/material.dart';

import '../service/SmartArabicText.dart';
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:SmartArabicText(
          text: 'اتصل بنا',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
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
        Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('بمكنك الاتصال بنا عن طريق وسائل الاتصال التالية'),
            _contactCard(
              icon: Icons.phone,
              title: 'رقم الهاتف',
              value: '+966 55 933 0058',
            ),
            const SizedBox(height: 12),
            _contactCard(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              value: 'info@wafrh.org',
            ),
            const SizedBox(height: 24),

            /// Social Media
            const Text(
              'تابعنا على',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(
                  icon: Icons.facebook,
                  color: Colors.blue,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _socialButton(
                  icon: Icons.camera_alt, // Instagram
                  color: Colors.purple,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                _socialButton(
                  icon: Icons.alternate_email, // Twitter / X
                  color: Colors.black,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  /// Contact Card
  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Social Button
  Widget _socialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
