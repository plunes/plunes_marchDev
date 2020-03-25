import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/config.dart';
import 'package:plunes/model/enquiry/post_enquery.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/helpquery_post.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HelpOptions extends StatefulWidget {
  static const tag = '/helpoptions';
  @override
  _HelpOptionsState createState() => _HelpOptionsState();
}

class _HelpOptionsState extends State<HelpOptions> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController description = new TextEditingController();
  bool booking = false;
  bool online_sol = false;
  bool feedback = false;
  bool show_popup = false;
  bool progress = false;

  String title = "";
  String user_id = "";
  String user_token = ""
;
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
    String img = prefs.getString("image");
    String name = prefs.getString("name");

    setState(() {
      user_token = token;
      user_id = uid;
    });
  }

  submit()async{

    setState(() {
      progress = true;
    });

    var body = {
      "text": title+" : "+description.text
    };


    print(body);

    HelpPost postEnqueryPost = await help_post(body, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;
      if(postEnqueryPost.success){


        show_popup = false;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (
              BuildContext context,
              ) =>
              _popup_saved(context),
        );

      }else{
        config.Config.showInSnackBar(_scaffoldKey, postEnqueryPost.message, Colors.red);
      }
    });

  }


  @override
  Widget build(BuildContext context) {

    Config.globalContext = context;

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("Help", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );


    final popup = Container(
      child: CupertinoAlertDialog(
        content: Container(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child:   InkWell(
                  onTap: (){
                    setState(() {
                      show_popup = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:8.0),
                    child: Icon(Icons.clear),
                  ),
                )
              ),



              Column(
                children: <Widget>[


                  SizedBox(
                    height: 20,
                  ),
                  Center(child: Text(title, style: TextStyle(fontSize: 16),)),

                  SizedBox(
                    height: 20,
                  ),

                  Container(
                    height: 80,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        maxLines: null,
                        autofocus: true,
                        controller: description,
                        decoration: InputDecoration.collapsed(hintText: "Description"),
                      ),
                    ),
                    decoration:BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), border:
                    Border.all(color: Colors.grey, width: 0.3))  ,
                  ),
                  SizedBox(
                    height: 20,
                  ),

                  GestureDetector(
                    onTap: submit,
                    child:progress? SpinKitThreeBounce(
                      color: Color(0xff01d35a),
                      size: 30.0,
                      // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                    ):
                    Container(
                      height: 35,
                      width: 200,
                      alignment: Alignment.center,
                      child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Color(0xff01d35a)),
                    ),
                  ),

                ],
              ),
            ],
          )
        ),
      ),
    );

    final form = ListView(

      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left:20, top: 10, bottom: 10),
          width: double.infinity,
          color: Color(0xfff0f0f0),
          child: Text("I have an issue with"),
        ),

        Column(
          children: <Widget>[



            InkWell(
              onTap: (){
                setState(() {
                  booking = !booking;
                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/images/help/booking-appointment.png',
                        height: 20, width: 20,),
                    ),
                    Expanded(child: Text("Booking Appointments", style: TextStyle(fontWeight: FontWeight.w600),)),
                    booking? Icon(Icons.keyboard_arrow_down , color: Colors.black,):
                    Icon(Icons.keyboard_arrow_right, color: Colors.black,)

                  ],
                ),
              ),
            ),



            Container(
              color: Color(0xffbdbdbd),
              height: 0.3,
            ),
            Visibility(
              visible: booking,
              child: Column(
                children: <Widget>[

                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "Booking failure";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Booking failure")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "Wrong lab/contact details";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Wrong lab/contact details")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "Appointment delayed or cancelled";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Appointment delayed or cancelled")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){

                      setState(() {
                        show_popup = true;
                        title = "Cancelling/rescheduling an appointment";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Text("Cancelling/rescheduling an appointment")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "SMS/OTP issues";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("SMS/OTP issues")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),


                ],
              ),
            )
          ],
        ),

        Container(
          color: Color(0xffbdbdbd),
          height: 0.3,
        ),


        Column(
          children: <Widget>[

            InkWell(
              onTap: (){
                setState(() {
                  online_sol = !online_sol;
                });
              },
              child: Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/images/help/online_solution.png', height: 20,
                        width: 20,),
                    ),

                    Expanded(child: Text("Online Solution", style: TextStyle(fontWeight: FontWeight.w600))),
                    online_sol? Icon(Icons.keyboard_arrow_down , color: Colors.black,):
                    Icon(Icons.keyboard_arrow_right, color: Colors.black,)

                  ],
                ),
              ),
            ),
            Container(
              color: Color(0xffbdbdbd),
              height: 0.3,
            ),
            Visibility(
              visible: online_sol,
              child: Column(
                children: <Widget>[

                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "Questions not answered";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Questions not answered")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "Not happy with response";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Not happy with response")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){

                      setState(() {
                        show_popup = true;
                        title = "Payment issues";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Payment issues")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),

        Container(
          color: Color(0xffbdbdbd),
          height: 0.3,
        ),



        Column(
          children: <Widget>[

            InkWell(
              onTap: (){
                setState(() {
                  feedback = !feedback;
                });
              },
              child:  Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.asset(
                        'assets/images/help/feedback.png', height: 20,
                        width: 20,),
                    ),
                    Expanded(child: Text("Feedbacks", style: TextStyle(fontWeight: FontWeight.w600))),

                    feedback? Icon(Icons.keyboard_arrow_down , color: Colors.black,):
                    Icon(Icons.keyboard_arrow_right, color: Colors.black,)
                  ],
                ),
              ),
            ),
            Container(
              color: Color(0xffbdbdbd),
              height: 0.3,
            ),
            Visibility(
              visible: feedback,
              child: Column(
                children: <Widget>[

                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "My feedback is not getting published";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("My feedback is not getting published"),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "Unable to write a feedback";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Unable to write a feedback")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "Booking failure";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("Booking failure")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Color(0xffbdbdbd),
                    height: 0.3,
                  ),

                  InkWell(
                    onTap: (){
                      setState(() {
                        show_popup = true;
                        title = "I want to edit my feedback";
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text("I want to edit my feedback")),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  ),



                ],
              ),
            )
          ],
        ),
        Container(
          color: Color(0xffbdbdbd),
          height: 0.3,
        ),


//        Container(
//          padding: EdgeInsets.only(left:20, top: 10, bottom: 10),
//          width: double.infinity,
//          color: Color(0xfff0f0f0),
//          child: Text("Your previous Issues."),
//        ),
//
//        ListView.builder(itemBuilder: (context, index){
//          return Container(
//
//
//          );
//        }, shrinkWrap: true,)
//

      ],

    );


    return Scaffold(
      appBar: app_bar,
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      body: Stack(
        children: <Widget>[
          form,
          show_popup? Container(
            height: double.infinity,
            width: double.infinity,
            color: Color(0xff90000000),
          ): Container(),
          show_popup? popup: Container()
        ],
      )



    );
  }

  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Sent..'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: new Text(
            'OK',
            style: TextStyle(color: Color(0xff01d35a)),
          ),
        ),
      ],
    );
  }

}
