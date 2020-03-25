import 'package:flutter/material.dart';
import '../config.dart';
import 'AccountSetting.dart';
import 'SecuritySetting.dart';

class SettingScreen extends StatefulWidget {
  static const tag = '/setting_screen';
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("Settings", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );


    return Scaffold(
      backgroundColor: Colors.white,
      appBar:app_bar,

      body: Container(

        child: Column(

          children: <Widget>[


            InkWell(
              onTap: (){
                Navigator.pushNamed(context, AccountSetting.tag);

              },
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset('assets/account.png', height: 25, width: 25,),
                    ),
                    Expanded(child: Text("Account Settings")),

                    Icon(Icons.keyboard_arrow_right, color: Colors.black,)

                  ],
                ),
              ),
            ),


            Container(
              color: Colors.grey,
              height: 0.5,
            ),

            InkWell(
              onTap: (){
                Navigator.pushNamed(context, SecuritySetting.tag);

              },
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset('assets/security.png', height: 25, width: 25,),
                    ),
                    Expanded(child: Text("Security Settings")),
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
        ),
      )
    );
  }
}