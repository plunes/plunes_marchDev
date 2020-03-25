import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_webservice/places.dart';

//import 'package:location/location.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/appointments/SendPrescriptionModel.dart';
import 'package:plunes/model/check_user.dart';
import 'package:plunes/model/profile/edit_profile.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/model/profile/user_profile.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:plunes/start_streen/LocationFetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class CreatePrescription extends StatefulWidget {
  var from, patientId;

  CreatePrescription({this.from, this.patientId});

  static const tag = '/createPrescription';

  @override
  _CreatePrescriptionState createState() => _CreatePrescriptionState();
}

class _CreatePrescriptionState extends State<CreatePrescription> {
  DateTime selectedDate = DateTime.now();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final patientNameController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final dateController = TextEditingController();
  final prescriptionController = TextEditingController();
  final diagnosisController = TextEditingController();
  final medicineController = TextEditingController();
  final testController = TextEditingController();
  final remarksController = TextEditingController();
  String errorMessage = "";

  bool name_valid = true;
  TextEditingController phone_no_ = TextEditingController();
  bool qualification_valid = true;
  bool practising_valid = true;
  bool college_valid = true;

  //// after submit
  bool progress = false, fromFlag = true;
  bool generaluser = true;

  String user_token = "";
  String user_id = "";
  String user_name = "";
  String _user_type = "";
  String user_phone = "";
  String specialities = "", prescriptionLogoUrl = '', prescriptionLogoText='';
  List<String> prescriptionFieldsList = new List();
  List<TextEditingController> _controllers = new List();

  @override
  void initState() {
    getSharedPreferences();
    super.initState();
  }

  Future getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    setState(() {
      user_token = token;
      user_id = uid;
      prescriptionLogoUrl = prefs.getString("PRESCRIPTION_LOGO_URL")!= null? prefs.getString("PRESCRIPTION_LOGO_URL") : '';
      prescriptionLogoText = prefs.getString("PRESCRIPTION_LOGO_TEXT")!=null? prefs.getString("PRESCRIPTION_LOGO_TEXT"):'';
      prescriptionFieldsList = prefs.getStringList("PRESCRIPTION_FIELDS")!=null? prefs.getStringList("PRESCRIPTION_FIELDS"):new List();
    });
    fromFlag = widget.from == 'Appointment';
   if(fromFlag)
   getUserData();
  }

  Future getUserData() async {
    UserProfilePost userProfilePost = await user_profile(widget.patientId, user_token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });
    patientNameController.text = userProfilePost.user.name;
    ageController.text = userProfilePost.user.birthDate;
    phone_no_.text = userProfilePost.user.mobileNumber;
    genderController.text = userProfilePost.user.gender != ''
        ? (userProfilePost.user.gender == 'F'
            ? 'Female'
            : userProfilePost.user.gender)
        : 'Male';
    if (userProfilePost.user.birthDate.contains('/'))
      ageController.text = (config.Config.calculateAge(DateTime(
              int.parse(userProfilePost.user.birthDate.split('/')[2]),
              int.parse(userProfilePost.user.birthDate.split('/')[1]),
              int.parse(userProfilePost.user.birthDate.split('/')[0]))))
          .toString();
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;
    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "Create Prescription",
        style: TextStyle(color: Colors.black),
      ),
    );
    Widget logoImageField = Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: 38, right: 38, top: 20, bottom: 10),
      child: prescriptionLogoUrl != ''
          ? CachedNetworkImage(
              imageUrl: prescriptionLogoUrl, height: 100, fit: BoxFit.contain)
          :  Text(
        prescriptionLogoText,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold)),
    );
    Widget patientTextField = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextFormField(
        controller: patientNameController,
        decoration: InputDecoration(
            labelText: 'Patient Name',
            errorText: name_valid ? null : "Please enter patient name"),
      ),
    );

    Widget phoneTextField = Container(
      margin: EdgeInsets.only(left: 38, right: 38, top: 10),
      child: TextFormField(
        enabled: false,
        keyboardType: TextInputType.phone,
        controller: phone_no_,
        decoration: InputDecoration(
          labelText: 'Phone No',
        ),
      ),
    );

    Widget ageTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextFormField(
        controller: ageController,
        decoration: InputDecoration(labelText: 'Age'),
      ),
    );

    Widget genderTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
        enabled: false,
        controller: genderController,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(labelText: 'Gender'),
      ),
    );

    Widget dateTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: InkWell(
        onTap: () {
          _selectDate(config.Config.globalContext);
        },
        child: TextFormField(
          enabled: false,
          controller: dateController,
          maxLines: null,
          decoration: InputDecoration(labelText: 'Date'),
        ),
      ),
    );

    Widget prescriptionTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextFormField(
        textCapitalization: TextCapitalization.words,
        controller: prescriptionController,
        decoration: InputDecoration(
            labelText: 'Prescription',
            errorText: practising_valid ? null : "Please enter prescription"),
      ),
    );

    Widget diagnosisTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextFormField(
        controller: diagnosisController,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
            labelText: 'Diagnosis',
            errorText: college_valid ? null : "Please enter diagnosis"),
      ),
    );

    Widget medicineTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
        controller: medicineController,
        decoration: InputDecoration(labelText: 'Medicine'),
      ),
    );

    Widget testTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
        controller: testController,
        decoration: InputDecoration(labelText: 'Test'),
      ),
    );

    Widget remarkTextField = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
        controller: remarksController,
        decoration: InputDecoration(labelText: 'Remarks'),
      ),
    );
    Widget submitPrescription = Padding(
      padding:
          const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30, top: 20),
      child: progress
          ? SpinKitThreeBounce(
              color: Color(0xff01d35a),
              size: 30.0,
              // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: Container(
                margin: EdgeInsets.only(right: 20, left: 10),
                child: FlatButton(
                  onPressed: sendPrescriptionApi,
                  color: Color(0xff01d35a),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("Send", style: TextStyle(color: Colors.white)),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
              ),
            ),
    );

    Widget form = Container(
      child: ListView(
        children: <Widget>[
          logoImageField,
          patientTextField,
          phoneTextField,
          ageTextField,
          genderTextField,
          dateTextField,
          getOtherFields(),
//          prescriptionTextField,
//          diagnosisTextField,
//          medicineTextField,
//          testTextField,
//          remarkTextField,
//          addFieldView(),
          submitPrescription,
        ],
      ),
    );

    return Scaffold(
        key: _scaffoldKey,
        appBar: app_bar,
        backgroundColor: Colors.white,
        body: SafeArea(child: fromFlag ? form : enterPhoneScreen()));
  }

  Widget enterPhoneScreen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 38, right: 38, top: 20),
            child: TextFormField(
              keyboardType: TextInputType.phone,
              controller: phone_no_,
              decoration: InputDecoration(
                labelText: 'Enter Patient Mobile Number',
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 30, top: 50),
              child: progress
                  ? SpinKitThreeBounce(
                      color: Color(0xff01d35a),
                      size: 30.0,
                      // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                    )
                  : ConstrainedBox(
                      constraints:
                          const BoxConstraints(minWidth: double.infinity),
                      child: Container(
                        margin: EdgeInsets.only(right: 20, left: 10),
                        child: FlatButton(
                          onPressed: gotoPrescriptionForm,
                          color: Color(0xff01d35a),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text("Continue",
                                style: TextStyle(color: Colors.white)),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                        ),
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  }

  Widget addFieldView() {
    return InkWell(
      onTap: () {},
      child: Container(
          margin: EdgeInsets.only(top: 30, bottom: 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <
              Widget>[
            Container(
                alignment: Alignment.centerLeft,
                child: Container(
                  alignment: Alignment.topLeft,
                  margin:
                      EdgeInsets.only(left: 38, right: 8, top: 10, bottom: 10),
                  child: Image.asset(
                    'assets/images/add_field_icon.png',
                    height: 30,
                    width: 30,
                    fit: BoxFit.contain,
                  ),
                )),
            Expanded(
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Add Field',
                        style: TextStyle(
                            fontSize: 15,
                            color: Color(
                                config.Config.getColorHexFromStr('#585858'))))))
          ])),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateController.text = picked.day.toString() +
            "/" +
            picked.month.toString() +
            "/" +
            picked.year.toString();
      });
  }

  Future gotoPrescriptionForm() async {
    if (phone_no_.text != '') {
      setState(() {
        progress = true;
      });
      CheckPost checkPost =
          await check_user(phone_no_.text.trim()).catchError((error) {
        config.Config.showLongToast('Something went wrong!');
        setState(() {
          progress = false;
        });
      });
      setState(() {
        patientNameController.text = checkPost.user.name;
        ageController.text = checkPost.user.birthDate;
        phone_no_.text = checkPost.user.mobileNumber;
        genderController.text = checkPost.user.gender != ''
            ? (checkPost.user.gender == 'F' ? 'Female' : 'Male')
            : 'Male';
        widget.patientId = checkPost.user.uid;
        fromFlag = true;
        progress = false;
        if (checkPost.user.birthDate.contains('/'))
          ageController.text = (config.Config.calculateAge(DateTime(
                  int.parse(checkPost.user.birthDate.split('/')[2]),
                  int.parse(checkPost.user.birthDate.split('/')[1]),
                  int.parse(checkPost.user.birthDate.split('/')[0]))))
              .toString();
      });
    } else {
      config.Config.showLongToast("Please enter phone number first.");
    }
  }

  sendPrescriptionApi() async {
    if (validation()) {
      setState(() {
        progress = true;
      });
      List list = new List();
      for(var i=0; i< prescriptionFieldsList.length; i++){
        list.add({prescriptionFieldsList[i] : _controllers[i].text});
      }
      var prescriptionData = {
        "patientName": patientNameController.text,
        "patientAge": ageController.text,
        "patientGender": genderController.text,
        "date": dateController.text,
        'fields': list
      };
      var body = {
        'userId': user_id,
        'patientId': widget.patientId,
        'prescriptionData': prescriptionData
      };
      print(body);
      SendPrescriptionModel result = await sendPrescriptionAPI(body, user_token).catchError((error) {
        config.Config.showLongToast("Something went wrong!" + error.toString());
        setState(() {
          progress = false;
        });
      });
      setState(() {
        progress = false;
        if (result.success) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => _popup_saved(context));
        } else {
          config.Config.showInSnackBar(_scaffoldKey, result.message, Colors.black87);
        }
      });
    } else
      config.Config.showInSnackBar(_scaffoldKey, errorMessage, Colors.black87);
  }

  bool validation() {
    if (patientNameController.text.trim().isEmpty) {
      errorMessage = 'Please enter patient name.';
      return false;
    } else if (ageController.text.trim().isEmpty) {
      errorMessage = 'Age field can not be empty.';
      return false;
    } else if (dateController.text.trim().isEmpty) {
      errorMessage = 'Please select date.';
      return false;
    } /*else if (prescriptionController.text.trim().isEmpty) {
      errorMessage = 'Prescription field can not be empty.';
      return false;
    } else if (diagnosisController.text.isEmpty) {
      errorMessage = 'Diagnosis field can not be empty.';
      return false;
    } else if (medicineController.text.isEmpty) {
      errorMessage = 'Medicine field can not be empty.';
      return false;
    } else if (testController.text.isEmpty) {
      errorMessage = 'Test field can not be empty.';
      return false;
    } else if (remarksController.text.isEmpty) {
      errorMessage = 'Remarks field can not be empty.';
      return false;
    }*/ else {
      return true;
    }
  }

  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Sent!'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(Config.globalContext);
            /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(screen: "profile"),
                ));*/
          },
          child: new Text(
            'OK',
            style: TextStyle(color: Color(0xff01d35a)),
          ),
        ),
      ],
    );
  }

  Widget getOtherFields() {
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: prescriptionFieldsList.length,
        itemBuilder: (BuildContext context, int index) {
          _controllers.add(new TextEditingController());

          return Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ), child: TextField(
        controller: _controllers[index],
        decoration: InputDecoration(labelText: prescriptionFieldsList[index]),
      ),
      );
    });





  }
}
