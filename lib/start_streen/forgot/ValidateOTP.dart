import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/config.dart';
import 'package:plunes/model/send_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NewPassword.dart';
import 'package:quiver/async.dart';


class ValidateOTP extends StatefulWidget {
  static const tag = 'validateOTP';
  final String phone;
  ValidateOTP({Key key, this.phone}) : super(key: key);

  @override
  _ValidateOTPState createState() => _ValidateOTPState(phone);
}

class _ValidateOTPState extends State<ValidateOTP> {

  String phone_no;
  bool progress = false;
  bool error_msg= false;
  String error_message = "Wrong OTP Please try Again!";
  bool resend = false;
  bool time = true;
  _ValidateOTPState(this. phone_no);


  void send_otp() async {
    var rng = new Random();
    var code = rng.nextInt(9000) + 1000;
    print(code);
    config.Config.otp_code = code.toString();


    String url = "https://control.msg91.com/api/sendotp.php" + "?authkey=" +
        config.Config.otp_auth_key + "&mobile=91" + phone_no+"&sender="+
        config.Config.sender_id+"&otp="+code.toString();

    startTimer();
    SendOtpPost p = await sendotp(url);
    print("data getting ## =====" + p.type);
  }

  void _showSnackBar(String pin, BuildContext context)  async {
    setState(() {
      if (pin == config.Config.otp_code) {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NewPassword(phone: phone_no,),
            ));
      } else {
        error_msg = true;
      }
    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTimer();
  }


  int _start = 30;
  int _current = 30;
  CountdownTimer countDownTimer;
  void startTimer() {

     countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {

  setState(() {
    resend = false;
    time = true;
    _current = _start - duration.elapsed.inSeconds;

    if(_current == 0){

      resend = true;
      time = false;

    }
  });
    });

    sub.onDone(() {
      sub.cancel();
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    countDownTimer.cancel();
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
          "Check OTP",
          style: TextStyle(color: Colors.black),
        ),
      );

      final form = Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Enter your 4 digit code that",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "you received on your phone",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 40),
                child: Builder(
                  builder: (context) => Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Center(
                      child:  PinPut(
                        fieldsCount: 4,
                        autoFocus: true,
                        onSubmit: (String pin) => _showSnackBar(pin, context),
                        inputDecoration: InputDecoration(counterText: ""),
                        clearButtonIcon: Icon(Icons.clear, color: Colors.transparent),
                      ),
//                      ),
                    ),
                  ),
                ),
              ),

              Visibility(
                  visible: error_msg,
                  child: Center(
                      child: Text(
                        error_message,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ))),


              Visibility(
                visible: time,
                child: Container(
                  alignment: FractionalOffset.center,
//                margin: EdgeInsets.only(top: 100, left: 40),
                  child: Center(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Text("Resend code in ", style: TextStyle(fontSize: 16),),
                        ),
                        Container(
                          child: Text('0:$_current', style: TextStyle(color: Color(0xff01d35a), fontSize: 16),),
                          margin: EdgeInsets.only(right: 40),
                        ),
                      ],
                    ),
                  ),
                ),
              ),


              Visibility(
                visible: resend,
                child: Center(
                  child: Container(
//                  margin: EdgeInsets.only(top: 100),
                    alignment: FractionalOffset.center,
                    child: InkWell(
                      onTap: send_otp,
                      child: Text(" Resend code", style: TextStyle(color: Color(0xff01d35a),
                          fontWeight: FontWeight.w500, fontSize: 16),),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      return ModalProgressHUD(
          color: Colors.black,
          dismissible: false,
          progressIndicator: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
          inAsyncCall: progress,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: app_bar,
            body: form,
          ));
    }
}
