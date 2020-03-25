import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/check_user.dart';
import 'package:plunes/model/send_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart';
import 'ValidateOTP.dart';
import 'NewPassword.dart';

class ForgetPassword extends StatefulWidget {

  static const tag = '/forget_password';

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController phone_no_ = TextEditingController();
  bool phone_valid= true;
  bool progress = false;
  bool show_error = false;

  String numberValidator(String value) {
    if(value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if(n == null) {

      return '"$value" is not a valid number';
    }
    return null;
  }


  void send_otp() async {

      int phone_length = phone_no_.text.length;
      setState(() {
        show_error = false;

        if (phone_no_.text != '' && phone_length == 10) {
          phone_valid = true;
        } else {
          phone_valid = false;
        }
      });
      var rng = new Random();
      var code = rng.nextInt(9000) + 1000;
      print(code);
      config.Config.otp_code = code.toString();

      String url = "https://control.msg91.com/api/sendotp.php" + "?authkey=" +
          config.Config.otp_auth_key + "&mobile=91" + phone_no_.text.trim()+"&sender="+
          config.Config.sender_id+"&otp="+code.toString();

      if (phone_valid) {

        setState(() {
          show_error = false;
          progress = true;
        });

        CheckPost checkPost = await check_user(phone_no_.text.trim()).catchError((error){
          config.Config.showLongToast("Something went wrong!");
          progress = false;
          show_error = false;
        });

        if(checkPost.success){
          SendOtpPost p = await sendotp(url);
          print("data getting ## =====" + p.type);
          setState(() {
            progress = false;
            if (p.type == 'success' && phone_valid) {
              print("success");

              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ValidateOTP(phone: phone_no_.text,),
                  ));

            }
          });
        }else{

          setState(() {
            progress = false;
            show_error = true;
          });
        }

      }

  }



  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Forgot Password",
        style: TextStyle(color: Colors.black),
      ),
    );


    final phone = TextFormField(
      controller: phone_no_,
      autofocus: true,
      onChanged: (text){

        setState(() {

          if(text.length == 10){
            phone_valid = true;
          }else{
            phone_valid = false;
          }
        });
      },
      //autofocus: true,
      keyboardType: TextInputType.phone,
      validator: numberValidator,
      decoration: InputDecoration(labelText: 'Phone No',
          errorText: phone_valid ?null: "Please enter valid phone number"),
    );


    final send_btn =    progress
        ? SpinKitThreeBounce(
      color: Color(0xff01d35a),
      size: 30.0,
      // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
    )
        :Container(
      width: 150,
      child: FlatButton(
        onPressed: send_otp,
        color: Color(0xff01d35a),
        child:  Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("Send OTP", style: TextStyle(color: Colors.white)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );


    final phone_field =  Container(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(height: 80 ,child: Center(child: Text("(+91)", style: TextStyle(color: Colors.black, fontSize: 16, ),)), margin: EdgeInsets.only(bottom:3),),

          Container(height: 80 ,child: phone, width: 200,margin: EdgeInsets.only(left:5),),
        ],
      ),
    );

    final form = Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[

            SizedBox(height: 50,),
            Center(child: Text("Verify your phone number", style: TextStyle(color: Colors.black, fontSize: 18),)),
            SizedBox(height: 10,),
            Center(child: Text("We will send you one time SMS message", style: TextStyle(color: Colors.grey, fontSize: 12),)),
            SizedBox(height: 10,),
            phone_field,
            send_btn,
            Visibility(visible: show_error,child: Center(child: Text("This number isn't registered!", style: TextStyle(color: Colors.red),),),)

          ],

        ),

      ),

    );



    return Scaffold(
      appBar: app_bar,
      backgroundColor: Colors.white,
      body: form,
    );
  }
}
