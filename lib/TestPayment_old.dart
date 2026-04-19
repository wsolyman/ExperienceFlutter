import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:checkout_flutter/checkout_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
class TestPayment extends StatefulWidget {
  const TestPayment({super.key});
  @override
  State<TestPayment> createState() => _TestPaymentState();
}

class _TestPaymentState extends State<TestPayment> {
  bool _isLoadingStatus = false;
  String _checkoutStatus = 'Ready to checkout';

  @override
  void initState() {
    super.initState();
  }

  // Retrieve transaction details
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
        return status; // Return the transaction status
      }
      // If statusCode is not 200, just throw an exception
      throw Exception('Failed to retrieve transaction: ${response.body}');
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _handleTransactionStatus(String chargeId) async {
    try {
      setState(() {
        _isLoadingStatus = true; // show loading indicator
        _checkoutStatus = 'Retrieving payment status...';
      });

      final status = await retrieveTransaction(chargeId);
      String message;
      switch (status) {
        case 'CAPTURED':
          message = 'Payment Captured Successfully';
          break;
        case 'DECLINED':
          message = 'Payment Declined';
          break;
        default:
          message = 'Payment status: $status';
      }

      setState(() {
        _checkoutStatus = message;
        _isLoadingStatus = false; // hide loading indicator
      });
    } catch (e) {
      setState(() {
        _checkoutStatus = 'Error retrieving transaction: $e';
        _isLoadingStatus = false; // hide loading indicator
      });
    }
  }

  /// Generates a secure hash string to use with Tap Checkout
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

  /// Start the checkout process using direct function calls
  /// No need for CheckoutFlutter class - just call startCheckout() directly
  Future<void> _startCheckout() async {
    try {
      setState(() {
        _checkoutStatus = 'Starting checkout...';
      });
      final hash = generateTapHashString(
          publicKey: "pk_test_2vUaSsZv3XEdfkcnMaS14jFTptiY0",
          secretKey: "sk_test_2vUaS0sE2APgFNvQ4oSuMK37LcYRt",
          amount: 2,
          currency: "SAR",
            postUrl: "https://expertwaqf.org/api/api/Webhook/tap-webhook",
          transactionReference: ""
      );

      /*Map<String, dynamic> configurations = {
        "hashString": "",
        "language": "AR",
        "themeMode": "light",
        "supportedPaymentMethods": "ALL", // To restrict specific methods, ex: ["VISA", "MASTERCARD"]
        "paymentType": "ALL",
        "selectedCurrency": "SAR",
        "supportedCurrencies": ["SAR"],  // To limit specific currencies ex: ["SAR", "BHD", "AED"]
        "supportedPaymentTypes": ['CARD'],
        "supportedRegions": [],
        "supportedSchemes": [],
        "supportedCountries": [],
        "gateway": {
          "publicKey": "pk_test_2vUaSsZv3XEdfkcnMaS14jFTptiY0",
          "merchantId": "68020742",
        },
        "customer": {
          "firstName": "waleed",
          "lastName": "sulaiman",
          "email": "waleed_solyman@hotmail.com",
          "phone": {"countryCode": "966", "number": "553597359"},
        },
        "transaction": {
          "mode": "charge",
          "charge": {
            "metadata": {
              "value_1": "checkout_flutter"
            },
            "reference": {
              "transaction": "trans_01",
              "order": "order_01",
              "idempotent": "order_01" // optinal: generate the same charge ID for the same value
            },
            "saveCard": true,
            "redirect": {
              "url": "https://demo.staging.tap.company/v2/sdk/checkout",
            },
            "post": "https://expertwaqf.org/api/api/Webhook/tap-webhook",
            "threeDSecure": true,
          },
        },
        "amount": "0.10",
        "order": {
          "currency": "SAR",
          "amount": "0.10",
          "items": [
            {
              "amount": "0.10",
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
        "amount": "5",
        "order": {
          "id": "",
          "currency": "SAR",
          "amount": "5",
          "items": [
            {
              "amount": "5",
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
      // Call startCheckout function directly
      final success = await startCheckout(
        configurations: configurations,
        onReady: () {
          setState(() {
            _checkoutStatus = 'Checkout is ready!';
          });
          print('Checkout is ready!');
        },
        onSuccess: (data) {
          // The value will be a Json string
          // Decode the JSON String into a Map
          final Map<String, dynamic> decoded = jsonDecode(data);

          // Extract the chargeId string
          final String chargeId = decoded['chargeId'];//  chg_T........
          print('chargeId: $chargeId');
          // Call your async function to check the transaction status
          _handleTransactionStatus(chargeId);
        },
        onError: (error) {
          setState(() {
            _checkoutStatus = 'Payment failed: $error';
          });
          print('Payment failed: $error');
        },
        onClose: () {
          setState(() {
            _checkoutStatus = 'Checkout closed';
          });
          print('Checkout closed');
        },
        onCancel: () {
          setState(() {
            _checkoutStatus = 'Checkout cancelled';
          });
          print('Checkout cancelled (Android)');
        },
      );

      if (!success) {
        setState(() {
          _checkoutStatus = 'Failed to start checkout';
        });
      }
    } catch (e) {
      setState(() {
        _checkoutStatus = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout Flutter Example'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      SizedBox(height: 8),
                      Text(
                        _checkoutStatus,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _startCheckout,
                icon: Icon(Icons.credit_card),
                label: Text('Start Checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}