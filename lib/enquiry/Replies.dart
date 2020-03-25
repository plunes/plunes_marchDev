import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/model/enquiry/get_all_enquiries.dart';
import 'package:plunes/model/enquiry/post_replay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plunes/config.dart' as config;


class Replies extends StatefulWidget {

  final String query;
  final String query_id;
  final int time;
  final String from_name;
  final String from_image;
  final List<RepliesData> replies;


  Replies({Key key, this.query,this.query_id,
    this.time, this.from_name, this.from_image, this.replies}) : super(key: key);

  static const tag = '/replies';
  @override
  _RepliesState createState() => _RepliesState( query,query_id,
      time, from_name,from_image ,replies);
}

class _RepliesState extends State<Replies> {

  final String query;
  final String query_id;
  final int time;
  final String from_name;
  final String from_image;
  final List<RepliesData> replies;

  _RepliesState(  this.query,this.query_id,
      this.time,this.from_name,this.from_image, this.replies);


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController comment_ = new TextEditingController();

  String user_token = "";
  String user_id = "";
  String user_name = "";
  String user_image = "";

  bool comment_valid = false;
  bool progress = false;


  List name = new List();
  List reply_text = new List();
  List reply_time = new List();
  List imageUrl = new List();

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    String name = prefs.getString("name");
    String image = prefs.getString("imageUrl")!= null ?prefs.getString("imageUrl"): "";
    setState(() {
      user_token = token;
      user_id= uid;
      user_name = name;
      user_image = image;
    });

    get_comments();
  }


  get_comments() async{

    for(int i =0; i< replies.length; i++){
      name.add(replies[i].fromUserName);
      reply_text.add(replies[i].reply);
      reply_time.add(replies[i].createdTime);
      imageUrl.add(replies[i].fromimageUrl);
    }

  }



  post_comments() async {
    setState(() {
      progress = true;
    });

    var body = {
      "enquiryId":query_id,
      "reply":comment_.text
    };

    SendReplayPost sendReplayPost = await send_replay_api(body, user_token)
        .catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });


    setState(() {
      progress = false;
      if(sendReplayPost.success){

        var curr_time = new DateTime.now().millisecondsSinceEpoch;

        name.add(user_name);
        reply_text.add(comment_.text );
        reply_time.add(curr_time);
        imageUrl.add(user_image);
        comment_.text = '';

      }else{
        config.Config.showInSnackBar(_scaffoldKey, sendReplayPost.message, Colors.red);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
  }


  @override
  Widget build(BuildContext context) {

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("Replies", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );


    final top = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Container(
            child: from_image !='' &&
                !from_image.contains("default") ?
            CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(from_image),
          ): Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              child:
              Text(config.Config.get_initial_name(from_name).toUpperCase(),
                style: TextStyle(color: Colors.white,
                    fontSize: 18, fontWeight: FontWeight.normal),),

              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                gradient: new LinearGradient(
                    colors: [ Color(0xffababab),
                      Color(0xff686868)],
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp
                ),) ),

          ),

          SizedBox(width: 10,),

          Expanded(child: Container(


            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisAlignment: MainAxisAlignment.start,

             children: <Widget>[
               Text(from_name, style: TextStyle(fontWeight: FontWeight.w600),),
               Text(query),

               Row(
                 children: <Widget>[
                   Image.asset(
                     'assets/images/solution/comment.png',
                     color: Colors.black,
                     height: 15,
                     width: 15,
                   ),
                   Container(
                       padding: EdgeInsets.only(
                           left: 5,
                           right: 10,
                           top: 10,
                           bottom: 10),
                       child: Text(
                         reply_text.length.toString() + ' Replies',
                         style: TextStyle(
                             color: Colors.black,
                             fontSize: 12),
                       )),


                   Expanded(child: Container(
                     alignment: Alignment.centerRight,
                     child: Text(config.Config.get_duration(time), style: TextStyle(fontSize: 12),),
                   ))

                 ],
               ),

               Container(height: 0.2,color: Colors.grey,)

             ],

            ),
          )),
        ],
      ),
    );


    final comment_list = Container(
      child: reply_text.length ==0? Center(
        child: Text("No results"),
      ):Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(itemBuilder: (context, index){

          return Container(

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Container(
                    child: imageUrl[index] !='' ? CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(imageUrl[index]),
                    ): Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        child:
                        Text(config.Config.get_initial_name(name[index]).toUpperCase(),
                          style: TextStyle(color: Colors.white,
                              fontSize: 18, fontWeight: FontWeight.normal),),

                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                          gradient: new LinearGradient(
                              colors: [ Color(0xffababab),
                                Color(0xff686868)],
                              begin: FractionalOffset.topCenter,
                              end: FractionalOffset.bottomCenter,
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp
                          ),) ),

                  ),

                  SizedBox(width: 10,),

                  Expanded(child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(child: Text(name[index], style: TextStyle(fontWeight: FontWeight.w600),)),
                              Text(config.Config.get_duration(reply_time[index]), style: TextStyle(fontSize: 12),)

                            ],
                          ),
                          Text(reply_text[index])
                        ],
                      ),
                    ),
                    decoration: BoxDecoration(borderRadius:
                    BorderRadius.all(Radius.circular(10)), color: Color(0xfff0f0f0)),
                  ))
                ],
              ),
            ),
          );
        }, itemCount: reply_text.length,),
      ),

    );

    final send = Container(
      alignment: Alignment.centerLeft,
      height: 45,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(width: 1, color: Color(0xff01d35a))),

      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: comment_,
                onChanged: (text){

                 setState(() {
                   if(text.length>0){
                     comment_valid = true;
                   }else{
                     comment_valid = false;
                   }
                 });
                },
                decoration: InputDecoration.collapsed(hintText: "Write here"),
              ),
            ),
        progress? SpinKitThreeBounce(
          color: Color(0xff01d35a),
          size: 30.0,
          // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
        ): InkWell(
              onTap: post_comments,
              child:Icon(Icons.send, color: comment_valid? Color(0xff01d35a):Colors.grey,) ,
            ),
          ],
        ),
      ),
    );


    final form = Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(

         children: <Widget>[
             top,
             Expanded(child: comment_list),
             send
         ],

        ),
      ),

    );


    return Scaffold(
      key: _scaffoldKey,
      appBar: app_bar,
      body: form,





    );
  }
}
