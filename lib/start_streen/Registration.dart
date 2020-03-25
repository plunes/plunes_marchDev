import 'dart:async';
import 'dart:convert';
import 'dart:io' show File, Platform;

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/login_reg_user.dart';
import 'package:plunes/start_streen/HospitalRegistration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import 'HomeScreen.dart';
import 'LocationFetch.dart';

class Registration extends StatefulWidget {
  static const tag = "/registration";
  final String phone;

  Registration({Key key, this.phone}) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState( phone);
}


class _RegistrationState extends State<Registration> {


  List _users = ["General User", "Doctor", "Hospital"];//, "Diagnostics Center"
  String gender = "Male";
  bool hospital = false;
  bool isSwitched = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _user_type;
  String phone;
  String latitude = "0.0";
  String longitude = "0.0";

  List<String> specialization_list = new List();
  String City_name;

  List<String> specialistbio = new List();
  String Specialist_bio = "";

  List<String> commondisease = new List();
  String Common_disease ="";

  List<String> specialistservices = new List();
  String Specialist_service = "";

  List<String> symptoms_list = new List();
  String symptoms = "";

  var location = new loc.Location();

  _RegistrationState( this.phone);

  // here we are creating the list needed for the DropDownButton
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String user in _users) {
      // here we are creating the drop down menu items, you can customize the iFtem right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(value: user, child: new Text(user)));
    }
    return items;
  }

  _launchURL() async {
    String url = config.Config.terms;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool show_mannual = true;
  TextEditingController hospital_name = new TextEditingController();
  TextEditingController address = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController City = new TextEditingController();
  TextEditingController About = new TextEditingController();
  TextEditingController registration_no = new TextEditingController();
  TextEditingController dob_ = new TextEditingController();



  TextEditingController email_id_get = new TextEditingController();
  List specialization_selected = new List();

  TextEditingController doc_name = new TextEditingController();
  TextEditingController doc_education = new TextEditingController();
  TextEditingController doc_designation = new TextEditingController();
  TextEditingController doc_department = new TextEditingController();
  TextEditingController doc_experience = new TextEditingController();
  TextEditingController doc_availability_from = new TextEditingController();
  TextEditingController doc_availability_to = new TextEditingController();

  List doctor_image =  new List();
  List doctor_name =  new List();
  List doctor_education = new List();
  List doctor_designation = new List();
  List doctor_department = new List();
  List doctor_experience = new List();
  List doctor_availability = new List();
  List doctor_img_file= new List();


  bool qualification;
  bool specilization;
  bool reg_no;
  bool exp_no;
  bool _passwordVisible = true;
  bool dob_valid = true;

  void display() {
    setState(() {
      qualification = true;
      specilization = true;
      reg_no = true;
      exp_no = true;
    });
  }

  void hiding() {
    setState(() {
      qualification = false;
      specilization = false;
      reg_no = false;
      exp_no = false;
    });
  }


  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,

        initialDate: selectedDate,
        firstDate: DateTime(1910, 1),
        lastDate: selectedDate

    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dob_.text = picked.day.toString()+"/"+picked.month.toString()+
        "/"+picked.year.toString();
      });
  }

  @override
  void initState() {

    _dropDownMenuItems = getDropDownMenuItems();
    _user_type = _dropDownMenuItems[0].value;

    super.initState();
    qualification = false;
    specilization = false;
    reg_no = false;
    exp_no = false;

    doc_availability_from.text = "00:00 AM";
    doc_availability_to.text = "00:00 AM";

    get_specialists("");
    getLocation();
  }


  Future<Null> _selectdata(String time, String type) async {
    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1].substring(0,2))
    );

    final TimeOfDay picker = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
    );


    if (picker != null) {

        if(type == "1"){
          doc_availability_from.text = picker.format(context);
        }else {
          doc_availability_to.text = picker.format(context);
        }

    }
  }

  void getLocation() async {
  /*  setState(() {
      progress = true;
    });*/

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {


      var location_ = await location.getLocation();
      latitude = location_.latitude.toString();
      longitude = location_.longitude.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString("latitude", latitude);
      prefs.setString("longitude", longitude);
      print(latitude + "," + longitude);
    }

    final coordinates = new Coordinates(double.parse(latitude), double.parse(longitude));
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

    var addr = addresses.first;
    String full_address = addr.addressLine;

    setState(() {
//      progress = false;
      location_.text = full_address;
      address.text = full_address;

    });
  }


  TextEditingController full_name_ = TextEditingController();
  bool name_valid = true;

  TextEditingController email_id_ = TextEditingController();
  bool emain_valid = true;

  TextEditingController password_ = TextEditingController();
  bool password_valid = true;

  TextEditingController professon_reg_no_ = TextEditingController();
  bool profession_valid = true;

  TextEditingController qualification_ = TextEditingController();
  bool qualification_valid = true;

  TextEditingController specialization_ = TextEditingController();
  bool specification_valid = true;

  TextEditingController location_ = TextEditingController();
  bool location_valid = true;

  TextEditingController experience_ = TextEditingController();
  bool experience_valid = true;

  TextEditingController referal_text = TextEditingController();

  RegistrationPost registrationPost;

  bool progress= false;
  TextEditingController search_controler = TextEditingController();

  bool icons = true;
  int data = 1;
  int male = 0;
  int female = 1;
  var image;

  void get_specialists(String specialist) async{
    for(int i =0; i< config.Config.specialist_lists.length; i++){
      specialization_list.add(config.Config.specialist_lists[i]);
      specialistbio.add(" ");
      commondisease.add(" ");
      specialistservices.add(" ");
      symptoms_list.add(" ");
    }
  }

  void hospital_regis()async{

    setState(() {
      progress = true;
    });


    List specialist_data = new List();
    List doc_list = new List();

    for(int i =0; i< specialization_selected.length; i++){
      int id_pos = config.Config.specialist_lists.indexOf(specialization_selected[i]);
      specialist_data.add({"specialityId": config.Config.specialist_id[id_pos]});
    }

    print(specialist_data);

    var geoLocation = {"latitude": latitude, "longitude": longitude};

    for(int i =0; i< doctor_name.length; i++){
      doc_list.add(	{
        "name":doctor_name[i],
        "education":doctor_education[i],
        "designation":doctor_designation[i],
        "department":doctor_department[i],
        "experience":doctor_experience[i],
        "availability":doctor_availability[i]
      });
    }

    List device_id = new List();
    device_id.add({"deviceId":config.Config.device_id});

    var body = {
      "userType":_user_type,
      "name": hospital_name.text,
      "address": address.text,
      "mobileNumber": phone,
      "biography": About.text,
      "registrationNumber": registration_no.text,
      "specialities":specialist_data,
      "doctors":doc_list,
      "geoLocation": geoLocation,
      "verifiedUser": 'true',
      "email": email_id_get.text,
      "password": password_.text,
      "deviceIds":device_id
    };
    registrationPost = await registration_api(body).catchError((error){
      config.Config.showLongToast("Something went wrong!");
    });
    setState(() {
      progress = false;
      if(registrationPost.success){
        _saveValues(
            registrationPost.token, registrationPost.user.uid,
            registrationPost.user.name,
            registrationPost.user.email,
            registrationPost.user.mobileNumber,
            registrationPost.user.userType,
            registrationPost.user.address,
            specialization_selected.join(",").toString()
        );
      }else{
        config.Config.showInSnackBar(_scaffoldKey, registrationPost.message, Colors.red);
      }
    });
  }

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      maxWidth: 512,
      maxHeight: 512,
    );
    return croppedFile;
  }

  Future getImage(BuildContext context) async {
     image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      image = await _cropImage(image);
      print("image==" + base64Encode(image.readAsBytesSync()).toString());
    }

    if (image != null) {
      String url = config.Config.image_upload + "upload";
      print("image==" + base64Encode(image.readAsBytesSync()).toString());

    }
  }


  void get_camera(BuildContext context) async {
     image = await ImagePicker.pickImage(
        source: ImageSource.camera,
    );

    if (image != null) {
      image = await _cropImage(image);
      print("image==" + base64Encode(image.readAsBytesSync()).toString());
    }

    if (image != null) {

      print("image==" + base64Encode(image.readAsBytesSync()).toString());

    }
  }


  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[

                new ListTile(
                    leading: new Icon(Icons.camera),
                    title: new Text('Camera'),
                    onTap: () {
                      get_camera(context);
                      Navigator.pop(context);
                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.image),
                  title: new Text('Gallery'),
                  onTap: () {
                    getImage(context);
                    Navigator.pop(context);
                  },
                ),

              ],
            ),
          );
        });
  }





  void register() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lat = prefs.getString("latitude");
    String lng = prefs.getString("longitude");

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    bool emailValid = RegExp(p).hasMatch(email_id_.text); //r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    int pass_length = password_.text.length;


    setState(() {
      latitude = lat;
      longitude = lng;
        if (full_name_.text != '') {
          name_valid = true;
          if (dob_.text != '') {
            dob_valid = true;
            if (email_id_.text != '' && emailValid) {
              emain_valid = true;
              if (password_.text != '' && pass_length >= 8) {
                password_valid = true;
//// profession ----------------

                if (_user_type == "Doctor" || _user_type == "Hospital" || _user_type == "Lab") {

                  if (professon_reg_no_.text != '') {
                    profession_valid = true;
                    if(specialization_.text != '') {
                      specification_valid = true;
                      if (experience_.text != '' && config.Config.isNumeric(experience_.text)) {
                        progress = true;
                        experience_valid = true;
                        handle();
                      } else {
                        experience_valid = false;
                      }
                    }else{
                      specification_valid = false;
                    }
                  } else {
                    profession_valid = false;
                  }

                } else {
                  progress = true;
                  handle();
                }
              } else {
                password_valid = false;
              }
            } else {
              emain_valid = false;
            }
          } else {
            dob_valid = false;
          }

      }else{
          name_valid = false;
        }
    });
  }

  void handle() async{
    var body;
    var geoLocation = {"latitude": latitude, "longitude": longitude};

    List device_id = new List();
    device_id.add(config.Config.device_id);

    if(_user_type == 'General User'){

      body = {
        "name": full_name_.text,
        "gender": gender == "Male" ? "M": "F",
        "birthDate": dob_.text,
        "mobileNumber": phone,
        "email": email_id_.text.trim(),
        "verifiedUser": 'true',
        "password": password_.text,
        "geoLocation": geoLocation,
        "userType": "User",
        "address": location_.text,
        "referralCode": referal_text.text,
        "deviceIds":device_id
      };

    } else{

      List specialists = specialization_.text.split(',');
      List specialist_data = new List();
      print(specialists);

      for(int i =0; i< specialists.length; i++){
        int id_pos = config.Config.specialist_lists.indexOf(specialists[i]);
        specialist_data.add({"specialityId": config.Config.specialist_id[id_pos]});
      }

      body = {
        "name": full_name_.text,
        "geoLocation": geoLocation,
        "email": email_id_.text.trim(),
        "password": password_.text,
        "mobileNumber": phone,
        "userType": _user_type,
        "verifiedUser": 'true',
        "gender": gender == "Male" ? "M": "F",
        "birthDate": dob_.text,
        "address": location_.text,
        "referralCode": referal_text.text,
        "experience": experience_.text,
        "registrationNumber": professon_reg_no_.text,
        "specialities":specialist_data,
        "deviceIds":device_id
      };
    }

    print(body);

    if (_user_type == "Doctor"){
      if(name_valid && dob_valid && emain_valid && password_valid && profession_valid && specialization_.text !='' && experience_valid) {

        registrationPost = await registration_api(body).catchError((error){
          config.Config.showLongToast("Something went wrong!");
         setState(() {
           progress = false;
         });
        });

        setState(() {
          progress = false;
          if(registrationPost.success){
            _saveValues(registrationPost.token, registrationPost.user.uid,
                registrationPost.user.name,
                registrationPost.user.email,
                registrationPost.user.mobileNumber,
                registrationPost.user.userType,
                registrationPost.user.address,
                specialization_.text
            );
          }else{
            config.Config.showInSnackBar(_scaffoldKey, registrationPost.message, Colors.red);
          }
        });
      }else{
        setState(() {
          progress = false;
        });
      }


    }else{
      if(name_valid && dob_valid && emain_valid && password_valid){
        registrationPost = await registration_api(body).catchError((error){
          config.Config.showLongToast("Something went wrong!");
         setState(() {
           progress = false;
         });
        });

        setState(() {
          if(registrationPost.success){
            progress = false;
            _saveValues(registrationPost.token, registrationPost.user.uid,
                registrationPost.user.name,
                registrationPost.user.email,
                registrationPost.user.mobileNumber,
                registrationPost.user.userType,
                registrationPost.user.address, ''
            );

          }else{
            config.Config.showInSnackBar(_scaffoldKey, registrationPost.message, Colors.red);
            progress = false;
          }
        });
      }else{
        setState(() {
          progress = false;
        });
      }
    }
  }



  _saveValues(String token, String uid, String name, String email, String phoneno, String user_type, String user_location, String speciality)  async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
    prefs.setString("uid", uid);

    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("phoneno", phoneno);

    prefs.setString("user_type", user_type);
    prefs.setString("user_location", user_location);
//    prefs.setString("experience", experience);
//    prefs.setString("practising", practising);
//    prefs.setString("college", college);
//    prefs.setString("intro", intro);
//    prefs.setString("professional_registration_number", professional_registration_number);
//    prefs.setString("qualification", qualification);

    prefs.setString("latitude", latitude);
    prefs.setString("longitude", longitude);
    prefs.setString("specialist", speciality);

    Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(screen: 'bids')));
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _user_type = selectedCity;
      if (_user_type == "Doctor" ) {
        display();
        full_name_.text = "Dr. ";
        hospital = false;
      }else if(_user_type == "Hospital" || _user_type == 'Lab'){
        hospital = true;
        full_name_.text = "";
      }
      else {
        full_name_.text = "";
        hiding();
        hospital = false;
      }
    });
  }

//  void call_login () async{
//
//    var match =   {
//      "phone_number": phone,
//      "password":password_.text,
//      "device_id":config.Config.device_id
//    };
//
//    print(match);
//
//    String url = config.Config.login_reg+"authenticate";
//
//    loginPost = await loginapi(url,match);
//    progress = false;
//
//    if(loginPost.success){
//      print(loginPost.user.token);
//
//      await _saveValues(loginPost.user.token, loginPost.user.name, loginPost.user.email,loginPost.user.activated,
//          loginPost.user.phone_number, loginPost.user.user_type, loginPost.user.uid, loginPost.user.imageUrl,
//          loginPost.user.speciality,  loginPost.user.professional_registration_number, loginPost.user.qualification,
//          loginPost.user.user_location, loginPost.user.experience,  loginPost.user.practising, loginPost.user.college,
//          loginPost.user.about);
//
//      // Navigator.pushNamed(context, HomeScreen.tag);
//
//      Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (context) => HomeScreen(screen: 'bids'),
//          ));
//    }
//  }


  @override
  Widget build(BuildContext context) {


    Config.globalContext = context;

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,

      title: Text(
        "Sign up",
        style: TextStyle(color: Colors.black),
      ),
    );

    final drop_down = Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          margin: EdgeInsets.only(left: 15, right: 15),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: DropdownButtonFormField(
              value: _user_type,
              items: _dropDownMenuItems,
              onChanged: changedDropDownItem,
            ),
          ),
        ),
      ),
    );


    final experience =  _user_type == 'Hospital' || _user_type == 'Lab'? Container() :Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: Visibility(
        visible: exp_no,
        child: TextField(
          controller: experience_,
          onChanged: (text){
            setState(() {
              if(text.length > 0){
                experience_valid = true;
              }else{
                experience_valid = false;
              }
             // experience_.text = text+" years";
            });
          },
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Experience (in number)*',
              errorText: experience_valid ?null: "Please enter your experience"
          ),
        ),
      ),
    );


    final full_name = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextField(
        controller: full_name_,
        onChanged: (text){

       setState(() {
         if(text.length >0){
           name_valid = true;
         }else{
           name_valid = false;
         }
       });
        },
        textCapitalization:  TextCapitalization.words,
        decoration: InputDecoration(labelText: 'Name*',
            errorText: name_valid ?null: "Please enter your full name"
        ),
      ),
    );




    final phone_ = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextFormField(
        enabled: false,
        keyboardType: TextInputType.phone,
        // validator: numberValidator,
        initialValue: phone,
        decoration: InputDecoration(labelText: 'Phone No*',),
      ),
    );


    final email = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
        onChanged: (text){
          setState(() {
            String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
            bool emailValid = RegExp(p).hasMatch(email_id_.text);
            emain_valid = emailValid;
          });
        },
        keyboardType: TextInputType.emailAddress,
        controller: email_id_,
        decoration: InputDecoration(labelText: 'Email Id*',
            errorText: emain_valid ?null: "Please enter valid email id"
        ),
      ),
    );


    final password = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
        controller: password_,
        onChanged: (text){
        setState(() {
          if(password_.text.length > 7){
            password_valid = true;
          }else{
            password_valid = false;
          }
        });
        },
        obscureText:_passwordVisible,
        decoration: InputDecoration(labelText: 'Password*',
            suffixIcon: GestureDetector(
              onTap: (){
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              child:_passwordVisible? Icon(Icons.visibility_off,): Icon(Icons.visibility, ),
            ),
            errorText: password_valid ?null: "Please enter atleast 8 character password"
        ),
      ),
    );


    final professon = Visibility(
      visible: reg_no,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextFormField(
          controller: professon_reg_no_,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: 'Professional Reg. No*',
              errorText: profession_valid ?null: "Please enter professional reg. no"),
        ),
      ),
    );


    final refered_by = Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextFormField(
          controller: referal_text,
          decoration: InputDecoration(labelText: 'Enter Referal Code (Optional)',
        ),
      ),
    );

    final dob_date = Container(
      width: 300,
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: InkWell(
        onTap: () async{
          _selectDate(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              enabled: false,
              maxLines: null,
              controller: dob_,
              decoration: InputDecoration(labelText: 'Date Of Birth*',

            ),
      ),

            Visibility(child: Container(

            margin: EdgeInsets.only(top:10),

                child: Text("Please enter your Date of Birth",
                  style: TextStyle(color: Colors.red),)), visible: !dob_valid,)
          ],
        ),
    ));


    final location = Container(
      width: 300,
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: InkWell(
        onTap: () async{

//          Prediction p = await PlacesAutocomplete.show(
//              context: context, apiKey: config.Config.google_location_api_key);
//          displayPrediction(p);

          Navigator.of(context).push(PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) => LocationFetch(latitude: latitude,longitude: longitude,))).then((val) {
                    if(val!=null){
                      List address_list = new List();
                      address_list = val.toString().split(":");
                      location_.text = address_list[0]+" "+address_list[1]+" "+address_list[2];
                      address.text = address_list[0]+" "+address_list[1]+" "+address_list[2];
                      setState(() {
                        latitude = address_list[3];
                        longitude = address_list[4];
                      });
                      print("getting loc"+latitude+", "+longitude);
                    }
          });
        },
        child: TextField(
          enabled: false,
          maxLines: null,
          controller: location_,
          decoration: InputDecoration(labelText: 'Location*',
              errorText: location_valid ?null: "Please enter your Location"),
        ),


      ),
    );


    final speciali = Visibility(
      visible: specilization,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: InkWell(
          onTap: () async{
            await showDialog(
                context: context,
                builder: (BuildContext context,) =>
                    Select_specialization(spec: specialization_list)
            ).then((val){

              if(val != '' && val != null){
                specialization_.text = val;
                print(val);

//                List bio = new List();
//                List dis = new List();
//                List ser = new List();
//                List sym = new List();
//
//                for(int i = 0; i<specialist_lists.length; i++){
//                  bio.add(specialistbio[specialization_list.indexOf(specialist_lists[i])]);
//                  dis.add(specialistbio[specialization_list.indexOf(specialist_lists[i])]);
//                  ser.add(specialistbio[specialization_list.indexOf(specialist_lists[i])]);
//                  sym.add(specialistbio[specialization_list.indexOf(specialist_lists[i])]);
//                }
//
//                Specialist_bio =  bio.join(',');
//                Common_disease = dis.join(',');
//                Specialist_service = ser.join(',');
//                symptoms = sym.join(',');

              }

            });
          },
          child: Column(
            children: <Widget>[
              TextField(
                enabled: false,
                maxLines: null,
                controller: specialization_,
                onChanged: (text){
                  setState(() {
                    get_specialists(text);
                  });
                },
                decoration: InputDecoration(labelText: 'Specialization*',
                    errorText: specification_valid ? null: "Please enter your specialization"),
              ),


              Visibility(child: Container(
                  margin: EdgeInsets.only(top:10),
                  child: Text("Please enter your Specialization",
                    style: TextStyle(color: Colors.red),)), visible: !specification_valid,)
            ],
          ),
        ),
      ),
    );


    final home_collection = Container(

      child: Row(
        children: <Widget>[


          Container(
              child: Text(
                "Make your enquiry private?",
                style: TextStyle(fontSize: 12),
              )),

          SizedBox(
            width: 5,
          ),

          GestureDetector(
            onTap: () {
              setState(() {
                isSwitched = !isSwitched;
              });
            },
            child: isSwitched
                ? Image.asset(
              'assets/images/enquiry/toggle_on.png',
              height: 45,
              width: 45,
            )
                : Image.asset(
              'assets/images/enquiry/toggle_off.png',
              height: 45,
              width: 45,
            ),
          ),

        ],
      ),


    );

    final signup =  Padding(
      padding: const EdgeInsets.only(left:36.0, right: 36.0, bottom: 30, top: 30),
      child: progress?SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ):  ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 10),
          child: FlatButton(
            onPressed:register,
            color: Color(0xff01d35a),
            child:  Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Signup", style: TextStyle(color: Colors.white)),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );


    final terms = Container(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("By registering, you agree to our ",style: TextStyle(color: Colors.grey),),
          InkWell(onTap:_launchURL,child: Container(child: Text("Terms of Service.", maxLines: null, style: TextStyle(  decoration: TextDecoration.underline,))))
        ],
      ),
    );


    final gender_ = Container(
      margin: EdgeInsets.only(top:20),
      child:   _user_type == 'Hospital' || _user_type == 'Lab' ? Container(): Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: new Radio(
              value: female,
              activeColor: Color(0xff01d35a),
              groupValue: data,
              onChanged: (val){
                setState(() {
                  male =0;
                  female = 1;
                  gender = "Male";
                });
              },
            ),
          ),

          new Text(
            'Male',
            style: new TextStyle(fontSize: 16.0),
          ),

          new Radio(
            value: male,
            activeColor: Color(0xff01d35a),
            groupValue: data,
            onChanged: (val){
              setState(() {
                male = 1;
                female = 0;
                gender = "Female";
              });
            },
          ),

          new Text(
            'Female',
            style: new TextStyle(
              fontSize: 16.0,
            ),
          ),


        ],
      ),

    );



    final mannual_add = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Text("Profile Image", style: TextStyle(fontSize: 12),),
          SizedBox(height: 30,),

          Row(
            children: <Widget>[
              InkWell(
                onTap: (){
                  _settingModalBottomSheet(context);

                },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[

                    Container(decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        color: Color(0x90ffBDBDBD) ), height: 80, width: 80,),
                    Align(
                      child: Icon(Icons.camera_enhance, color: Colors.white,),
                    ),
                    Align(
                        child: image!=  null? CircleAvatar(
                          radius: 40,
                          backgroundImage: FileImage(image),)
                        : Container()
                    ),
                  ],
                ),
              ),

              SizedBox(width: 10,),

              Container(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("File Name"),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: (){
                        _settingModalBottomSheet(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Upload"),
                        ),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                            border: Border.all(width: 0.3, color: Colors.grey)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20,),
          Text("Full Name"),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(borderRadius:
            BorderRadius.all(Radius.circular(10)), border:
            Border.all(width: 0.3, color: Colors.grey)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textCapitalization: TextCapitalization.words,
                controller: doc_name,
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
            ),
          ),


          SizedBox(height: 10,),
          Text("Education Qualification"),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(borderRadius:
            BorderRadius.all(Radius.circular(10)), border:
            Border.all(width: 0.3, color: Colors.grey)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textCapitalization: TextCapitalization.characters,
                controller: doc_education,
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
            ),
          ),


          SizedBox(height: 10,),
          Text("Designation"),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(borderRadius:
            BorderRadius.all(Radius.circular(10)), border:
            Border.all(width: 0.3, color: Colors.grey)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: doc_designation,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
            ),
          ),

          SizedBox(height: 10,),
          Text("Department"),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(borderRadius:
            BorderRadius.all(Radius.circular(10)), border:
            Border.all(width: 0.3, color: Colors.grey)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                textCapitalization: TextCapitalization.words,
                controller: doc_department,
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
            ),
          ),

          SizedBox(height: 10,),
          Text("Experience"),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(borderRadius:
            BorderRadius.all(Radius.circular(10)), border:
            Border.all(width: 0.3, color: Colors.grey)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: doc_experience,
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
            ),
          ),


          SizedBox(height: 10,),
          Text("Availability"),
          SizedBox(height: 10,),
          Row(
            children: <Widget>[
              Expanded(child: Container(
                decoration: BoxDecoration(borderRadius:
                BorderRadius.all(Radius.circular(10)), border:
                Border.all(width: 0.3, color: Colors.grey)),
                child: InkWell(
                  onTap: (){

                    _selectdata(doc_availability_from.text, "1");

                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      enabled: false,
                      controller: doc_availability_from,
                      decoration: InputDecoration.collapsed(hintText: "00:00 AM"),
                    ),
                  ),
                ),
              ),),

              SizedBox(width: 10,),
              Text(":", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              SizedBox(width: 10,),

              Expanded(child: Container(
                decoration: BoxDecoration(borderRadius:
                BorderRadius.all(Radius.circular(10)), border:
                Border.all(width: 0.3, color: Colors.grey)),
                child: InkWell(
                  onTap: (){

                    _selectdata(doc_availability_to.text, "2");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      enabled: false,
                      controller: doc_availability_to,
                      decoration: InputDecoration.collapsed(hintText: "00:00 AM"),
                    ),
                  ),
                ),
              ),),

            ],

          ),


          SizedBox(height: 20,),

          SizedBox(height: 20,),
          InkWell(
            onTap: (){
              if(doc_name.text != "" && doc_education.text != '' && doc_experience.text != '' && doc_availability_from.text != '' && doc_availability_to.text != ''){
                setState(() {
                    doctor_name.add(doc_name.text);
                    doctor_education.add(doc_education.text);

                    if(doc_designation.text == ''){
                      doctor_designation.add('');
                    }else{
                      doctor_designation.add(doc_designation.text);
                    }

                    doctor_department.add(doc_department.text);

                    doctor_experience.add(doc_experience.text);

                    doctor_availability.add(doc_availability_from.text+"-"+doc_availability_to.text);

                      doctor_image.add(base64Encode(image.readAsBytesSync()).toString());
                      doctor_img_file.add(image);

                    doc_name.text = "";
                    doc_education.text = "";
                    doc_designation.text = "";
                    doc_department.text = "";
                    doc_experience.text = "";
                    doc_availability_from.text = "00:00 AM";
                    doc_availability_to.text = "00:00 AM";
                });
              }

            },
            child: Container(width: 90, alignment: Alignment.center, height: 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.all
                (Radius.circular(15)),
                  color: Color(0xff01d35a)),
              child: Text("Add", style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );


    final hospital_reg =  Expanded(
        child: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            child: ListView(

              children: <Widget>[
                SizedBox(height: 20,),
                Center(
                  child: Text("Profile Information",
                    style: TextStyle(fontWeight: FontWeight.bold))
                ),
                SizedBox(height: 20,),
                Text("Name"),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(borderRadius:
                  BorderRadius.all(Radius.circular(10)), border:
                  Border.all(width: 0.3, color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(

                      textCapitalization: TextCapitalization.words,
                      controller: hospital_name,
                      decoration: InputDecoration.collapsed(hintText: ""),
                    ),
                  ),
                ),


                SizedBox(height: 10,),
                Text("Address"),
                SizedBox(height: 10,),

                InkWell(
                  onTap: (){

                    Navigator.of(context).push(PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) =>
                            LocationFetch(latitude: latitude,longitude: longitude,))).then((val) {

                      List address_list = new List();
                      address_list = val.toString().split(":");
                      address.text = address_list[0]+" "+address_list[1]+" "+address_list[2];
                      location_.text = address_list[0]+" "+address_list[1]+" "+address_list[2];

                      setState(() {
                        latitude = address_list[3];
                        longitude = address_list[4];
                      });
                      print("getting loc"+latitude+", "+longitude);

                    });

                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius:
                    BorderRadius.all(Radius.circular(10)), border:
                    Border.all(width: 0.3, color: Colors.grey)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        maxLines: null,
                        enabled: false,
                        controller: address,
                        decoration: InputDecoration.collapsed(hintText: ""),
                      ),
                    ),
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start
                  ,children: <Widget>[
                  SizedBox(height: 10,),
                  Text("Phone"),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(borderRadius:
                    BorderRadius.all(Radius.circular(10)), border:
                    Border.all(width: 0.3, color: Colors.grey)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        enabled: false,
                        keyboardType: TextInputType.phone,
                        // validator: numberValidator,
                        initialValue: phone,
                        decoration: InputDecoration.collapsed(hintText: ""),
                      ),
                    ),
                  ),
                ],),

//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start
//                        ,children: <Widget>[
//                        SizedBox(height: 10,),
//                        Text("State"),
//                        SizedBox(height: 10,),
//                        Container(
//                          decoration: BoxDecoration(borderRadius:
//                          BorderRadius.all(Radius.circular(10)), border:
//                          Border.all(width: 0.3, color: Colors.grey)),
//                          child: Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: TextField(
//                              controller: state,
//                              decoration: InputDecoration.collapsed(hintText: ""),
//                            ),
//                          ),
//                        ),
//                      ],),
//                    ),
//
//                    SizedBox(width: 10,),
//
//                    Expanded(
//                      child: Column(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        children: <Widget>[
//                          SizedBox(height: 10,),
//                          Text("City"),
//                          SizedBox(height: 10,),
//                          Container(
//                            decoration: BoxDecoration(borderRadius:
//                            BorderRadius.all(Radius.circular(10)), border:
//                            Border.all(width: 0.3, color: Colors.grey)),
//                            child: Padding(
//                              padding: const EdgeInsets.all(8.0),
//                              child: TextField(
//                                controller: City,
//                                decoration: InputDecoration.collapsed(hintText: ""),
//                              ),
//                            ),
//                          ),
//                        ],),
//                    )
//
//                  ],
//                ),

                SizedBox(height: 10,),
                Text("About"),
                SizedBox(height: 10,),
                Container(
                  height: 100,
                  decoration: BoxDecoration(borderRadius:
                  BorderRadius.all(Radius.circular(10)), border:
                  Border.all(width: 0.3, color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: About,
                      maxLines: null,
                      minLines: 3,
                      maxLength: 250,
                      decoration: InputDecoration.collapsed(hintText: ""),
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                Text("Registration No"),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(borderRadius:
                  BorderRadius.all(Radius.circular(10)), border:
                  Border.all(width: 0.3, color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      textCapitalization: TextCapitalization.characters,
                      controller: registration_no,
                      decoration: InputDecoration.collapsed(hintText: ""),
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                Center(
                  child: Text("Add Specialization",
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                SizedBox(height: 10,),
                Center(
                  child: Text("Add Specialization and service",
                    style: TextStyle(fontSize: 12,
                        color: Colors.grey),),
                ),

                SizedBox(height: 20,),

                InkWell(
                  onTap: (){

                    showDialog(
                        context: context,
                        builder: (BuildContext context,) =>
                            Specialization()
                    ).then((selected_val){
                      setState(() {
                        specialization_selected.addAll(selected_val);
                        print(specialization_selected);
                      });

                    });
                  },
                  child: Container(alignment: Alignment.center, decoration:
                  BoxDecoration(borderRadius: BorderRadius.all
                    (Radius.circular(12)), color: Color(0xff01d35a)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Add",style: TextStyle(color:
                      Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                SizedBox(height: 20,),

                ListView.builder(itemBuilder: (context, index){
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(child: Text(specialization_selected[index])),
                              InkWell(child: Container(child:
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Icon(Icons.clear, color: Colors.black,size: 18,),
                              ),), onTap: (){

                                setState(() {
                                  specialization_selected.removeAt(index);
                                });
                              },),
                              SizedBox(width: 10,)
                            ],
                          ),
                          SizedBox(height: 10,),
                          Container(height: 0.3, color: Colors.grey,),
                        ],
                      ) ,
                    ),
                  );
                }, itemCount: specialization_selected.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),),


                SizedBox(height: 10,),

                Center(
                  child: Text("Add Doctor",
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ),

                SizedBox(height: 10,),
//                Center(
//                  child: Text("Add doctor by search or email",
//                    style: TextStyle(fontSize: 12,
//                        color: Colors.grey),),
//                ),

//                SizedBox(height: 10,),
//                Text("Search"),
//                SizedBox(height: 10,),
//                Container(
//                  decoration: BoxDecoration(borderRadius:
//                  BorderRadius.all(Radius.circular(10)), border:
//                  Border.all(width: 0.3, color: Colors.grey)),
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: Padding(
//                          padding: const EdgeInsets.all(10.0),
//                          child: TextField(
//                            decoration: InputDecoration.collapsed(
//                                hintText: "Enter doctor name", hintStyle:
//                            TextStyle(fontSize: 12, color: Colors.grey )),
//                          ),
//                        ),
//                      ),
//
//
//                      Padding(
//                        padding: const EdgeInsets.only(right:8.0),
//                        child: Icon(Icons.search, color: Colors.grey,size: 18,),
//                      )
//                    ],
//                  ),
//                ),
//

                SizedBox(height: 10,),

                InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  onTap: (){
                    setState(() {
                      show_mannual = !show_mannual;
                    });

                  },
                  child: Container(
                    decoration: BoxDecoration(borderRadius:
                    BorderRadius.all(Radius.circular(10)), border:
                    Border.all(width: 0.3, color:show_mannual? Color(0xff01d35a): Colors.grey ), color:show_mannual? Color(0xff01d35a): Colors.transparent),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text("Add Manually", style: TextStyle(fontSize: 12, color: show_mannual? Colors.white: Colors.black ),),
                            show_mannual? Icon(Icons.keyboard_arrow_up,  color: show_mannual? Colors.white: Colors.black ):
                            Icon(Icons.keyboard_arrow_down,
                              color: Colors.black,)
                          ],

                        ),
                      ),
                    ),
                  ),
                ),


                SizedBox(height: 20,),
                show_mannual? mannual_add: Container(),

                SizedBox(height: 10,),

                doctor_education.length == 0? Container():  Container(
                  height: 100,
                  child: ListView.builder(itemBuilder: (context, index){
                    return Container(height: 100,
                      width: 300,
                      margin: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(radius: 20,  backgroundImage: FileImage(doctor_img_file[index]),),

                          SizedBox(width: 10,),
                          Expanded(child: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Text(doctor_name[index], style: TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.bold),),
                                Text(doctor_education[index],
                                  style: TextStyle(color: Colors.grey, fontSize: 12),),
                                Text(doctor_designation[index],
                                  style: TextStyle(color: Colors.grey, fontSize: 12),),
                                Text(doctor_department[index],
                                  style: TextStyle(color: Colors.grey, fontSize: 12),),
                                Text(doctor_experience[index]+" years of experience",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),),
                              ],
                            ),
                          )),

                          InkWell(child: Padding(
                            padding: const EdgeInsets.only(left:8.0, bottom: 8, right: 8),
                            child: Icon(Icons.close, size: 18,),
                          ),
                          onTap: (){
                            setState(() {
                              doctor_name.removeAt(index);
                              doctor_education.removeAt(index);
                              doctor_designation.removeAt(index);
                              doctor_department.removeAt(index);
                              doctor_experience.removeAt(index);
                              doctor_image.removeAt(index);
                              doctor_img_file.removeAt(index);

                            });

                          },),
                          SizedBox(width: 10,),

                          Container(width:0.3, height: 100, color: Colors.grey,
                            margin: EdgeInsets.only(top: 10, bottom: 10),)

                        ],
                      ),
                    );
                  }, scrollDirection: Axis.horizontal, itemCount: doctor_name.length,),
                ),

                SizedBox(height: 30,),
                Center(
                  child: Text("Manage Account",
                    style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                SizedBox(height: 10,),
                Center(
                  child: Text("Add users",
                    style: TextStyle(fontSize: 12,
                        color: Colors.grey),),
                ),

                Text("Admin",
                  style: TextStyle(fontSize: 12,
                      color: Colors.black),),

//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: Text("Ankit Garg",
//                        style: TextStyle(fontSize: 12,
//                            color: Colors.black),),
//                    ),
//
//                    Text("Edit", style: TextStyle(fontSize: 12, color: Color(0xff01d35a)),)
//
//                  ],
//                ),

                SizedBox(height: 10,),
                Text("Add User",
                  style: TextStyle(fontSize: 12,
                      color: Colors.black),),
                SizedBox(height: 10,),
                Container(
                    decoration: BoxDecoration(borderRadius:
                    BorderRadius.all(Radius.circular(10)), border:
                    Border.all(width: 0.3, color: Colors.grey)),
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: TextField(

                                    decoration: InputDecoration.collapsed(
                                        hintText: "User email", hintStyle:
                                    TextStyle(fontSize: 12, color: Colors.grey )),
                                    controller: email_id_get,
                                  )
                              )
                            ]
                        )
                    )
                ),

                SizedBox(height: 10,),


                Container(
                    decoration: BoxDecoration(borderRadius:
                    BorderRadius.all(Radius.circular(10)), border:
                    Border.all(width: 0.3, color: Colors.grey)),
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: TextField(

                                    decoration: InputDecoration.collapsed(
                                        hintText: "User Password", hintStyle:
                                    TextStyle(fontSize: 12, color: Colors.grey )),
                                    controller: password_,
                                  )
                              )
                            ],
                        )
                    )
                ),

                SizedBox(height: 10,),
                Text("Please enter at least 8 character Password"),
                SizedBox(height: 10,width: 30,),

                SizedBox(height: 20,),


                progress? SpinKitThreeBounce(
                  color: Color(0xff01d35a),
                  size: 30.0,
                  // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                ):   Container(margin: EdgeInsets.only(left: 90, right: 90),
                  height: 40,
                  decoration:
                  BoxDecoration(borderRadius: BorderRadius.all
                    (Radius.circular(15)), color: Color(0xff01d35a),),
                  child:  FlatButton(
                    onPressed:  hospital_regis,
                      child: Text("Submit", style: TextStyle(color: Colors.white),)),
                ),

                SizedBox(height: 30,),

              ],
            ),
          ),
        )

    );




    final form_list = Expanded(child: ListView(
      children: <Widget>[
        full_name,
        gender_,
        dob_date,
        phone_,
        email,
        password,
        location,
        professon,
        speciali,
        experience,
        //home_collection,
        refered_by,
        signup,
        terms,
        SizedBox(height: 20,),
      ],
    ));


    final form = Container(
      child: Column(
        children: <Widget>[
          drop_down,
          hospital? HospitalRegistration(phone: phone,):form_list,
        ],
      ),
    );

    return Scaffold(
        appBar: app_bar,
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: GestureDetector(child: form, onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        })
    );
  }
}


class Select_specialization extends StatefulWidget {

  final List spec;

  Select_specialization({Key key, this.spec}) : super(key: key);

  @override
  _Select_specializationState createState() => _Select_specializationState(spec);
}

class _Select_specializationState extends State<Select_specialization> {

  List spec;
  _Select_specializationState( this.spec);

  String teamName = '';
  bool icons = true;

  List specialization_filter_lists = new List();
  Set selected = new Set();
  List<bool> select = new List();
  bool show_err_msg = false;

  TextEditingController search_controler = new TextEditingController();


  @override
  void initState() {
    super.initState();
    specialization_filter_lists.addAll(spec);
    for(int i = 0; i<spec.length; i++){
      select.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final search = Card(
      elevation: 0,
      child: Stack(
        children: <Widget>[
          Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.only(left:15.0, top:15, bottom: 15, right: 30),
              child: TextField(
                controller: search_controler,
                decoration: InputDecoration.collapsed(hintText: 'Search'),
                onChanged: (text) {

                  setState(() {
                    specialization_filter_lists.clear();
                    for(int i = 0; i< spec.length; i++){
                      if( spec[i].toString().toLowerCase().contains(text)){
                        specialization_filter_lists.add(spec[i]);
                      }
                    }

                    if(text.length > 0){
                      icons = false;
                    }else{
                      icons = true;
                    }print(text);
                  });
                },
              ),
            ),
          ),


          Align(
            child: Container(
              child: InkWell(
                onTap: (){
                  setState(() {
                    search_controler.text = "";
                    icons = true;
                    specialization_filter_lists.addAll(spec);
                  });
                },
                child: icons?  Icon(
                  Icons.search,
                  color: Colors.grey,
                ): Icon(Icons.close),
              ),
              padding: EdgeInsets.only(right: 20, top: 18),
            ),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );


    return CupertinoAlertDialog(
      title: new Text("Specialists"),
      content: Container(
        height: 400,

        child: Column(
          children: <Widget>[

            search,
            show_err_msg? Text("could not select more than 5 specialists", style: TextStyle(color: Colors.red, fontSize: 12),): Text(""),

            specialization_filter_lists.length == 0? Expanded(child:

            Center(child: Text("No data", style: TextStyle(color: Colors.grey)))):  Expanded(

              child: ListView.builder(itemBuilder: (BuildContext context, index){
                return FlatButton(
                  onPressed: selected.length == 5? null: (){
                    print(select[index]);

                    setState(() {

                      select[index] =  !select[index];

                      if( select[index]){
                        selected.add(specialization_filter_lists[index]);
                      }else{
                        selected.remove(specialization_filter_lists[index]);
                      }

                      teamName =   selected.join(',');
                      print(specialization_filter_lists[index]);

                      if(selected.length > 4){
                        show_err_msg = true;
                      }else{
                        show_err_msg = false;
                      }
                    });
                  },
                  child: Column(

                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Container(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(specialization_filter_lists[index],
                          style: TextStyle(color: select[index]? Color(0xff01d35a): Colors.black),),
                      )),

                      Divider(height: 0.5, color: Colors.grey,)

                    ],
                  ),
                );
              }, itemCount: specialization_filter_lists.length,),
            ),
          ],
        ),
      ),

      actions: [
        CupertinoDialogAction(
          textStyle: TextStyle(color: Color(0xff01d35a)),
          isDefaultAction: true, child: new Text("Done"),onPressed: (){
          Navigator.of(context).pop(teamName);
        },)
      ],
    );
  }
}


class Specialization extends StatefulWidget {
  @override
  _SpecializationState createState() => _SpecializationState();
}

class _SpecializationState extends State<Specialization> {

  List select_procedure = new List();
  List<bool> select = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for(int i =0; i< config.Config.specialist_lists.length; i++){
      select.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Container(
        height: 400,
        child: Column(
          children: <Widget>[


            Container(
              alignment: Alignment.topRight,
              child: FlatButton(

                onPressed: (){
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.close, color: Colors.black,
                  ),
                ),
              ),
            ),

            Text("Select", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
            config.Config.specialist_lists.length == 0? Expanded(child:

            Center(child: Text("No data",
              style: TextStyle(color: Colors.grey),),),):  Expanded(

              child: ListView.builder(itemBuilder: (BuildContext context, index){
                return FlatButton(
                  onPressed: (){
                    setState(() {
                      select[index] = !select[index];
                      if(select[index]){
                        select_procedure.add(config.Config.specialist_lists[index]);
                      }else{
                        select_procedure.removeAt(index);
                      }
                    });
                  },



                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Container(child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Text(config.Config.specialist_lists[index],
                                  style: TextStyle(color: Colors.black, fontSize: 14),),
                                alignment: Alignment.centerLeft,
                              ),
                            ),

                            Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: Container(
                                width: 40,
                                child: FlatButton(
                                  child: Checkbox(value: select[index], onChanged: (val){
                                  }),
                                  onPressed: (){
                                    setState(() {
                                      select[index] = !select[index];
                                      if(select[index]){
                                        select_procedure.add(config.Config.specialist_lists[index]);
                                      }else{
                                        select_procedure.removeAt(index);
                                      }
                                    },);
                                  },
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),),

                      Divider(height: 0.5, color: Colors.grey,),
                    ],
                  ),
                );
              }, itemCount: config.Config.specialist_lists.length,),
            ),


            GestureDetector(
              onTap: (){
                Navigator.of(context).pop(select_procedure);
              },
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
                child: Text("Apply", style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



