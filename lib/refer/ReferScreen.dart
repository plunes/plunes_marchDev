import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:share/share.dart';
import 'package:plunes/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';



class ReferScreen extends StatefulWidget {
  static const tag = '/referscreen';
  @override
  _ReferScreenState createState() => _ReferScreenState();
}

class _ReferScreenState extends State<ReferScreen> {

  bool progress = true;

  String user_token= "";
  String user_id = "";


  String credit = "";
  String refer_code = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    getSharedPreferences();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    setState(() {
      user_token = token;
      user_id = uid;
    });
    getuser_data(token);
  }

  getuser_data(String token) async{
    MyProfile  myProfileData = await my_profile_data(token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });
    setState(() {
      progress = false;
      credit= myProfileData.credits;
      refer_code = myProfileData.userReferralCode;
    });

  }


  @override
  Widget build(BuildContext context) {

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "Refer & Earn",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      ),
    );



    return Scaffold(
      appBar: app_bar,
      backgroundColor: Colors.white,

      body: progress? SpinKitThreeBounce(
        color: Color(0xff01d35a),
        size: 30.0,
        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
      ): Container(
        margin: EdgeInsets.all(20),
        child: Column(
          //shrinkWrap: true,
          children: <Widget>[

            Text("Invite your friends & get Rs 100 each", textAlign: TextAlign.left, style: TextStyle(
              color: Color(0xff262626),
              fontSize: 22,
              fontWeight: FontWeight.w600
            ),),

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(height: 5,width: 5,

                  margin: EdgeInsets.only(top: 8),

                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.black),),
                SizedBox(width: 5,),
                Expanded(
                  child: Text("Share the code below or ask them to enter it when they sign up",
                  style: TextStyle(color: Color(0xff444444),
                  fontSize: 15),),
                ),
              ],
            ),

            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(height: 5,width: 5,

                  margin: EdgeInsets.only(top: 8),

                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.black),),
                SizedBox(width: 5,),
                Expanded(
                  child: Text("You will get instant cash as soon as your friend registers successfully",
                    style: TextStyle(color: Color(0xff444444),
                        fontSize: 15),),
                ),
              ],
            ),
            SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(height: 5,width: 5,
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.black),),
                SizedBox(width: 5,),
                Expanded(
                  child: Text("Cash can be used on all the medical procedures, appointments & tests",
                    style: TextStyle(color: Color(0xff444444),
                        fontSize: 15),),
                ),
              ],
            ),


            Expanded(
              child: Image.asset('assets/images/refer/cover.png', height: 250,
              width: double.infinity,),
            ),
            SizedBox(height: 10,),


            Container(child: Text("Available Credits", style: TextStyle(fontSize: 15),), alignment: Alignment.centerLeft,),
            SizedBox(height: 10,),




            Container(
              child: Row(
                children: <Widget>[

                 Image.asset('assets/images/refer/credit.png', height: 30, width: 30,),
                  SizedBox(width: 5,),
                  Text(credit, style: TextStyle(fontSize: 16, color: Color(0xff5D5D5D), fontWeight: FontWeight.bold),)
                ],
              ),
            ),

            SizedBox(height: 30,),

            Container(child: Text("Share Your Invite Code"), alignment: Alignment.centerLeft,),
            SizedBox(height: 10,),

            InkWell(
              onTap: (){
                Clipboard.setData(new ClipboardData(text: refer_code));
                config.Config.showLongToast("Copy to clipboard");
              },
              child: Container(
                color: Color(0xffF9F9F9),
                height: 45,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[

                      Text(refer_code, style: TextStyle(
                        color: Color(0xff313131),
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),),

                      Expanded(child: Container()),

                      Text("COPY CODE", style: TextStyle(color: Color(0xff01D35A),
                          fontSize: 15),),

                    ],
                  ),
                ),
              ),
            ),


            Container(height: 1,color: Colors.grey,),

            SizedBox(height: 30,),
            InkWell(
              onTap: (){
                Share.share("Join me on Plunes and get upto 50% discount instantly!Use my invite code: $refer_code and get Rs. 100/- as free referral cash.Download Plunes now: https://plunes.com");
              },
              borderRadius: BorderRadius.all(Radius.circular(20)),
              child: Container(
                height: 45,
                alignment: Alignment.center,
                child: Text("Invite Friends", style: TextStyle(color: Colors.white, fontSize: 18),),
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), color: Color(0xff01D35A)),
              ),
            )



          ],
        ),
      ),

    );
  }
}
