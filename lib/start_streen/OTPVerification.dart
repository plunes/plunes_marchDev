import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/model/check_user.dart';
import 'package:plunes/model/send_otp.dart';
import 'package:plunes/start_streen/forgot/Foget_password.dart';
import 'package:plunes/start_streen/Registration.dart';
import 'dart:async';
import 'dart:convert';
import '../config.dart';
import 'package:plunes/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'CheckOTP.dart';

class OTPVerification extends StatefulWidget {
  static const tag = '/otpverification';

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  TextEditingController phone_no_ = TextEditingController();
  bool phone_valid = true;
  bool progress = false;
  bool show_error = false;

  String numberValidator(String value) {
    if (value == null) {
      return null;
    }
    final n = num.tryParse(value);
    if (n == null) {
      return '"$value" is not a valid number';
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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

    print("data=== " + phone_valid.toString());
    if (phone_valid) {
      if (config.Config.opt_verification) {
        setState(() {
          show_error = false;
          progress = true;
        });

        CheckPost checkPost = await check_user( phone_no_.text.trim()).catchError((error){
          config.Config.showLongToast("Something went wrong!");
        });

        var rng = new Random();
        var code = rng.nextInt(9000) + 1000;
        print(code);
        config.Config.otp_code = code.toString();

        if (!checkPost.success) {
          String url = "https://control.msg91.com/api/sendotp.php" +
              "?authkey=" +
              config.Config.otp_auth_key +
              "&mobile=91" +
              phone_no_.text.trim() +
              "&sender=" +
              config.Config.sender_id +
              "&otp=" +
              code.toString();

          SendOtpPost p = await sendotp(url);
          print("data getting ## =====" + p.type);

          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckOTP(phone: phone_no_.text),
              ));

          setState(() {
            progress = false;
            if (p.type == 'success' && phone_valid) {
              print(p.type + "done");
            }
          });
        } else {
          setState(() {
            progress = false;
            show_error = true;
          });
        }
      } else {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Registration(
                phone: phone_no_.text,
              ),
            ));
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
      title: Text(
        "OTP Verification",
        style: TextStyle(color: Colors.black),
      ),
    );

    final phone = TextFormField(
      controller: phone_no_,
      // autofocus: true,
      keyboardType: TextInputType.phone,
      validator: numberValidator,
      decoration: InputDecoration(
          labelText: 'Phone No',
          errorText: phone_valid ? null : "Please enter valid phone number"),
    );

    final form = Container(
      margin: EdgeInsets.only(bottom: 50),
      alignment: FractionalOffset.center,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
              child: Text(
            "Verify your phone number",
            style: TextStyle(color: Colors.black, fontSize: 18),
          )),
          SizedBox(
            height: 10,
          ),
          Center(
              child: Text(
            "We will send you one time SMS message",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          )),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 7),

//                  height: 80,
                  width: 80,
                  child: Column(children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child:  Center(
                          child: Text(
                            "+91",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          )),
                    ),
                    Container(
                      height: 2.0,
                      width: 50,
                      color: Colors.grey,
                    )
                  ],),
//                  margin: EdgeInsets.only(bottom: 3),
                ),
                Container(
                  height: 80,
                  child: phone,
                  width: 200,
                  margin: EdgeInsets.only(left: 5),
                ),
              ],
            ),
          ),
          progress
              ? SpinKitThreeBounce(
                  color: Color(0xff01d35a),
                  size: 30.0,
                  // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                )
              : Container(
                  width: 150,
                  child: FlatButton(
                    onPressed: send_otp,
                    color: Color(0xff01d35a),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Send OTP",
                          style: TextStyle(color: Colors.white)),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
          Visibility(
            visible: show_error,
            child: Center(
              child: Text(
                "This number already registered",
                style: TextStyle(color: Colors.red),
              ),
            ),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: app_bar,
      body: form,
    );
  }
}
