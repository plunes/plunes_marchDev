import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/appointment/Appointments.dart';
import 'package:plunes/solution/BiddingActivity.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/check_user.dart';
import 'package:plunes/model/send_otp.dart';
import 'package:plunes/start_streen/Allevents.dart';
import 'package:plunes/start_streen/CheckOTP.dart';
import 'package:plunes/start_streen/Registration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'CheckOTP.dart';
import 'HomeScreen.dart';

class EnterPhoneScreen extends StatefulWidget {
  static const tag = 'enter_phonescreen';
  @override
  _EnterPhoneScreenState createState() => _EnterPhoneScreenState();
}

class _EnterPhoneScreenState extends State<EnterPhoneScreen> {

  bool valid_no = false;
  final phone_no = new TextEditingController();
  bool progress = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  FirebaseMessaging _firebaseMessaging;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(defaultPresentSound: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessaging_Listeners();
  }
  Future onSelectNotification(String screen) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String guided_tour = prefs.getString("guide_tour");
    String home_screen = prefs.getString("home");
    if(guided_tour == 'done' && home_screen == 'done'){
      handle_redirection(screen);
    }
  }
  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text(title),
        content: new Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: new Text('Ok'),
          )
        ],
      ),
    );
  }

  void handle_redirection(String screen){
    if(screen == 'reply' ||
        screen == 'enquiry'){

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(screen: "consult"),
          ));


    }else if(screen== 'solution' ||
        screen == 'price'){

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BiddingActivity(screen: 1,),));

    }else if(screen == 'booking'){

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Appointments(
              screen: 1,
            ),
          ));
    }else{

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(screen: "notification"),
          ));

    }
  }


  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }


  Future _showNotificationWithDefaultSound(String msg) async {

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();


    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
   msg,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void firebaseCloudMessaging_Listeners() {

    if(Platform.isIOS){
      iOS_Permission();
    }

    _firebaseMessaging.getToken().then((token) {
      print("device token==="+token);
      config.Config.device_id = token;
    });

    _firebaseMessaging.configure(

      onMessage: (Map<String, dynamic> message) async {
        print('getting message $message');
        _showNotificationWithDefaultSound(message['notification']['body']);
      },

      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },


      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');

      },
    );
  }



  void submit() async{

    if(!valid_no && phone_no.text != ''){

      if(config.Config.opt_verification){

        setState(() {
          progress = true;
        });

        CheckPost checkPost = await check_user(phone_no.text.trim()).catchError((error){
          config.Config.showLongToast("Something went wrong!");
            setState(() {
              progress = false;
            });
        });

        var rng = new Random();
        var code = rng.nextInt(9000) + 1000;
        print(code);

        config.Config.otp_code = code.toString();

        if(!checkPost.success){
          String url = "https://control.msg91.com/api/sendotp.php"+"?authkey="+ config.Config.otp_auth_key+"&mobile=91"+ phone_no.text.trim()+"&sender="+config.Config.sender_id+"&otp="+code.toString();
          SendOtpPost sendOtpPost = await sendotp(url);
          print(sendOtpPost.type);
          setState(() {
            progress = false;
          });

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckOTP(phone: phone_no.text),
              ));
        }

        else{
          setState(() {
            progress = false;
          });

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Allevents(
                  phone: phone_no.text,
                ),
              ));
        }

      }else{
        setState(() {
          progress = false;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Registration(
                phone: phone_no.text,
              ),
            ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    return Scaffold(
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          margin: EdgeInsets.only(left:30, right: 30,),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/images/login/first_user.png', ),
                  ),
                ),

                SizedBox(height: 50,),

             Column(
               crossAxisAlignment:CrossAxisAlignment.start,
               children: <Widget>[
                 Center(
                   child: Container(
                     margin: EdgeInsets.only(left:30, right: 30),
                     child: Column(
                       children: <Widget>[
                         Text("Enter a new Era of ", textAlign: TextAlign.center, style:
                         TextStyle(fontSize: 20, color: Color(0xff898989), fontWeight: FontWeight.w500, ),),
                         Text("Healthcare", textAlign: TextAlign.center, style:
                         TextStyle(fontSize: 20,color: Color(0xff898989),  fontWeight: FontWeight.w500) )
                       ],
                     ),
                   ),
                 ),

                 SizedBox(height: 50,),

                 Container(
                     margin: EdgeInsets.only(left: 10, right: 10),
                     child: Text("Phone Number", style: TextStyle(fontSize: 18, color: Colors.grey),)),

                 SizedBox(height: 10,),

                 Container(
                   margin: EdgeInsets.only(left:10, right: 10),
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: <Widget>[

                       Column(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: <Widget>[
                           Container(
                             alignment: Alignment.bottomCenter,
                               height: 30,
                               child: Text("+91", style: TextStyle(fontSize: 18, color: Colors.grey),)),
                           SizedBox(height: 10,),
                           Container(height: 2, color: Colors.grey, width: 50,),
                         ],
                       ),
                       SizedBox(width: 10),
                       Expanded(child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: <Widget>[
                           Container(
                             height: 30,
//                              padding: EdgeInsets.only(bottom: 5, top: 5),
                             child: TextField(
                               style: TextStyle(fontSize: 18),
                               keyboardType: TextInputType.phone,
                               autofocus: true,
                               onChanged: (text){
                                 setState(() {
                                   if(text.length == 10){
                                     valid_no = false;
                                   }else{
                                     valid_no = true;
                                   }
                                 });
                               },
                               decoration: InputDecoration.collapsed(hintText: "Enter Number"),
                               controller: phone_no,
                             ),
                           ),
                           SizedBox(height: 10),
                           Container(
//                             margin: EdgeInsets.only(top:10),
                               height: 2, color: Colors.grey),
                         ],
                       ))

                     ],

                   )
                 ),
                 SizedBox(height: 10,),
                 Visibility(
                     visible: valid_no,
                     child: Center(child: Text("Please enter valid phone number",
                       style: TextStyle(color: Colors.red),))),
                 SizedBox(height: 30,),
                 Center(
                   child: progress?SpinKitThreeBounce(
                     color: Color(0xff01d35a),
                     size: 30.0,
                     // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                   ): Container(
                    width: 150,
                     child: FlatButton(
                       autofocus: true,
                       onPressed: submit,
                       color: Color(0xff01d35a),
                       child:  Padding(
                         padding: const EdgeInsets.all(12.0),
                         child: Text("Enter", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                       ),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                     )),
                 ),
               ],
             ),
                SizedBox(height: 30,)
              ],
            ),
          ),

        ),
      ),

    );
  }




}
