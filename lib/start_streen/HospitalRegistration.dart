import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plunes/model/profile/image_upload.dart';
import 'package:plunes/model/profile/login_reg_user.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:plunes/start_streen/LocationFetch.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/start_streen/Registration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;

class HospitalRegistration extends StatefulWidget {
  final String phone;

  HospitalRegistration({Key key, this.phone}) : super(key: key);

  @override
  _HospitalRegistrationState createState() => _HospitalRegistrationState(phone);
}

class _HospitalRegistrationState extends State<HospitalRegistration> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final String phone;
  _HospitalRegistrationState(this.phone);

  TextEditingController name_ = new TextEditingController();
  TextEditingController address_ = new TextEditingController();
  TextEditingController about_ = new TextEditingController();
  TextEditingController reg_no_ = new TextEditingController();
  TextEditingController email_ = new TextEditingController();
  TextEditingController password_ = new TextEditingController();


  TextEditingController doc_name_ = new TextEditingController();
  TextEditingController doc_edu_ = new TextEditingController();
  TextEditingController doc_designation_ = new TextEditingController();
  TextEditingController doc_department_ = new TextEditingController();
  TextEditingController doc_experience_ = new TextEditingController();
  TextEditingController doc_specialization_ = new TextEditingController();


  bool valid_name = true;
  bool valid_address = true;
  bool valid_about = true;
  bool valid_reg_no = true;
  bool valid_email = true;
  bool valid_password = true;


  List doc_names = new List();
  List doc_edus = new List();
  List doc_designations = new List();
  List doc_departments = new List();
  List doc_experiences = new List();
  List doc_specialisty = new List();



  List specialization_list = new List();
  List doc_list = new List();


  String latitude = "";
  String longitude = "";
  bool progress = false;
  var location = new loc.Location();



  void get_specialists(String specialist) async{
    for(int i =0; i< config.Config.specialist_lists.length; i++){
      specialization_list.add(config.Config.specialist_lists[i]);
    }
  }


  register(){
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    bool emailValid = RegExp(p).hasMatch(email_.text); //r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
    int pass_length = password_.text.length;


    setState(() {
      if(name_.text != ''){
        valid_name = true;

        if(address_.text != ''){
          valid_address = true;

            if(about_.text != ''){

              valid_about = true;

              if(reg_no_.text != ''){

                valid_reg_no = true;

                if(email_.text != '' && emailValid){
                  valid_email = true;

                  if(password_.text != '' && pass_length > 7 ){
                    valid_password = true;

                    handle();


                  }else{
                    valid_password = false;
                  }


                }else{
                  valid_email = false;


                }

              }else{
                valid_reg_no = false;
              }

            }else{
              valid_about = false;
            }


        }else{

          valid_address = false;
        }



      }else{
        valid_name = false;
      }
    });



  }



  void handle()async{
    doc_list = [];
    List specialist_data = new List();
    var geoLocation = {"latitude": latitude, "longitude": longitude};
    List device_id = new List();
    device_id.add(config.Config.device_id);
    for(int i =0;i< doc_names.length; i++){
     for(int j =0; j< doc_specialisty[i].toString().split(",").length; j++){
        specialist_data.add({"specialityId": config.Config.specialist_id[config.Config.specialist_lists.indexOf(doc_specialisty[i].toString().split(",")[j])]});
      }
      doc_list.add({
        "name":doc_names[i],
        "education":doc_edus[i],
        "designation":doc_designations[i],
        "department":doc_departments[i],
        "experience":doc_experiences[i],
        "specialities":specialist_data
      });
    }
if(doc_list.length>0){
  var body = {
    'userType' : 'Hospital',
    "name": name_.text,
    "address": address_.text,
    "mobileNumber": phone,
    "biography": about_.text,
    "registrationNumber": reg_no_.text,
    "doctors":doc_list,
    "geoLocation": geoLocation,
    "verifiedUser": 'true',
    "email": email_.text.trim(),
    "password": password_.text,
    "deviceIds":device_id
  };
  RegistrationPost registrationPost = await registration_api(body).catchError((error){
    config.Config.showLongToast("Something went wrong!");
    setState(() {
      progress = false;
    });
  });
  setState(() {
    progress = false;
    if(registrationPost.success){
      doc_names.clear();
      doc_edus.clear();
      doc_edus.clear();
      doc_designations.clear();
      doc_departments.clear();
      doc_experiences.clear();
      doc_specialisty.clear();
      specialist_data.clear();

      _saveValues(
          registrationPost.token,
          registrationPost.user.uid,
          registrationPost.user.name,
          registrationPost.user.email,
          registrationPost.user.mobileNumber,
          registrationPost.user.userType,
          registrationPost.user.address
      );

    }else{
      config.Config.showInSnackBar(_scaffoldKey, registrationPost.message, Colors.red);
    }
  });
}else {
  config.Config.showInSnackBar(_scaffoldKey, 'Please add at least one doctor.', Colors.red);
}

  }

  _saveValues(String token, String uid,
      String name, String email, String phoneno,
      String user_type, String user_location,
      )  async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
    prefs.setString("uid", uid);

    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("phoneno", phoneno);

    prefs.setString("user_type", user_type);
    prefs.setString("user_location", user_location);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(screen: 'bids'),
        ));
  }

  add_doctor(){
    if(doc_name_.text != "" &&
        doc_edu_.text != "" &&
        doc_designation_.text != "" &&
        doc_department_.text != "" &&
        doc_experience_.text != "" &&
        doc_specialization_.text != ""
    ){

      setState(() {
        doc_names.add(doc_name_.text);
        doc_edus.add(doc_edu_.text);
        doc_designations.add(doc_designation_.text);
        doc_departments.add(doc_department_.text);
        doc_experiences.add(doc_experience_.text);
        doc_specialisty.add(doc_specialization_.text);
      });

      doc_name_.text = "";
      doc_edu_.text = "";
      doc_designation_.text = "";
      doc_department_.text = "";
      doc_experience_.text = "";
      doc_specialization_.text = "";

    }
  }

  _launchURL() async {
    String url = config.Config.terms;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocation();
    get_specialists("");
  }


  void getLocation() async {
    setState(() {
      progress = true;
    });

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
      progress = false;
      address_.text = full_address;
    });
  }


  @override
  Widget build(BuildContext context) {
    final name = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          textCapitalization: TextCapitalization.words,
          controller: name_,
          decoration: InputDecoration(border: InputBorder.none, hintText: '', contentPadding: EdgeInsets.zero),
        ),
      ),
    );

    final address = InkWell(
      onTap: () {
        Navigator.of(context)
            .push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context, _, __) => LocationFetch(latitude: latitude, longitude: longitude,)))
            .then((val) {
          List address_list = new List();
          address_list = val.toString().split(":");
          address_.text =
              address_list[0] + " " + address_list[1] + " " + address_list[2];

          setState(() {
            latitude = address_list[3];
            longitude = address_list[4];
          });
          print("getting loc" + latitude + ", " + longitude);
        });
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(width: 0.3, color: Colors.grey)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            maxLines: null,
            enabled: false,
            controller: address_,
            decoration: InputDecoration.collapsed(hintText: ""),
          ),
        ),
      ),
    );

    final phone_number = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 0.3, color: Colors.grey)),
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
    );

    final about = Container(
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: about_,
          maxLines: null,
          minLines: 3,
          maxLength: 250,
          decoration: InputDecoration.collapsed(hintText: ""),
        ),
      ),
    );

    final reg_no = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          textCapitalization: TextCapitalization.characters,
          controller: reg_no_,
          decoration: InputDecoration.collapsed(hintText: ""),
        ),
      ),
    );


    final email =  Container(
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
                            hintText: "Email", hintStyle:
                        TextStyle(fontSize: 12, color: Colors.grey )),
                        controller: email_,
                      )
                  )
                ]
            )
        )
    );



  final doctor_speciality =   Container(
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
            doc_specialization_.text = val;
          }

        });
      },
      child: Column(
        children: <Widget>[
          TextField(
            enabled: false,
            maxLines: null,
            controller: doc_specialization_,
            onChanged: (text){
              setState(() {
                get_specialists(text);
              });
            },
            decoration: InputDecoration(labelText: 'Specialization*',),
          ),

          Container(
              margin: EdgeInsets.only(top:10),
              child: Text("Please enter your Specialization",
                style: TextStyle(color: Colors.red),))
        ],
      ),
    ),
  );


    final password = Container(
        decoration: BoxDecoration(borderRadius:
        BorderRadius.all(Radius.circular(10)), border:
        Border.all(width: 0.3, color: Colors.grey)),
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(

                      obscureText: true,
                      decoration: InputDecoration.collapsed(
                          hintText: "Password", hintStyle:
                      TextStyle(fontSize: 12, color: Colors.grey )),
                      controller: password_,
                    )
                )
              ],
            )
        )
    );


    final doc_name = Container(
      decoration: BoxDecoration(borderRadius:
      BorderRadius.all(Radius.circular(10)), border:
      Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          textCapitalization: TextCapitalization.words,
          controller: doc_name_,
          decoration: InputDecoration.collapsed(hintText: ""),
        ),
      ),
    );



    final doc_edu = Container(
      decoration: BoxDecoration(borderRadius:
      BorderRadius.all(Radius.circular(10)), border:
      Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          textCapitalization: TextCapitalization.characters,
          controller: doc_edu_,
          decoration: InputDecoration.collapsed(hintText: ""),
        ),
      ),
    );



    final doc_degignation =      Container(
      decoration: BoxDecoration(borderRadius:
      BorderRadius.all(Radius.circular(10)), border:
      Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: doc_designation_,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration.collapsed(hintText: ""),
        ),
      ),
    );


    final doc_department = Container(
      decoration: BoxDecoration(borderRadius:
      BorderRadius.all(Radius.circular(10)), border:
      Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          textCapitalization: TextCapitalization.words,
          controller: doc_department_,
          decoration: InputDecoration.collapsed(hintText: ""),
        ),
      ),
    );


    final doc_experience =     Container(
      decoration: BoxDecoration(borderRadius:
      BorderRadius.all(Radius.circular(10)), border:
      Border.all(width: 0.3, color: Colors.grey)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          controller: doc_experience_,
          decoration: InputDecoration.collapsed(hintText: ""),
        ),
      ),
    );

    final signup = Padding(
      padding: const EdgeInsets.only(left:36.0, right: 36.0, bottom: 30, top: 30),
      child: progress?SpinKitThreeBounce(
        color:  Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ):

      ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 10),
          child: FlatButton(
            onPressed:register,
            color:doc_names.length == 0? Colors.grey: Color(0xff01d35a),
            child:  Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Signup", style: TextStyle(color: Colors.white)),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );

    final add =  Padding(
      padding: const EdgeInsets.only(left:36.0, right: 36.0, bottom: 30, top: 30),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 10),
          child: FlatButton(
            onPressed:add_doctor,
            color: Color(0xff01d35a),
            child:  Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Add", style: TextStyle(color: Colors.white)),
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
          InkWell(onTap:_launchURL,child: Container(child: Text("Terms of Service.", maxLines: null,
              style: TextStyle(  decoration: TextDecoration.underline,))))
        ],
      ),
    );

    final doctor_lists = doc_names.length == 0? Container(): Container(
      height: 100,
      child: ListView.builder(itemBuilder: (context, index){
        return Container(
          margin: EdgeInsets.only(right: 10),
          width: 250,
          child:Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                      gradient: new LinearGradient(
                          colors: [Color(0xffababab), Color(0xff686868)],
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp
                      ),

                    ),
                    alignment: Alignment.center,
                    child: Text(config.Config.get_initial_name(doc_names[index]), style:
                    TextStyle(color: Colors.white, fontSize: 14),),
                  ),

                  SizedBox(
                    width: 10,
                  ),


                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Text(doc_names[index], style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                      Text(doc_edus[index]),
                      Text(doc_designations[index]),
                      Text(doc_experiences[index]+" years of experience")

                    ],
                  )),

                ],

              ),


              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                    onTap: (){


                      setState(() {
                        doc_names.removeAt(index);
                        doc_edus.removeAt(index);
                        doc_designations.removeAt(index);
                        doc_departments.removeAt(index);
                        doc_experiences.removeAt(index);
                      });



                    },
                    child
                    : Padding(
                      padding: const EdgeInsets.only(bottom:8.0, left: 8),
                      child: Icon(Icons.clear),
                    )),
              ),
            ],
          )
        );
      }, scrollDirection: Axis.horizontal, itemCount: doc_names.length,),

    );




    final doc_speciality =   Container(
      decoration: BoxDecoration(borderRadius:
      BorderRadius.all(Radius.circular(10)), border:
      Border.all(width: 0.3, color: Colors.grey)),
      child: InkWell(
        onTap: (){
             showDialog(
                context: context,
                builder: (BuildContext context,) =>
                Select_specialization(spec: specialization_list)
            ).then((val){
            if(val != '' && val != null){
            doc_specialization_.text = val;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            enabled: false,
            maxLines: null,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            controller: doc_specialization_,
            decoration: InputDecoration.collapsed(hintText: ""),
          ),
        ),
      ),
    );


    final form = ListView(
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Center(
          child: Text(
            "Profile Information",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text("Hospital Name"),
        SizedBox(
          height: 10,
        ),
        name,


        Visibility(child: Text("Please enter valid name",
          style: TextStyle(color: Colors.red),), visible: !valid_name,),


        SizedBox(
          height: 10,
        ),
        Text("Address"),
        SizedBox(
          height: 10,
        ),
        address,
        Visibility(child: Text("Please enter valid address",
          style: TextStyle(color: Colors.red),), visible: !valid_address,),


        SizedBox(
          height: 10,
        ),
        Text("Phone"),
        SizedBox(
          height: 10,
        ),
        phone_number,


        SizedBox(
          height: 10,
        ),
        Text("Email"),
        SizedBox(height: 10,),
        email,

        Visibility(child: Text("Please enter valid Email",
          style: TextStyle(color: Colors.red),), visible: !valid_email,),



        SizedBox(
          height: 10,
        ),
        Text("Password (at least 8 character)"),
        SizedBox(height: 10,),
        password,
        Visibility(child: Text("Please enter valid Password",
          style: TextStyle(color: Colors.red),), visible: !valid_password,),




        SizedBox(
          height: 10,
        ),
        Text("About Hospital"),
        SizedBox(
          height: 10,
        ),
        about,
        Visibility(child: Text("Please enter valid Intoduction",
          style: TextStyle(color: Colors.red),), visible: !valid_about,),




        SizedBox(
          height: 10,
        ),
        Text("Registration No"),
        SizedBox(
          height: 10,
        ),
        reg_no,
        SizedBox(
          height:20,
        ),
        Center(
          child: Text(
            "Add Doctor",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10,
        ),

        SizedBox(height: 20,),
        Text("Full Name"),
        SizedBox(height: 10,),
        doc_name,


        SizedBox(height: 10,),
        Text("Education Qualification"),
        SizedBox(height: 10,),
        doc_edu,


        SizedBox(height: 10,),
        Text("Designation"),
        SizedBox(height: 10,),
        doc_degignation,

        SizedBox(height: 10,),
        Text("Department"),
        SizedBox(height: 10,),
        doc_department,



        SizedBox(height: 10,),
        Text("Speciality"),
        SizedBox(height: 10,),
        doc_speciality,

        SizedBox(height: 10,),
        Text("Experience (in years)"),
        SizedBox(height: 10,),
        doc_experience,


        SizedBox(height: 10,),
        add,
        SizedBox(height: 10,),

        doctor_lists,

        SizedBox(height: 10,),
        signup,
        terms,

      ],
    );

    return Expanded(
      child: Scaffold(body: Container(child: form, margin: EdgeInsets.all(20),),
        key: _scaffoldKey,
      )
    );
  }
}
