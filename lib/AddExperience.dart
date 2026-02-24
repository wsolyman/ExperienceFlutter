import 'package:experience/Myexperience.dart';
import 'package:experience/model/lookups.dart';
import 'package:experience/service/CallAPI.dart';
import 'package:experience/service/SmartArabicStyle.dart';
import 'package:experience/service/SmartArabicText.dart';
import 'package:experience/utils/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'HomeScreen.dart';
import 'constant.dart';
class WaqfType {
  final String value;
  final String title;
  final String description;
  final String icon;

  WaqfType({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class AddExperience extends StatefulWidget {
  @override
  _AddExperienceState createState() => _AddExperienceState();
}

class _AddExperienceState extends State<AddExperience>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  WaqfType? _selectedWaqfType;
  late final TextEditingController _dateController;
//for creative
  // إبداعي (Creative)
  final _formKeyCreative = GlobalKey<FormState>();
  final TextEditingController _creativeTitleController = TextEditingController();
  final TextEditingController _creativeDescriptionController = TextEditingController();
  String? _creativeType;
  String? _creativeDuration;

  Map<String, bool> _creativeFileFormats = {
    'PDF': false,
    'PNG': false,
    'JPG': false,
    'SVG': false,
    'PSD': false,
    'AI': false,
    'MP4': false,
    'أخرى': false,
  };
  int? _creativeLicense;
  final TextEditingController _creativeFileLinkController = TextEditingController();
  // for timing
  final _formKeytiming = GlobalKey<FormState>();
  final TextEditingController _timedescriptionController = TextEditingController();
  String? _timeselectedDuration;
  String? _weeklyHours;
  final List<weeklyHoursItem> _weeklyHoursOptions = [
    weeklyHoursItem(text: '2 ساعة', value: '2'),
    weeklyHoursItem(text: '4 ساعة', value: '2'),
    weeklyHoursItem(text: '6 ساعة', value: '6'),
    weeklyHoursItem(text: '8 ساعة', value: '8'),
    weeklyHoursItem(text: '10 ساعة', value: '10'),
    weeklyHoursItem(text: 'مفتوح', value: '0'),
  ];
  weeklyHoursItem? _selectedweeklyHoursItem;
  Map<String, bool> _timeSlots = {
    'صباحي': false,
    'مسائي': false,
  };
  int? _participationMethod;
  String? _projectType;
  // Step 2 display data for review and send
  bool _isSubmitting = false;

  void _resetSelections() {
    _descriptionController.clear();
    _selectedDuration = null;
    _weeklyHours = null;
    _availableDays.updateAll((key, value) => false);
    _timeSlots.updateAll((key, value) => false);
    _participationMethod = null;
    _projectType = null;
  }


  String get _formattedDate {
    if (_selectedDate == null) return '';
    return "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
  }
  Widget _buildCheckboxList(Map<dayesItem, bool> items) {
    return Wrap(
      spacing: 8,
      children: items.keys.map((dayesItem) {
        return FilterChip(
          label: Text(dayesItem.text,style: SmartArabicTextStyle.create(context: context,
              baseSize: 10,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500),),
          selected: items[dayesItem]!,
          onSelected: (selected) {
            setState(() {
              items[dayesItem] = selected;
            });
          },
        );
      }).toList(),
    );
  }
  // for معرفي
  final _formKeyknoledge = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fileLinkController = TextEditingController();
  String? _selectedDuration;
  // Controllers and fields for "استشاري" (consultation)
  final _formKeyConsultation = GlobalKey<FormState>();
  final TextEditingController _consultationDescriptionController =
  TextEditingController();
  String? _consultationDuration;
  String? _trainingDuration;

  final List<sessionItem> _sessionDurations = [
    sessionItem(text: '30 دقيقة', value: '30'),
    sessionItem(text: '60 دقيقة', value: '60'),
    sessionItem(text: '90 دقيقة', value: '90'),
    sessionItem(text: '120 دقيقة', value: '120'),
  ];
  sessionItem? _selectedsessionItem;

  final Map<dayesItem,bool> _availableDays= {
    dayesItem(text: 'السبت', value: '0'): false,
    dayesItem(text: 'الأحد', value: '1'): false,
    dayesItem(text: 'الإثنين', value: '2'): false,
    dayesItem(text: 'الثلاثاء', value: '3'): false,
    dayesItem(text: 'الأربعاء', value: '4'): false,
    dayesItem(text: 'الخميس', value: '5'): false,
    dayesItem(text: 'الجمعة', value: '6'): false,
  };
  TimeOfDay? _availableFrom;
  // Controllers and fields for "تدريبي" (training)
  final _formKeyTraining = GlobalKey<FormState>();
  final TextEditingController _trainingDescriptionController =
  TextEditingController();
  String? _trainingType;
  String? _trainingPeriod;
  int? _trainingDelivery;
  final List<String> _trainingDurations = [
    'أسبوع واحد',
    'أسبوعان',
    'شهر',
    'شهران',
    '3 أشهر',
    '6 أشهر',
  ];
  final TextEditingController _trainingSeatsController =
  TextEditingController();
  String? _trainingLevel;
  DateTime? _selectedDate;
  // حضوري، عن بعد، هجين
  final TextEditingController _trainingTopicsController =
  TextEditingController();
  final TextEditingController _trainingRequirementsController =
  TextEditingController();

  final TextEditingController _trainingMaterialsLinkController =
  TextEditingController();
  // Controllers and fields for "تقني" (technical product)
  final _formKeyTechnical = GlobalKey<FormState>();
  final TextEditingController _techDescriptionController =
  TextEditingController();
  String? _techType;
  final TextEditingController _techLanguageController = TextEditingController();
  final TextEditingController _techVersionController = TextEditingController();
  int? _techLicense;
  final TextEditingController _techFeaturesController = TextEditingController();
  final TextEditingController _techRequirementsController =
  TextEditingController();
  final Map<String, bool> _techDocumentation = {
    'دليل المستخدم': false,
    'دليل التثبيت': false,
    'توثيق API': false,
    'شروحات فيديو': false,
  };
  String? _techWaqfDuration;
  final TextEditingController _techRepoLinkController = TextEditingController();
  final TextEditingController _techDocsLinkController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  final List<WaqfType> waqfTypes = [
    WaqfType(
      value: 'معرفي',
      title: 'الوقف المعرفي',
      description: 'كتب، بحوث، أدلة علمية، مناهج',
      icon: 'assets/icons/ledg.svg',
    ),
    WaqfType(
      value: 'استشاري',
      title: 'الوقف الاستشاري',
      description: 'ساعات استشارة مهنية متخصصة',
      icon: 'assets/icons/consult.svg',
    ),
    WaqfType(
      value: 'تدريبي',
      title: 'الوقف التدريبي',
      description: 'دورات، ورش عمل، برامج تدريبية',
        icon: 'assets/icons/train.svg',
    ),
    WaqfType(
      value: 'تقني',
      title: 'الوقف التقني',
      description: 'تطبيقات، أنظمة، أدوات رقمية',
        icon: 'assets/icons/tech.svg',
    ),
    WaqfType(
      value: 'إبداعي',
      title: 'الوقف الإبداعي',
      description: 'تصميمات، أعمال فنية، محتوى مرئي',
      icon: 'assets/icons/Creative.svg',
    ),
    WaqfType(
      value: 'زمني',
      title: 'الوقف الزمني',
      description: 'تخصيص وقت شهري لخدمة مشروع ما',
      icon: 'assets/icons/time.svg',
    ),
  ];
  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formattedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _buttonAnimation =
        Tween<double>(begin: 1.0, end: 0.7).animate(_animationController);
  }

  Future<void> _pickTime(BuildContext context, bool isFrom) async {
    final initialTime = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _availableFrom = picked;
        } else {
         // _availableTo = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  void _goToNextStep() {
    if (_currentStep == 0) {
      if (_selectedWaqfType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('يرجى اختيار نوع الوقف')),
        );
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      bool valid = true;
      if (_selectedWaqfType?.value == 'استشاري') {
        valid = _formKeyConsultation.currentState?.validate() ?? false;
        if (valid) {
          if (_availableFrom == null ) {
            valid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('يرجى تحديد الأوقات المتاحة')),
            );
          }
          if (!_availableDays.containsValue(true)) {
            valid = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('يرجى اختيار الأيام المتاحة')),
            );
          }
        }
      } else if (_selectedWaqfType?.value == 'تدريبي') {
        valid = _formKeyTraining.currentState?.validate() ?? false;
      } else if (_selectedWaqfType?.value == 'تقني') {
        valid = _formKeyTechnical.currentState?.validate() ?? false;
      } else if (_selectedWaqfType?.value == 'معرفي') {
        valid = _formKeyknoledge.currentState?.validate() ?? false;
      }
      else if (_selectedWaqfType?.value == 'زمني') {
      valid = _formKeytiming.currentState?.validate() ?? false;
    }
      else if (_selectedWaqfType?.value == 'إبداعي') {
        valid = _formKeyCreative.currentState?.validate() ?? false;
        if (valid) {
          if (!_creativeFileFormats.containsValue(true)) {
            valid = false;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى اختيار صيغة ملف واحدة على الأقل')));
          }
          if (_creativeLicense == null) {
            valid = false;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يرجى اختيار نوع الترخيص')));
          }
        }
      }
      if (valid) {
        setState(() {
          _currentStep = 2;
        });
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else{_resetAll(); _resetSelections();}
  }

  Future<void> _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });
    _animationController.forward();
    final prefs = await SharedPreferences.getInstance();
    String _token = prefs.getString('token')??'';
    final experiencefield=prefs.getInt('fieldId');
    print(experiencefield);
    final selectedDays = _availableDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key.value)
        .toList();
    final fileformates= _techDocumentation.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final timeslots=_timeSlots.entries.where((e) => e.value).map((e) => e.key).toList();
    final selectedDaysString = selectedDays.join(',');
    final selectedfileformate = fileformates.join(',');
    final selectedtimeslots = timeslots.join(',');
    Map<String, dynamic> data = {

    };
    if (_selectedWaqfType?.value == 'إبداعي') {
      final creativeFormats = _creativeFileFormats.entries.where((e) => e.value).map((e) => e.key).toList();
      data.addAll({
        'exprienceName': _creativeTitleController.text,
        'description': _creativeDescriptionController.text,
        'categoryId': 5,
        'fieldId': experiencefield,
        'trainningTypeId': int.tryParse(_creativeType!)??0 ,
        'periodId':  int.tryParse(_creativeDuration!)??0 ,
        'filesFormate': creativeFormats.join(','),
        'licienseTypeId': _creativeLicense,
        'DeliveryLink': _creativeFileLinkController.text,
      });
    }
    else if (_selectedWaqfType?.value == 'زمني') {
      data.addAll({
        'exprienceName': _timedescriptionController.text.trim(),
        'description': _timedescriptionController.text.trim(),
        'periodId': _timeselectedDuration,
        'categoryId': 6,
        'fieldId': experiencefield,
        'availablesHoures': _weeklyHours,
        'dayes': _availableDays.entries.where((e) => e.value).map((e) => e.key.value).toList().join(','),
        'availableIntervales': selectedtimeslots,
        'deliveryMethodId': _participationMethod,
        'trainningTypeId': int.tryParse(_projectType!)??0 ,
      });
    }
    else if (_selectedWaqfType?.value == 'معرفي') {
      data.addAll({

          'exprienceName': _descriptionController.text,
          'description': _descriptionController.text,
          'categoryId': 1,
          'fieldId': experiencefield,
          'deliveryLink': _fileLinkController.text,
          'periodId': _selectedDuration,
      });

    }
    else if (_selectedWaqfType?.value == 'استشاري') {
      data.addAll({
        'exprienceName': _consultationDescriptionController.text,
        'description': _consultationDescriptionController.text,
        'periodId': int.parse(_consultationDuration!) ,
        'categoryId': 2,
        'fieldId': experiencefield,
        'sessionPeriodinminutes': _selectedsessionItem!.value,
        'dayes': selectedDaysString,
        'startTime': _formatTimeOfDay(_availableFrom),
        'startDate': _formattedDate,
      });
    } else if (_selectedWaqfType?.value == 'تدريبي') {
      data.addAll({
        //we must revise trainning
        'exprienceName': _trainingDescriptionController.text,
        'description': _trainingDescriptionController.text,
        'trainningTypeId': int.tryParse(_trainingType!) ?? 0 ,
        'categoryId': 3,
        'fieldId': experiencefield,
        'noofSeats': int.tryParse(_trainingSeatsController.text) ?? 0,
        'trainninglevelId': int.tryParse(_trainingLevel!) ?? 0 ,
        'deliveryMethodId':  _trainingDelivery,
        'trainningTopics': _trainingTopicsController.text,
        'trainningRequirement': _trainingRequirementsController.text,
        'periodId': int.tryParse(_trainingPeriod!) ?? 0  ,
        'deliveryLink': _trainingMaterialsLinkController.text,
      });
    } else if (_selectedWaqfType?.value == 'تقني') {
      data.addAll({
        //we must revise
        'exprienceName': _techDescriptionController.text,
        'description': _techDescriptionController.text,
        'trainningTypeId': int.tryParse(_techType!)??0,
        'categoryId': 4,
        'fieldId': experiencefield,
        'programmingLangauge': _techLanguageController.text + _techVersionController.text,
       // 'techVersion': _techVersionController.text,
        'licienseTypeId': _techLicense,
        "trainningTopics": _techFeaturesController.text,
        'trainningRequirement': _techRequirementsController.text,
        'filesFormate': selectedfileformate,
        'periodId': int.tryParse(_techWaqfDuration!)??0 ,
        'deliveryLink': _techRepoLinkController.text,
        'technicalsourcesLink': _techDocsLinkController.text,
      });
    }

    try {
      var url = serverUrl + 'Experiences';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $_token'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: Text("رسالة"),
                content: Text("تم إضافة الوقف بنجاح"),
                actions: <Widget>[
                  TextButton(
                    style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen(selectedIndex: 3,userid: 0,)),
                            (route) => false,
                      );
                    },
                    child: Text("إغلاق" , style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),),
                  )
                ],
              );
            });

        _resetAll();
      }  else if (response.statusCode == 400)
        {
          setState(() {
            _isSubmitting = false;
          });
          var decodedData = json.decode(response.body);
          var errorMessage = decodedData["errors"][0]?? '';
          showDialog(
              context: context,
              builder: (c) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text("رسالة خطأ"),
                  content: Text(errorMessage),
                  actions: <Widget>[
                    TextButton(
                      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.primaryBlue)),
                      onPressed: () {
                        Navigator.of(context).pop();

                      },
                      child: Text("إغلاق" , style: SmartArabicTextStyle.create(context: context,
                          baseSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),),
                    ),
                  ],
                );
              });
        }

      else {
        print(response.statusCode);
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإرسال، حاول مرة أخرى')),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الاتصال بالخادم')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
      _animationController.reverse();
    }
  }
  bool isLoading = true;
  final CallAPI api = CallAPI();
  List<Period> Periods = [];
  Future<void> loadperiods(int categoryID) async {

    final result = await api.getList<Period>(
      baseUrl: serverUrl,
      endpoint: 'Experiences/periods?categoryId='+categoryID.toString(),
      fromJson: (json) => Period.fromJson(json),
    );
    if (result.success) {
      setState(() {
        Periods.clear();
        Periods = result.data!;
        if(categoryID==5 || categoryID==6 || categoryID==4 || categoryID==3)
          {
            loadtrainingtypes(categoryID);
          }
        else
        isLoading = false;
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

  List<TrainingType> trainingtypes = [];
  Future<void> loadtrainingtypes(int categoryID) async {

    final result = await api.getList<TrainingType>(
      baseUrl: serverUrl,
      endpoint: 'Lookups/trainingTypes?categoryId='+categoryID.toString(),
      fromJson: (json) => TrainingType.fromJson(json),
    );
    if (result.success) {
      setState(() {
        trainingtypes.clear();
        trainingtypes = result.data!;
        if(categoryID==5 || categoryID==4)
        {
          loadLicenseTypes(categoryID);
        }
      else  if(categoryID==6)
        {
          loadDeliveryMethods(categoryID);
        }
      else if (categoryID==3)
        {
          loadDeTrainingLevels(categoryID);
        }
        else
        isLoading = false;
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
  List<LicenseType> LicenseTypes = [];
  Future<void> loadLicenseTypes(int categoryID) async {

    final result = await api.getList<LicenseType>(
      baseUrl: serverUrl,
      endpoint: 'Lookups/licenseTypes?categoryId='+categoryID.toString(),
      fromJson: (json) => LicenseType.fromJson(json),
    );
    if (result.success) {
      setState(() {
        LicenseTypes.clear();
        LicenseTypes = result.data!;
          if(categoryID==3)
        {
          loadDeliveryMethods(categoryID);
        }

        else
            {
              isLoading = false;
            }

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
  List<DeliveryMethod> DeliveryMethods = [];
  Future<void> loadDeliveryMethods(int categoryID) async {

    final result = await api.getList<DeliveryMethod>(
      baseUrl: serverUrl,
      endpoint: 'Lookups/deliveryMethods?categoryId='+categoryID.toString(),
      fromJson: (json) => DeliveryMethod.fromJson(json),
    );
    if (result.success) {
      setState(() {
        DeliveryMethods.clear();
        DeliveryMethods = result.data!;
        isLoading = false;
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
  List<TrainingLevel> TrainingLevels = [];
  Future<void> loadDeTrainingLevels( int categoryid) async {

    final result = await api.getList<TrainingLevel>(
      baseUrl: serverUrl,
      endpoint: 'Lookups/trainingLevels',
      fromJson: (json) => TrainingLevel.fromJson(json),
    );
    if (result.success) {
      setState(() {
        TrainingLevels.clear();
        TrainingLevels = result.data!;
        if( categoryid==3)
        {
          loadDeliveryMethods(categoryid);
        }
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
  void _resetAll() {
    _consultationDescriptionController.clear();
    _trainingDescriptionController.clear();
    _trainingSeatsController.clear();
    _trainingTopicsController.clear();
    _trainingRequirementsController.clear();
    _trainingMaterialsLinkController.clear();
    _techDescriptionController.clear();
    _techLanguageController.clear();
    _techVersionController.clear();
    _techFeaturesController.clear();
    _techRequirementsController.clear();
    _techRepoLinkController.clear();
    _techDocsLinkController.clear();
    _formKeyConsultation.currentState?.reset();
    _formKeyTraining.currentState?.reset();
    _formKeyTechnical.currentState?.reset();
    setState(() {
      _selectedWaqfType = null;
      _consultationDuration = null;
      _selectedDuration=null;
      _availableFrom = null;
      _availableDays.updateAll((key, value) => false);
      _trainingType = null;
      _trainingDuration = null;
      _trainingLevel = null;
      _trainingDelivery = null;
      _trainingPeriod = null;
      _techType = null;
      _techLicense = null;
      _techWaqfDuration = null;
      _currentStep = 0;
      _techDocumentation.updateAll((key, value) => false);
      _creativeType = null;
      _creativeDuration = null;
      _creativeLicense = null;
       Periods.clear();
    });
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLine,
    bool requiredField = true,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines:maxLine,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        labelStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (value) {
        if (!requiredField) return null;
        if (value == null || value.trim().isEmpty) {
          return validatorMsg ?? 'هذا الحقل مطلوب';
        }

        return null;
      },
    );
  }
  Widget _stepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isActive = _currentStep == index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue :  Color(0xFF3FC2CD),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );

      }),
    );
  }

  Widget _buildtitle(String title)
  {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            width: 170,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0B7780),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Text(
              title,
              style: SmartArabicTextStyle.create(context: context,
                  baseSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600),
            ),
          ),

        ),
      ],
    );
  }

  Widget _buildStepOne() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _stepIndicator(),
          SizedBox(height: 24),
        _buildtitle( 'اختر نوع الوقف'),
        SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: waqfTypes.length,
              itemBuilder: (context, index) {
                final waqf = waqfTypes[index];
                final selected = _selectedWaqfType == waqf;
                return Card(
                  color: Colors.white,
                  elevation: selected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: selected ? AppColors.primaryBlue : Colors.white,
                      width: selected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading:
                    SvgPicture.asset(
                      waqf.icon,
                      height: 30,
                      width: 30,
                      colorFilter: selected ? ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn)  : ColorFilter.mode(AppColors.primaryBlue, BlendMode.srcIn), // Optional color filter
                    ),
                    //Icon(waqf.icon, size: 30, color: selected ?AppColors.primaryBlue : Colors.teal),
                    title:
                    Text(waqf.title,
                      style: SmartArabicTextStyle.create(context: context,
                          baseSize: 12,
                          color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500
                          ),),
                    subtitle: Text(waqf.description , style: SmartArabicTextStyle.create(context: context,
                        baseSize: 10,
                        color: AppColors.primaryBlue,
                        ),) ,
                    onTap: () {
                      setState(() {
                        _selectedWaqfType = waqf;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToNextStep,
              child: SmartArabicText(
                text: 'التالي',
                baseSize:12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                backgroundColor:  AppColors.primaryBlue,
                shadowColor:  Colors.white, // same shadow as previous style
              ),
            ),
          ),
        ],
      ),
    );
  }
  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
      labelStyle: SmartArabicTextStyle.create(color: AppColors.primaryBlue.withOpacity(0.6) ,baseSize: 12, context: context),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.primaryBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColors.primaryBlue.withOpacity(0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
  Widget _buildStepTwo() {

    if (_selectedWaqfType?.value == 'إبداعي')
    {
      loadperiods(5);
      if (isLoading) {
        return  const FullScreenLoading(
          message: 'جاري تحميل البيانات...',
          withScaffold: true,
        );
      }
      return Form(
        key: _formKeyCreative,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _stepIndicator(),
              const SizedBox(height: 24),
              _buildtitle( _selectedWaqfType!.title ?? ''),
              const SizedBox(height: 16),
              _buildTextField( controller:_creativeTitleController,label:'عنوان العمل الإبداعي',hint:'عنوان العمل الإبداعي',maxLine:1,requiredField:true),
              const SizedBox(height: 16),
              /// وصف العمل
              _buildTextField( controller:_creativeDescriptionController,label:'وصف العمل الإبداعي',hint:'وصف العمل الإبداعي',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              /// نوع العمل
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                initialValue: _creativeType,
                hint: const Text('نوع العمل الإبداعي'),
               decoration: _dropdownDecoration('العمل الإبداعي',),
                items: trainingtypes.map((t) {
                  return DropdownMenuItem(
                    value: t.id.toString(),

                    child: Text(t.trainingType,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                  ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _creativeType = v),
                validator: (v) => v == null ? 'يرجى اختيار نوع العمل' : null,
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                initialValue: _creativeDuration,
                hint: const Text('اختر المدة'),
                decoration: _dropdownDecoration('مدة الوقف'),
                items: Periods.map((p) {
                  return DropdownMenuItem(
                    value: p.id.toString(),
                    child:Text(p.expriencePeriod1,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _creativeDuration = v),
                validator: (v) => v == null ? 'الرجاء اختيار المدة' : null,
              ),

              const SizedBox(height: 16),

              /// صيغ الملفات
              const Text('صيغة الملفات المتاحة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _creativeFileFormats.keys.map((format) {
                  return FilterChip(
                    label: Text(format),
                    selected: _creativeFileFormats[format]!,
                    onSelected: (v) =>
                        setState(() => _creativeFileFormats[format] = v),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              /// نوع الترخيص
              const Text('نوع الترخيص',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Column(
                children: LicenseTypes.map((license) {
                  return RadioListTile<int>(
                    value: license.id,
                    groupValue: _creativeLicense,
                    title: Text(license.liciensyTypeTitle,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),),
                    onChanged: (v) => setState(() => _creativeLicense = v),
                  );
                }).toList(),
              ),

              if (_creativeLicense == null)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    'يرجى اختيار نوع الترخيص',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 16),
              _buildTextField( controller:_creativeFileLinkController,label:'رابط الملفات',hint:'https://drive.google.com/...',maxLine:1,requiredField:true,keyboardType:TextInputType.url ),
              /// رابط الملفات
              const SizedBox(height: 24),
              /// أزرار التنقل
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToPreviousStep,
                      child: SmartArabicText(
                        text: 'السابق',
                        baseSize:12,
                        color: const Color(0xFF717070),
                        fontWeight: FontWeight.w700,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),

                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKeyCreative.currentState!.validate() &&
                            _creativeLicense != null) {
                          _goToNextStep();
                        }
                      },
                      child:  SmartArabicText(
                        text: 'التالي',
                        baseSize:12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        backgroundColor:  AppColors.primaryBlue,
                        shadowColor:  Colors.white, // same shadow as previous style

                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

    }
    else if (_selectedWaqfType?.value == 'زمني')
    {
      loadperiods(6);
      if (isLoading) {
        return  const FullScreenLoading(
          message: 'جاري تحميل البيانات...',
          withScaffold: true,
        );
      }
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKeytiming,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _stepIndicator(),
              const SizedBox(height: 24),
              _buildtitle( _selectedWaqfType!.title ?? ''),
              const SizedBox(height: 16),
              _buildTextField( controller:_timedescriptionController,label:'وصف المشروع/النشاط',hint:'وصف المشروع/النشاط',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              /// وصف النشاط
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _timeselectedDuration,
                hint: const Text('اختر المدة'),
                decoration: _dropdownDecoration('مدة الوقف',),
                items: Periods.map((p) {
                  return DropdownMenuItem(
                    value: p.id.toString(),
                    child:Text(p.expriencePeriod1,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );
                }).toList(),
                onChanged: (v) => setState(() => _timeselectedDuration = v),
                validator: (v) => v == null ? 'الرجاء اختيار المدة' : null,
              ),

              const SizedBox(height: 16),

              /// الوقت المتاح أسبوعيًا
              DropdownButtonFormField<weeklyHoursItem>(
                dropdownColor: Colors.white,
                value: _selectedweeklyHoursItem,
                hint: const Text('اختر الوقت المتاح'),
                decoration: _dropdownDecoration('الوقت المتاح أسبوعيا',),
                items: _weeklyHoursOptions.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child:Text(item.text,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedweeklyHoursItem = v;
                    _weeklyHours = v?.value;
                  });
                },
                validator: (v) => v == null ? 'يرجى اختيار عدد الساعات' : null,
              ),

              const SizedBox(height: 16),

              /// الأيام المتاحة
               Text('الأيام المتاحة',
                style: SmartArabicTextStyle.create(context: context,
                    baseSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),),
              _buildCheckboxList(_availableDays),

              const SizedBox(height: 16),

              /// الفترات الزمنية
               Text('الفترات الزمنية المتاحة',
                style: SmartArabicTextStyle.create(context: context,
                    baseSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),),
              Wrap(
                spacing: 12,
                children: _timeSlots.keys.map((slot) {
                  return FilterChip(
                    label: Text(slot == 'صباحي'
                        ? 'الفترة الصباحية (8 ص - 12 م)'
                        : 'الفترة المسائية (4 م - 8 م)',style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),),
                    selected: _timeSlots[slot]!,
                    onSelected: (v) => setState(() => _timeSlots[slot] = v),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              /// طريقة المشاركة
               Text('طريقة المشاركة',
                style: SmartArabicTextStyle.create(context: context,
                    baseSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),),
              Column(
                children: DeliveryMethods.map((m) {
                  return RadioListTile<int>(
                    value: m.id,
                    groupValue: _participationMethod,
                    title: Text(m.deliveryMethodTitle,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),),
                    onChanged: (v) => setState(() => _participationMethod = v),
                  );
                }).toList(),
              ),

              if (_participationMethod == null)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    'يرجى اختيار طريقة المشاركة',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 16),
              /// نوع المشروع
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _projectType,
                hint: const Text('اختر نوع المشروع'),
                decoration: _dropdownDecoration('نوع المشروع',),
                items: trainingtypes.map((t) {
                  return DropdownMenuItem(
                    value: t.id.toString(),
                    child:Text(t.trainingType,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );
                }).toList(),
                onChanged: (v) => setState(() => _projectType = v),
                validator: (v) => v == null ? 'يرجى اختيار نوع المشروع' : null,
              ),

              const SizedBox(height: 24),

              /// أزرار التنقل
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToPreviousStep,
                      child:SmartArabicText(
                        text: 'السابق',
                        baseSize:12,
                        color: const Color(0xFF717070),
                        fontWeight: FontWeight.w700,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),

                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKeytiming.currentState!.validate() &&
                            _availableDays.containsValue(true) &&
                            _timeSlots.containsValue(true) &&
                            _participationMethod != null) {
                          _goToNextStep();
                        }
                      },
                      child:  SmartArabicText(
                        text: 'التالي',
                        baseSize:12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        backgroundColor:  AppColors.primaryBlue,
                        shadowColor:  Colors.white, // same shadow as previous style

                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
   else if(_selectedWaqfType?.value == 'معرفي')
      {
       loadperiods(1);
        if (isLoading) {
          return  const FullScreenLoading(
            message: 'جاري تحميل البيانات...',
            withScaffold: true,
          );
        }
        return Form(
          key: _formKeyknoledge,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _stepIndicator(),
                const SizedBox(height: 24),
                _buildtitle( _selectedWaqfType!.title ?? ''),
                const SizedBox(height: 16),
                _buildTextField( controller:_descriptionController,label:'وصف المنتج',hint:'وصف تفصيلي للمنتج الوقفي وفوائده',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: _selectedDuration,
                  hint: const Text('اختر المدة'),
                  isExpanded: true,
                  decoration: _dropdownDecoration('مدة الوقف',),
                  items: Periods.map((p) {
                    return DropdownMenuItem(
                      value: p.id.toString(),
                      child:Text(p.expriencePeriod1,style: SmartArabicTextStyle.create(context: context,
                          baseSize: 12,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500),
                      ),

                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedDuration = v),
                  validator: (v) => v == null ? 'الرجاء اختيار المدة' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField( controller:_fileLinkController,label:'رابط الملفات',hint:'https://drive.google.com/...',maxLine:1,requiredField:true, keyboardType: TextInputType.url),
                const SizedBox(height: 6),
                Text(
                  'يرجى رفع الملفات على منصة تخزين سحابي وإضافة الرابط هنا',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 24),

                /// أزرار التنقل
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _goToPreviousStep,
                        child:SmartArabicText(
                          text: 'السابق',
                          baseSize:12,
                          color: const Color(0xFF717070),
                          fontWeight: FontWeight.w700,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),

                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKeyknoledge.currentState!.validate()) {
                            _goToNextStep();
                          }
                        },
                        child:  SmartArabicText(
                          text: 'التالي',
                          baseSize:12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 4,
                          backgroundColor:  AppColors.primaryBlue,
                          shadowColor:  Colors.white, // same shadow as previous style

                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      }
    else if (_selectedWaqfType?.value == 'استشاري') {
      loadperiods(2);
      if (isLoading) {
        return  const FullScreenLoading(
          message: 'جاري تحميل البيانات...',
          withScaffold: true,
        );
      }
      return Form(
        key: _formKeyConsultation,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _stepIndicator(),
              const SizedBox(height: 24),
              _buildtitle( _selectedWaqfType!.title ?? ''),
              const SizedBox(height: 16),

              const SizedBox(height: 6),
              _buildTextField( controller:_consultationDescriptionController,label:'وصف الاستشارة',hint:'وصف تفصيلي للاستشارة والمجالات التي تغطيها',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _consultationDuration,
                hint: const Text('اختر المدة'),
                isExpanded: true,
                decoration: _dropdownDecoration('مدة الوقف',),
                items: Periods.map((p) {
                  return DropdownMenuItem(
                    value: p.id.toString(),
                    child:Text(p.expriencePeriod1,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );
                }).toList(),
                onChanged: (v) => setState(() => _consultationDuration = v),
                validator: (v) => v == null ? 'الرجاء اختيار المدة' : null,
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 6),
              DropdownButtonFormField<sessionItem>(
                dropdownColor: Colors.white,
                value: _selectedsessionItem,
                hint: const Text('اختر مدة الجلسة'),
                isExpanded: true,
                decoration: _dropdownDecoration('مدة الجلسة',),
                items: _sessionDurations.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child:Text(item.text,style:  SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedsessionItem = v),
                validator: (v) => v == null ? 'يرجى اختيار مدة الجلسة' : null,
              ),

              const SizedBox(height: 16),

              /// الأيام المتاحة
              Row(
                children:  [
                  Icon(Icons.calendar_view_day_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('الأيام المتاحة',
                    style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: _availableDays.keys.map((d) {
                  return FilterChip(
                    label: Text(d.text ,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),),
                    selected: _availableDays[d]!,
                    onSelected: (v) => setState(() => _availableDays[d] = v),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              /// تاريخ البداية
              Row(
                children:  [
                  Icon(Icons.calendar_today, size: 20),
                  SizedBox(width: 8),
                  Text('تاريخ البداية',
                    style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color:Colors.black,
                        fontWeight: FontWeight.w500),),
                ],
              ),
              const SizedBox(height: 6),

              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: 'اختر التاريخ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
                validator: (_) =>
                _selectedDate == null ? 'يرجى اختيار تاريخ صالح' : null,
                controller: _dateController, // controller واحد فقط
              ),

              const SizedBox(height: 16),

              /// وقت البداية
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text('وقت البداية',
                    style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),),
                ],
              ),
              const SizedBox(height: 6),
              OutlinedButton(
                onPressed: () => _pickTime(context, true),
                child: Text(
                  _availableFrom == null
                      ? 'اختر الوقت'
                      : _formatTimeOfDay(_availableFrom!),
                style: SmartArabicTextStyle.create(context: context,
                    baseSize: 12,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500),),
              ),

              const SizedBox(height: 24),

              /// أزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToPreviousStep,
                      child:SmartArabicText(
                        text: 'السابق',
                        baseSize:12,
                        color: const Color(0xFF717070),
                        fontWeight: FontWeight.w700,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),

                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKeyConsultation.currentState!.validate()) {
                          _goToNextStep();
                        }
                      },
                      child:  SmartArabicText(
                        text: 'التالي',
                        baseSize:12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        backgroundColor:  AppColors.primaryBlue,
                        shadowColor:  Colors.white, // same shadow as previous style

                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

    } else if (_selectedWaqfType?.value == 'تدريبي') {
      loadperiods(3);
      if (isLoading) {
        return  const FullScreenLoading(
          message: 'جاري تحميل البيانات...',
          withScaffold: true,
        );
      }
      return Form(
        key: _formKeyTraining,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _stepIndicator(),
              const SizedBox(height: 24),
              _buildtitle( _selectedWaqfType!.title ?? ''),
              const SizedBox(height: 16),
              _buildTextField( controller:_trainingDescriptionController,label:'عنوان الدورة التدريبية',hint:'وصف تفصيلي للدورة التدريبية ومحتواها',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _trainingType,
                hint: const Text('اختر نوع التدريب'),
                decoration: _dropdownDecoration('نوع التدريب',),
                items: trainingtypes.map((p) {
                  return DropdownMenuItem(
                    value: p.id.toString(),
                    child:Text(p.trainingType,style:SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );}).toList(),
                onChanged: (val) => setState(() => _trainingType = val),
                validator: (value) =>
                value == null ? 'يرجى اختيار نوع التدريب' : null,
              ),

              const SizedBox(height: 16),

              /// مدة الدورة

              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _trainingDuration,
                hint: const Text('اختر المدة'),
                decoration: _dropdownDecoration('مدة الدورة',),
                items: _trainingDurations
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setState(() => _trainingDuration = val),
                validator: (value) =>
                value == null ? 'يرجى اختيار مدة الدورة' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField( controller:_trainingSeatsController,label:'عدد المقاعد المتاحة',hint:'20',maxLine:1,requiredField:true, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              /// المستوى
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _trainingLevel,
                hint: const Text('اختر المستوى'),
                decoration: _dropdownDecoration('المستوى',),
                items: TrainingLevels.map((level) {
                  return DropdownMenuItem(
                    value: level.id.toString(),
                    child:Text(level.trainingLevelTitle,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );
                }).toList(),
                onChanged: (val) => setState(() => _trainingLevel = val),
                validator: (value) =>
                value == null ? 'يرجى اختيار المستوى' : null,
              ),

              const SizedBox(height: 16),
              /// طريقة التقديم
               Text('طريقة التقديم',
                style: SmartArabicTextStyle.create(context: context,
                    baseSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),),
              const SizedBox(height: 6),
              Column(
                children: DeliveryMethods.map((method) {
                  return RadioListTile<int>(
                    value: method.id,
                    groupValue: _trainingDelivery,
                    title: Text(method.deliveryMethodTitle,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),),
                    onChanged: (val) => setState(() => _trainingDelivery = val),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              _buildTextField( controller:_trainingTopicsController,label:'المحاور الرئيسية للدورة',hint:'• المحور الأول\n• المحور الثاني\n• المحور الثالث',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              _buildTextField( controller:_trainingRequirementsController,label:'المتطلبات الأساسية',hint:'المعرفة أو المهارات المطلوبة',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              /// مدة الوقف

              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _trainingPeriod,
                hint: const Text('اختر المدة'),
    decoration: _dropdownDecoration('مدة الوقف',),
                items: Periods.map((p) {
                  return DropdownMenuItem(
                    value: p.id.toString(),
                    child:Text(p.expriencePeriod1,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );
                }).toList(),
                onChanged: (val) => setState(() => _trainingPeriod = val),
                validator: (value) =>
                value == null ? 'الرجاء اختيار المدة' : null,
              ),

              const SizedBox(height: 16),

              _buildTextField( controller:_trainingMaterialsLinkController,label:'رابط المواد التدريبية',hint:'https://drive.google.com/...',maxLine:1,requiredField:true, keyboardType: TextInputType.url),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToPreviousStep,
                      child:SmartArabicText(
                        text: 'السابق',
                        baseSize:12,
                        color: const Color(0xFF717070),
                        fontWeight: FontWeight.w700,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),

                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _goToNextStep,
                      child:  SmartArabicText(
                        text: 'التالي',
                        baseSize:12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        backgroundColor:  AppColors.primaryBlue,
                        shadowColor:  Colors.white, // same shadow as previous style

                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

    } else if (_selectedWaqfType?.value == 'تقني') {
      loadperiods(4);
      if (isLoading) {
        return  const FullScreenLoading(
          message: 'جاري تحميل البيانات...',
          withScaffold: true,
        );
      }

      return Form(
        key: _formKeyTechnical,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _stepIndicator(),
              const SizedBox(height: 24),
              _buildtitle( _selectedWaqfType!.title ?? ''),
              const SizedBox(height: 16),
              const Text(
                'تفاصيل المنتج التقني',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

              const SizedBox(height: 16),
              _buildTextField( controller:_techDescriptionController,label:'وصف المنتج التقني',hint:'وصف تفصيلي للمنتج التقني وفوائده',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              /// نوع المنت
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                initialValue: _techType,
                hint: const Text('اختر نوع المنتج'),
                decoration: _dropdownDecoration('نوع المنتج التقني'),
                items: trainingtypes.map((p) {
                  return DropdownMenuItem(
                    value: p.id.toString(),
                    child:Text(p.trainingType.toString(),style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),

                  );
                }).toList(),
                onChanged: (v) => setState(() => _techType = v),
                validator: (v) => v == null ? 'يرجى اختيار نوع المنتج' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField( controller:_techLanguageController,label:'لغة البرمجة / التقنية',hint:'React, Python, PHP',maxLine:1,requiredField:true),
              const SizedBox(height: 16),
              _buildTextField( controller:_techVersionController,label:'الإصدار',hint:'v1.0.0',maxLine:1,requiredField:true),
              const SizedBox(height: 16),
              /// نوع الترخيص
              Text('نوع الترخيص',
                style: SmartArabicTextStyle.create(context: context,
                    baseSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500),),
              const SizedBox(height: 6),
              Column(
                children: LicenseTypes.map((license) {
                  return RadioListTile<int>(
                    value: license.id,
                    groupValue: _techLicense,
                    title: Text(license.liciensyTypeTitle,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),),
                    onChanged: (v) => setState(() => _techLicense = v),
                  );
                }).toList(),
              ),
              if (_techLicense == null)
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    'يرجى اختيار نوع الترخيص',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              _buildTextField( controller:_techFeaturesController,label:'الميزات الرئيسية',hint:'• الميزة الأولى\n• الميزة الثانية',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              _buildTextField( controller:_techRequirementsController,label:'المتطلبات التقنية',hint:'Node.js, MySQL, Browser حديث...',maxLine:3,requiredField:true,keyboardType:TextInputType.multiline),
              const SizedBox(height: 16),
              /// التوثيق
               Text('التوثيق متوفر',
                   style: SmartArabicTextStyle.create(context: context,
    baseSize: 12,
    color: Colors.black,
    fontWeight: FontWeight.w500),),
              Column(
                children: _techDocumentation.keys.map((doc) {
                  return CheckboxListTile(
                    title: Text(doc,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),),
                    value: _techDocumentation[doc],
                    onChanged: (v) =>
                        setState(() => _techDocumentation[doc] = v ?? false),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: _techWaqfDuration,
                hint: const Text('اختر المدة'),
                decoration: _dropdownDecoration('مدة الوقف',),
                items: Periods.map((p) {
                  return DropdownMenuItem(
                    value: p.id.toString(),
                    child:Text(p.expriencePeriod1,style: SmartArabicTextStyle.create(context: context,
                        baseSize: 12,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _techWaqfDuration = v),
                validator: (v) => v == null ? 'الرجاء اختيار المدة' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField( controller:_techRepoLinkController,label:'رابط المشروع',hint:'https://github.com/...',maxLine:1,requiredField:true,keyboardType: TextInputType.url),
              const SizedBox(height: 16),
              _buildTextField( controller:_techDocsLinkController,label:'رابط التوثيق والملفات الإضافية',hint:'https://drive.google.com/...',maxLine:1,requiredField:true, keyboardType: TextInputType.url),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToPreviousStep,
                      child:SmartArabicText(
                        text: 'السابق',
                        baseSize:12,
                        color: const Color(0xFF717070),
                        fontWeight: FontWeight.w700,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),

                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKeyTechnical.currentState!.validate() &&
                            _techLicense != null) {
                          _goToNextStep();
                        }
                      },
                      child:  SmartArabicText(
                        text: 'التالي',
                        baseSize:12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        backgroundColor:  AppColors.primaryBlue,
                        shadowColor:  Colors.white, // same shadow as previous style
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

    } else {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _stepIndicator(),
            SizedBox(height: 24),
            Text(
              'تفاصيل الوقف (${_selectedWaqfType?.title ?? ''})',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Text(
              'لا توجد تفاصيل إضافية لهذا النوع حالياً.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    child:SmartArabicText(
                      text: 'السابق',
                      baseSize:12,
                      color: const Color(0xFF717070),
                      fontWeight: FontWeight.w700,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),

                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _goToNextStep,
                  child:  SmartArabicText(
                    text: 'التالي',
                    baseSize:12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    backgroundColor:  AppColors.primaryBlue,
                    shadowColor:  Colors.white, // same shadow as previous style

                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStepThree() {
    final selectedDays = _availableDays.entries
        .where((e) => e.value)
        .map((e) => e.key.text)
        .toList();
    String daysSelected = _availableDays.entries.where((e) => e.value).map((e) => e.key.value).join(", ");
    String timeSlotsSelected = _timeSlots.entries.where((e) => e.value).map((e) => e.key).join(", ");
    return Padding(
      padding: EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _stepIndicator(),
            SizedBox(height: 24),
            _buildtitle('مراجعة البيانات'),

            SizedBox(height: 24),
            Text('نوع الوقف:', style: SmartArabicTextStyle.create(context: context,
                baseSize: 12,
                color: Colors.black,
                fontWeight: FontWeight.w500)),
            Text(_selectedWaqfType?.title ?? '' ,style: SmartArabicTextStyle.create(context: context,
                baseSize: 10,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500),),
            SizedBox(height: 16),

            if (_selectedWaqfType?.value == 'إبداعي')...[
              _buildReviewItem('عنوان العمل:',_creativeTitleController.text),
              _buildReviewItem('وصف العمل:',_creativeDescriptionController.text),
              _buildReviewItem('نوع العمل:',trainingtypes.firstWhere((p) => p.id.toString() == _creativeType.toString()).trainingType ?? ''),
              _buildReviewItem('مدة الوقف:', Periods.firstWhere((p) => p.id.toString() == _creativeDuration).expriencePeriod1 ?? ''),
              _buildReviewItem('صيغة الملفات:', _creativeFileFormats.entries.where((e) => e.value).map((e) => e.key).join(', ')),
              _buildReviewItem('نوع الترخيص:', LicenseTypes.firstWhere((p) => p.id.toString() == _creativeLicense.toString()).liciensyTypeTitle ?? ''),
              _buildReviewItem('رابط الملفات:',_creativeFileLinkController.text),
            ],
            if(_selectedWaqfType?.value == 'زمني')
              ...[
                _buildReviewItem('وصف المشروع/النشاط', _timedescriptionController.text),
                _buildReviewItem('مدة الوقف',                Periods.firstWhere((p) => p.id.toString() == _timeselectedDuration.toString()).expriencePeriod1 ?? ''),
                _buildReviewItem('الوقت المتاح أسبوعياً', _weeklyHoursOptions.firstWhere((item) => item.value == _weeklyHours.toString(),).text.toString()),
                _buildReviewItem('الأيام المتاحة',
                selectedDays.join(', ')),
                _buildReviewItem('الفترات الزمنية المتاحة', timeSlotsSelected == 'صباحي' ? 'الفترة الصباحية (8 ص - 12 م)' : 'الفترة المسائية (4 م - 8 م)'),
                _buildReviewItem('طريقة المشاركة', DeliveryMethods.firstWhere((p) => p.id.toString() == _participationMethod.toString()).deliveryMethodTitle ?? ''),
                _buildReviewItem('نوع المشروع',trainingtypes.firstWhere((p) => p.id.toString() == _projectType.toString()).trainingType ?? ''),
           ],
            if(_selectedWaqfType?.value == 'معرفي')...[
              _buildReviewItem('وصف المنتج:', _descriptionController.text),
              _buildReviewItem('مدة الوقف:', Periods.firstWhere((p) => p.id.toString() == _selectedDuration).expriencePeriod1 ?? ''),
              _buildReviewItem('رابط الملفات:',_fileLinkController.text),
            ],
            if (_selectedWaqfType?.value == 'استشاري') ...[
              _buildReviewItem('وصف الاستشارة:', _consultationDescriptionController.text),
              _buildReviewItem('مدة الوقف:',Periods.firstWhere((p) => p.id.toString() == _consultationDuration).expriencePeriod1 ?? ''),
              _buildReviewItem('مدة الجلسة الاستشارية:', _selectedsessionItem!.text ?? ''),
              _buildReviewItem('الأيام المتاحة:', selectedDays.join(', ')),
              _buildReviewItem('تاريخ البداية', '${_formattedDate}'),
              _buildReviewItem('وقت البداية', '${_formatTimeOfDay(_availableFrom)}'),
            ],

            if (_selectedWaqfType?.value == 'تدريبي') ...[
              _buildReviewItem('وصف الدورة التدريبية:', _trainingDescriptionController.text),
              _buildReviewItem('نوع التدريب:', trainingtypes.firstWhere((p) => p.id.toString() == _trainingType).trainingType ?? ''),
              _buildReviewItem('مدة الدورة:', _trainingDuration ?? ''),
              _buildReviewItem('عدد المقاعد المتاحة:', _trainingSeatsController.text),
              _buildReviewItem('المستوى:', TrainingLevels.firstWhere((p) => p.id.toString() == _trainingLevel.toString()).trainingLevelTitle ?? ''),
              _buildReviewItem('طريقة التقديم:', DeliveryMethods.firstWhere((p) => p.id.toString() == _trainingDelivery.toString()).deliveryMethodTitle ?? ''),
              _buildReviewItem('المحاور الرئيسية للدورة:', _trainingTopicsController.text),
              _buildReviewItem('المتطلبات الأساسية:', _trainingRequirementsController.text),
              _buildReviewItem('مدة الوقف:', Periods.firstWhere((p) => p.id.toString() == _trainingPeriod.toString()).expriencePeriod1 ?? ''),
              _buildReviewItem('رابط المواد التدريبية:', _trainingMaterialsLinkController.text),
            ],
            if (_selectedWaqfType?.value == 'تقني') ...[
              _buildReviewItem('وصف المنتج التقني:', _techDescriptionController.text),
              _buildReviewItem('نوع المنتج التقني:', trainingtypes.firstWhere((p) => p.id.toString() == _techType).trainingType ?? ''),
              _buildReviewItem('لغة البرمجة/التقنية:', _techLanguageController.text),
              _buildReviewItem('الإصدار:', _techVersionController.text),
              _buildReviewItem('نوع الترخيص:', LicenseTypes.firstWhere((p) => p.id.toString() == _techLicense.toString()).liciensyTypeTitle ?? ''),
              _buildReviewItem('الميزات الرئيسية:', _techFeaturesController.text),
              _buildReviewItem('المتطلبات التقنية:', _techRequirementsController.text),
              _buildReviewItem('التوثيق المتوفر:', _techDocumentation.entries.where((e) => e.value).map((e) => e.key).join(', ')),
              _buildReviewItem('مدة الوقف:', Periods.firstWhere((p) => p.id.toString() == _techWaqfDuration.toString()).expriencePeriod1 ?? ''),
              _buildReviewItem('رابط المشروع:', _techRepoLinkController.text),
              _buildReviewItem('رابط التوثيق والملفات الإضافية:', _techDocsLinkController.text),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goToPreviousStep,
                    child:SmartArabicText(
                      text: 'السابق',
                      baseSize:12,
                      color: const Color(0xFF717070),
                      fontWeight: FontWeight.w700,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),

                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ScaleTransition(
                    scale: _buttonAnimation,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        backgroundColor:  AppColors.primaryBlue,
                        shadowColor:  Colors.white, // same shadow as previous style

                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SmallLoadingWidget(),
                          SizedBox(width: 8),
                          Text('جاري المعالجة...'),
                        ],
                      )
                          :
                      SmartArabicText(
                        text: 'ارسال',
                        baseSize:12,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _consultationDescriptionController.dispose();
    _trainingDescriptionController.dispose();
    _trainingSeatsController.dispose();
    _trainingTopicsController.dispose();
    _trainingRequirementsController.dispose();
    _trainingMaterialsLinkController.dispose();
    _techDescriptionController.dispose();
    _techLanguageController.dispose();
    _techVersionController.dispose();
    _techFeaturesController.dispose();
    _techRequirementsController.dispose();
    _techRepoLinkController.dispose();
    _techDocsLinkController.dispose();
    _animationController.dispose();
    _creativeTitleController.dispose();
    _creativeDescriptionController.dispose();
    _creativeFileLinkController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_currentStep) {
      case 0:
        body = _buildStepOne();
        break;
      case 1:
        body = _buildStepTwo();
        break;
      case 2:
        body = _buildStepThree();
        break;
      default:
        body = Center(child: Text('خطأ في التنقل بين الخطوات'));
    }

    return Scaffold(
      appBar: AppBar(
        title:
        SmartArabicText(
          text: 'إضافة خبرة',
          baseSize:12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(child: body) ,
      ),
    );

  }
  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 2.92,
                letterSpacing: -0.50,
              ),
            ),
          ),
          const SizedBox(width: 15), // <-- add horizontal spacing here
          Expanded(
            flex: 5,
            child: Text(
                value,
                style:
                SmartArabicTextStyle.create(color: Color(0xFF717070) ,baseSize: 12,fontWeight: FontWeight.w500, context: context)
            ),
          ),
        ],
      ),
    );
  }
}
