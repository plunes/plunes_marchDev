import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_webservice/places.dart';
//import 'package:location/location.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/edit_profile.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:plunes/start_streen/LocationFetch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';


GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: config.Config.google_location_api_key);

class EditProfile extends StatefulWidget {
  static const tag = '/editprofile';

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

//// update fields

  TextEditingController full_name_ = TextEditingController();
  bool name_valid = true;


  TextEditingController phone_no_ = TextEditingController();
  TextEditingController email_id_ = TextEditingController();
  TextEditingController location_ = TextEditingController();


  TextEditingController qualification_ = TextEditingController();
  bool qualification_valid = true;

  TextEditingController professon_reg_no_ = TextEditingController();
  TextEditingController specialization_ = TextEditingController();
  TextEditingController experience_ = TextEditingController();


  TextEditingController practising = TextEditingController();
  bool practising_valid = true;


  TextEditingController college = TextEditingController();
  bool college_valid = true;


  TextEditingController introduction = TextEditingController();

  //// after submit
  bool progress= true;
  String latitude= "0.0";
  String longitude = "0.0";
  bool generaluser = true;

  String user_token = "";
  String user_id = "";


  String user_name = "";
  String _user_type = "";
  String user_phone = "";
  String specialities = "";

  @override
  void initState() {

    getSharedPreferences();
    super.initState();
  }


  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {
      user_token = token;
      user_id = uid;
    });

    get_profile_info(token);
  }

  get_profile_info(String token) async{
    MyProfile myProfileData = await my_profile_data(token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });

    full_name_.text = myProfileData.name;
    phone_no_.text = myProfileData.mobileNumber;
    _user_type = myProfileData.userType;
    email_id_.text = myProfileData.email;
    location_.text = myProfileData.address;
    experience_.text = myProfileData.experience;
    professon_reg_no_.text = myProfileData.registrationNumber;
    practising.text = myProfileData.practising;
    qualification_.text = myProfileData.qualification;
    college.text = myProfileData.college;
    introduction.text = myProfileData.biography;

    latitude = myProfileData.latitude;
    longitude = myProfileData.longitude;

    List specilaity_id = new List();
    for(int i =0; i< myProfileData.specialities.length; i++){
      specilaity_id.add(myProfileData.specialities[i].specialityId);
    }

    List speciality = new List();
    for(int i =0; i< specilaity_id.length; i++){
      int pos = config.Config.specialist_id.indexOf(specilaity_id[i]);
      speciality.add(config.Config.specialist_lists[pos]);
    }

    specialities = speciality.join(", ");
    specialization_.text = specialities;

    setState(() {
      progress = false;

      if(_user_type == 'User' || _user_type == 'Hospital'){
        generaluser = true;
      }else{
        generaluser = false;
      }


    });

  }

  void register(){

    setState(() {

      if(full_name_.text != '' ) {
        name_valid = true;

//// profession ----------------
              if (!generaluser) {
                if(qualification_.text != ''){

                  qualification_valid = true;

                        if(practising.text != ''){

                          practising_valid = true;

                          if(college.text != ''){


                            college_valid = true;
                            progress = true;

                            handle();

                          }else{
                            college_valid = false;
                          }
                        }else{
                          practising_valid = false;
                        }
                }else{
                  qualification_valid = false;
                }
              }else{
                progress = true;
                handle();
              }
      }else{
        name_valid = false;
      }
    });

  }

  void handle() async{

   var body;
    EditProfilePost p;

   if(_user_type == "User" || _user_type == "Hospital"){
      body = {
        "name":full_name_.text,
        "address" : location_.text,
        "latitude":latitude,
        "longitude":longitude
     };
   }else{
      body = {
        "name":full_name_.text,
        "email":email_id_.text.trim(),
        "address" : location_.text,
        "registrationNumber":professon_reg_no_.text,
        "qualification":qualification_.text,
        "biography":introduction.text,
        "practising": practising.text,
        "college": college.text,
        "latitude":latitude,
        "longitude":longitude
     };
   }


    if (_user_type == "Doctor"){
      if(name_valid && qualification_valid &&
       practising_valid && college_valid) {


       p = await edit_profile(body, user_token).catchError((error){
          config.Config.showLongToast("Something went wrong!");
          print(error.toString());
          setState(() {
            progress = false;
          });
        });

        setState(() {
          progress = false;
          if(p.success){
            _saveValues();

            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(screen: "profile"),
                ));
          }else{
            config.Config.showInSnackBar(_scaffoldKey, p.message, Colors.red);
          }
        });

      }else{
        setState(() {
          progress = false;
        });
      }

    }else{

      if(name_valid){
        p = await edit_profile(body, user_token).catchError((error){
          config.Config.showLongToast("Something went wrong!");
          print(error.toString());
          setState(() {
            progress = false;
          });
        });
        setState(() {
          progress = false;
          if(p.success){
            _saveValues();
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(screen: "profile"),
                ));

          }else{
            config.Config.showInSnackBar(_scaffoldKey, p.message, Colors.red);
          }

        });
      }else{
        setState(() {
          progress = false;
        });
      }
    }
  }

  _saveValues(
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", user_token);
    prefs.setString("uid", user_id);

    prefs.setString("name", full_name_.text);
    prefs.setString("email", email_id_.text);
    prefs.setString("phoneno", phone_no_.text);

    prefs.setString("user_type", _user_type);
    prefs.setString("user_location", location_.text);
    prefs.setString("specialist", specialities);
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
        "Edit Profile",
        style: TextStyle(color: Colors.black),
      ),
    );

    final experience = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: Visibility(
        visible: !generaluser,
        child: TextFormField(
          enabled: false,
          controller: experience_,
          decoration: InputDecoration(labelText: 'Experience*',
          ),
        ),
      ),
    );



    final full_name = Container(
      margin: EdgeInsets.only(left: 38, right: 38),
      child: TextFormField(
        controller: full_name_,
        decoration: InputDecoration(labelText: 'Full Name*',
            errorText: name_valid ?null: "Please enter your full name"
        ),
      ),
    );


    final phone_ = Container(
      margin: EdgeInsets.only(left: 38, right: 38, top: 10),
      child: TextFormField(
        enabled: false,
        keyboardType: TextInputType.phone,
        controller: phone_no_,
        decoration: InputDecoration(labelText: 'Phone No*',),
      ),
    );


    final email = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextFormField(
        enabled:  false,
        keyboardType: TextInputType.emailAddress,
        controller: email_id_,
        decoration: InputDecoration(labelText: 'Email Id*'
        ),
      ),
    );


    final professon = Visibility(
      visible: !generaluser,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextFormField(
//          enabled: false,
          controller: professon_reg_no_,
          decoration: InputDecoration(labelText: 'Profession Reg. No*'),
        ),
      ),
    );

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
              pageBuilder: (BuildContext context, _, __) =>
                  LocationFetch(latitude: latitude,longitude: longitude,))).then((val) {
            List address_list = new List();
            address_list = val.toString().split(":");
            location_.text = address_list[0]+" "+address_list[1]+" "+address_list[2];

            setState(() {
              latitude = address_list[3];
              longitude = address_list[4];
            });
            print("getting loc"+latitude+", "+longitude);

          });
        },
        child: TextFormField(
          enabled: false,
          maxLines: null,
          controller: location_,
          decoration: InputDecoration(labelText: 'Location*'),
        ),
      ),
    );

    final quali = Visibility(
      visible: !generaluser,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextField(
         // enabled: false,
          controller: qualification_,
            textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(labelText: 'Qualification*',
              errorText: qualification_valid ?null: "Please enter qualification"),
        ),
      ),
    );



    final speciali = Visibility(
      visible: !generaluser,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextFormField(
          enabled: false,
          controller: specialization_,
          maxLines: null,
          decoration: InputDecoration(labelText: 'Specialization*'),
        ),
      ),
    );


    final practisi = Visibility(
      visible: !generaluser,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextFormField(
          textCapitalization: TextCapitalization.words,
          controller: practising,
          decoration: InputDecoration(labelText: 'Practising*',
              errorText: practising_valid ? null: "Please enter your practising"),
        ),
      ),
    );


    final colle = Visibility(
      visible: !generaluser,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextFormField(
          controller: college,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: 'College/University*',
              errorText: college_valid ? null: "Please enter your College/University name"),
        ),
      ),
    );

    final intro = Visibility(
      visible: !generaluser,
      child: Container(
        margin: EdgeInsets.only(
          left: 38,
          right: 38,
        ),
        child: TextField(
          maxLength: 1000,
          maxLines: null,
          controller: introduction,
          decoration: InputDecoration(labelText: 'Introduction'),
        ),
      ),
    );

    final signup = Padding(
      padding: const EdgeInsets.only(left:20.0, right: 20.0, bottom: 30),
      child: progress?SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ):ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 10),
          child: FlatButton(
            onPressed:register,
            color: Color(0xff01d35a),
            child:  Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Done", style: TextStyle(color: Colors.white)),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );


    final form = Container(
      child: ListView(
        children: <Widget>[
          full_name,
          phone_,
          email,
          location,
          quali,
          professon,
          speciali,
          experience,
          practisi,
          colle,
          intro,
          signup,
        ],
      ),
    );


    return Scaffold(
        appBar: app_bar,
        backgroundColor: Colors.white,
        body: form
    );
  }
}
