
import 'dart:convert';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/service/apiservice.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'HomeScreen.dart';
import 'SkeletonBox.dart';
import 'constant.dart';

import 'model/Exprience.dart';
import 'model/order.dart';
import 'myordersdetails.dart';

class OrdersPage extends StatefulWidget {

  const OrdersPage({Key? key}) : super(key: key);
  @override
  State<OrdersPage> createState() => _OrdersPageState();
}
class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Order>> _ordersFuture;
  @override
  void initState() {
    super.initState();
    _ordersFuture = fetchOrders();
  }

  Future<List<Order>> fetchOrders() async {
    var url = serverUrl + 'Orders';
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token')??'';
    final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'}
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 5,userid: 0,)), // Replace with your home page
                  (route) => false,
            );
          },
        ),
        title:
          SmartArabicText(
            text: 'الطلبات',
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
        FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const FullScreenLoading(
              message: 'جاري تحميل البيانات...',
              withScaffold: true,
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('خطأ في تحميل الطلبات: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد طلبات'));
          }
          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  title:
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/order.svg',
                        height: 20,
                        width: 20,
                        colorFilter: ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn) , // Optional color filter
                      ),
                      const SizedBox(width: 8),
                      SmartArabicText(
                        text: 'طلب رقم: ${order.orderId}',
                        baseSize:10,
                        color: Color(0xFF0B7780),
                        fontWeight: FontWeight.bold,
                      ),
                    ],

                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 8),
                      _buildReviewItem('تاريخ الطلب :' +'   '+ order.orderDate.toLocal().toString().split(" ")[0],order.orderDate.toLocal().toString().split(" ")[0]),
                      //_buildReviewItem('الحالة:',order.status),
                      _buildReviewItem('المبلغ الإجمالي :' +'   ' + order.totalAmount.toStringAsFixed(2),order.totalAmount.toStringAsFixed(2)),
                      _buildReviewItem('حالة الدفع :' + '   '+ (order.paymentStatus == 1 ? "تم الدفع" : "لم يتم الدفع").toString()  ,''),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => myordersdetails(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),),
    );
  }
}
Widget _buildReviewItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child:  Container(
            width:200,
            height: 31,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: const Color(0x3F000000)),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 0),
                )
              ],
            ),
            child: SmartArabicText(
              text: label,
              baseSize:10,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
    ),

        /*const SizedBox(width: 10), // <-- add horizontal spacing here
        Expanded(
          flex: 5,
          child:
          SmartArabicText(
            text: value,
            baseSize:10,
            color: Color(0xFF0B7780),
            fontWeight: FontWeight.w500,
          ),

        ),*/

  );

}