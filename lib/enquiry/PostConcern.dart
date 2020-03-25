import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/enquiry/get_docs_byspeciality.dart';
import 'package:plunes/model/enquiry/post_enquery.dart';
import 'package:plunes/profile/UserProfile.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../config.dart';

typedef CallBackFromPopup = void Function(bool flag, String from);

class PostConcern extends StatefulWidget {
  static const tag = "postconcern";
  final String choose;

  PostConcern({Key key, this.choose}) : super(key: key);

  @override
  _PostConcernState createState() => _PostConcernState(choose);
}

class _PostConcernState extends State<PostConcern> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  bool cancel = false;
  List data = new List();

  String user_token = "";
  String user_id = "";
  String image_url = "";
  String user_name = "";
  List _specialists = new List();
  String _specialist = "";

  TextEditingController _concern = new TextEditingController();
  bool valid_concern = true;
  bool progress = false;
  bool isSwitched = false;
  static final url = config.Config.solution + "postquery";

  String choose;

  bool isPopup = false;
  var pName = '', pSpeciality = '', pId = '';

  _PostConcernState(this.choose);

  var image;

  List<DropdownMenuItem<String>> _dropDownMenuItems;

  // here we are creating the list needed for the DropDownButton

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();

    for (String user in _specialists) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
      items.add(new DropdownMenuItem(value: user, child: new Text(user)));
    }
    return items;
  }

  @override
  void initState() {
    // TODO: implement initState
    _specialists.addAll(config.Config.specialist_lists);
    _dropDownMenuItems = getDropDownMenuItems();
    _specialist = _dropDownMenuItems[0].value;

    setState(() {
      _specialist = choose;
    });

    getSharedPreferences();
    super.initState();
  }

  void changedDropDownItem(String choose) {
    setState(() {
      _specialist = choose;
    });
  }

  filter_data(String text) {
    print(config.Config.specialist_lists.length);
    data.clear();
    for (int i = 0; i < config.Config.specialist_lists.length; i++) {
      if (config.Config.specialist_lists[i]
          .toString()
          .toLowerCase()
          .contains(text)) {
        data.add(config.Config.specialist_lists[i]);

        // data.add(config.Config.procedure_lists[i]);
      }
    }
    print(data.length);
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
      image_url = img;
      user_name = name;
    });
  }



  Widget  _submittedDialog(BuildContext context) {
    return new AlertDialog(
      content: Container(
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          // shrinkWrap: true,
          mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            Container(
              child: InkWell(
                child: Icon(
                  Icons.clear,
                  color: Colors.black,
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(screen: "consult"),
                      ));

                },
              ),
              alignment: Alignment.topRight,
            ),

            Container(
              child: Image.asset(
                'assets/concern.png',
                height: 100,
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Container(
              child: Text(
                "Your Enquiry has been submitted",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            SizedBox(height: 20),

            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Text(
                "We will notify you soon.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      centerTitle: true,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        "Enquiry",
        style: TextStyle(color: Colors.black),
      ),
    );


    final choose_speciality = Container(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(width: 1, color: Color(0xff01d35a))),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField(
            value: _specialist,
            items: _dropDownMenuItems,
            decoration: InputDecoration.collapsed(hintText: null),
            onChanged: changedDropDownItem,
          ),
        ),
      ),
    );

    final form = Container(
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //search_procedure,
          choose_speciality,
          professionalLists(context)
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: app_bar,
      body: Stack(
        children: <Widget>[
          form,
          isPopup
              ? Container(
                  alignment: FractionalOffset.center,
                  color: const Color(0x88000000),
                  height: MediaQuery.of(context).size.height,
                  child: PostEnquiry(
                      p_name: pName,
                      p_speciality: pSpeciality,
                      p_id: pId,
                      onTap: (bool flag, String from) {
                        setState(() {
                          isPopup = false;
                        });
                        if (flag) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (
                              BuildContext context,
                            ) =>
                                _submittedDialog(context),
                          );
                        }
                      }),
                )
              : Container()

        ],
      ),
    );
  }

  Widget professionalLists(BuildContext context) {
    var body = {"keyword": _specialist, "userid": user_id};

    int pos = config.Config.specialist_lists.indexOf(_specialist);
    String specialisty_id = config.Config.specialist_id[pos];
    print(body);

    return Expanded(
      child: FutureBuilder<GetDoctors_specialisty>(
        future: get_docs_byspeciality(specialisty_id, user_token),
        builder:
            (BuildContext context, AsyncSnapshot<GetDoctors_specialisty> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.posts.length == 0) {
              return Center(
                  child: Text(
                "No results",
                style: TextStyle(fontSize: 12),
              ));
            } else {

              return ListView.builder(
                itemBuilder: (context, index) {
                String initial_name = config.Config.get_initial_name(snapshot.data.posts[index].name);

                  return snapshot.data.posts[index].id != user_id ? Column(
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserProfile(
                                          user_id:
                                              snapshot.data.posts[index].id,
                                        ),
                                      ));
                                },
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(40)),
                                            color: Color(0xff989898),
                                            gradient: new LinearGradient(
                                            colors: [
                                              Color(0xffababab),
                                              Color(0xff686868)
                                            ],
                                            begin: FractionalOffset.topCenter,
                                            end: FractionalOffset.bottomCenter,
                                            stops: [0.0, 1.0],
                                            tileMode: TileMode.clamp)),
                                        width: 50,
                                        alignment: Alignment.center,
                                        child: Text(
                                          initial_name.toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.normal),
                                        )),
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          snapshot.data.posts[index].imageUrl),
                                      backgroundColor: Colors.transparent,
                                      radius: 30,
                                      child: Visibility(
                                        visible: snapshot.data.posts[index].imageUrl == config.Config.default_img ||
                                            snapshot.data.posts[index].imageUrl == config.Config.default_img2 ||
                                            snapshot.data.posts[index].imageUrl == '',
                                        child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(35)),
                                              gradient: new LinearGradient(
                                                  colors: [
                                                    Color(0xffababab),
                                                    Color(0xff686868)
                                                  ],
                                                  begin: FractionalOffset.topCenter,
                                                  end: FractionalOffset.bottomCenter,
                                                  stops: [0.0, 1.0],
                                                  tileMode: TileMode.clamp),
                                            ),
                                            width: 60,
                                            alignment: Alignment.center,
                                            child: Text(
                                              initial_name.toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.normal),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: 10, top: 5, bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserProfile(
                                                user_id:
                                                snapshot.data.posts[index].id,
                                              ),
                                            ));
                                      },
                                      child: Container(
                                        width: 180,
                                        child: Text(
                                          snapshot.data.posts[index].name,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: 180,
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              snapshot.data.posts[index].address,// specialisty
                                              style:
                                                  TextStyle(color: Colors.grey),
                                              maxLines: 1,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                         /*     Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            isPopup = !isPopup;
                                            pId = snapshot.data.posts[index].id;
                                          });
                                        },
                                        child: Container(
                                            width: 70,
                                            margin: EdgeInsets.only(top: 10),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 0.5)),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15,
                                                  right: 15,
                                                  top: 6,
                                                  bottom: 6),
                                              child: Text(
                                                "Ask",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ),

//                      Container(
//                        margin: EdgeInsets.only(left: 60),
//                        child: Row(
//                          children: <Widget>[
//                            Expanded(
//                              flex: 3,
//                              child: Row(
//                                children: <Widget>[
//
//
//                                  Container(
//                                    height: 20,
//                                    alignment: Alignment.center,
//                                    child: Stack(
//                                      children: <Widget>[
//                                        Padding(
//                                          padding: const EdgeInsets.only(left:12.0, right: 12),
//                                          child: Text(" Apreciate ", style: TextStyle(color: Colors.black,
//                                              fontSize: 10),),
//                                        ),
//                                      ],
//                                    ),
//                                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)), border: Border.all(color: Colors.grey, width: 0.3)),
//                                  ),
//                                  SizedBox(width: 5,),
//                                  Text("6", style: TextStyle(fontSize: 12),),
//
//                                ],
//                              ),
//                            ),
//
//                            SizedBox(width: 10,),
//                            Expanded(
//                              flex: 2,
//                              child: Row(
//                                children: <Widget>[
//
//                                  Icon(Icons.star, size: 12, color: Color(0xff01d35a),),
//                                  Icon(Icons.star, size: 12, color: Color(0xff01d35a),),
//                                  Icon(Icons.star, size: 12, color: Color(0xff01d35a),),
//                                  Icon(Icons.star_border, size: 12, color: Color(0xff01d35a),),
//                                  Icon(Icons.star_border, size: 12, color: Color(0xff01d35a),),
//
//
//                                ],
//                              ),
//                            ),
//                            Expanded(flex: 2, child: Container(
//                                alignment: Alignment.centerRight,
//                                child: Text("1.2 km away", style: TextStyle(color: Colors.grey, fontSize: 12),)))
//
//                          ],
//
//                        ),
//
//                      ),
//

                      Container(
                        margin: EdgeInsets.only(left: 60, top: 10),
                        height: 0.3,
                        color: Colors.grey,
                      ),
                    ],
                  ): Container();
                },
                itemCount: snapshot.data.posts.length,
                physics: ClampingScrollPhysics(),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                  "No results",
                  style: TextStyle(fontSize: 12),
                ));
          }
          // By default, show a loading spinner
          return ListView.builder(itemBuilder: (context, index) {
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
        },
      ),
    );
  }
}

class PostEnquiry extends StatefulWidget {
  final String p_name;
  final String p_speciality;
  final String p_id;
  final CallBackFromPopup onTap;

  PostEnquiry({Key key, this.p_name, this.p_speciality, this.p_id, this.onTap})
      : super(key: key);

  @override
  _PostEnquiryState createState() =>
      _PostEnquiryState(p_name, p_speciality, p_id);
}

class _PostEnquiryState extends State<PostEnquiry> {
  final String p_name;
  final String p_speciality;
  final String p_id;

  _PostEnquiryState(this.p_name, this.p_speciality, this.p_id);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  bool isSwitched = false;
  bool progress = false;
  final _concern = new TextEditingController();
  bool valid_concern = false;
  FocusNode _focus = new FocusNode();

  String base64_image = "";
  String user_id = "";
  String user_name = "";
  String user_token = "";
  String user_image = "";
  bool success = false;


  _submit_query() async {
    setState(() {
      progress = true;
    });

    var body = {
      "fromUserId": user_id,
      "toUserId": p_id,
      "enquiry": _concern.text
    };

    print(body);

    PostEnqueryPost postEnqueryPost = await post_enquery(body, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;
      if(postEnqueryPost.success){
        widget.onTap(postEnqueryPost.success, 'complete');
      }else{
        config.Config.showLongToast("Something went wrong!");
      }
    });

  }

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
      user_image = img;
      user_name = name;
    });
    print(token);
  }

  Widget _buildTextField() {
    return CupertinoTextField(
      padding: EdgeInsets.zero,
      controller: _concern,
      textCapitalization: TextCapitalization.sentences,
      placeholder: '',
      style: TextStyle(fontSize: 13),
      decoration: BoxDecoration(
        border: Border.all(
          width: 0.0,
          color: Colors.transparent,
        ),
      ),
      cursorColor: Color(0xff01d35a),
      maxLines: 4,
      maxLength: 200,
      keyboardType: TextInputType.text,
      onChanged: (text) {
        setState(() {
          if (text.length > 0) {
            valid_concern = false;
          } else {
            valid_concern = true;
          }
        });
      },
      prefix: const Padding(padding: EdgeInsets.symmetric(horizontal: 4.0)),
      autofocus: true,
      suffixMode: OverlayVisibilityMode.editing,
      onSubmitted: (String text)=> setState(()=> _concern.clear()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      alignment: FractionalOffset.center,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: CupertinoAlertDialog(
          content: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/2,
            child: Column(
//              physics: const NeverScrollableScrollPhysics(),
//              padding: EdgeInsets.zero,
//              shrinkWrap: true,
              children: <Widget>[
                Align(
                  child: Container(
                      child: InkWell(
                        child: Icon(
                          Icons.clear,
                          size: 20,
                        ),
                        onTap: () {
                          widget.onTap(false, 'finish');
                        },
                      )),
                  alignment: Alignment.topRight,
                ),
                Card(
                  child: Text(
                    "Post Enquiry",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  color: Colors.transparent,
                  elevation: 0,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    "Ask a Professional",
                    textAlign: TextAlign.center,
                  ),
                ),
               Container(
                 width: MediaQuery.of(context).size.width,
                 child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: <Widget>[
                   Expanded(child: Container(
                     width: MediaQuery.of(context).size.width,
                     margin: EdgeInsets.only(top: 10),
                     decoration: BoxDecoration(
                         borderRadius:
                         BorderRadius.all(Radius.circular(10)),
                         border: Border.all(
                             color: Color(0xffBDBDBD), width: 0.3)),
                     child: Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: _buildTextField()
                     ),
                   ),)
                 ],),),

                SizedBox(
                  height: 10,
                ),
                Align(
                    child: Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: progress
                            ? SpinKitThreeBounce(
                                color: Color(0xff01d35a),
                                size: 30.0,
                              )
                            : Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10)),
                                    color: Color(0xff01d35a)),
                                child: FlatButton(
                                  onPressed: () {
                                    if(_concern.text != ''){
                                      _submit_query();
                                    }
                                  },
                                  child: new Text(
                                    'Done',
                                    style: TextStyle(
                                        color: Colors.white),
                                  ),
                                ),
                              ))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
