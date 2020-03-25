import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/enquiry/get_all_enquiries.dart';
import 'package:plunes/enquiry/PostConcern.dart';
import 'package:plunes/enquiry/Replies.dart';
import 'package:plunes/profile/UserProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../config.dart';

class MainSolutionScreen extends StatefulWidget {
  static const tag  = "/main_solution";

  @override
  _MainSolutionScreenState createState() => _MainSolutionScreenState();
}

class _MainSolutionScreenState extends State<MainSolutionScreen> {

  TextEditingController _searchcontroller = TextEditingController();
  bool cancel = false;
  List data = new List();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  String user_id = "";
  String user_token = "";
  bool call = false;
  String user_type = "";

  List<EnquiriesData> for_you = new List();
  List<EnquiriesData> you_asked = new List();
  List<bool> show_replies_for_you = new List();
  List<bool> show_replies_you_asked = new List();


  @override
  void initState() {
    filter_data("");
    getSharedPreferences();
    super.initState();
  }


  filter_data(String text) {
    data.clear();
    for (int i = 0; i < config.Config.specialist_lists.length; i++) {
      if (config.Config.specialist_lists[i].toString().toLowerCase().contains(
          text.toLowerCase())) {
        data.add(config.Config.specialist_lists[i]);
      }
    }
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    String type = prefs.getString("user_type");
    setState(() {
      user_id = uid;
      user_token = token;
      user_type = type;
    });
    get_all_enquires(token);
  }


  get_all_enquires(String token) async {
      AllEnquiriesPost allEnquiriesPost = await all_enquiries(token).catchError((
          error) {
        config.Config.showLongToast("Something went wrong!");
        print(error.toString());
        setState(() {
          call = true;
        });
      });

      if (allEnquiriesPost.success) {
        print(allEnquiriesPost.enquiries.length);

        for(int i = 0; i < allEnquiriesPost.enquiries.length; i++) {
        if(user_id.contains(allEnquiriesPost.enquiries[i].toUserId)){
          for_you.add(allEnquiriesPost.enquiries[i]);
          show_replies_for_you.add(true);

        }else{
          you_asked.add(allEnquiriesPost.enquiries[i]);
          show_replies_you_asked.add(true);
        }
      }

    } else {
      config.Config.showInSnackBar(
          _scaffoldKey, allEnquiriesPost.message, Colors.red);
    }


    setState(() {
      call = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final message = Container(
      margin: EdgeInsets.only(left: 40, right: 40),
      child: Center(
        child: Text(
          "Post your Enquiries to the Professionals.",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );

    final search_procedure = Container(
        margin: EdgeInsets.all(20),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                      controller: _searchcontroller,
                      style: DefaultTextStyle
                          .of(context)
                          .style
                          .copyWith(),
                      onChanged: (text) {
                        setState(() {
                          if (text.length != 0) {
                            cancel = true;
                          } else {
                            cancel = false;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Choose Speciality' /*"Name the specialist here"*/,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            borderSide:
                            BorderSide(width: 0.1, color: Color(0xff01d35a))),
                      )),

                  suggestionsCallback: (pattern) {
                    print(pattern);
                    if (pattern != '') {
                      filter_data(pattern);
                    } else {
                      filter_data(pattern);
                    }

                    return data;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  hideOnEmpty: false,
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      cancel = false;
                    });
                    _searchcontroller.text = "";
                    print(suggestion);

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PostConcern(
                                choose: suggestion,
                              ),
                        ));
                  },
                ),
              ],
            ),
            cancel
                ? Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  setState(() {
                    cancel = false;
                    _searchcontroller.text = '';
                  });
                },
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.clear),
                  ),
                ),
              ),
            )
                : Container(),
          ],
        ));

    final loading = Expanded(
      child: ListView.builder(itemBuilder: (context, index) {
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
      }),
    );


    final options_tabs = Container(
        padding: EdgeInsets.all(10),
        child: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                constraints: BoxConstraints.expand(height: 30),
                //  foregroundDecoration: BoxDecoration(color:Colors.red),
                child: TabBar(
                  tabs: [
                    Tab(
                        text: "For You"
                    ),
                    Tab(
                      text: "You Asked",
                    ),

                  ],
                  labelStyle:
                  TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff262626)),
                  indicatorColor: Color(0xff01d35a),
                  unselectedLabelColor: Color(0xff808080),
                  labelColor: Colors.black,
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14,),
                ),
              ),
              Container(
                child: Expanded(
                  child: Container(
                    child: TabBarView(
                      children: [
                          for_you_() ,
                         you_asked_()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));


    final form = Container(
      child: Column(
        children: <Widget>[
          message,
          search_procedure,
          call? Expanded(child: user_type=="User"?you_asked_(): options_tabs): loading
        ],
      ),
    );

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: form
    );
  }

  Widget for_you_() {
    if (for_you.length == 0) {
      return Center(
        child: Text("No Enquiries Yet"),
      );
    } else {
      return ListView.builder(itemBuilder: (context, index) {

        String initial_name = config.Config.get_initial_name(
           for_you[index].fromUserName);


        return InkWell(
          onTap: (){

            setState(() {
              show_replies_for_you[index] = !show_replies_for_you[index];
            });
          },
          child: Container(
            child: Column(
              children: <Widget>[

                Container(height: 0.2,color: Colors.white,),
                Container(
                  color: Color(0xff666666),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[



                        InkWell(
                          onTap:(){

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfile(
                                      user_id:for_you[index].fromUserId
                                  ),
                                ));


                          },
                          child: Container(
                            margin: EdgeInsets.only(top:10)
                            ,child: for_you[index].fromUserimageUrl !='' &&
                              !for_you[index].fromUserimageUrl.contains("default")
                            ? CircleAvatar(
                              radius: 20,

                              backgroundImage: NetworkImage(for_you[index].fromUserimageUrl),
                            ): Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                child:
                                Text(initial_name.toUpperCase(),
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 18, fontWeight: FontWeight.normal),),

                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                                  gradient: new LinearGradient(
                                      colors: [ Color(0xffababab),
                                        Color(0xff686868)],
                                      begin: FractionalOffset.topCenter,
                                      end: FractionalOffset.bottomCenter,
                                      stops: [0.0, 1.0],
                                      tileMode: TileMode.clamp
                                  ),) ),

                          ),
                        ),


                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Container(
                                child: InkWell(
                                  onTap:(){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfile(
                                              user_id:for_you[index].fromUserId
                                          ),
                                        ));

                                  },
                                  child: Text(for_you[index].fromUserName, style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                  ),
                                ),
                                margin: EdgeInsets.only(top: 10),
                              ),

                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(for_you[index].enquiry,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ),

                              Row(
                                children: <Widget>[

                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Replies(

                                                  query: for_you[index].enquiry,
                                                  query_id: for_you[index].id,
                                                  from_name: for_you[index].fromUserName,
                                                  time: for_you[index].createdTime,
                                                  replies: for_you[index].replies,
                                                    from_image:for_you[index].fromUserimageUrl
                                                ),
                                          ));
                                    },
                                    child: Row(
                                      children: <Widget>[

                                        Image.asset(
                                          'assets/images/solution/comment.png',
                                          color: Colors.white,
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
                                              for_you[index].replies.length.toString() + ' Replies',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  decoration: TextDecoration.underline,
                                                  fontSize: 12),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(config.Config.get_duration(for_you[index].createdTime), style: TextStyle(
                                            color: Colors.white, fontSize: 12),)),
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                Visibility(
                  visible: show_replies_for_you[index],
                  child: Container(
                    child: ListView.builder(itemBuilder: (context, i) {
                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              InkWell(
                                onTap:(){

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfile(
                                            user_id:for_you[index].replies[i].fromUserId
                                        ),
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top:10)
                                  ,child: for_you[index].replies[i].fromimageUrl !='' &&
                                    !for_you[index].replies[i].fromimageUrl.contains("default")

                                    ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(for_you[index].replies[i].fromimageUrl),
                                ): Container(
                                    height: 40,
                                    width: 40,
                                    alignment: Alignment.center,
                                    child:
                                    Text(initial_name.toUpperCase(),
                                      style: TextStyle(color: Colors.white,
                                          fontSize: 18, fontWeight: FontWeight.normal),),

                                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                                      gradient: new LinearGradient(
                                          colors: [ Color(0xffababab),
                                            Color(0xff686868)],
                                          begin: FractionalOffset.topCenter,
                                          end: FractionalOffset.bottomCenter,
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp
                                      ),) ),

                                ),
                              ),


                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Container(
                                      child: InkWell(
                                        onTap:(){

                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => UserProfile(
                                                    user_id:for_you[index].replies[i].fromUserId
                                                ),
                                              ));

                                      },
                                        child: Text(for_you[index].replies[i].fromUserName, style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(top: 10),
                                    ),

                                    Container(
                                      margin: EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text(for_you[index].replies[i].reply,
                                          style:
                                          TextStyle(
                                              fontSize: 14, color: Colors.black)),
                                    ),

                                    Row(
                                      children: <Widget>[
//                                  Image.asset(
//                                    'assets/images/solution/comment.png',
//                                    color: Colors.black,
//                                    height: 15,
//                                    width: 15,
//                                  ),
//                                  Container(
//                                      padding: EdgeInsets.only(
//                                          left: 5,
//                                          right: 10,
//                                          top: 10,
//                                          bottom: 10),
//                                      child: Text(
//                                        "5"+' Replies',
//                                        style: TextStyle(
//                                            color: Colors.black, fontSize: 12),
//                                      )),

                                        Expanded(
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                config.Config.get_duration(for_you[index].replies[i].createdTime), style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),)),
                                        )
                                      ],
                                    ),
                                    Container(height: 0.2, color: Colors.grey,
                                      margin: EdgeInsets.only(top: 10),)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                    }, itemCount: for_you[index].replies.length, shrinkWrap: true,
                      physics: ClampingScrollPhysics(),),
                  ),
                )

              ],
            ),
          ),
        );
      }, itemCount: for_you.length,);
    }
  }


  Widget you_asked_() {
    if (you_asked.length == 0) {
      return Center(
        child: Text("No Enquiries Yet"),
      );
    } else {
      return ListView.builder(itemBuilder: (context, index) {

        String initial_name = config.Config.get_initial_name(
            you_asked[index].fromUserName);

        return InkWell(
          onTap: (){

            setState(() {
              show_replies_you_asked[index] = !show_replies_you_asked[index];
            });
          },
          child: Container(
            child: Column(
              children: <Widget>[
                Container(height: 0.2,color: Colors.white,),
                Container(
                  color: Color(0xff666666),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[


                        InkWell(
                          onTap:(){

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfile(
                                      user_id:you_asked[index].fromUserId
                                  ),
                                ));

                          },
                          child: Container(
                            margin: EdgeInsets.only(top:10)
                            ,child: you_asked[index].fromUserimageUrl !='' &&
                              !you_asked[index].fromUserimageUrl.contains("default")

                            ? CircleAvatar(
                            radius: 20,

                            backgroundImage: NetworkImage(you_asked[index].fromUserimageUrl ),
                          ): Container(
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              child:
                              Text(initial_name.toUpperCase(),
                                style: TextStyle(color: Colors.white,
                                    fontSize: 18, fontWeight: FontWeight.normal),),

                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                                gradient: new LinearGradient(
                                    colors: [ Color(0xffababab),
                                      Color(0xff686868)],
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    stops: [0.0, 1.0],
                                    tileMode: TileMode.clamp
                                ),) ),

                          ),
                        ),

                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[

                              Container(
                                child: InkWell(
                                  onTap:(){

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfile(
                                              user_id:you_asked[index].fromUserId
                                          ),
                                        ));

                                  },
                                  child: Text(you_asked[index].fromUserName, style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                  ),
                                ),
                                margin: EdgeInsets.only(top: 10),
                              ),

                              Container(
                                margin: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(you_asked[index].enquiry,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ),

                              Row(
                                children: <Widget>[


                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                Replies(
                                                  query_id:you_asked[index].id,
                                                  query: you_asked[index].enquiry,
                                                    time: you_asked[index].createdTime,
                                                    replies: you_asked[index].replies,
                                                  from_name: you_asked[index].toUserName,
                                                  from_image:you_asked[index].toUserimageUrl

                                                ),
                                          ));
                                    },
                                    child: Row(
                                      children: <Widget>[

                                        Image.asset(
                                          'assets/images/solution/comment.png',
                                          color: Colors.white,
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
                                              you_asked[index].replies.length.toString()+ ' Replies',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  decoration: TextDecoration.underline,
                                                  fontSize: 12),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(config.Config.get_duration(you_asked[index].createdTime), style: TextStyle(
                                            color: Colors.white, fontSize: 12),)),
                                  )
                                ],
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                Visibility(
                  visible:  show_replies_you_asked[index] ,
                  child: Container(
                    child: ListView.builder(itemBuilder: (context, i) {

                      String initial_name2 = config.Config.get_initial_name(
                          you_asked[index].replies[i].fromUserName);

                      return Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                onTap:(){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfile(
                                          user_id:you_asked[index].replies[i].fromUserId
                                        ),
                                      ));
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top:10)
                                  ,child: you_asked[index].replies[i].fromimageUrl !=''
                                    && !you_asked[index].replies[i].fromimageUrl.contains("default")


                                    ? CircleAvatar(
                                  radius: 20,

                                  backgroundImage: NetworkImage(you_asked[index].replies[i].fromimageUrl),
                                ): Container(
                                    height: 40,
                                    width: 40,
                                    alignment: Alignment.center,
                                    child:
                                    Text(initial_name2.toUpperCase(),
                                      style: TextStyle(color: Colors.white,
                                          fontSize: 18, fontWeight: FontWeight.normal),),

                                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                                      gradient: new LinearGradient(
                                          colors: [ Color(0xffababab),
                                            Color(0xff686868)],
                                          begin: FractionalOffset.topCenter,
                                          end: FractionalOffset.bottomCenter,
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp
                                      ),) ),

                                ),
                              ),

                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[

                                    Container(
                                      child: Text(you_asked[index].replies[i].fromUserName, style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                      ),
                                      margin: EdgeInsets.only(top: 10),
                                    ),

                                    Container(
                                      margin: EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text(you_asked[index].replies[i].reply,
                                          style:
                                          TextStyle(
                                              fontSize: 14, color: Colors.black)),
                                    ),

                                    Row(
                                      children: <Widget>[

                                        Expanded(
                                          child: Container(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                config.Config.get_duration(you_asked[index].replies[i].createdTime), style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12),)),
                                        )
                                      ],
                                    ),
                                    Container(height: 0.2, color: Colors.grey,
                                      margin: EdgeInsets.only(top: 10),)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },  itemCount: you_asked[index].replies.length, shrinkWrap: true,
                      physics: ClampingScrollPhysics(),),
                  ),
                ),
              ],
            ),
          ),
        );
      }, itemCount: you_asked.length,);
    }
  }
}