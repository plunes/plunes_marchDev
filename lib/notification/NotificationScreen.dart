import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/appointment/Appointments.dart';
import 'package:plunes/solution/BiddingActivity.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/all_notifications.dart';
import 'package:plunes/start_streen/Allevents.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';


class NotificationScreen extends StatefulWidget {
  static const tag = '/notificationscreen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  String user_token = "";
  String user_id = "";


  bool progress = true;
  List<PostsData> notification_lists = new List();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {
      user_token = token;
      user_id = uid;
    });

    get_data();
  }



  void get_data() async{

    AllNotificationsPost allNotificationsPost = await all_notifications(user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error);
      setState(() {
        progress = false;
      });
    });


    for(int i =0; i< allNotificationsPost.posts.length; i++){
      notification_lists.add(allNotificationsPost.posts[i]);
    }

     setState(() {
       if(allNotificationsPost.success){
        progress = false;
       }else{
         config.Config.showInSnackBar(_scaffoldKey, allNotificationsPost.message, Colors.red);
       }
     });

  }

  @override
  void initState() {
    getSharedPreferences();
    super.initState();
  }


  Widget notifications(BuildContext context){
    if(notification_lists.length ==0){
      return Center(
        child: Text("No Notifications Yet"),
      );
    }
    return  Column(
      children: <Widget>[
        Expanded(
          child: Container(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  String  initial_name = notification_lists[index].senderName!=''? config.Config.get_initial_name(notification_lists[index].senderName):'';
                  return Container(
                    child: InkWell(
                      onTap: () {
                        if(notification_lists[index].Notificationtype == 'reply' || notification_lists[index].Notificationtype == 'enquiry'){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(screen: "consult")));
                        }else if(notification_lists[index].Notificationtype == 'solution' || notification_lists[index].Notificationtype == 'price'){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BiddingActivity(screen: 0)));
                        }else if(notification_lists[index].Notificationtype == 'booking'){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Appointments(
                                  screen: 0,
                                ),
                              ));
                        }else if(notification_lists[index].Notificationtype == 'plockr'){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(screen: "plocker"),
                              ));
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 0, right: 10),
                                     child: notification_lists[index].Senderimageurl !='' && !notification_lists[index].Senderimageurl.contains("default") ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(notification_lists[index].Senderimageurl),
                                      ): Container(
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          child:
                                          Text(initial_name.toUpperCase(),
                                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.normal)),

                                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                                            gradient: new LinearGradient(
                                                colors: [Color(0xffababab), Color(0xff686868)],
                                                begin: FractionalOffset.topCenter,
                                                end: FractionalOffset.bottomCenter,
                                                stops: [0.0, 1.0],
                                                tileMode: TileMode.clamp
                                            ),) ),
                                    ),
                                    Expanded(child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(notification_lists[index].senderName,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),

                                          Container(
                                            width: 200,
                                            child: Text(
                                              notification_lists[index].notification,
                                              maxLines: null,
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 20),
                                      alignment: Alignment.topRight,
                                      child: Text(config.Config.get_duration(notification_lists[index].Currtime) ,
                                        style: TextStyle(
                                            fontSize: 13),
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 0.3,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: notification_lists.length,
              )),
        ),
      ],
    );
  }

  final loading = ListView.builder(itemBuilder: (context, index) {
    return Shimmer.fromColors(
      baseColor: Color(0xffF5F5F5),
      highlightColor: Color(0xffFAFAFA),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xffF5F5F5),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 10,
                          color: Color(0xffF5F5F5),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 10,
                          color: Color(0xffF5F5F5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: progress? loading: notifications(context)
    );
  }
}
