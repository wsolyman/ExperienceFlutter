import 'dart:convert';
import 'package:experience/HomeScreen.dart';
import 'package:experience/LoginScreen.dart';
import 'package:experience/service/CallAPI.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/service/apiservice.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'SkeletonBox.dart';
import 'constant.dart';
import 'model/Expert.dart';
import 'model/Exprience.dart';
import 'model/cartmodel.dart';
class ExperienceField {
  final int id;
  final String experienceFieldTitle;

  ExperienceField({
    required this.id,
    required this.experienceFieldTitle,
  });

  factory ExperienceField.fromJson(Map<String, dynamic> json) {
    return ExperienceField(
      id: json['id'],
      experienceFieldTitle: json['exprienceFieldTitle'], // maps the JSON key
    );
  }
}
// Main Screen
class Experties extends StatefulWidget {
  const Experties({Key? key}) : super(key: key);
  @override
  _ExpertiesState createState() => _ExpertiesState();
}

class _ExpertiesState extends State<Experties> {
  final ScrollController _scrollController = ScrollController();
  var url = serverUrl + 'Auth/experts';
  late final ApiService apiService = ApiService(baseUrl: url);
  List<UserExpert> Experts = [];
  List<ExperienceField> ExperienceFields = [ExperienceField(id: 0, experienceFieldTitle: 'الكل')];
  int currentPage = 0;
  bool isLoading = false;
  bool hasNextPage = true;
  int? selectedFieldID;
  int itemcount=0;
  final TextEditingController _searchController = TextEditingController();
  String? searchQuery;
  final List<Experience> cart = [];
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('logined') ?? false;
    if (isLoggedIn) {
      setState(() {
        itemcount= prefs.getInt('cartItemsCount') ?? 0;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    loadFields();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          hasNextPage) {
        fetchExpert();
      }
    });
  }
  final CallAPI api = CallAPI();
  Future<void> loadFields() async {
    final result = await api.getList<ExperienceField>(
      baseUrl: serverUrl,
      endpoint: 'Experiences/fields',
      fromJson: (json) => ExperienceField.fromJson(json),
    );
    if (result.success) {
      setState(() {

        final ExperienceFielddata = result.data!;
        ExperienceFields=[ExperienceFields.first,...ExperienceFielddata];
        fetchExpert();
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result.error}')),
      );
    }
  }
  // Replace with real API call, here using mocked data for demo


  Future<void> fetchExpert({bool reset = false}) async {
    if (isLoading || (!hasNextPage && !reset)) return;

    setState(() {
      isLoading = true;
      if (reset) {
        Experts.clear();
        currentPage = 0;
        hasNextPage = true;
      }
    });

    try {

      final result = await apiService.fetchExpert(
        currentPage,
        FieldId: selectedFieldID == 0 ? null : selectedFieldID,
        search: searchQuery, //
      );
      final newExperts = result['experts'] as List<UserExpert>;
      setState(() {
        Experts.addAll(newExperts);
        hasNextPage = result['hasNextPage'];
        currentPage++;
      });
    } catch (e) {
      // handle error
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onCategorySelected(int FieldID) {
    setState(() {
      searchQuery=null;
      _searchController.clear();
       selectedFieldID = FieldID == 0 ? null : FieldID;
    });
    fetchExpert(reset: true);
  }
bool isAddtocardLoading=false;
  Widget buildExperienceListTile(UserExpert exp) {
    final width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: 3,
          color: Colors.white,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),

          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// ---------- HEADER ----------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Icon
                    /// User Image / Avatar
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                      backgroundImage: (exp.profileUrl != null && exp.profileUrl!.isNotEmpty)
                          ? NetworkImage(serverUrl+exp.profileUrl!)
                          : null,
                      child: (exp.profileUrl == null || exp.profileUrl!.isEmpty)
                          ? const Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.primaryBlue,
                      )
                          : null,
                    ),

                    const SizedBox(width: 12),

                    /// Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Title
                          SmartArabicText(
                            text: exp.fullName,
                            baseSize:12,
                            color: Color(0xFF0B7780),
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 6),
                          /// Meta
                          Row(
                            children: [
                              _chip(exp.experiences[0].fieldTitle,1),
                            ],
                          ),
                          const SizedBox(height: 6),
                          /// Rating
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              _buildRatingStars(exp.totalEvaluations?? 0),
                              const SizedBox(width: 6),
                                SmartArabicText(
                                text:  '(عدد المبيعات ' + exp.itemsPurchased.toString() +')',
                                baseSize:10,
                                 color: Color(0xff9ca3af),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                /// ---------- FOOTER ----------
            Align(
              alignment: Alignment.centerLeft,
              child:  SizedBox(

                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    SharedPreferences userpref = await SharedPreferences.getInstance();
                    setState(() {
                      userpref.setInt('expertid', exp.userId);
                    });
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => HomeScreen(selectedIndex: 1,userid:exp.userId)),
                    );
                  },
                  icon: const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const
                  SmartArabicText(
                      text: 'عرض المنتجات',
                      baseSize:12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold

                  ),

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
  static Widget _chip(String text,int tcolcor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tcolcor==0 ? const Color(0xFFD1FAE5) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xff374151),
        ),
      ),
    );
  }
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(4, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < rating && rating % 1 != 0) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:SmartArabicText(
          text: 'الخبراء المساهمين',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,

        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HomeScreen(selectedIndex: 1,userid: 0,searchtext: null,)),
                  );
                },
              ),
              if (itemcount>0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${itemcount.toString()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:
        Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن خبير...',
                hintStyle: (TextStyle(fontSize: 10)),
                prefixIcon: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    searchQuery = _searchController.text.trim();
                    fetchExpert(reset: true);
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (value) {
               searchQuery = value.trim();
                fetchExpert(reset: true);
              },
            ),
          ),

          Container(
            height: 50,
            padding: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ExperienceFields.length,
              itemBuilder: (context, index) {
                final cat = ExperienceFields[index];
                final selected = (selectedFieldID ?? 0) == cat.id;
                return GestureDetector(
                  onTap: () => onCategorySelected(cat.id),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding:
                    EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                      selected ? AppColors.primaryBlue : Colors.white60,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue.withOpacity(0.5) // Border color when selected
                            : Colors.grey.shade400, // Border color when not selected
                        width: selected ? 1 : 1, // Different border width based on selection
                      ),

                    ),
                    child: Center(
                      child: SmartArabicText(
                        text: cat.experienceFieldTitle,
                        baseSize: 8,
                        color: selected ? Colors.white : AppColors.primaryBlue,
                      ),

                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: isAddtocardLoading ?  FullScreenLoading(
            message: 'جاري تحميل البيانات...',
            withScaffold: true,
          ) :
            ListView.builder(
              controller: _scrollController,
              itemCount: Experts.length + (hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                /// Skeleton First Load
                if (Experts.isEmpty && isLoading) {
                  return buildExperienceSkeleton();
                }
                /// Pagination Loader
                if (index == Experts.length  ) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final exp = Experts[index];
                if (index < Experts.length) {
                  return buildExperienceListTile(
                    exp,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
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



