import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/update_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class ChangePassword extends StatefulWidget {
  static const tag = '/change_password';
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController old_password_ = TextEditingController();
  bool password_valid_old  = true;
  bool _passwordVisible_old = true;

  TextEditingController new_password_ = TextEditingController();
  bool password_valid_new = true;
  bool _passwordVisible_new = true;

  bool progress = false;
  String user_id = "";
  String user_toke = "";
  String user_phone = "";


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
    String phone = prefs.getString("phoneno");


    setState(() {
      user_id = uid;
      user_toke = token;
      user_phone = phone;
    });

  }

    void change_password() async{
      if(old_password_.text != '' && new_password_.text != '' &&
      password_valid_old && password_valid_new){

        setState(() {
          progress = true;
        });

        var body = {
          "password":new_password_.text,
          "mobileNumber":user_phone.trim()
        };

        PostPassword updatePassword = await update_password(body).catchError((error){
          config.Config.showLongToast("Something went wrong!");
          setState(() {
            progress = false;
          });
        });


        setState(() {
          progress = false;
          if(updatePassword.success){
            config.Config.showInSnackBar(_scaffoldKey, "Successfully changed", Color(0xff01d35a));

          }else{
            config.Config.showInSnackBar(_scaffoldKey, updatePassword.message, Colors.red);
          }
        });

      }else{
        config.Config.showInSnackBar(_scaffoldKey, "Invalid entry, Please Try Again!", Colors.red);
      }
    }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;


    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("Change Password", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );

    final old_password = Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: TextField(
        controller: old_password_,
        obscureText:_passwordVisible_old,
        onChanged: (text){

          setState(() {

            if(text.length < 8){
              password_valid_old = false;
            }else{
              password_valid_old = true;
            }

          });


        },

        decoration: InputDecoration(labelText: 'Old Password',
            prefixIcon: Icon(Icons.lock_outline, color: password_valid_old? Color(0xff01d35a): Colors.red,),
            suffixIcon: GestureDetector(

              onTap: (){
                setState(() {
                  _passwordVisible_old = !_passwordVisible_old;
                });
              },

              child:_passwordVisible_old? Icon(Icons.visibility_off,): Icon(Icons.visibility, ),
            ),
            errorText: password_valid_old ?null: "Please enter atleast 8 character password"
        ),
      ),
    );

    final new_password = Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: TextField(
        controller: new_password_,
        obscureText:_passwordVisible_new,
        onChanged: (text){

          setState(() {
            if(text.length < 8){
              password_valid_new = false;
            }else{
              password_valid_new = true;
            }
          });
        },
        decoration: InputDecoration(labelText: 'New Password',
            prefixIcon: Icon(Icons.lock_outline, color: password_valid_new? Color(0xff01d35a): Colors.red,),
            suffixIcon: GestureDetector(

              onTap: (){
                setState(() {
                  _passwordVisible_new = !_passwordVisible_new;
                });
              },

              child:_passwordVisible_new? Icon(Icons.visibility_off,): Icon(Icons.visibility, ),
            ),
            errorText: password_valid_new ?null: "Please enter atleast 8 character password"
        ),
      ),
    );


    final submit_btn =  Padding(
      padding: const EdgeInsets.only(left:50.0, right: 50.0, top: 30),
      child:progress?SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ): ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: RaisedButton(
          onPressed: change_password,
          color: Color(0xff01d35a) ,
          child:  Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Submit", style: TextStyle(color: Colors.white)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );


    final form = Container(
      margin: EdgeInsets.all(20),

      child: Column(
        children: <Widget>[

          old_password,
          new_password,
          submit_btn,

        ],
      ),
    );


    return Scaffold(
      key: _scaffoldKey,
        appBar: app_bar,
        backgroundColor: Colors.white,
        body: form
    );
  }
}
