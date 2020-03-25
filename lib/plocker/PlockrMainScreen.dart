import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plunes/appointment/CreatePrescription.dart';
import 'package:plunes/config.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/plockr/GetPrescriptions.dart';
import 'package:plunes/model/plockr/SendPrescription.dart';
import 'package:plunes/model/profile/image_upload.dart';
import 'package:plunes/profile/ProfileImage.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';

/*Created New Repo 30Dec2019*/
class PlockrMainScreen extends StatefulWidget {
  static const tag = '/plockrmainscreen';
  @override
  _PlockrMainScreenState createState() => _PlockrMainScreenState();
}

class _PlockrMainScreenState extends State<PlockrMainScreen> {

  bool cross = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final Map<String, IconData> _data = Map.fromIterables(['Share'], [Icons.filter_1]);

  var image;
  bool progress = false, isPrescriptionCreated = true;
  String image_url = "";

  String user_token = "";
  String user_id = "";
  String user_type = "";
  List<PersonalReports> personel_ = new List();
  List<BusinessReports> business_ = new List();
  List<PersonalReports> filter_personel = new List();
  TextEditingController search_controller = new TextEditingController();
  int selectedReportPosition = -1;

    @override
    void initState() {
      super.initState();
      getSharedPreferences();
    }

    getSharedPreferences() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.getString("token");
      String uid = prefs.getString("uid");
      String type  = prefs.getString("user_type");

      setState(() {
        user_token = token;
        user_id = uid;
        user_type = type;
        isPrescriptionCreated = (prefs.getString("PRESCRIPTION_LOGO_URL")!='' || prefs.getString("PRESCRIPTION_LOGO_TEXT")!='' )? true : false;///check prescription is created or not.

      });

      get_reports();
    }

    void get_camera(BuildContext context) async {
    image = await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      image = await _cropImage(image);
      print("image==" + base64Encode(image.readAsBytesSync()).toString());
    }
    if(image != null) {
      setState(() {
        progress = true;
      });
      var body = {
        "data": base64Encode(image.readAsBytesSync()),
      };
      ImgUploadPost imgUploadPost = await image_upload(body, user_token).catchError((error){
        Config.showLongToast("Something went wrong!");
        setState(() {
          progress = false;
        });
      });

      setState(() {
        progress = false;
        if(imgUploadPost.success){
          image_url = config.Config.base_url+imgUploadPost.url;
          upload_prescription();
        }else{
          Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
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
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
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
        Config.showLongToast("Something went wrong!");
        setState(() {
          progress = false;
        });
      });
      setState(() {
        progress = false;
        if(imgUploadPost.success){
          image_url = config.Config.base_url+imgUploadPost.url;
          upload_prescription();
        }else{
          Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
    }
  }

  upload_prescription(){
    if(image_url!= ''){
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context,) =>
            AddUserProcedure(
              image_url: image_url,
            ));
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


  get_reports() async{
    setState(() {
      progress = true;
    });

    GetPrescription getPrescription = await get_prescription(user_token).catchError((error){
      Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;
      if(getPrescription.success){
        personel_.addAll(getPrescription.personal);
        filter_personel.addAll(getPrescription.personal);
        business_.addAll(getPrescription.business);
        getUploadedPrescription();



      }
    });
  }
  getUploadedPrescription() async{
    setState(() {
      progress = true;
    });

    GetPrescriptionFile getPrescription = await getUploadedPrescriptionFile(user_token).catchError((error){
      Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;
      if(getPrescription.success){
        personel_.addAll(getPrescription.personal);
        filter_personel.addAll(getPrescription.personal);
//        business_.addAll(getPrescription.business);
      }
    });
  }

  filter_data(String text){
    filter_personel.clear();
    setState(() {
      for(int i =0; i<personel_.length; i++){
        if(personel_[i].reportName.toLowerCase().contains(text.toLowerCase())){
          filter_personel.add(personel_[i]);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final personel = Container(
      child: Column(
        children: <Widget>[
        progress? SpinKitThreeBounce(
          color: Color(0xff01d35a),
          size: 30.0,
          // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
        ):
        Container(
            child:  Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                radius: 10,
                onTap: (){
                  _settingModalBottomSheet(context);
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Text("Upload Reports", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500,
                                    fontSize: 16),),
                                Expanded(child: Container()),
                               Image.asset('assets/images/plockr/upload.png', height: 18, width: 18)
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(height: 0.5,color: Colors.grey,   margin: EdgeInsets.only(left: 10, right: 10),)

                    ],
                  ),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0, bottom: 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: search_controller,
                      decoration: InputDecoration.collapsed(hintText: "Search"),
                      onChanged: (text){
                        setState(() {
                          if(text.length > 0){
                            cross = true;
                          }else{
                            cross = false;
                          }
                        });
                        filter_data(text);
                      },
                    ),
                  ),

                  Container(
                    alignment: Alignment.center,
//                    padding: const EdgeInsets.only(right:8.0),
                    child:cross?InkWell(
                      child: Icon(Icons.close, color: Colors.grey,),
                      onTap: (){
                        setState(() {
                          cross = false;
                          search_controller.text = "";
                          filter_data("");
                        });
                      },
                    ): Icon(Icons.search, color: Colors.grey,) ,
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(border: Border.all(width: 1, color: Color(0xff01d35a)), borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
          Expanded(child: filter_personel.length == 0? Center(
            child: Text("No Results"),
          ):  ListView.builder(itemBuilder: (context, index){
            return Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap:(){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            ShowImageDetails(
                              data: filter_personel,
                              position: index
                            ),
                      );
                    },
                    child: Container(
//                      padding: const EdgeInsets.only(top:8.0,),//+ '.thumbnail.png'
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                      filter_personel[index].reportUrl.contains(".pdf") ?
                      Card(
                        semanticContainer: true,
                        elevation: 5,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Container(
                          width: 120,
                          height: 100.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0), ),
                          ),
                          child: Stack(children: <Widget>[
                            Center(child: Container(
                              color: Colors.white,
                              child: FadeInImage(image: NetworkImage(filter_personel[index].reportUrl+ '.thumbnail.png'), placeholder: AssetImage('assets/images/plockr/pdf.png'))
                            ),),
                          ],),        alignment: Alignment.center,
                        ))

                      : filter_personel[index].reportUrl.contains(".doc") ? Card(
                          semanticContainer: true,
                          elevation: 5,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            width: 120,
                            height: 100.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8.0), ),

                            ),
                            child:  Container(
                              child: Stack(children: <Widget>[
                              Center(child: Container(
                                color: Colors.white,
                                child: FadeInImage(image: NetworkImage(filter_personel[index].reportUrl+ '.thumbnail.png'), placeholder: AssetImage('assets/images/plockr/doc.png'))
                              ))
                            ],),),
                            alignment: Alignment.center,
                          ))
                      :
                      filter_personel[index].reportUrl.contains(".docx") ? Card(
                          semanticContainer: true,
                          elevation: 5,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            width: 120,
                            height: 100.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10.0))
                            ),
                            child: Text("DOC File", style: TextStyle(fontSize: 18, color: Colors.white),),
                            alignment: Alignment.center,
                          )) :
                      Card(
                          semanticContainer: true,
                          elevation: 5,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Container(
                            width: 120,
                            height: 100.0,
                            child: Stack(
                              children: <Widget>[
                                Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(filter_personel[index].reportUrl)
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                    )
                                ),
                              ],
                            ),
                          ))
                      ,
                          Expanded(child: Container(
                            margin: EdgeInsets.only(left:10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Text(filter_personel[index].reportName.trimLeft(), maxLines: 3, style: TextStyle(color: Color(0xff5D5D5D), fontWeight: FontWeight.w600, fontSize: 15),),
                                Text(config.Config.get_duration(filter_personel[index].createdTime), style: TextStyle(fontSize: 12, color: Color(0xff5D5D5D)),),
                                SizedBox(height: 10,),
                                Text(filter_personel[index].userName, style:
                                TextStyle(color: Color(0xff5D5D5D), fontSize: 13)),
                                Text(filter_personel[index].remarks, maxLines: 1, style:
                                TextStyle(color: Color(0xff5D5D5D), fontSize: 13)),

//                                filter_personel[index].userExperience == '' ||filter_personel[index].userExperience == null
//                                    ? Container(): Text(filter_personel[index].userExperience+"years of experience", style: TextStyle(color: Color(0xff5D5D5D), fontSize: 13),),
                               // Text(filter_personel[index].userAddress, maxLines:2, style: TextStyle(color: Color(0xff5D5D5D), fontSize: 13),),


                              ],
                            ),
                          )),

                          getMenuPopup(index),

                    /*      Container(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                iconEnabledColor: Colors.black,
                                icon: Icon(Icons.more_horiz),
                                elevation: 8,
                                items: _data.keys.map((
                                    String value) {
                                  return new DropdownMenuItem<
                                      String>(
                                    value: value,
                                    child: new Text(value, style: TextStyle(fontSize: 12),),
                                  );
                                }).toList(),
                                onChanged: (text) {
                                  print(text);
                                  if(text == 'Share'){
                                    Share.share(personel_[index].reportUrl);
                                  }else if(text == 'Add Notes'){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context,) =>
                                          AddComments(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),*/
                        ],
                      ),
                    ),
                  ),
                 index == filter_personel.length-1? Container(margin: EdgeInsets.only(bottom: 15)): Container(height: 0.3,color: Colors.grey,margin: EdgeInsets.only(top:12, bottom: 12),)
                ],
              ),
            );
          }, itemCount: filter_personel.length,)),
          user_type == 'Doctor'?InkWell(
            onTap: (){
              gotoCreatePrescription();
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 50, color: Color(Config.getColorHexFromStr('#f8f8f8')),child: Container(
              alignment: Alignment.center,
              child: Text(
                'Create Prescription',
                style: TextStyle(
                  color: Color(0xff01d35a),
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                  decoration:
                  TextDecoration.underline,
                ),
              ))
          ),): Container()

        ],
      ),
    );

    final business = Container(
      child: Column(
        children: <Widget>[

//          Container(
//            height: 50,
//            margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
//            alignment: Alignment.center,
//            child: Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Row(
//                children: <Widget>[
//
//                  Expanded(
//                    child: TextField(
//                      decoration: InputDecoration.collapsed(hintText: "Search"),
//                      onChanged: (text){
//                        setState(() {
//                          if(text.length > 0){
//                            cross = false;
//                          }else{
//                            cross = true;
//                          }
//                        });
//                      },
//                    ),
//                  ),
//
//                  Padding(
//                    padding: const EdgeInsets.only(right:8.0),
//                    child: Icon(Icons.search),
//                  ),
//
//                ],
//              ),
//            ),
//            decoration: BoxDecoration(border: Border.all(width: 1, color: Color(0xff01d35a)),
//                borderRadius: BorderRadius.all(Radius.circular(10))),
//          ),


          Expanded(child: business_.length == 0? Center(
            child: Text("No Results"),
          ):ListView.builder(itemBuilder: (context, index){
            return Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              color: Color(0xffF9F9F9),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top:8.0,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        InkWell(
                          child: Container(height:100,
                            child: Image.network(business_[index].reportUrl),
                            width: 120,),
                          onTap: () {
//
//                            showDialog(
//                              context: context,
//                              builder: (BuildContext context,) =>
//                                  ShowImageDetails(
//                                    data: business_,
//
//                                  ),
//                            );

                          },
                        ),

                        Expanded(child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(business_[index].remarks, style: TextStyle(color: Color(0xff5D5D5D)),),
                              Text("Dec 12 10:30 AM", style: TextStyle(fontSize: 12, color: Color(0xff5D5D5D)),),
                              SizedBox(height: 5,),
                              Text("asdfsd", style: TextStyle(color: Color(0xff5D5D5D), fontSize: 13),),
                              Text("asdfsd", style: TextStyle(color: Color(0xff5D5D5D), fontSize: 13),),
                              Text("asdfsd", style: TextStyle(color: Color(0xff5D5D5D), fontSize: 13),),
                              Text("asdfsd", style: TextStyle(color: Color(0xff5D5D5D), fontSize: 13),),
                            ],
                          ),
                        )),

                        Container(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              iconEnabledColor: Colors.black,
                              icon: Icon(Icons.more_horiz),
                              elevation: 8,
                              items: _data.keys.map((
                                  String value) {
                                return new DropdownMenuItem<
                                    String>(
                                  value: value,
                                  child: new Text(value, style: TextStyle(fontSize: 12),),
                                );
                              }).toList(),
                              onChanged: (text) {
                                if(text == 'Share'){
                                  Share.share(personel_[index].reportUrl);
                                }else if(text == 'Add Notes'){
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context,) =>
                                        AddComments(),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 0.3,color: Colors.grey,margin: EdgeInsets.only(top:20, bottom: 20),)
                ],
              ),
            );
          }, itemCount: business_.length,), )

        ],
      ),
    );

    final options_tabs = Container(
        child: DefaultTabController(
          length: 2,
          // initialIndex: screen,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only( bottom: 10),
                constraints: BoxConstraints.expand(height: 30),
                child: TabBar(
                  tabs: [

                    Tab(
                        text: "Personal"
                    ),
                    Tab(
                      text: "Business",
                    ),

                  ],
                  labelStyle:
                  TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff262626)),
                  indicatorColor: Color(0xff01d35a),
                  unselectedLabelColor: Color(0xff808080),
                  labelColor: Colors.black,
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500,fontSize: 14, ),
                ),
              ),
              Expanded(
                child: Container(
                  child: TabBarView(
                    children: [
                      personel,
                      business,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));


    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: personel,
    );
  }

  void gotoCreatePrescription() {
    if(isPrescriptionCreated){
      Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePrescription(from: 'PLOCKR',patientId: '')));
    }else{
      showDialog(context: context, barrierDismissible: true, builder: (BuildContext context) => _showAlertPopup(context, 'Kindly Create your Template from the website to send Prescription directly.'));
    }
  }
  Widget _showAlertPopup(BuildContext context, String text) {
    return new CupertinoAlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                      "",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    )),
                Align(
                  alignment : FractionalOffset.topRight,
                  child:  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Icon(Icons.clear, color:  Color(config.Config.getColorHexFromStr('#585858')),),
                      alignment: Alignment.topRight,
                    ),
                  ),),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 20),
              child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, wordSpacing: 1.2)),
            )
          ],
        ),
      ),
    );
  }

  showMenuSelection(String value, int index) {
    if (value == 'Delete') {
      selectedReportPosition = index;
      confirmationDialog(context, 'Do you want to delete this report?',index);
    } else if (value == "Share") {
      Share.share(personel_[index].reportUrl);
    }
  }
  Widget getMenuPopup(int index) {
    return Container(
      child: PopupMenuButton<String>(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 5, bottom: 10),
          child: Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
        ),
        padding: EdgeInsets.zero,
        onSelected: (value) {
          showMenuSelection(value, index);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Delete',
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                ),
                Text('Delete')
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Share',
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Icon(
                    Icons.share,
                    color: Colors.grey,
                  ),
                ),
                Text('Share')
              ],
            ),
          ),
        ],
      ),
    );
  }

  confirmationDialog(BuildContext context, String action, int index) {
    return showGeneralDialog<bool>(
        barrierColor: Colors.black.withOpacity(0.3),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Container(
                    margin: EdgeInsets.fromLTRB(25, 10, 10, 0),
                    child: Text(action)),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(
                      "No",
                      style: TextStyle(color: Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false); // showDialog() returns false
                    },
                  ),
                  new FlatButton(
                    child: new Text(
                      "Yes",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      deleteReportWebService(index);

                    },
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  void deleteReportWebService(int index) async {
    SendPrescription result  = await deleteReport(personel_[index].id, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
    });

    if(result.success){
      setState(() {
        filter_personel.removeAt(selectedReportPosition);
      });
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (
            BuildContext context,
            ) =>
            _popup_saved(context),
      );
    }else{
      config.Config.showLongToast("Something went wrong!");
    }
  }
  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Your report has been successfully deleted.'),
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

class AddUserProcedure extends StatefulWidget {
  final String image_url;

  AddUserProcedure({Key key, this.image_url}) : super(key: key);
  @override
  _AddUserProcedureState createState() => _AddUserProcedureState(image_url);
}

class _AddUserProcedureState extends State<AddUserProcedure> {
  final String image_url;
  _AddUserProcedureState(this.image_url);

  bool progress = false;
  String user_token = "";
  String user_id = "";
  String _specialist = "";
  List<PopupMenuItem<String>> _dropDownMenuItems;
  List _specialists = new List();

  TextEditingController notes_ = new TextEditingController();
  TextEditingController report_name = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
  }



  List<PopupMenuItem<String>> getDropDownMenuItems() {
    List<PopupMenuItem<String>> items = new List();

    for (String user in _specialists) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new PopupMenuItem(value: user, child: new Text(user)));
    }
    return items;
  }


  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {
      user_token = token;
      user_id = uid;
    });

    _specialists.addAll(config.Config.specialist_lists);
    _dropDownMenuItems = getDropDownMenuItems();
    _specialist = _dropDownMenuItems[0].value;

  }



  post_reports() async{
    setState(() {
      progress = true;
    });

    String speciality_id = "";
    for(int i = 0; i< config.Config.specialist_lists.length; i++){
      int pos = config.Config.specialist_lists.indexOf(_specialist);
      speciality_id = config.Config.specialist_id[pos];
    }

    var body = {
      "reportUrl": image_url,
      "userId": user_id,
      "remarks":notes_.text,
      "specialityId":speciality_id,
      "self": true,
      "reportName": report_name.text
    };

    SendPrescription sendPrescription = await send_prescription(body, user_token).catchError((error){
      Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;
      if(sendPrescription.success){
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext context,
              ) =>
              _popup_saved(context),
        );
      }else{
        Config.showLongToast(sendPrescription.message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Container(child: InkWell(child: Image.network(image_url, fit: BoxFit.cover,),
              onTap: (){
                showDialog(
                  context: context,
                  builder: (BuildContext context,) =>
                      ProfileImage(
                        image_url: image_url,
                        text: " ",
                      ),
                );
              },),
                height: 200,width: double.infinity,),

                Container(
                  margin: EdgeInsets.only(top:10),
                  child: Text("Choose Speciality"),
                ),

              Container(
                margin: EdgeInsets.only(top:10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(width: 1, color: Color(0xff01d35a))),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: PopupMenuButton(
                    initialValue: _specialist,
                    padding: EdgeInsets.only(left: 10, right: 5, bottom: 10),
                    child: Container(
                      padding: EdgeInsets.only(left: 5, right: 10),
                      child: Text(_specialist,textAlign: TextAlign.start, style: TextStyle(color: Colors.black, fontSize: 15),),
                    ),
                    onSelected: (value) {
                      setState(() {
                        _specialist = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => _dropDownMenuItems,
                  )

                ),
              ),
              SizedBox(
                height: 20,
              ),

              TextField(
                autofocus: true,
                maxLines: 1,
                style: TextStyle(fontSize: 14),
                controller: report_name,
                decoration: InputDecoration(
                    hintText: "Report Name",
                    border:OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.grey))),
              ),

              SizedBox(
                height: 20,
              ),

              TextField(
                autofocus: true,
                maxLines: 4,
                maxLength: 250,
                style: TextStyle(fontSize: 14),
                controller: notes_,
                decoration: InputDecoration(
                    hintText: "Add Notes",
                    border:OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.grey))),
              ),

              SizedBox(
                height: 20,
              ),

              progress? SpinKitThreeBounce(
                color: Color(0xff01d35a),
                size: 30.0,
                // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
              ):  Row(
                children: <Widget>[

                  Container(
                    height: 40,
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.all
                      (Radius.circular(15)), color: Color(0xff01d35a),),
                    child:  FlatButton(
                        onPressed:  post_reports,
                        child: Text("Submit", style: TextStyle(color: Colors.white),)),
                  ),

                  Expanded(
                    child: Container(),
                  ),

                  Container(
                    height: 40,
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.all
                      (Radius.circular(15)), color: Colors.transparent,),
                       child:  FlatButton(
                        onPressed:  (){
                          Navigator.pop(context);
                        },
                        child: Text("Skip", style: TextStyle(color: Colors.white),)),
                  ),


                ],
              ),




            ],
          ),
        ),
      ),
    );
  }
  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Submitted..'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(screen: "plocker"),
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



class AddComments extends StatefulWidget {
  @override
  _AddCommentsState createState() => _AddCommentsState();
}

class _AddCommentsState extends State<AddComments> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            TextField(
              autofocus: true,
              maxLines: 4,
              maxLength: 250,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  hintText: "Add Notes",
                  border:OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.grey))),
            ),

            SizedBox(height: 10,),

            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
                child: Text("Save", style: TextStyle(fontSize: 16, color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class ShowImageDetails extends StatefulWidget {

  final  List<PersonalReports> data;
  final int position;
  ShowImageDetails({Key key, this.data, this.position}) : super(key: key);

  @override
  _ShowImageDetailsState createState() => _ShowImageDetailsState(data, position);
}

class _ShowImageDetailsState extends State<ShowImageDetails> {

  final  List<PersonalReports> data;
  final int position;
  _ShowImageDetailsState(this.data, this.position);

  final Map<String, IconData> _data = Map.fromIterables(['Share'], [Icons.filter_1]);


  //// Other Details

  bool reasons = false;
  bool consumption = false;
  bool avoid = false;
  bool precaution = false;
  bool medicine = false;
  bool remarks = false;
  bool test = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: Container(

                  )),

                  Container(
                    child: GestureDetector(child: Container(child: Icon(Icons.clear),
                      alignment: Alignment.topRight,),
                      onTap: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 20,
            ),

            InkWell(
              onTap: (){
                if(!data[position].reportUrl.contains(".pdf")){
                  showDialog(
                    context: context,
                    builder: (BuildContext context,) =>
                        ProfileImage(
                          image_url: data[position].reportUrl,
                          text: " ",
                        ),
                  );
                }
              },
              child: data[position].reportUrl.contains(".pdf")? InkWell(
                child: Container(
                  width: double.infinity,
                  height: 250.0,
                  decoration: BoxDecoration(
                    color: Colors.grey
                  ),
                  child:  Stack(
                    children: <Widget>[
                      Stack(children: <Widget>[
                        Center(child: Image.asset('assets/images/plockr/pdf.png', width: 180,height: 160,)),
                        Center(child: Container(
                          width: double.infinity,

                          color: Colors.grey,
                          child: Container(
                              width: double.infinity,
                              height: 250.0,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(data[position].reportUrl+ '.thumbnail.png')
                                  )
                              )
                          )

//                          FadeInImage(image: NetworkImage(data[position].reportUrl+ '.thumbnail.png'), placeholder: AssetImage('assets/images/plockr/pdf.png'))
                          ,),),
                      ],),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                            color: Color(0xff60000000)
                        ),
                      ),
                      Center(child: Text("Tap to view file", style: TextStyle(color: Colors.white, fontSize: 20)))
                    ],
                  ),
                  alignment: Alignment.center,
                ),
                onTap: ()async{
                    String url = data[position].reportUrl;

                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                },
              ): data[position].reportUrl.contains(".doc")? InkWell(
                child: Container(
                  width: double.infinity,
                  height: 250.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.grey
                  ),
                  child: Text("Tap to view file", style: TextStyle(color: Colors.white, fontSize: 20)),
                  alignment: Alignment.center,
                ),
                onTap: ()async{
                  String url = data[position].reportUrl;

                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ): data[position].reportUrl.contains(".docx")? InkWell(
                child: Container(
                  width: double.infinity,
                  height: 250.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Colors.grey
                  ),
                  child: Text("Tap to view file", style: TextStyle(color: Colors.white, fontSize: 20)),
                  alignment: Alignment.center,
                ),
                onTap: ()async{
                  String url = data[position].reportUrl;

                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }


                },
              ):Container(
                width: double.infinity,
                height: 250.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(data[position].reportUrl)
                  ),
                ),
                child:  Stack(
                  children: <Widget>[
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: Color(0xff90000000)
                      ),
                    ),
                    Center(child: Text("Tap to view file", style: TextStyle(color: Colors.white, fontSize: 20)))
                  ],
                ),
                alignment: Alignment.center,
              )

            ),

            Container(
              margin: EdgeInsets.only(top:10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(data[position].reportName.trimLeft(), textAlign: TextAlign.left, style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),),
                  Text(config.Config.get_duration(data[position].createdTime), style: TextStyle(fontSize: 12),),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20,),
                      Text("Report Created By:", style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 5,),
                      Text(data[position].userName, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),),

                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20,),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 0.3,color: Colors.grey,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        reasons = !reasons;
                      });
                    },
                    child: Container(child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Diagnosis", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500),),
                        ),
                      reasons? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                    height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),

                  Visibility(child: Text(data[position].reasonDiagnosis), visible: reasons,),
                  SizedBox(height: 15,),
                  Container(height: 0.3,color: Colors.grey,),
                ],
              ),
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 0.3,color: Colors.grey,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        medicine = !medicine;
                      });
                    },
                    child: Container(child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Medicine", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500),),
                        ),
                        medicine? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),

                  Visibility(child: Text(data[position].medicines), visible: medicine,),
                  SizedBox(height: 15,),
                  Container(height: 0.3,color: Colors.grey,),

                ],
              ),
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 0.3,color: Colors.grey,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        test = !test;
                      });
                    },
                    child: Container(child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Test", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500),),
                        ),

                        test? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),

                  Visibility(child: Text(data[position].test), visible: test,),
                  SizedBox(height: 15,),
                  Container(height: 0.3,color: Colors.grey,),
                ],
              ),
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 0.3,color: Colors.grey,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        consumption = !consumption;
                      });
                    },
                    child: Container(child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Consumption (Diet)", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500),),
                        ),

                        consumption? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),

                  Visibility(child: Text(data[position].consumptionDiet), visible: consumption),
                  SizedBox(height: 15,),
                  Container(height: 0.3,color: Colors.grey,),
                ],
              ),
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 0.3,color: Colors.grey,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        avoid = !avoid;
                      });
                    },
                    child: Container(child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Avoid (Diet)", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500),),
                        ),

                          avoid? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down)
                        ],
                      ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),

                  Visibility(child: Text(data[position].avoidDiet), visible: avoid,),
                  SizedBox(height: 15,),
                  Container(height: 0.3,color: Colors.grey,),
                ],
              ),
            ),

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 0.3,color: Colors.grey,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        precaution = !precaution;
                      });
                    },
                    child: Container(child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Precautions", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500),),
                        ),

                        precaution? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),

                  Visibility(child: Text(data[position].precautions), visible: precaution,),
                  SizedBox(height: 15,),
                  Container(height: 0.3,color: Colors.grey,),
                ],
              ),
            ),




            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(height: 0.3,color: Colors.grey,),
                  InkWell(
                    onTap: (){
                      setState(() {
                        remarks = !remarks;
                      });
                    },
                    child: Container(child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("Remarks", style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w500),),
                        ),

                        remarks? Icon(Icons.keyboard_arrow_up): Icon(Icons.keyboard_arrow_down)
                      ],
                    ),
                      height: 50,
                      alignment: Alignment.centerLeft,
                    ),
                  ),

                  Visibility(child: Text(data[position].remarks), visible: remarks,),
                  SizedBox(height: 15,),
                  Container(height: 0.3,color: Colors.grey,),
                ],
              ),
            ),

            SizedBox(height: 20,)

          ],
        ),
      ),
    );
  }
}

