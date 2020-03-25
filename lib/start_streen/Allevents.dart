import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/appointment/Appointments.dart';
import 'package:plunes/solution/BiddingActivity.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/login_reg_user.dart';
import 'package:plunes/start_streen/EnterPhoneScreen.dart';
import 'package:plunes/start_streen/forgot/Foget_password.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import 'HomeScreen.dart';


class Allevents extends StatefulWidget {
  static const tag = '/login_page';
  String phone;
  Allevents({Key key, this.phone}) : super(key: key);

  @override
  _AlleventsState createState() => _AlleventsState(phone);
}

class _AlleventsState extends State<Allevents> {
  @override
  TextEditingController phone_no = TextEditingController();
  TextEditingController passwd = TextEditingController();
  bool password = true;
  bool _passwordVisible = true;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  new FlutterLocalNotificationsPlugin();
  BuildContext _buildContext;

  FirebaseMessaging _firebaseMessaging;
  final String phone;
  String title = '', body = '';

  _AlleventsState( this.phone);
  bool progress= false;
  String err_text = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  _saveValues(String token,String uid,
      String name, String email, String phoneno,
      String user_type, String user_location,String speciality,
      String image_url, String cover_url
      )async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
    prefs.setString("uid", uid);

    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("phoneno", phoneno);

    prefs.setString("user_type", user_type);
    prefs.setString("user_location", user_location);
    prefs.setString("specialist", speciality);
    prefs.setString("imageUrl", image_url);
    prefs.setString("coverUrl", cover_url);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(screen: 'bids'),
        ));
  }

  Future onSelectNotification(String screen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String guided_tour = prefs.getString("guide_tour");
    String home_screen = prefs.getString("home");
    if(guided_tour == 'done' && home_screen == 'done'){
      handle_redirection(screen);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phone_no.text = phone;

//    var initializationSettingsAndroid =
//    new AndroidInitializationSettings('mipmap/ic_launcher');
//    var initializationSettingsIOS = new IOSInitializationSettings(defaultPresentSound: true,
//        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//    var initializationSettings = new InitializationSettings(
//        initializationSettingsAndroid, initializationSettingsIOS);
//    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
//    flutterLocalNotificationsPlugin.initialize(initializationSettings,
//        onSelectNotification: onSelectNotification);
//    _firebaseMessaging = FirebaseMessaging();
//    firebaseCloudMessaging_Listeners();
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

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future _showNotificationWithDefaultSound(String msg, String title, String screen) async {
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

  void firebaseCloudMessaging_Listeners() {
      if(Platform.isIOS)
        iOS_Permission();


    _firebaseMessaging.getToken().then((token) {
      print("device token==="+token);
      config.Config.device_id = token;
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('getting message $message');
//        showLocalNotification(message);
        print('on resume $message');
        print(message);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String guided_tour = prefs.getString("guide_tour");
        String home_screen = prefs.getString("home");

        if(guided_tour == 'done' && home_screen == 'done'){
          String screen = message['data']['screen'];
          handle_redirection(screen);
        }
        _showNotificationWithDefaultSound(message['notification']['body']!=null?message['notification']['body']:'',
            message['notification']['title'],message['data']['screen']!=null? message['data']['screen']:'');
      },

      onResume: (Map<String, dynamic> message) async {
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
        print('on launch $message');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String guided_tour = prefs.getString("guide_tour");
        String home_screen = prefs.getString("home");
        if(guided_tour == 'done' && home_screen == 'done'){
          String screen = message['data']['screen'];
          handle_redirection(screen);
        }
      }
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
//                        Clipboard.setData(new ClipboardData(text: body));
//                        _scaffoldKeyNotification.currentState.showSnackBar(
//                            new SnackBar(content: new Text("Copied to Clipboard", style: TextStyle(color: Colors.white),), backgroundColor: Colors.black,));
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

  void handle_redirection(String screen){
        print(screen);

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
                builder: (context) => BiddingActivity(screen: 0,),));

        }else if(screen == 'booking'){

          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Appointments(
                  screen: 0,
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


  void login() async{
    FocusScope.of(context).requestFocus(new FocusNode());
    if(password && passwd.text != '' && phone_no.text != ''){

      setState(() {
        progress = true;
      });

      var body;

      if(phone_no.text.contains("@")){
        body = {
          "email": phone_no.text.trim(),
          "password":passwd.text,
          "deviceId":config.Config.device_id
        };

      }else{
        body = {
          "mobileNumber": phone_no.text.trim(),
          "password":passwd.text,
          "deviceId":config.Config.device_id
        };
      }

      print(body);

      LoginPost loginPost = await loginapi(body).catchError((error){
        config.Config.showLongToast("Something went wrong!");
        print(error.toString());
        setState(() {
          progress = false;
        });
      });


      List specialisties_id = new List();
      List specialisties_ = new List();

      setState((){
        progress = false;
        if(loginPost.success){

          for(int i =0; i< loginPost.user.specialities.length; i++){
            specialisties_id.add(loginPost.user.specialities[i].specialityId);
            int pos = config.Config.specialist_id.indexOf(config.Config.specialist_id[i]);
            specialisties_.add(config.Config.specialist_lists[pos]);
          }

           _saveValues(
               loginPost.token,
               loginPost.user.uid,

               loginPost.user.name,
               loginPost.user.email,
               loginPost.user.mobileNumber,

               loginPost.user.userType,
               loginPost.user.address,
               specialisties_.join(","),
             loginPost.user.imageUrl,
             loginPost.user.coverImageUrl
           );


        }else{
          config.Config.showInSnackBar(_scaffoldKey, "Login Failed", Colors.red);
        }
      });
    }else{
      progress = false;
    }
  }

  Widget build(BuildContext context) {
    _buildContext = context;
    Config.globalContext = context;

    final login_btn = Container(
      margin:    EdgeInsets.only(right: 20, left: 10),
      child: FlatButton(
        onPressed:login,
        color: Color(0xff01d35a),
        child:  Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Login", style: TextStyle(color: Colors.white)),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    final signup_btn =  Container(
      margin: EdgeInsets.only(top:20, left: 50, right: 50),
      child: InkWell(child: Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Create an account",style:
        TextStyle(color: Color(0xff585858), decoration: TextDecoration.underline,
            fontWeight: FontWeight.normal, fontSize: 14),),
      )),onTap: (){

        Navigator.pushNamed(context, EnterPhoneScreen.tag);

      },
      borderRadius: BorderRadius.circular(15),),
    );

    final phone_number = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
        style: TextStyle(color: Color(0xff585858), fontSize: 14, ),
        controller: phone_no,
        decoration: InputDecoration(labelText: 'Phone No or Email id',
          hintStyle: TextStyle(color: Color(0xff585858), fontSize: 14),
        //  labelStyle: TextStyle(color: Color(0xff585858), fontSize: 14),
          ),
        ),
      );


    final pass_word = Container(
      margin: EdgeInsets.only(
        left: 38,
        right: 38,
      ),
      child: TextField(
          obscureText:_passwordVisible,
        controller: passwd,
        style: TextStyle(color: Color(0xff585858)),
        onChanged: (tex){
            setState(() {
              int pass_length = tex.length;

              if(tex != '' && pass_length >= 8){
                password = true;
              }else{
                password = false;
              }
            });
        },

        decoration: InputDecoration(labelText: 'Password',
           // labelStyle: TextStyle(color: Color(0xff585858), fontSize: 14),
            hintStyle: TextStyle(color: Color(0xff585858), fontSize: 14),
            suffixIcon: GestureDetector(
              onTap: (){
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
              child:_passwordVisible? Icon(Icons.visibility_off,): Icon(Icons.visibility, ),
            ),
            errorText: password ?null: 'Please enter at least 8 character'),
      ),
    );


    final forgotLabel = Container(
      alignment: Alignment.topRight,
      margin: EdgeInsets.only(right: 30),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Forgot password?',
            style: TextStyle(color: Color(0xff585858),fontSize: 14, fontWeight: FontWeight.normal),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(context, ForgetPassword.tag);
        },
      ),
    );


    final form = Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[

          Center(child: Image.asset('assets/logo1.png', height: 125, width: 125,)),
          SizedBox(height: 30,),
          phone_number,
          SizedBox(height: 10,),
          pass_word,


          SizedBox(height: 20,),

          Container(
            margin: EdgeInsets.only(left: 30, right: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: progress?  SpinKitThreeBounce(
                  color: Color(0xff01d35a),
                  size: 30.0,
                  // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                ): login_btn, flex: 1,),
                Expanded(child: forgotLabel, flex: 1,),
              ],
            ),
          ),

       //   SizedBox(height: 10,),
          signup_btn,
          SizedBox(height: 10,),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: form,
      ),
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new CupertinoAlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => SystemNavigator.pop(),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

}

