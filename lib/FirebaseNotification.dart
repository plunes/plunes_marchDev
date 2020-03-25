import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:plunes/solution/BiddingActivity.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appointment/Appointments.dart';
import 'config.dart';

class FirebaseNotification  {
  FirebaseMessaging _firebaseMessaging;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String title = '', body = '';
  BuildContext _buildContext;
  GlobalKey<ScaffoldState> _scaffoldKeyNotification;

  void setUpFireBase(BuildContext context, GlobalKey<ScaffoldState> _scaffoldKey) {
    _buildContext = context;
    _scaffoldKeyNotification = _scaffoldKey;
    _firebaseMessaging = FirebaseMessaging();
    var initializationSettingsAndroid = new AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(defaultPresentSound: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    fireBaseCloudMessagingListeners();
  }


  Future onSelectNotification(String screen) async {
    print('==firebase==screen== $screen');
    Navigator.push(
        _buildContext,
        MaterialPageRoute(
          builder: (context) => Appointments(
            screen: 0,
          ),
        ));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String guided_tour = prefs.getString("guide_tour");
    String home_screen = prefs.getString("home");
    if(guided_tour == 'done' && home_screen == 'done'){
//      handleRedirection(screen);
      handle_redirection(screen);
    }
  }
  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    _buildContext = Config.globalContext;
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: _buildContext,
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

/*  void handleRedirection(String screen){
    if(screen == "4" || screen == "5" || screen == "6" ){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => BiddingActivity(screen: 1)));
    }else if(screen == config.Config.solution_notification || screen ==config.Config.comment_notification || screen == config.Config.appreciate_comment || screen == config.Config.apreciate_solution){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => HomeScreen(screen: "consult"),));
    }else if(screen== "7"||screen== "10"){
      Navigator.push(_buildContext,MaterialPageRoute(builder: (context) => AppointmentDetails(screen: 1),));
    }else if(screen == "8" || screen== "9" ){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => AppointmentDetails(screen: 0)));
    }  else if (screen == "11") {
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => BiddingActivity(screen: 0),));
    }else if(screen == ''){
      Navigator.push(_buildContext, MaterialPageRoute(builder: (context) => BiddingActivity(screen: 2)));
    }
  }*/

  void handle_redirection(String screen){
    _buildContext = Config.globalContext;

    print(screen);

    if(screen == 'reply' ||
        screen == 'enquiry'){

      Navigator.push(
          _buildContext,
          MaterialPageRoute(
            builder: (context) => HomeScreen(screen: "consult"),
          ));

    }else if(screen== 'solution' || screen == 'price'){

      Navigator.push(
          _buildContext,
          MaterialPageRoute(
            builder: (context) => BiddingActivity(screen: 0,),));

    }else if(screen == 'booking'){

      Navigator.push(
          _buildContext,
          MaterialPageRoute(
            builder: (context) => Appointments(
              screen: 0,
            ),
          ));

    }else if(screen == 'plockr'){

      Navigator.push(
          _buildContext,
          MaterialPageRoute(
            builder: (context) => HomeScreen(screen: "plockr"),
          ));
    }


    else{

      Navigator.push(
          _buildContext,
          MaterialPageRoute(
            builder: (context) => HomeScreen(screen: "notification"),
          ));
    }
  }


  void fireBaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.getToken().then((token) {
      print('Firebase Token: $token');
      Config.device_id = token;
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        Navigator.push(
            _buildContext,
            MaterialPageRoute(
              builder: (context) => Appointments(
                screen: 0,
              ),
            ));
        print('getting message $message');
//        showLocalNotification(message);
        print('on resume $message');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String guided_tour = prefs.getString("guide_tour");
        String home_screen = prefs.getString("home");

//        if(guided_tour == 'done' && home_screen == 'done'){
//          String screen = message['data']['screen'];
//          handle_redirection(screen);
//        }


        _showNotificationWithDefaultSound(message['notification']['body']!=null?message['notification']['body']:'',
            message['notification']['title'],message['data']['screen']!=null? message['data']['screen']:'');


      },
      onResume: (Map<String, dynamic> message) async {
        Navigator.push(
            _buildContext,
            MaterialPageRoute(
              builder: (context) => Appointments(
                screen: 0,
              ),
            ));
     /*   print('==firebase==onResume== $message');
        showLocalNotification(message);*/

        print('on resume $message');
        print(message);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String guided_tour = prefs.getString("guide_tour");
        String home_screen = prefs.getString("home");

        if(guided_tour == 'done' && home_screen == 'done'){
          String screen = message['data']['screen'];
          handle_redirection(screen);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        Navigator.push(
            _buildContext,
            MaterialPageRoute(
              builder: (context) => Appointments(
                screen: 0,
              ),
            ));
    /*    print('==firebase==onLaunch== $message');
        showLocalNotification(message);*/
        print('on launch $message');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String guided_tour = prefs.getString("guide_tour");
        String home_screen = prefs.getString("home");
        if(guided_tour == 'done' && home_screen == 'done'){
          String screen = message['data']['screen'];
          handle_redirection(screen);
        }
      },
    );
  }
  Future _showNotificationWithDefaultSound(String msg, String title, String screen) async {
  /*  print('==_showNotificationWithDefaultSound==screen== $msg');

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails('your channel id', 'your channel name', 'your channel description', importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Post',
      msg,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );*/
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);

    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(sound: "default");


    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      msg,
      platformChannelSpecifics,
      payload: screen,
    );

  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<Null> _filterPopUp(String body, String userID) async {
    return showDialog<Null>(
        context: _buildContext,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return new Material(
              type: MaterialType.transparency,
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                margin: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      color: Colors.white,
                      alignment: Alignment.topLeft,
                      child: Text(title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 10.0),
                      color: Colors.white,
                      alignment: Alignment.topLeft,
                      child: InkWell( onLongPress: () {
                        Navigator.pop(context);
                        Clipboard.setData(new ClipboardData(text: body));
                        _scaffoldKeyNotification.currentState.showSnackBar(
                            new SnackBar(content: new Text("Copied to Clipboard", style: TextStyle(color: Colors.white),), backgroundColor: Colors.black,));
                        },child: Text(body,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 16.0),
                      ),),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 30.0),
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: new Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          margin: EdgeInsets.only(right: 10.0),
                          height: 30.0,
                          decoration: new BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.black26),
                          child: new Center(
                              child: new Text(
                                "DONE",
                                textAlign: TextAlign.center,
                                style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                  fontFamily: "openSans",
                                ),
                              )),

                          // Add box decoration
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyNotification,
      body: Container(),
    );
  }

  void showLocalNotification(Map<String, dynamic> message) {
    if (Platform.isIOS){
      title = message["notification"]['title']!=null?message["notification"]['title']:'';
      body = message["notification"]['body']!=null? message["notification"]['body']:'' ;
    } else {
      title = message["notification"]['title']!=null?message["notification"]['title']:'';
      body = message["notification"]['body']!=null? message["notification"]['body']:'' ;
    }
    _filterPopUp(body, title);
  }

}