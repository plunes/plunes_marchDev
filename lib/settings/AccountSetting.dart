import 'package:flutter/material.dart';
import 'package:plunes/profile/EditProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';


class AccountSetting extends StatefulWidget {
  static const tag = '/accountsetting';
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {

  bool isSwitched = true;

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("uid");
    Navigator.pushNamed(context, EditProfile.tag);
  }



  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("Account Settings", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );



    final form  = Column(

      children: <Widget>[


        InkWell(
          onTap: (){

          },
          child: Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:  Image.asset('assets/notification.png', height: 25, width: 25,),
                ),

                Expanded(child: Text("Notifications")),

                Switch(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Color(0xff01d35a),
                ),

              ],
            ),
          ),
        ),


        Container(
          color: Colors.grey,
          height: 0.5,
        ),

        InkWell(
          onTap: getSharedPreferences,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset('assets/edit_profile.png', height: 25, width: 25,),
                ),
                Expanded(child: Text("Edit Profile")),
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


    return Scaffold(


      appBar: app_bar,
      body: form,
    );
  }
}
