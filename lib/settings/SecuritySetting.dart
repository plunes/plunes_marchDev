import 'package:flutter/material.dart';
import 'package:plunes/model/profile/logout.dart';
import 'package:plunes/model/profile/logout_all.dart';
import 'package:plunes/start_streen/Allevents.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'ChangePassword.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;

class SecuritySetting extends StatefulWidget {
  static const tag = '/securitysetting';

  @override
  _SecuritySettingState createState() => _SecuritySettingState();
}

class _SecuritySettingState extends State<SecuritySetting> {

  bool progress= false;
  String user_id ="";
  String user_token = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getshareference();

  }

  void getshareference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {

      user_id = uid;
      user_token = token;

    });

  }
  void logout() async {
    setState(() {
      progress = true;
    });

    LogoutAllPost logoutAllPost = await logout_all_api(user_id, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");

      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;

      if (logoutAllPost.success){
        _logout();
      }
      else{
        config.Config.showInSnackBar(_scaffoldKey, logoutAllPost.message, Colors.red);
      }

    });
  }


  void _logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("home");
    preferences.remove("guide_tour");


    preferences.remove("token");
    preferences.remove("uid");

    preferences.remove("name");
    preferences.remove("email");
    preferences.remove("phoneno");

    preferences.remove("user_type");
    preferences.remove("user_location");
    preferences.remove("specialist");

    preferences.remove("imageUrl");
    preferences.remove("coverUrl");

    Navigator.popAndPushNamed(context, Allevents.tag);
  }


  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("Security Settings", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );

    final form  = Column(

      children: <Widget>[
        InkWell(
          onTap: (){

            Navigator.pushNamed(context, ChangePassword.tag);
          },
          child: Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:   Image.asset('assets/change_pass.png', height: 25, width: 25,),
                ),

                Expanded(child: Text("Change Password")),
                Icon(Icons.keyboard_arrow_right, color: Colors.black,)


              ],
            ),
          ),
        ),


        Container(
          color: Colors.grey,
          height: 0.5,
        ),


        InkWell(
          onTap: logout,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset('assets/logout2.png', height: 25, width: 25,),
                ),
                Expanded(child: Text("Logout from all devices")),
                Icon(Icons.keyboard_arrow_right, color: Colors.black,)
              ],
            ),
          ),
        ),

        Container(
          color: Colors.grey,
          height: 0.5,
        ),

      ],
    );
    return ModalProgressHUD(
      color: Colors.black,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Colors.white,
      ),

      inAsyncCall: progress,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: app_bar,
          backgroundColor: Colors.white,
          body: form
      ),
    );
  }
}
