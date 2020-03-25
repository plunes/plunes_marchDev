import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/image_upload.dart';
import 'package:plunes/model/profile/achievments/post_achievments.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';


class AchievemntsScreen extends StatefulWidget {
  static const tag = '/achievemntsscreen';

  @override
  _AchievemntsScreenState createState() => _AchievemntsScreenState();
}

class _AchievemntsScreenState extends State<AchievemntsScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  TextEditingController _textcontroller = TextEditingController();
  TextEditingController _shareimage = TextEditingController();
  static String base_assets = 'assets/images/achievments/gradient/';

  String set_image = base_assets+"11.jpg";
  bool upload_ = true;
  bool progress = false;

  String user_token ="";
  String user_id = "";
  int counter = 0;

  String img = config.Config.default_achiev+'11.jpg';
  File images;
  String image_url = "";

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    print("user toke = "+token);

    setState(() {
      user_token = token;
      user_id = uid;

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
          image_url = imgUploadPost.url;
          upload_ = false;
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
          image_url = imgUploadPost.url;
          upload_ = false;
        }else{
          config.Config.showInSnackBar(_scaffoldKey, imgUploadPost.message, Colors.red);
        }
      });
    }
  }

  void post() async{

    setState(() {
      progress = true;
    });

    var achievement;

      if(!upload_){
        achievement = {
          "title": _shareimage.text,
          "imageUrl": config.Config.base_url+image_url
        };

      }else{
        achievement = {
          "title": _textcontroller.text,
          "imageUrl": img
        };
      }

      var body = {
        "achievement":achievement
      };


      print(body);


    PostAchievments postAchievments =  await post_achievments(body, user_token).catchError((error){
        config.Config.showLongToast("Something went wrong!");
        setState(() {
          progress = false;
        });
      });

      setState(() {
        progress = false;
        if(postAchievments.success){

          _textcontroller.text = "";
          _shareimage.text = "";

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (
                BuildContext context,
                ) =>
                _popup_saved(context),
          );

        }else{
          config.Config.showInSnackBar(_scaffoldKey, postAchievments.message, Colors.red);
        }
      });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
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
    Config.globalContext = context;
    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "Achievement",
        style: TextStyle(color: Colors.black),
      ),
    );


    final post_view =  Container(
        child:  Stack(
          alignment: Alignment.center,
          children: <Widget>[

            Container(
                child: Image.asset(set_image, fit: BoxFit.fitWidth,)
            ),


            Align(
              child: Container(
                height: 280,
                  alignment: Alignment.center,

                  padding: EdgeInsets.all(10),
                  child: TextField(
                    maxLines: null,
                    style: TextStyle(color: Colors.white, ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.multiline,
                  controller: _textcontroller,
                  onChanged: (text){
                      setState(() {
                        counter = text.length;
                      });
                    },
                    maxLength: 250,
                    maxLengthEnforced: true,
                  cursorColor: Colors.white,

                      buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                  decoration: InputDecoration.collapsed(

                      hintText: "Share your Achievement",
                      hintStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.normal, color: Color(0xfff0f0f0))),
                ),
              ),
            ),


          ],
        )


    );

    final image_view =  Container(
        child:  Stack(
          alignment: Alignment.center,
          children: <Widget>[

            Container(
              height: 300,
                width: double.infinity,
                child: Image.network(config.Config.base_url+image_url, fit: BoxFit.cover,)
            ),

            Container(
              height: 300,
              width: double.infinity,
              color: Color(0xff99000000),
            ),


            Align(
              child: Container(
                height: 280,
                alignment: Alignment.center,

                padding: EdgeInsets.all(10),
                child: TextField(
                  maxLines: null,
                  style: TextStyle(color: Colors.white, ),
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.multiline,
                  controller: _textcontroller,
                  onChanged: (text){
                    setState(() {
                      counter = text.length;
                    });
                  },
                  maxLength: 250,
                  maxLengthEnforced: true,
                  cursorColor: Colors.white,

                  buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                  decoration: InputDecoration.collapsed(

                      hintText: "Share your Achievement",
                      hintStyle: TextStyle(fontSize: 18, fontStyle: FontStyle.normal, color: Color(0xfff0f0f0))),
                ),
              ),
            ),


          ],
        )


    );



    final filter =  Container(
      color: Colors.white,
      height: 40,
      child: ListView(

        scrollDirection: Axis.horizontal,
        children: <Widget>[

          InkWell(
            onTap: (){
              setState(() {
                set_image = base_assets+'11.jpg';
                img = config.Config.default_achiev+'11.jpg';
              });
            },

            child: Container(
              margin: EdgeInsets.only( left:5,),
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/11.jpg',),
              ),

            ),
          ),
          SizedBox(width: 5,),


          InkWell(
            onTap: (){
              setState(() {
                set_image = base_assets+'1.jpg';
                img = config.Config.default_achiev+'1.jpg';


              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/1.jpg',),
              ),

            ),
          ),

          SizedBox(width: 5,),

          InkWell(
            onTap: (){
              setState(() {

                set_image = base_assets+'2.jpg';
                img = config.Config.default_achiev+'2.jpg';
              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/2.jpg',),
              ),

            ),
          ),

          SizedBox(width: 5,),
          InkWell(
            onTap: (){
              setState(() {

                set_image = base_assets+'3.jpg';
                img = config.Config.default_achiev+'3.jpg';
              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/3.jpg',),
              ),

            ),
          ),

          SizedBox(width: 5,),

          InkWell(
            onTap: (){
              setState(() {

                set_image = base_assets+'4.jpg';
                img = config.Config.default_achiev+'4.jpg';
              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/4.jpg',),
              ),

            ),
          ),

          SizedBox(width: 5,),


          InkWell(
            onTap: (){
              setState(() {

                set_image = base_assets+'5.jpg';
                img = config.Config.default_achiev+'5.jpg';
              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/5.jpg',),
              ),
            ),
          ),

          SizedBox(width: 5,),

          InkWell(
            onTap: (){
              setState(() {
                set_image = base_assets+'6.jpg';
                img = config.Config.default_achiev+'6.jpg';
              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/6.jpg',),
              ),

            ),
          ),

          SizedBox(width: 5,),

          InkWell(
            onTap: (){
              setState(() {
                set_image = base_assets+'8.jpg';
                img = config.Config.default_achiev+'8.jpg';
              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/8.jpg',),
              ),

            ),
          ),

          SizedBox(width: 5,),

          InkWell(
            onTap: (){
              setState(() {
                set_image = base_assets+'9.jpg';
                img = config.Config.default_achiev+'9.jpg';
              });
            },
            child: Container(
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/9.jpg',),
              ),

            ),
          ),

          SizedBox(width: 5,),

          InkWell(
            onTap: (){
              setState(() {
                set_image = base_assets+'10.jpg';
                img = config.Config.default_achiev+'10.jpg';
              });
            },

            child: Container(
              margin: EdgeInsets.only( right: 5),
              child:  CircleAvatar(
                backgroundImage:AssetImage('assets/images/achievments/gradient/10.jpg',),
              ),
            ),
          ),


        ],
      ),
    );


    final attach_photo = Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Color(0xff01d35a), width: 1)),

        alignment: Alignment.center,
        margin: EdgeInsets.only(left: 50, right: 50, top: 50),

        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: (){
            _settingModalBottomSheet(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[

                Icon(Icons.attach_file),
                Text("Attachment Photo"),

              ],
            ),
          ),
        )

    );



    final share_text  = Container(
      child:  Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: images == null
              ? Text('')
              :Column(

            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(color: Colors.white, alignment:Alignment.center,
                  child: Image.file(images, fit: BoxFit.fill,height: 200,)),
              Container(
                width: 300,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color:
                Color(0xff01d35a), width: 1)),
                margin: EdgeInsets.only(top:10),
                padding: EdgeInsets.all(10),
                child: TextField(
                  maxLines: null,
                  style: TextStyle(color: Colors.black),
                  controller: _shareimage,
                  decoration: InputDecoration.collapsed(
                      hintText: "Share your Achievments",
                      hintStyle:
                      TextStyle(fontSize: 18, fontStyle: FontStyle.normal, color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final share_btn = Container(
      child:progress?SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ): InkWell(
        onTap: counter == 0? null: post,
        child: Container(
          margin: EdgeInsets.only(top: 50 , left: 50, right: 50),
          height: 45,
          decoration: BoxDecoration(borderRadius:
          BorderRadius.circular(35),color:counter == 0? Colors.grey: Color(0xff01d35a)),
          alignment: Alignment.center,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Share", style: TextStyle(color: Colors.white),),
            ),
          ),
        ),
      ),
    );


    final share_btn_img = Container(
      child: progress?SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ): InkWell(
        onTap: post,
        child: Container(
          margin: EdgeInsets.only(top: 50 , left: 50, right: 50),
          height: 45,
          decoration: BoxDecoration(borderRadius:
          BorderRadius.circular(35),color: Color(0xff01d35a)),
          alignment: Alignment.center,
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Share", style: TextStyle(color: Colors.white),),
            ),
          ),
        ),
      ),

    );

    final form_img =  Container(

      child: ListView(
        children: <Widget>[

        image_view,
          share_text,
          share_btn_img,
          SizedBox(height: 20,)

        ],
      ),
    );



    final form_text =  Container(

      child: ListView(
        children: <Widget>[

          post_view,
          Container(margin:EdgeInsets.all(10),
              alignment: Alignment.topRight,child: Text(counter.toString()+"/250")),
          filter,
          attach_photo,
          share_btn,
          SizedBox(height: 20,)

        ],
      ),
    );



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: app_bar,
      key: _scaffoldKey,
      body: GestureDetector(onTap:(){
        FocusScope.of(context).requestFocus(new FocusNode());
      },child:upload_?  form_text: form_img),
    );
  }
}


Widget _popup_saved(BuildContext context) {
  return new CupertinoAlertDialog(
    title: new Text('Success'),
    content: new Text('Successfully Posted..'),
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
