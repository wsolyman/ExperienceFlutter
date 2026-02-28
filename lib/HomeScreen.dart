import 'package:experience/Experties.dart';
import 'package:experience/constant.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CartScreen.dart';
import 'FirstHomeScreen.dart';
import 'HomeContentScreen.dart';
import 'Myexperience.dart';
import 'ProfileScreen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key ,required this.selectedIndex,required this.userid,this.searchtext}) : super(key: key);
  final selectedIndex;
  final userid;
  final searchtext;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? currentBackPressTime;
  String pagesearchtext='';
  Future<bool> _onWillPop() async {
    final now = DateTime.now();

    // If back button is pressed twice within 2 seconds, exit app
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {

      currentBackPressTime = now;
      // Show confirmation dialog
      final bool? shouldExit = await showDialog(
        context: context,
        builder: (context) => _buildExitDialog(context),
      );

      return shouldExit ?? false;
    }

    return true;
  }
  Widget _buildExitDialog(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic direction
      child: AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('تأكيد الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في الخروج من التطبيق؟'),
        actions: [
          TextButton(
            style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
            onPressed: () {
              Navigator.of(context).pop();

            },
            child: Text("إلغاء" , style: SmartArabicTextStyle.create(context: context,
                baseSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700),),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text(
              'خروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  int selectedPos = 0;
  int userid=0;
  Widget bodyContainer() {
    switch (selectedPos) {
      case 0:
        return  FirstHomeScreen();
      case 1:
        return HomeContentScreen(
          userid: userid,
          searchtext:  pagesearchtext=='' ? null : pagesearchtext
        );
      case 2:
        return const Experties();
      case 3:
        return showexp? Myexperience():CartScreen();
      case 4:
        return showexp? CartScreen():ProfileScreen();
      //  return const CartScreen();
      case 5:
        return const ProfileScreen();
      default:
        return  FirstHomeScreen();
    }
  }
  bool showexp=false;
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userid=widget.userid;
      pagesearchtext=widget.searchtext==null ?'' :widget.searchtext ;
      final isLoggedIn = prefs.getBool('logined') ?? false;
      final experiencefield=prefs.getInt('fieldId');
      if (isLoggedIn) {
        if(experiencefield! >0)
        {
          showexp=true;
        }
        else if(experiencefield! ==0)
        {
            showexp=false;
        }
      }
      if(widget.selectedIndex==4 && !showexp)
      {
        selectedPos=3;
      }
      else  if(widget.selectedIndex==5 && !showexp)
      {
        selectedPos=4;
      }
      else
      {
        selectedPos=widget.selectedIndex;
      }
    });

  }
  void initState() {
    super.initState();
    _checkLoginStatus();

  }
  @override
  Widget build(BuildContext context) {
    return  PopScope(
        canPop: false, // Disable default back behavior
        onPopInvoked: (bool didPop) async {
          if (!didPop) {
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              // Navigator.of(context).pop(); // Use this if you want to go back
              // To exit the app completely:
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          }
        },
        child: showexp ?
      Scaffold(
      body: bodyContainer(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: selectedPos,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
         setState(() {
           selectedPos=index;
           userid=0;
           pagesearchtext='';
         });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'الخبراء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'خبراتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الحساب',
          ),
        ],
      ),
    ) : Scaffold(
    body: bodyContainer(),
    bottomNavigationBar: BottomNavigationBar(
    backgroundColor: Colors.white,
    currentIndex: selectedPos,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: AppColors.primaryBlue,
    unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          selectedPos=index;
          userid=0;
          pagesearchtext='';
        });
      },
    items: const [
    BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.search),
    label: 'المنتجات',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.people_outline),
    label: 'الخبراء',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.shopping_cart),
    label: 'السلة',
    ),
    BottomNavigationBarItem(
    icon: Icon(Icons.person),
    label: 'الحساب',
    ),
    ],
    ),
    ));
  }


}