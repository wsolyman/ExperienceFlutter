import 'package:flutter/material.dart';
import 'dart:convert';

import '../utils/loading_widget.dart';

class ExpertProgressPage extends StatefulWidget {
  final int expertId;

  const ExpertProgressPage({Key? key, required this.expertId}) : super(key: key);

  @override
  _ExpertProgressPageState createState() => _ExpertProgressPageState();
}

class _ExpertProgressPageState extends State<ExpertProgressPage> {
  List<ProgressItem> _progressItems = [];
  bool _isLoading = true;
  bool _allCompleted = false;

  // Sample JSON data
  final String _sampleJson = '''
  [
    {
      "measuretitle": "عدد الخبرات",
      "measurevalue": 2,
      "expertvalue": 1
    },
    {
      "measuretitle": "عدد المبيعات",
      "measurevalue": 5,
      "expertvalue": 2
    },
    {
      "measuretitle": "قيمة الدخل",
      "measurevalue": 1000,
      "expertvalue": 200
    },
   
    {
      "measuretitle": "مستوى التقييم",
      "measurevalue": 4,
      "expertvalue": 2
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Simulate API delay
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        final List<dynamic> data = json.decode(_sampleJson);
        setState(() {
          _progressItems = data.map((item) => ProgressItem.fromJson(item)).toList();
          _checkAllCompleted();
          _isLoading = false;
        });
      } catch (e) {
        print('Error parsing JSON: $e');
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _checkAllCompleted() {
    bool allComplete = true;
    for (var item in _progressItems) {
      if (item.expertvalue < item.measurevalue) {
        allComplete = false;
        break;
      }
    }
    setState(() {
      _allCompleted = allComplete;
    });
  }

  void _sendRequest() {
    // Simulate API call
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم الإرسال بنجاح'),
          content: const Text('تم إرسال طلب التقدم بنجاح إلى الخادم.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    });
  }

  void _updateProgressValue(int index, int newValue) {
    setState(() {
      _progressItems[index] = ProgressItem(
        measuretitle: _progressItems[index].measuretitle,
        measurevalue: _progressItems[index].measurevalue,
        expertvalue: newValue,
      );
      _checkAllCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تقدم الخبير'),
          centerTitle: true,
          actions: [
            // Test button to simulate completion
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadSampleData();
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Summary Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ملخص التقدم',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0B7780),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_progressItems.length} معيار تقييم',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _allCompleted ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _allCompleted ? 'جاهز للإرسال' : 'غير مكتمل',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress List
              Expanded(
                child: ListView.builder(
                  itemCount: _progressItems.length,
                  itemBuilder: (context, index) {
                    final item = _progressItems[index];
                    final percentage =
                    (item.expertvalue / item.measurevalue).clamp(0.0, 1.0);

                    return _buildProgressCard(item, percentage, index);
                  },
                ),
              ),

              // Action Buttons
              if (_allCompleted)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sendRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SmallLoadingWidget(),
                            SizedBox(width: 8),
                            Text('جاري المعالجة...'),
                          ],
                        )
                            : const Text(
                          'إرسال طلب التقدم',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Reset all values to minimum
                        for (int i = 0; i < _progressItems.length; i++) {
                          _updateProgressValue(i, 0);
                        }
                      },
                      child: const Text(
                        'إعادة تعيين القيم',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Replace _buildProgressCard with this for circular progress
  Widget _buildProgressCard(ProgressItem item, double percentage, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Circular progress indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage >= 1 ? Colors.green : const Color(0xFF028F9A),
                    ),
                  ),
                ),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 1 ? Colors.green : const Color(0xFF028F9A),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.measuretitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B7780),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'قيمتك: ${item.expertvalue}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'المطلوب: ${item.measurevalue}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: percentage >= 1 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: percentage >= 1 ? Colors.green : Colors.orange,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          percentage >= 1 ? 'مكتمل' : 'غير مكتمل',
                          style: TextStyle(
                            color: percentage >= 1 ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressItem {
  final String measuretitle;
  final int measurevalue;
  int expertvalue;

  ProgressItem({
    required this.measuretitle,
    required this.measurevalue,
    required this.expertvalue,
  });

  factory ProgressItem.fromJson(Map<String, dynamic> json) {
    return ProgressItem(
      measuretitle: json['measuretitle'],
      measurevalue: json['measurevalue'],
      expertvalue: json['expertvalue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measuretitle': measuretitle,
      'measurevalue': measurevalue,
      'expertvalue': expertvalue,
    };
  }
}