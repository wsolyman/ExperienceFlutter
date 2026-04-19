import 'package:experience/service/SmartArabicText.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:checkout_flutter/checkout_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:experience/constant.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/OrdersPage.dart';
import 'package:experience/CartScreen.dart';

import 'HomeScreen.dart';

class TestPayment extends StatefulWidget {
  final int orderId;
  final double amount;

  const TestPayment({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  State<TestPayment> createState() => _TestPaymentState();
}

class _TestPaymentState extends State<TestPayment> {
  bool _isLoadingStatus = false;
  bool _isProcessingPayment = false;
  String _checkoutStatus = 'جاهز للدفع';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }
  // Update payment status on server
  Future<bool> _updatePaymentStatus(int orderId, bool isSuccess, {String? chargeId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String token = prefs.getString('token') ?? '';
      final url = Uri.parse('${serverUrl}Orders/${orderId}/payment');
      Map<String, dynamic> requestBody = {
        'isPaymentSuccessful': isSuccess
      };
      /*if (chargeId != null && isSuccess) {
        requestBody['chargeId'] = chargeId;
      }*/

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update payment status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating payment status: $e');
      return false;
    }
  }

  // Retrieve transaction details from Tap
  Future<String> retrieveTransaction(String chargeId) async {
    final String apiUrl = 'https://api.tap.company/v2/charges/$chargeId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer sk_test_2vUaS0sE2APgFNvQ4oSuMK37LcYRt',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data["status"];
        return status;
      }
      throw Exception('Failed to retrieve transaction: ${response.body}');
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _handleTransactionStatus(String chargeId, int orderId) async {
    try {
      setState(() {
        _isLoadingStatus = true;
        _checkoutStatus = 'جاري التحقق من حالة الدفع...';
      });
      final status = await retrieveTransaction(chargeId);
      if (status == 'CAPTURED') {
        // Payment successful
        final updated = await _updatePaymentStatus(orderId, true, chargeId: chargeId);
        if (updated) {
          if (mounted) {
            _showSuccessDialog();
          }
        } else {
          if (mounted) {
            _showErrorDialog(
                'تم الدفع بنجاح ولكن حدث خطأ في تحديث حالة الطلب',
                true // Payment succeeded but update failed
            );
          }
        }
      } else {
        // Payment failed
        await _updatePaymentStatus(orderId, false);

        if (mounted) {
          _showErrorDialog(
              status == 'DECLINED' ? 'تم رفض الدفع' : 'فشل عملية الدفع: $status',
              false
          );
        }
      }
    } catch (e) {
      await _updatePaymentStatus(orderId, false);

      if (mounted) {
        _showErrorDialog('حدث خطأ أثناء معالجة الدفع: $e', false);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'تم الدفع بنجاح',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B7780),
                ),
              ),
            ],
          ),
          content: Text(
            'تمت عملية الدفع بنجاح. سيتم تحويلك إلى صفحة الطلبات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7780),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _redirectToOrdersPage();
                },
                child: const Text(
                  'عرض الطلبات',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message, bool partialSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'فشل الدفع',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          actions: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _redirectToCartPage();
                },
                child: const Text(
                  'العودة للسلة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _redirectToOrdersPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const OrdersPage(),
      ),
          (route) => false,
    );
  }

  void _redirectToCartPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(selectedIndex: 4, userid: 0), // Replace with your CartPage widget
      ),
          (route) => false,
    );
  }

  /// Generates a secure hash string for Tap Checkout
  String generateTapHashString({
    required String publicKey,
    required String secretKey,
    required double amount,
    required String currency,
    String postUrl = '',
    String transactionReference = '',
  }) {
    final key = utf8.encode(secretKey);
    final formattedAmount = amount.toStringAsFixed(2);

    final toBeHashed = 'x_publickey$publicKey'
        'x_amount$formattedAmount'
        'x_currency$currency'
        'x_transaction$transactionReference'
        'x_post$postUrl';

    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(utf8.encode(toBeHashed));
    return digest.toString();
  }

  Future<void> _startCheckout() async {
    if (_isProcessingPayment) return;

    try {
      setState(() {
        _isProcessingPayment = true;
        _checkoutStatus = 'جاري تجهيز الدفع...';
        _errorMessage = null;
      });

      final hash = generateTapHashString(
        publicKey: "pk_test_2vUaSsZv3XEdfkcnMaS14jFTptiY0",
        secretKey: "sk_test_2vUaS0sE2APgFNvQ4oSuMK37LcYRt",
        amount: widget.amount,
        currency: "SAR",
        postUrl: "https://expertwaqf.org/api/api/Webhook/tap-webhook",
        transactionReference: widget.orderId.toString(),
      );

     /* Map<String, dynamic> configurations = {
        "hashString": "",
        "language": "AR",
        "themeMode": "light",
        "supportedPaymentMethods": "ALL",
        "paymentType": "ALL",
        "selectedCurrency": "SAR",
        "supportedCurrencies": "ALL",
        "supportedPaymentTypes": [],
        "supportedRegions": [],
        "supportedSchemes": [],
        "supportedCountries": [],
        "gateway": {
          "publicKey": "pk_test_2vUaSsZv3XEdfkcnMaS14jFTptiY0",
          "merchantId": "68020742",
        },
        "customer": {
          "firstName": "Waqf",
          "lastName": "User",
          "email": "Test@test.com",
          "phone": {"countryCode": "966", "number": 05553597359},
        },
        "transaction": {
          "mode": "charge",
          "charge": {
            "saveCard": false,
            "auto": {"type": "VOID", "time": 100},
            "redirect": {
              "url": "https://demo.staging.tap.company/v2/sdk/checkout",
            },
            "threeDSecure": true,
            "subscription": {
              "type": "SCHEDULED",
              "amount_variability": "FIXED",
              "txn_count": 0,
            },
            "airline": {
              "reference": {"booking": ""},
            },
          },
        },
        "amount": widget.amount.toString(),
        "order": {
          "id": "",
          "currency": "SAR",
          "amount": widget.amount.toString(),
          "items": [
            {
              "amount": widget.amount.toString(),
              "currency": "SAR",
              "name": "طلب رقم ${widget.orderId}",
              "quantity": 1,
              "description": "الدفع للطلب رقم ${widget.orderId}",
            },
          ],
        },
        "cardOptions": {
          "showBrands": true,
          "showLoadingState": false,
          "collectHolderName": true,
          "preLoadCardName": "",
          "cardNameEditable": true,
          "cardFundingSource": "all",
          "saveCardOption": "all",
          "forceLtr": false,
          "alternativeCardInputs": {"cardScanner": true, "cardNFC": true},
        },
        "isApplePayAvailableOnClient": true,
      };*/
      Map<String, dynamic> configurations = {
        "hashString": "",
        "language": "en",
        "themeMode": "light",
        "supportedPaymentMethods": "ALL",
        "paymentType": "ALL",
        "selectedCurrency": "SAR",
        "supportedCurrencies": "ALL", // or ["SAR"]
        "supportedPaymentTypes": [],
        "supportedRegions": [],
        "supportedSchemes": [],
        "supportedCountries": [],
        "gateway": {
          "publicKey": "pk_test_2vUaSsZv3XEdfkcnMaS14jFTptiY0",
          "merchantId": "68020742",
        },
        "customer": {
          "firstName": "Android",
          "lastName": "Test",
          "email": "example@gmail.com",
          "phone": {"countryCode": "966", "number": "55567890"},
        },
        "transaction": {
          "mode":
          "charge", // or "authorize" // add "authorize" instead of "charge" to test authorization
          "charge": {
            // or "authorize" // add "authorize" instead of "charge" to test authorization
            "saveCard": true,
            "auto": {"type": "VOID", "time": 100},
            "redirect": {
              "url": "https://demo.staging.tap.company/v2/sdk/checkout",
            },
            "threeDSecure": true,
            "subscription": {
              "type": "SCHEDULED",
              "amount_variability": "FIXED",
              "txn_count": 0,
            },
            "airline": {
              "reference": {"booking": ""},
            },
          },
        },
        "amount": widget.amount.round().toString(),
        "order": {
          "id": "",
          "currency": "SAR",
          "amount": widget.amount.round().toString(),
          "items": [
            {
              "amount": widget.amount.round().toString(),
              "currency": "SAR",
              "name": "Item Title 1",
              "quantity": 1,
              "description": "item description 1",
            },
          ],
        },
        "cardOptions": {
          "showBrands": true,
          "showLoadingState": false,
          "collectHolderName": true,
          "preLoadCardName": "",
          "cardNameEditable": true,
          "cardFundingSource": "all",
          "saveCardOption": "all",
          "forceLtr": false,
          "alternativeCardInputs": {"cardScanner": true, "cardNFC": true},
        },
        "isApplePayAvailableOnClient": true,
      };
      final success = await startCheckout(
        configurations: configurations,
        onReady: () {
          if (mounted) {
            setState(() {
              _checkoutStatus = 'جاهز للدفع';
            });
          }
        },
        onSuccess: (data) {
          final Map<String, dynamic> decoded = jsonDecode(data);
          final String chargeId = decoded['chargeId'];
          _handleTransactionStatus(chargeId, widget.orderId);
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isProcessingPayment = false;
              _checkoutStatus = 'فشل الدفع: $error';
            });
            _showErrorDialog('حدث خطأ أثناء عملية الدفع: $error', false);
          }
        },
        onClose: () {
          if (mounted) {
            setState(() {
              _isProcessingPayment = false;
              _checkoutStatus = 'تم إغلاق نافذة الدفع';
            });
          }
        },
        onCancel: () {
          if (mounted) {
            setState(() {
              _isProcessingPayment = false;
              _checkoutStatus = 'تم إلغاء الدفع';
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إلغاء عملية الدفع'),
                backgroundColor: Colors.orange,
              ),
            );
            _redirectToCartPage();
          }
        },
      );

      if (!success && mounted) {
        setState(() {
          _isProcessingPayment = false;
          _checkoutStatus = 'فشل في بدء عملية الدفع';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _checkoutStatus = 'خطأ: $e';
        });
        _showErrorDialog('حدث خطأ غير متوقع: $e', false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0B7780),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const SmartArabicText(
          text: 'إتمام الدفع',
          baseSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order Summary Card
              Container(
                padding: EdgeInsets.all(screenWidth * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0B7780),
                      const Color(0xFF27A8B3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(height: 16),
                    SmartArabicText(
                      text: 'ملخص الطلب',
                      baseSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SmartArabicText(
                                text: 'رقم الطلب:',
                                baseSize: 14,
                                color: Color(0xFF0B7780),
                                fontWeight: FontWeight.bold,
                              ),
                              SmartArabicText(
                                text: '${widget.orderId}',
                                baseSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                          const Divider(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SmartArabicText(
                                text: 'المبلغ المطلوب:',
                                baseSize: 14,
                                color: Color(0xFF0B7780),
                                fontWeight: FontWeight.bold,
                              ),
                              Row(
                                children: [
                                  SmartArabicText(
                                    text: widget.amount.toStringAsFixed(2),
                                    baseSize: 18,
                                    color: const Color(0xFF0B7780),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(width: 4),
                                  const SmartArabicText(
                                    text: 'ر.س',
                                    baseSize: 14,
                                    color: Color(0xFF0B7780),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Status Card
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    if (_isProcessingPayment || _isLoadingStatus)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0B7780)),
                        ),
                      ),
                    if (_isProcessingPayment || _isLoadingStatus)
                      const SizedBox(height: 12),
                    SmartArabicText(
                      text: _checkoutStatus,
                      baseSize: 14,
                      color: _errorMessage != null ? Colors.red : Colors.grey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Payment Button
              ElevatedButton(
                onPressed: (_isProcessingPayment || _isLoadingStatus) ? null : _startCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B7780),
                  disabledBackgroundColor: Colors.grey[400],
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isProcessingPayment && !_isLoadingStatus)
                      const Icon(Icons.payment, color: Colors.white),
                    if (_isProcessingPayment || _isLoadingStatus)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    const SizedBox(width: 12),
                    SmartArabicText(
                      text: (_isProcessingPayment || _isLoadingStatus)
                          ? 'جاري المعالجة...'
                          : 'الدفع الآن',
                      baseSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Security Note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 8),
                  SmartArabicText(
                    text: 'مدفوعات آمنة عبر تاب',
                    baseSize: 12,
                    color: Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}