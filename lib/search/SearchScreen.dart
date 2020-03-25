import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/profile/UserProfile.dart';
import 'package:plunes/search/searchmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

String search= config.Config.search + 'search';

Future<PostsSearchList> Search_api(var body, var token) async {

  var header = {
    "Accept": "application/json",
    "Authorization":"Bearer "+token
  };

  final response = await http.post(search, body: json.encode(body), headers: header);

  print(token.toString());
  print(response.statusCode);


  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON
    var data = json.decode(response.body);
    print("search response: "+data.toString());
    return PostsSearchList.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class PostsSearchList {

  final List<Postdata> posts;
  final bool empty;
  final String Query;
  PostsSearchList({
    this.posts,this.empty, this.Query
  });

  factory PostsSearchList.fromJson(Map<String, dynamic> parsedJson) {
    bool empty_data = parsedJson['empty'];

    if(!empty_data){

      List<Postdata> posts = new List<Postdata>();

      posts = List<Postdata>.from(parsedJson['data'].map((i)=>Postdata.fromJson(i)));

      return new PostsSearchList(
          posts: posts,
          empty: parsedJson['empty']
      );
    }else{
      return new PostsSearchList(
          empty: parsedJson['empty']
      );
    }
  }
}

class Postdata {

  final String ID;
  final String name;
  final String ProfessionalImageUrl;
  final String Speciality;
  final String UserType;
  final bool Inutility;
  final String ImageUrl;
  final String  Experience;


  Postdata({this.ID, this.name,
    this.ProfessionalImageUrl, this.Speciality,
    this.UserType, this.ImageUrl, this.Experience,
  this.Inutility});

  factory Postdata.fromJson(Map<String, dynamic> json) {

    return new Postdata(
        ID:json['ID'],
        name: json['Name'],
        ProfessionalImageUrl: json['ProfessionalImageUrl'],
        Speciality: json['Specialist'],
        UserType: json['UserType'],
        ImageUrl: json['ImageUrl'],
        Experience: json['Experience'],
        Inutility: json['InUtility']
    );
  }
}

class SearchScreen extends StatefulWidget {
  static const tag = 'search_screen';
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  TextEditingController search_controler = TextEditingController();
  String user_token="";
  String user_id = "";
  bool icons = true;
  //PostsList postsList;
  List _special_lities= new List();

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _speciality="";
  String bio = "";
  bool show_drop = false;
  bool show_prof = false;
  bool call = false;

  String professional= "";

  // here we are creating the list needed for the DropDownButton
  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();

    for (String speciality in _special_lities) {
      // here we are creating the drop down menu items, you can customize the item right here
      // but I'll just use a simple text for this
        items.add(new DropdownMenuItem(value: speciality,
            child: new Text(speciality,
              style: TextStyle(fontSize: 12, color: Colors.black,),)
        ),
      );
    }
    return items;
  }


  void add_utility_api(String utility_id, String name) async{
    print(utility_id);

    Navigator.pop(context);
    String url = config.Config.profile+'add_utility';



    var body = {
      "user_id": user_id,
      "utility_id": utility_id
    };



    AddUtilityPost addUtilityPost = await add_utility(url, body, user_token);


    if(addUtilityPost.success){

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (
            BuildContext context,
            ) =>
            succes_add_utility(context, name),
      );


    }else{

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (
            BuildContext context,
            ) =>
            failed_add_utility(context, name),
      );
    }



  }


  getSharedPreferences() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {
      user_token = token;
      user_id = uid;
    });

    _special_lities.add("Choose Speciality");
    _special_lities.addAll(config.Config.specialist_lists);
    _dropDownMenuItems = getDropDownMenuItems();
    _speciality = _dropDownMenuItems[0].value;

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi ) {

      setState(() {
        call = true;
      });

    }else{

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (
            BuildContext context,
            ) =>
            _popup_no_internet(context),
      );

    }
  }

  @override
  void initState() {
    super.initState();

    getSharedPreferences();

  }


  void changedDropDownItems(String selectedCity) {



    setState(() {
      _speciality = selectedCity;
    });
  }


  @override
  Widget build(BuildContext context) {

    var  body;
    if(_speciality == 'Choose Speciality'){
        body = {
        "keyword":search_controler.text,
        "userid":user_id,
        "speciality": "",
        "count":"100"
      };
    }else{
        body = {
        "keyword":search_controler.text,
        "userid":user_id,
        "speciality": _speciality,
        "count":"100"
      };
    }



    final search = Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(13)),
              border: Border.all(width: 1, color: Color(0xff01d35a))),
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 15.0, top: 15, bottom: 15, right: 30),
            child: TextField(
              autofocus: true,
              style: TextStyle(fontSize: 14),
              controller: search_controler,
              decoration: InputDecoration.collapsed(hintText: 'Search'),
              onChanged: (text) {
                setState(() {

                  if(text == ''){
                    icons = true;
                  }else{
                    icons = false;
                  }
                });
              },
            ),
          ),
        ),


        Align(
          child: Container(
            child: InkWell(
              onTap: (){
                setState(() {
                  search_controler.text = "";
                  icons = true;
                });
              },
              child: icons?  Icon(
                Icons.search,size: 21,
                color: Color(0xff616161),
              ): Icon(Icons.close, size: 21,color: Color(0xff616161),),
            ),
            padding: EdgeInsets.only(right: 20, top: 25),
          ),
          alignment: Alignment.centerRight,
        ),



      ],
    );



    final speciality = Container(
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.only(left: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Color(0xffBDBDBD), width: 0.5),),

      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Theme(

          data: Theme.of(context).copyWith(
            brightness: Brightness.light,
            textSelectionColor: Colors.white,
            canvasColor: Colors.white,
            primaryColorBrightness: Brightness.dark,
          ),

          child: DropdownButtonFormField(

            hint: Text(
              "Choose Speciality", style: TextStyle(color: Colors.white),),
            value: _speciality,

            decoration: InputDecoration.collapsed(hintText: "Choose Speciality",
                hintStyle: TextStyle(color: Colors.black),
                hasFloatingPlaceholder: true, fillColor: Colors.white),
            items: _dropDownMenuItems,
            onChanged: changedDropDownItems,
          ),
        ),
      ),
    );

    final filter = Container(
      child: Padding(
        padding: const EdgeInsets.only(left:8.0),
        child: Container(
          margin: EdgeInsets.only(right: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xff01d35a)),
                  child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text("Doctors", style: TextStyle(color: Colors.white),)
                  ),
                ),

              ),

              Expanded(flex:2,child: speciality),
            ],
          ),
        ),
      ),
    );

    final search_lists =  call? Expanded(
      child: FutureBuilder<PostsSearchList>(
        future: Search_api(body,user_token ),
        builder: (BuildContext  context,AsyncSnapshot<PostsSearchList> snapshot){
          if(snapshot.hasData){
            if(snapshot.data.empty){
              return Center(child: Text("No results"));
            }else{
              return Container(
                margin: EdgeInsets.only(top:20),
                child: ListView.builder(itemBuilder: (context, index){
                  return Container(
                    padding: EdgeInsets.only(right: 10, left: 10),
                    child: Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          GestureDetector(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfile(
                                      user_id:snapshot.data.posts[index].ID,
                                    ),
                                  ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(top:10),




                              child: Stack(
                                children: <Widget>[

                                  Container(
                                      height: 50,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),
                                          color: Color(0xff989898)),
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(snapshot.data.posts[index].name.substring(0,1),
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),)),

                                  CircleAvatar(
                                    backgroundImage:NetworkImage(snapshot.data.posts[index].ImageUrl),
                                    backgroundColor: Colors.transparent,
                                    radius: 25,
                                    child: Visibility(
                                      visible: snapshot.data.posts[index].ImageUrl ==
                                          config.Config.default_img ||
                                          snapshot.data.posts[index].ImageUrl ==
                                              config.Config.default_img2||
                                          snapshot.data.posts[index].ImageUrl == '',

                                      child: Container(
                                          height: 50,
                                          decoration:
                                          BoxDecoration(borderRadius:
                                          BorderRadius.all(Radius.circular(30)),
                                                  gradient: new LinearGradient(
                                                      colors: [Color(0xffababab), Color(0xff686868)],
                                                      begin: FractionalOffset.topCenter,
                                                      end: FractionalOffset.bottomCenter,
                                                      stops: [0.0, 1.0],
                                                      tileMode: TileMode.clamp
                                                  ),
                                              color: Color(0xff989898)

                                          ),

                                          width: 50,
                                          alignment: Alignment.center,
                                          child: Text(snapshot.data.posts[index].name.substring(0,2).toUpperCase(),
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),



                          Expanded(child: Container(
                            margin: EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10,),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[


                                      Expanded(child: GestureDetector(
                                        onTap: (){
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => UserProfile(
                                                  user_id:snapshot.data.posts[index].ID,
                                                ),
                                              ));
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start
                                          ,children: <Widget>[
                                          Text(snapshot.data.posts[index].name, style:
                                          TextStyle(color: Colors.black, fontSize: 16, fontWeight:
                                          FontWeight.bold),),
                                          Text(snapshot.data.posts[index].Speciality, maxLines: 1,
                                            style: TextStyle(color: Colors.black38),),
                                          SizedBox(height: 10,),

                                          Row(
                                            children: <Widget>[
                                              Container(height: 5, width: 5,
                                                decoration: BoxDecoration(borderRadius:
                                                BorderRadius.all(Radius.circular(10)),
                                                 color: Color(0xff01d35a)),),
                                              SizedBox(width: 10,),

                                          double.parse(  snapshot.data.posts[index].Experience)< 40?
                                              Text(snapshot.data.posts[index].Experience+" years",
                                                style:
                                              TextStyle(color: Colors.black38, fontSize: 12),):

                                              Text("40+ years",
                                                style:
                                                TextStyle(color: Colors.black38, fontSize: 12),),
                                            ],
                                          ),
                                          SizedBox(height: 10,)
                                        ],
                                        ),
                                      )),


                                      SizedBox(width: 20,),

                                      Expanded(
                                        child: Container(


                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: <Widget>[

                                          snapshot.data.posts[index].Inutility?    GestureDetector(
                                                onTap: (){



                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    builder: (
                                                        BuildContext context,
                                                        ) =>
                                                        _popup_add_utility(context,
                                                            snapshot.data.posts[index].ID,
                                                            snapshot.data.posts[index].name),
                                                  );
                                                },


                                                child: Container(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(bottom:10.0, left: 30),
                                                      child: Image.asset('assets/utility.png', height: 25, width: 25,),
                                                    )),
                                              ): Container(
                                              child: Padding(
                                                padding: const EdgeInsets.only(bottom:10.0, left: 30),
                                                child: Image.asset('assets/utility.png', height: 25, width: 25,),
                                              )),

                                              Text("", maxLines: 1,
                                                style: TextStyle(color: Colors.black38),),
                                              Text("1.2 Kms away", style: TextStyle(fontSize: 12, color: Colors.black45),)
                                              ,SizedBox(height: 10,),
                                            ],
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),

                                Container(
                                    color: Color(0xffBDBDBD),
                                    height: 0.5)
                              ],

                            ),



                          )),

                        ],
                      ),
                    ),

                  );

                },
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: snapshot.data.posts.length,
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Text("");
          }

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
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    ):Container();

    final form = Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: <Widget>[

          search,
          filter,
          search_lists

        ],
      ),
    );


    return Scaffold(
        backgroundColor: Colors.white,
        body:form
    );

  }



  Widget failed_add_utility(BuildContext context, String name){
    return CupertinoAlertDialog(
        title: new Text("Failed"),
        content: Container(
          child: Column(

            children: <Widget>[

              SizedBox(height: 10,),
              Image.asset(
                "assets/images/bid/failed.png", height: 40, width: 40,),
              SizedBox(height: 10,),
              Center(
                child: Text("Could not add utility"),
              )
            ],
          ),
        ),

        actions: [
          CupertinoDialogAction(
            textStyle: TextStyle(color: Color(0xff01d35a)),
            isDefaultAction: true,
            child: new Text("OK"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ]);
  }



  Widget succes_add_utility(BuildContext context, String name){
   return CupertinoAlertDialog(
        title: new Text("Successfully Added"),
        content: Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 10,),
              Image.asset(
                "assets/images/bid/check.png", height: 50, width: 50,),
              SizedBox(height: 10,),
              Center(
                child: Text("$name successfully added in your utility network. "),
              ),
            ],
          ),
        ),


        actions: [
          CupertinoDialogAction(
            textStyle: TextStyle(color: Color(0xff01d35a)),
            isDefaultAction: true,
            child: new Text("OK"),
            onPressed: () {
              Navigator.pop(context);

            },
          ),
        ]);
  }


  Widget _popup_add_utility(BuildContext context, String utility_id, String name) {

    return new CupertinoAlertDialog(
      content: Column(
        children: <Widget>[
          Text("Add to utility", style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),),
          SizedBox(height: 5,),
          Text("Do you want to add Dr. $name to your utility network?"),

          SizedBox(height: 20,),

          Row(
            children: <Widget>[

              Expanded(child: GestureDetector(
                onTap: (){
                  add_utility_api(utility_id, name);
                },
                child: Container(
                  child: Text("Yes", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                  alignment: Alignment.center,
                  height: 35,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),color: Color(0xff01d35a)),
                ),
              )),


              SizedBox(width: 20,),

              Expanded(child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                  child: Text("No", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),),
                  alignment: Alignment.center,
                  height: 35,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(width: 1, color: Colors.grey)),
                ),
              )),



            ],

          )

        ],
      ),
//      actions: <Widget>[
//        new FlatButton(
//          onPressed: () {
//            Navigator.pop(context);
//            Navigator.pop(context);
//
//          },
//          child: new Text(
//            'OK',
//            style: TextStyle(color: Color(0xff01d35a)),
//          ),
//        ),
//      ],
    );
  }

  Widget _popup_no_internet(BuildContext context) {
    return new CupertinoAlertDialog(

      title: new Text('No Internet'),
      content: new Text("Can't connect to the Internet "),

      actions: <Widget>[

        new FlatButton(
          onPressed: () {
            Navigator.pop(context);
            getSharedPreferences();
          },
          child: new Text('Try Again', style: TextStyle(color: Color(0xff01d35a)),),
        ),

      ],
    );
  }

}
