import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plunes/availability/Businesshours.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/model/profile/image_upload.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/update_doctor.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditDoctors extends StatefulWidget {
  static const tag = '/editdoctors';

  final List<DoctorsData> doctordata;
  final int pos;

  EditDoctors({Key key, this.doctordata, this.pos}) : super(key: key);

  @override
  _EditDoctorsState createState() => _EditDoctorsState(doctordata, pos);
}

class _EditDoctorsState extends State<EditDoctors> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<DoctorsData> doctordata = new List();
  int pos;
  _EditDoctorsState( this.doctordata, this.pos);

  TextEditingController doc_name = new TextEditingController();
  TextEditingController doc_education = new TextEditingController();
  TextEditingController doc_designation = new TextEditingController();
  TextEditingController doc_department = new TextEditingController();
  TextEditingController doc_experience = new TextEditingController();

  bool progress = false;
  String image_url = "";

  String user_token = "";
  String user_id = "";
  String url = "";
  String name = "";
  String initial_name = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    setState(() {
      user_token = token;
      user_id = uid;
    });

    doc_name.text = doctordata[pos].name;
    name = doctordata[pos].name;
    doc_education.text = doctordata[pos].education;
    doc_designation.text = doctordata[pos].designation;
    doc_department.text = doctordata[pos].department;
    doc_experience.text = doctordata[pos].experience;
    image_url = doctordata[pos].imageUrl;

    initial_name =  config.Config.get_initial_name(name);

    url = config.Config.user+"/"+user_id+"/doctors/"+ doctordata[pos].id+"/timeSlots";
  }


  update() async{

    setState(() {
      progress = true;
    });

    var doctor =  {
      "doctorId": doctordata[pos].id,
      "name":doc_name.text,
      "education": doc_education.text,
      "designation": doc_designation.text,
      "department": doc_department.text,
      "experience": doc_experience.text,
      "imageUrl": image_url
    } ;

    List doctors_ = new List();
    doctors_.add(doctor);

    var body = {
      "doctors": doctors_
    };

    print(body);

    UpdateDoctor updateDoctor =  await update_doctor(body, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!"+error.toString());
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;
      if(updateDoctor.success){

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext context,
              ) =>
              _popup_saved(context),
        );

      }else{
        config.Config.showInSnackBar(_scaffoldKey, updateDoctor.message, Colors.red);
      }
    });
  }

  Future<File> _cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        maxWidth: 1080,
        maxHeight: 1080
    );
    return croppedFile;
  }



  Future getImage(BuildContext context) async {
    var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      image = await _cropImage(image);
      print("image==" + base64Encode(image.readAsBytesSync()).toString());
    }

    if (image != null) {
      setState(() {
        progress = true;
      });

      var body = {
        "data": base64Encode(image.readAsBytesSync()),
      };

      ImgUploadPost imgUploadPost = await image_upload(body, user_token).catchError((error){
        config.Config.showLongToast("Something went wrong!");
        setState(() {
          progress = false;
        });
      });


      setState(() {
        progress = false;
        if(imgUploadPost.success){
          image_url = config.Config.base_url+imgUploadPost.url;

        }else{
          config.Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
    }
  }

  void get_camera(BuildContext context) async {
     var image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      image = await _cropImage(image);
      print("image==" + base64Encode(image.readAsBytesSync()).toString());
    }

    if (image != null) {
      setState(() {
        progress = true;
      });

      var body = {
        "data": base64Encode(image.readAsBytesSync()),
      };

      ImgUploadPost imgUploadPost = await image_upload(body, user_token).catchError((error){
        config.Config.showLongToast("Something went wrong!");
        setState(() {
          progress = false;
        });
      });


      setState(() {
        progress = false;
        if(imgUploadPost.success){
          image_url = config.Config.base_url+imgUploadPost.url;
        }else{
          config.Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
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
  @override
  Widget build(BuildContext context) {


    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      elevation: 3,
      title: Text(
        "Edit Doctor",
        style: TextStyle(color: Colors.black),
      ),
    );


    final mannual_add = Container(
      margin: EdgeInsets.only(left:20, right: 20),
      child: ListView(
        children: <Widget>[

       SizedBox(height: 20,),
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
                        child: image_url!='' && image_url!= null ? CircleAvatar(
                          radius: 40,
                          backgroundImage:NetworkImage(image_url),)
                            : Container(
                            height: 80,
                            width: 80,
                            alignment: Alignment.center,
                            child:
                            Text(initial_name.toUpperCase(),
                              style: TextStyle(color: Colors.white,
                                  fontSize: 18, fontWeight: FontWeight.normal),),
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(
                                Radius.circular(40)),
                              gradient: new LinearGradient(
                                  colors: [Color(0xffababab), Color(0xff686868)],
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  stops: [0.0, 1.0],
                                  tileMode: TileMode.clamp
                              ),) ),
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
                controller: doc_department,
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
            ),
          ),

          SizedBox(height: 10,),
          Text("Experience (in years)"),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(borderRadius:
            BorderRadius.all(Radius.circular(10)), border:
            Border.all(width: 0.3, color: Colors.grey)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: doc_experience,
                keyboardType: TextInputType.number,
                decoration: InputDecoration.collapsed(hintText: ''),
              ),
            ),
          ),

//          SizedBox(height: 10,),
//          Text("Availability"),
//          SizedBox(height: 10,),

          Visibility(
            visible: false,
            child: InkWell(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BusinessHours(
                        url: url,
                      ),
                    ));

              },
              child: Container(width: 90, alignment: Alignment.center, height: 40,
                decoration: BoxDecoration(borderRadius: BorderRadius.all
                  (Radius.circular(15)),
                    color: Color(0xff01d35a)),
                child: Text("Add Availability", style: TextStyle(color: Colors.white),),
              ),
            ),
          ),


          SizedBox(height: 20,),
      progress? SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ):  InkWell(
            onTap: update,
            child: Container(width: 90, alignment: Alignment.center, height: 40,
              decoration: BoxDecoration(borderRadius: BorderRadius.all
                (Radius.circular(15)),
                  color: Color(0xff01d35a)),
              child: Text("Submit", style: TextStyle(color: Colors.white),),
            ),
          ),

          SizedBox(height: 20,),
        ],
      ),
    );


    return Scaffold(
      key: _scaffoldKey,
      appBar: app_bar,
      backgroundColor: Colors.white,
      body: mannual_add,
    );
  }

  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Saved..'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(screen: "profile"),
                  ));
          },
          child: new Text(
            'OK',
            style: TextStyle(color: Color(0xff01d35a)),
          ),
        ),
      ],
    );
  }



}
