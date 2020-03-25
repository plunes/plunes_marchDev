import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/update_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plunes/start_streen/forgot/Foget_password.dart';


class NewPassword extends StatefulWidget {
  final String phone;
  NewPassword({Key key, this.phone}) : super(key: key);
  @override
  _NewPasswordState createState() => _NewPasswordState(phone);
}

class _NewPasswordState extends State<NewPassword> {

  String phone_no;
  bool err_msg = false;
  bool progress = false;

  _NewPasswordState(this. phone_no);

  bool password_valid1 = true;
  bool password_valid2 = true;
  bool error_msg = false;
  bool not_change = false;

  bool _passwordVisible1= true;
  bool _passwordVisible2 = true;


  TextEditingController password_1 = TextEditingController();
  TextEditingController password_2 = TextEditingController();

  void change_password() async{
    var match = {
      "password":password_2.text,
      "mobileNumber":phone_no.trim()
    };

    PostPassword updatePassword = await update_password(match).catchError((error){
      config.Config.showLongToast("Something went wrong!");
     setState(() {
       progress = false;
     });
    });

    setState(() {
      progress = false;
      if(updatePassword.success){
        err_msg = false;
        not_change = false;
        Navigator.pop(context);

      }else{

        not_change = true;
        err_msg = true;
      }

    });
  }


  void resetpassword(){

      setState(() {
        if(password_1.text != '' && password_1.text.length >=8){
          password_valid1= true;

          if(password_2.text != '' && password_2.text.length >=8){
            password_valid2 = true;


            if(password_1.text == password_2.text){
              progress = true;
              error_msg = false;
              not_change = false;
              change_password();


            }else{
              error_msg = true;
            }


          }else{
            password_valid2 = false;
          }

        }else{
          password_valid1= false;

        }
      });

  }




  @override
  Widget build(BuildContext context) {

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "Reset Password",
        style: TextStyle(color: Colors.black),
      ),
    );

    final reset_pass =  Padding(
      padding: const EdgeInsets.only(left:50.0, right: 50.0, top: 30),
      child: progress?  SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ):  ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: RaisedButton(
          onPressed: resetpassword,
          color: Color(0xff01d35a),
          child:  Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Reset Password", style: TextStyle(color: Colors.white)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );


    final form = Container(

      margin: EdgeInsets.all(20),
      child: ListView(
        children: <Widget>[

          Center(child: Text("Enter your password here to protect your account", style: TextStyle(color: Colors.grey),)),
          SizedBox(
            height: 20,
          ),

          Container(
            margin: EdgeInsets.only(
              left: 38,
              right: 38,
            ),

            child: TextFormField(
              controller: password_1,
              autofocus: true,
              onChanged: (text){

                setState(() {
                  if(text.length>= 8){
                    password_valid1 = true;
                  }else{
                    password_valid1 = false;
                  }
                });
              },
              obscureText:_passwordVisible1,
              decoration: InputDecoration(labelText: 'Enter Password',
                  suffixIcon: GestureDetector(

                    onTap: (){
                      setState(() {
                        _passwordVisible1 = !_passwordVisible1;
                      });
                    },
                    child:_passwordVisible1? Icon(Icons.visibility_off): Icon(Icons.visibility),
                  ),
                  errorText: password_valid1 ?null: "Please enter atleast 8 character password"
              ),
            ),
          ),


          Container(
            margin: EdgeInsets.only(
              left: 38,
              right: 38,
            ),
            child: TextFormField(
              onChanged: (text){

             setState(() {
               if(text.length>= 8){
                 password_valid2 = true;
               }else{
                 password_valid2 = false;
               }
             });

              },
              controller: password_2,
              obscureText:_passwordVisible2,
              decoration: InputDecoration(labelText: 'Confirm Password',
                  suffixIcon: GestureDetector(
                    child:_passwordVisible2? Icon(Icons.visibility_off): Icon(Icons.visibility),
                    onTap: (){
                      setState(() {
                        _passwordVisible2 = !_passwordVisible2;
                      });
                    },
                  ),
                  errorText: password_valid2 ?null: "Please enter atleast 8 character password"
              ),
            ),
          ),

          SizedBox(
            height: 20,
          ),

          Visibility(visible:error_msg,child: Center(child: Text("Password is not equal", style: TextStyle(color: Colors.red, fontSize: 12),))),
          reset_pass


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
