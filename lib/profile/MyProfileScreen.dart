import 'dart:convert';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/achievments/delete_achievment.dart';
import 'package:plunes/model/profile/edit_profile.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/model/profile/image_upload.dart';
import 'package:plunes/profile/AddDoctors.dart';
import 'package:plunes/profile/DoctorDetails.dart';
import 'package:plunes/profile/EditDoctors.dart';
import 'package:plunes/profile/EditProfile.dart';
import 'package:plunes/profile/ProfileImage.dart';
import 'package:plunes/profile/achievemnts/AchievemntsScreen.dart';
import 'package:plunes/profile/catlogue/ViewCatalogue.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';


class MyProfileScreen extends StatefulWidget {
  static const tag = '/myprofilescreens';
  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String user_token="";
  String user_id = "";
  String specialities = "";
  String user_type = "";
  String email = "";
  String address = "";
  String experience = "";
  String practising = "";
  String qualification = "";
  String college = "";
  String biography = "";

  String image_url = "";
  String cover_url = "";

  String name = "";
  String initial_name = "";

  bool progress = true;

  String upload_image_url = "";
  String upload_cover_url = "";


  MyProfile myProfileData;


  int pro = 10;

  List achievment_img = new List();
  List achievment_title = new List();
  List achievment_id = new List();

  /// doctors list
  List doc_names = new List();
  List doc_edus = new List();
  List doc_designations = new List();
  List doc_experiences = new List();
  List doc_id = new List();
  List doc_imageUrl = new List();

  /// hospital specializations
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _speciality="";
  Set _special_lities = new Set();
  List procedure_name = new List();


  // here we are creating the list needed for the DropDownButton
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String speciality in _special_lities) {
      items.add(new DropdownMenuItem(value: speciality,
          child: new Text(speciality,
            style: TextStyle(fontSize: 12, color: Colors.black,),)
      ),
      );
    }
    return items;
  }


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
    get_profile_info(token);
  }

  void get_data() async{
    procedure_name.clear();
    for(int j =0; j< config.Config.procedure_speciality.length; j++){
      if(config.Config.procedure_speciality[j].contains(_speciality)){
        print(config.Config.procedure_name[j]);
        procedure_name.add(config.Config.procedure_name[j]);
      }
    }

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
        if(imgUploadPost.success){
          upload_image_url = config.Config.base_url+imgUploadPost.url;
          upload_image();
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

        if(imgUploadPost.success){
          upload_image_url = config.Config.base_url+imgUploadPost.url;
          upload_image();
        }else{
          config.Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
    }
  }


  Future getImage2(BuildContext context) async {

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
        if(imgUploadPost.success){
          upload_image2(config.Config.base_url+imgUploadPost.url);
        }else{
          config.Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
    }
  }


  void get_camera2(BuildContext context) async {


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

        if(imgUploadPost.success){

          upload_image2(config.Config.base_url+imgUploadPost.url);
        }else{
          config.Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
    }
  }


  void delete_achievment(String achievments_id) async{
    setState(() {
      progress = true;
    });


    AchievmentsDelete achievmentsDelete = await achievments_delete(achievments_id,user_token)
        .catchError((error){
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });


    setState(() {
      progress = false;
      getSharedPreferences();

      if(achievmentsDelete.success){
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext context,
              ) =>
              _popup_saved(context),
        );

      }else{
        config.Config.showInSnackBar(_scaffoldKey, achievmentsDelete.message, Colors.red);
      }

    });
  }

  upload_image2(String url)async{

    var body = {
      "coverImageUrl": url
    };

    print(body);

    EditProfilePost editProfilePost = await edit_profile(body, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });


    setState(() {
      progress = false;

      if(editProfilePost.success){
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(screen: "profile"),
            ));
      }else{
        config.Config.showInSnackBar(_scaffoldKey, editProfilePost.message, Colors.red);
      }
    });

  }

  upload_image()async{

    var body = {
      "imageUrl": upload_image_url
    };

    EditProfilePost editProfilePost = await edit_profile(body, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });


    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("imageUrl", upload_image_url);


    setState(() {
      progress = false;
      if(editProfilePost.success){
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(screen: "profile"),
            ));
      }else{
        config.Config.showInSnackBar(_scaffoldKey, editProfilePost.message, Colors.red);
      }
    });

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


  void _settingModalBottomSheet2(context) {
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
                      get_camera2(context);
                      Navigator.pop(context);
                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.image),
                  title: new Text('Gallery'),
                  onTap: () {
                    getImage2(context);
                    Navigator.pop(context);
                  },
                ),

              ],
            ),
          );
        });
  }

  get_profile_info(String token) async{
    achievment_img.clear();
    achievment_title.clear();
    achievment_id.clear();

    doc_names.clear();
    doc_edus.clear();
    doc_designations.clear();
    doc_experiences.clear();///......................................................................................................
    doc_id.clear();
    doc_imageUrl.clear();

     myProfileData = await my_profile_data(token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });
    print( myProfileData.otherFields.toString());
    image_url = myProfileData.imageUrl;
    name = myProfileData.name;
    cover_url = myProfileData.coverImageUrl;
     user_type = myProfileData.userType;
     email = myProfileData.email;
     address = myProfileData.address;
     experience = myProfileData.experience;
     practising = myProfileData.practising;
     qualification = myProfileData.qualification;
     college = myProfileData.college;
     biography = myProfileData.biography;
     initial_name = config.Config.get_initial_name(name);

     for(int i =0; i< myProfileData.achievments.length; i++){
       achievment_img.add(myProfileData.achievments[i].imageUrl);
       achievment_title.add(myProfileData.achievments[i].title);
       achievment_id.add(myProfileData.achievments[i].id);
     }

     if(myProfileData.doctorsdata.length > 0){
       for(int i =0; i< myProfileData.doctorsdata.length; i++){
         doc_names.add(myProfileData.doctorsdata[i].name);
         doc_edus.add(myProfileData.doctorsdata[i].education);
         doc_designations.add(myProfileData.doctorsdata[i].designation);
         doc_experiences.add(myProfileData.doctorsdata[i].experience);
         doc_id.add(myProfileData.doctorsdata[i].id);
         doc_imageUrl.add(myProfileData.doctorsdata[i].imageUrl);
         _special_lities.add("Choose Speciality");
         for(int j =0; j< myProfileData.doctorsdata[i].specialities.length; j++){
           int pos = config.Config.specialist_id.indexOf(myProfileData.doctorsdata[i].specialities[j].specialityId);
           print(config.Config.specialist_lists[pos]);
           _special_lities.add(config.Config.specialist_lists[pos]);
         }
       }
       _dropDownMenuItems = getDropDownMenuItems();
       _speciality = _dropDownMenuItems[0].value;
       get_data();
     }


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
      setState(() {
        progress = false;
      });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("PRESCRIPTION_LOGO_URL", myProfileData.prescriptionLogoUrl);
    prefs.setString("PRESCRIPTION_LOGO_TEXT", myProfileData.prescriptionLogoText);
    prefs.setStringList("PRESCRIPTION_FIELDS", myProfileData.otherFields);

  }


  @override
  Widget build(BuildContext context) {

    final profile = Container(
      margin: EdgeInsets.only(left: 15, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
            margin: EdgeInsets.only(right: 10),
            child: Stack(
              children: <Widget>[
                InkWell(
                  onTap: (){
                    if(image_url != ""){
                      showDialog(
                        context: context,
                        builder: (BuildContext context,) =>
                            ProfileImage(
                              image_url: image_url,
                              text: " "),
                      );
                    }else{
                      _settingModalBottomSheet(context);
                    }
                  },
                  child:image_url !='' ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(image_url),
                  ): Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      child:
                      Text(initial_name.toUpperCase(),
                        style: TextStyle(color: Colors.white,
                            fontSize: 22, fontWeight: FontWeight.normal),),

                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),
                        gradient: new LinearGradient(
                            colors: [Color(0xffababab), Color(0xff686868)],
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp
                        ),) ),
                ),


                Positioned(
                  child: InkWell(
                    child: Container(
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 12,
                      ),
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Color(0xff01d35a)),
                    ),
                    onTap: () {
                      _settingModalBottomSheet(context);
                    },
                  ),
                  top: 40,
                  left: 40,
                ),
              ],
            ),
          ),

          Expanded(child: Container(
            margin: EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(name,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),

//                Text(
//                  user_type,
//                  style: TextStyle(color: Colors.grey, fontSize: 14),
//                ),


                Container(
                  child: Text(
                    email,
                    maxLines: 2,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),),

          Container(
            alignment: Alignment.topRight,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.pushNamed(context, EditProfile.tag);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Edit Profile",
                  style: TextStyle(
                      color: Color(0xff01d35a),
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
          // cam_video
        ],
      ),
    );


    final loading = Container(
      child: Shimmer.fromColors(
        baseColor: Color(0xffF5F5F5),
        highlightColor: Color(0xffFAFAFA),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Color(0xffF5F5F5),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              height: 10,
              color: Color(0xffF5F5F5),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              height: 10,
              color: Color(0xffF5F5F5),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              height: 10,
              color: Color(0xffF5F5F5),
            ),
          ],
        ),
      ),
    );
    final btn_option = Container(
        margin: EdgeInsets.only(top:20),
        child:
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          user_type == 'User'?Container():  Column(children: <Widget>[
            InkWell(
              onTap: () {

                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewCatalogue(
                        services: myProfileData.specialities
                      ),
                    ));
              },
              child: Image.asset(
                'assets/images/catalogue/catalog.png',
                height: 50,
                width: 50,
              ), borderRadius: BorderRadius.circular(25),),
            SizedBox(
              height: 5,
            ),
            Text("Catalogue")
          ]),

          user_type == 'User'?Container(): SizedBox(width: 40,),

          Column(children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AchievemntsScreen.tag);
              },
              child: Image.asset(
                'assets/images/achievments/achivement.png',
                height: 50,
                width: 50,
              ), borderRadius: BorderRadius.circular(25),),

            SizedBox(
              height: 5,
            ),

            Text("Achievement")
          ])

        ]));


    final location = Container(
      margin: EdgeInsets.only(top:20, left: 20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[

          Image.asset(
            'assets/images/profile/location.png',
            height: 22,
            width: 22,
          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child: RichText(
              text: new TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Location '),
                  new TextSpan(text: address, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        ],
      ),
    );



    final expertise = specialities == ''? Container(): Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            'assets/images/profile/expertise.png',
            height: 22,
            width: 22,

          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child: RichText(
              text: new TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Area of Expertise '),
                  new TextSpan(text: specialities, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        ],
      ),
    );

    final exp = experience == ''? Container(): Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[

          Image.asset(
            'assets/clock.png',
            height: 22,
            width: 22,
            color: Colors.grey,
          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child: RichText(
              text: new TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  new TextSpan(text: 'Experience of Practice '),
                  new TextSpan(text: experience+" years", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final pract = practising == ''? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          Image.asset('assets/images/profile/practise.png', height: 22, width: 22, color: Colors.grey),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: RichText(
              text: new TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Practising '),
                  new TextSpan(text: practising, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        ],
      ),
    );

    final quali = qualification == ''? Container(): Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          Image.asset(
            'assets/images/profile/qualification.png',
            height: 25,
            width: 25,
            color: Colors.grey,
          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child: RichText(
              text: new TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Qualifications '),
                  new TextSpan(text: qualification, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        ],
      ),
    );

    final col = college== ''? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          Image.asset(
            'assets/images/profile/college.png',
            height: 22,
            width: 22,
            color: Colors.grey,
          ),


          SizedBox(
            width: 10,
          ),
          Expanded(
            child: RichText(
              text: new TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  new TextSpan(
                      text: 'College/University '),
                  new TextSpan(text: college, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        ],
      ),
    );

    final introduction = biography == ''? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[

          Text("Introduction", style: new TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black)),
          SizedBox(
            width: 10,
          ),

          Text(biography, style: TextStyle(color: Colors.grey))

        ],
      ),
    );

    final achievment = achievment_id.length == 0? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 20),
      child: Text("Achievements", style: TextStyle(fontWeight: FontWeight.w600),),
    );

    final achievemnts = achievment_id.length == 0? Container():Container(
      margin: EdgeInsets.only(bottom: 20),
      height: 150,
      child: ListView.builder(itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: InkWell(
            onTap: (){

              showDialog(
                context: context,
                builder: (BuildContext context,) =>
                    ProfileImage(
                      image_url: achievment_img[index],
                      text: achievment_title[index],
                    ));

            },
            child: Container(
              child: Stack(
                children: <Widget>[

                  Container(child: Image.network(achievment_img[index],
                    fit: BoxFit.cover,), height: 150,width: 200,
                  ),

                  Container(child: Text(achievment_title[index],
                    style: TextStyle(color: Colors.white),),
                    height: 150, width: 200,alignment: Alignment.center,),


                  Positioned(
                    bottom: 100,
                    right: 5,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        iconEnabledColor: Color(0xff01d35a),
                        icon: Icon(Icons.more_horiz),
                        elevation: 8,
                        items: <String>['Delete'].map((
                            String value) {
                          return new DropdownMenuItem<
                              String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (text) {
                          print(text);
                          if (text == 'Delete') {
                            delete_achievment(achievment_id[index]);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                  color: Colors.grey),
              height: 150,
              width: 200,

            ),
          ),
        );

      }, scrollDirection: Axis.horizontal,itemCount: myProfileData.achievments.length,),
    );



    ////////////////////////////////////////////

    final hos_introduction = biography == ''? Container(): Container(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[


          Text("Introduction", style: TextStyle(fontWeight: FontWeight.w600),),

          SizedBox(height: 10,),
          Text(biography)
        ],
      ),
    );




    final hos_cover = Container(
      width: double.infinity,
      height: 250,
      child:Stack(
    children: <Widget>[
      Container(
        color: Colors.grey,
        height: 250,
        width: double.infinity,

      ),
          InkWell(
            onTap: (){
              if(cover_url != ""){
                showDialog(
                  context: context,
                  builder: (BuildContext context,) => ProfileImage(image_url: cover_url, text: " "),
                );

              }

            },
            child: Container(child: Image.network(cover_url, fit: BoxFit.cover),
            height: 250, width: double.infinity),
          ),

            Align(
              child: Container(
                alignment: Alignment.topRight,
                height:250,
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 12,
                      ),
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.green),
                    ),
                  ),
                  onTap: () {
                    _settingModalBottomSheet2(context);
                  },
                ),
              ),
            ),
    ],

    )

    );


    final hos_profile = Container(

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Container(
              margin: EdgeInsets.only(right: 10),
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      if(image_url != ""){

                        showDialog(
                          context: context,
                          builder: (BuildContext context,) =>
                              ProfileImage(
                                image_url: image_url,
                                text: " ",
                              ),
                        );

                      }else{
                        _settingModalBottomSheet(context);
                      }
                    },
                    child:image_url !='' ? CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(image_url),
                    ): Container(
                        height: 60,
                        width: 60,
                        alignment: Alignment.center,
                        child:
                        Text(initial_name.toUpperCase(),
                          style: TextStyle(color: Colors.white,
                              fontSize: 22, fontWeight: FontWeight.normal),),

                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),
                          gradient: new LinearGradient(
                              colors: [Color(0xffababab), Color(0xff686868)],
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp
                          ),) ),
                  ),


                  Positioned(
                    child: InkWell(
                      child: Container(
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 12,
                        ),
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            color: Colors.green),
                      ),
                      onTap: () {
                        _settingModalBottomSheet(context);
                      },
                    ),
                    top: 40,
                    left: 40,
                  ),
                ],
              ),
            ),

            Expanded(child: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                  SizedBox(height: 5,),
                  Text(address)
                ],
              ),
            ))

          ],
        ),
      ),

    );


    final hos_add_achievments =  Column(children: <Widget>[
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, AchievemntsScreen.tag);
        },
        child: Image.asset(
          'assets/images/achievments/achivement.png',
          height: 50,
          width: 50,
        ), borderRadius: BorderRadius.circular(25),),

      SizedBox(
        height: 5,
      ),

      Text("Achievement")
    ]);

    final hos_location = Container(
      margin: EdgeInsets.only(top:20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,

            children: <Widget>[

              Image.asset(
                'assets/images/profile/location.png',
                height: 22,
                width: 22,
              ),

              SizedBox(
                width: 10,
              ),


              Expanded(child: Text(address, style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.w300)))

            ],
          ),
          InkWell(
            onTap: (){
              MapUtils.openMap(double.parse(myProfileData.latitude), double.parse( myProfileData.longitude));
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(child: Text("View on Map", style: TextStyle(color: Color(0xff01d35a)),),
                margin: EdgeInsets.only(left: 30),),
            ),
          ),

          SizedBox(height: 10,),
          Container(height: 0.3,color: Colors.grey,),
          SizedBox(height: 10,),
        ],
      ),
    );

    final hos_specialization = Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Text("Specializations", style: TextStyle(fontWeight: FontWeight.w600),),
            SizedBox(
              height: 10,
            ),
            Container(
              // margin: EdgeInsets.only(left: 10, right: 10),

              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 1, color: Color(0xff01d35a))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                  hint: Text(
                    "Choose Speciality", style: TextStyle(color: Colors.white),),
                  value: _speciality,
                  decoration: InputDecoration.collapsed(hintText: "Choose Speciality",
                      hintStyle: TextStyle(color: Colors.black),
                      hasFloatingPlaceholder: true, fillColor: Colors.white),
                  items: _dropDownMenuItems,
                  onChanged: (val){

                    print(val);

                    setState(() {
                      _speciality = val;
                      get_data();

                    });
                  },
                ),
              ),
            ),


            ListView.builder(itemBuilder: (context, index){

              return Container(

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[

                      Expanded(child: Text(procedure_name[index])),

                      SizedBox(width: 10,),

                      InkWell(child: Text("Know more", style: TextStyle(color: Colors.grey),),

                      onTap: (){

                        print(procedure_name[index]);

                        int pos = config.Config.procedure_name.indexOf(procedure_name[index]);

                        showDialog(
                            context: context,
                            builder: (
                                BuildContext context,
                                ) =>
                                _popup_dialoge(
                                    context,
                                    config.Config
                                        .procedure_description[
                                    pos],
                                    procedure_name[index]));
                      },)
                    ],
                  ),
                ),
              );

            }, itemCount:procedure_name.length> pro? pro: procedure_name.length, shrinkWrap: true, physics: ScrollPhysics(),),

            _speciality == 'Choose Speciality'? Container(): Center(
              child: InkWell(
                onTap: (){

                  setState(() {


                    if(pro == 10){
                      pro = procedure_name.length;
                    }else{
                      pro = 10;
                    }


                  });

                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:pro ==10? Text("View More", style: TextStyle(color: Color(0xff01d35a)),):
                  Text("View Less", style: TextStyle(color: Color(0xff01d35a)),),
                ),
              ),
            )




          ],
        ),
      ),
    );


    final hos_doctors = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(child: Row(
            children: <Widget>[
              Expanded(child: Text("Team of Experts", style: TextStyle(fontWeight: FontWeight.w600),)),

              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddDoctors(

                        ),
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Add Expert",style: TextStyle(color: Color(0xff01d35a), fontWeight: FontWeight.w600), ),
                ),
              ),
            ],
          ),
          margin: EdgeInsets.only(left: 20),),
          SizedBox(height:20,),

          Container(
            height: 100,
            child: ListView.builder(itemBuilder: (context, index){
              return InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetails(
                            doctordata: myProfileData.doctorsdata,
                            pos: index
                        ),
                      ));
                },
                child: Container(
                    margin: EdgeInsets.only(right: 10, left: 10),
                    width: 260,
                    child:Stack(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                        doc_imageUrl[index]!= ''?
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(doc_imageUrl[index]),
                            ):
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
                                Text(doc_names[index], maxLines: 1,style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                                Text(doc_edus[index], maxLines: 1,),
                                Text(doc_designations[index], maxLines: 1,),
                                Text(doc_experiences[index]+ " years", maxLines: 1)
                              ],
                            )),
                          ],
                        ),

                        Align(
                          alignment: Alignment.topRight,
                          child:  Container(
                            height: 100,
                            alignment: Alignment.topRight,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconEnabledColor: Colors.green,
                                icon: Icon(Icons.more_horiz),
                                elevation: 8,
                                items: <String>['Edit'].map((
                                    String value) {
                                  return new DropdownMenuItem<
                                      String>(
                                    value: value,
                                    child: new Text(value),
                                  );
                                }).toList(),
                                onChanged: (text) {
                                  print(text);
                                  if (text == 'Edit') {
                                    print( myProfileData.doctorsdata[0]);
                                    print(index);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditDoctors(
                                            doctordata: myProfileData.doctorsdata,
                                            pos: index
                                          ),
                                        ));


                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ),
              );
            }, itemCount: doc_id.length,scrollDirection: Axis.horizontal, ),
          )


        ],
      ),


    );

    final hospital_form = ListView(
      children: <Widget>[
        hos_cover,
        hos_profile,
        hos_add_achievments,
        Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              hos_location,
              hos_introduction
            ],
          ),
        ),

        hos_specialization,
        hos_doctors,
        achievment,
        achievemnts,
      ],
    );

   final doctor_form = Container(
      child: ListView(
        children: <Widget>[
          profile,
          btn_option,

          location,
          expertise,
          exp,
          pract,
          quali,
          col,
          introduction,
          achievment,
          achievemnts,
        ],
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: progress? loading: user_type=='Hospital'?hospital_form: doctor_form,
    );
  }


  Widget _popup_dialoge(BuildContext context, String def, String name) {
    return new CupertinoAlertDialog(
      content: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      name,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Icon(Icons.close),
                    ),
                    alignment: Alignment.topRight,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                def,
                maxLines: 6,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 35,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
                alignment: Alignment.center,
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Deleted..'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);

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

