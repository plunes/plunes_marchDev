import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:plunes/appointment/Appointments.dart';
import 'package:plunes/help/HelpOption.dart';
import 'package:plunes/model/CouponsModel.dart';
import 'package:plunes/plocker/PlockrMainScreen.dart';
import 'package:plunes/refer/ReferScreen.dart';
import 'package:plunes/solution/BiddingScreen.dart';
import 'package:plunes/model/profile/logout.dart';
import 'package:plunes/plocker/PlockerScreen.dart';
import 'package:plunes/profile/MyProfileScreen.dart';
import 'package:plunes/start_streen/Nearyou.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plunes/start_streen/Allevents.dart';
import 'package:plunes/notification/NotificationScreen.dart';
import 'package:plunes/settings/SettingsScreen.dart';
import 'package:plunes/manage_payment/ManagePayment.dart';
import 'package:plunes/aboutus/AboutUs.dart';
import 'package:plunes/config.dart' as config;
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plunes/availability/Businesshours.dart';
import 'package:plunes/check_net.dart';
import 'package:plunes/enquiry/MainSolutionScreen.dart';
import '../Coupons.dart';
import '../config.dart';


class HomeScreen extends StatefulWidget {
  static const tag = '/homescreen';
  final String screen;

  HomeScreen({Key key, this.screen}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState(screen);
}

class _HomeScreenState extends State<HomeScreen> {
  String user_token;
  String user_name = "";
  String screen;
  String user_id = "";
  static String user_type = "";
  String user_email = "";
  String initial_name = "";

  bool no_internet = false;

  _HomeScreenState(this.screen);
  Check_Internet net = new Check_Internet();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;
  int count = 0;
  bool show_badge = false;
  bool progress = false;
  String imageUrl = "";

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    String name = prefs.getString("name");
    String email = prefs.getString("email");
    String type = prefs.getString("user_type");
    String image = prefs.getString("imageUrl");

    setState(() {
      imageUrl = image;
      user_name = name;
      user_token = token;
      user_id = uid;
      user_type = type;
      user_email = email;
    });

    save();
    if(user_type!='Hospital'){
      if (screen == 'bids') {
        _selectedIndex = 0;
      }  else if (screen == 'plockr') {
        _selectedIndex = 1;
      } else if (screen == 'notification') {
        _selectedIndex = 2;
      } else if (screen == 'profile') {
        _selectedIndex = 3;
      }}else {
      if (screen == 'bids') {
        _selectedIndex = 0;
      }  else if (screen == 'notification') {
        _selectedIndex = 1;
      } else if (screen == 'profile') {
        _selectedIndex = 2;
      }
    }
  initial_name = config.Config.get_initial_name(name);
  }

  final List<Widget> _widgetOptions = [
    BiddingPage(),
    //MainSolutionScreen(),
    PlockrMainScreen(),
    NotificationScreen(),
    MyProfileScreen()
  ];
  final List<Widget> _widgetOptionsHospital = [
    BiddingPage(),
    NotificationScreen(),
    MyProfileScreen()
  ];
  save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("home", "done");
    prefs.setString("guide_tour", "done");
    PermissionStatus permission = await LocationPermissions().requestPermissions();
  }

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }


  void logout() async {
    closeDrawer();
    confirmationDialog(context, 'Do you want to logout?');
  }

  void closeDrawer() {
    if( _scaffoldKey.currentState.isDrawerOpen)
      _scaffoldKey.currentState.openEndDrawer();
  }
  void _logout() async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove("home");
    preferences.remove("guide_tour");
    preferences.remove("token");
    preferences.remove("uid");
    preferences.remove("name");
    preferences.remove("email");
    preferences.remove("phoneno");
    preferences.remove("user_type");
    preferences.remove("user_location");
    preferences.remove("specialist");
    preferences.remove("imageUrl");
    preferences.remove("coverUrl");
    preferences.clear();
    Navigator.popAndPushNamed(context, Allevents.tag);
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;
    final drawer = Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top:20),
                    child: InkWell(

                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          if(user_type!='Hospital')
                          _selectedIndex = 3;
                          else
                            _selectedIndex = 2;

                        });
                      },

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 10,),

                          imageUrl!='' && imageUrl != null ? CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(imageUrl),
                            ): Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                child:
                                Text(initial_name.toUpperCase(),
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 18, fontWeight: FontWeight.normal),),
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                                  gradient: new LinearGradient(
                                      colors: [Color(0xffababab), Color(0xff686868)],
                                      begin: FractionalOffset.topCenter,
                                      end: FractionalOffset.bottomCenter,
                                      stops: [0.0, 1.0],
                                      tileMode: TileMode.clamp
                                  ),)),
                          Container(
                            width: 200,
                            margin: EdgeInsets.only(left: 10, top: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Text(
                                  user_name.trimLeft(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),

                              /*  user_type == 'User' ? Container(
                                    width: 150,
                                    child: Text(user_email, maxLines: null, style: TextStyle(fontWeight: FontWeight.w500,
                                        color: Colors.black, fontSize: 16),)

                                ) :    Container(
                                  width: 150,
                                  child: Text(user_email, maxLines: null, style: TextStyle(fontWeight: FontWeight.w500,
                                      color: Colors.black, fontSize: 16),),
                                )*/
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                  user_type == 'User' ? Container() :    Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ),

                  user_type == 'User' ? Container() : ListTile(
                    onTap: (){

                      Navigator.pop(context);

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusinessHours(url: config.Config.user+"/"+user_id+"/timeSlots"),
                          ));

                    },
                    trailing: Text(""),
                    leading: Image.asset('assets/images/nav/availability.png', height: 25, width: 25,),
                    title: Text("My Availability", style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16),),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ),


                  ListTile(
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Appointments(screen: 0,),));
                    },
                    leading: Image.asset('assets/images/nav/appintment.png', height: 25, width: 25,),
                    title: Text("Appointments",style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16)),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ),

                  ListTile(
                    onTap: () {
                      Navigator.popAndPushNamed(context, SettingScreen.tag);
                    },
                    leading:  Image.asset('assets/images/nav/settings.png', height: 25, width: 25,),
                    title: Text("Settings",style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16)),
                  ),


                  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ),

                  user_type == 'User'?Container() : ListTile(
                    onTap: (){
                      Navigator.popAndPushNamed(context, ManagePayments.tag);
                    },
                    leading: Image.asset('assets/images/nav/payments.png', height: 25, width: 25,),
                    title: Text("Manage Payment",style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16)),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ),

                  ListTile(
                    onTap: (){
                      Navigator.popAndPushNamed(context, HelpOptions.tag);
                    },
                    leading:  Image.asset('assets/images/nav/help.png', height: 25, width: 25,),
                    title: Text("Help",style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16)),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ),

                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(PageRouteBuilder(opaque: false, pageBuilder: (BuildContext context, _, __) => AboutUs()));
                    },
                    leading: Image.asset('assets/images/nav/about.png', height: 25, width: 25,),
                    title: Text("About Us",style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16)),
                  ),

                  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ),

                  user_type != 'Hospital' ?  ListTile(
                    onTap: () {

                    Navigator.popAndPushNamed(context, ReferScreen.tag);

                    },
                    leading: Image.asset('assets/images/refer/refer.png', height: 25, width: 25,),
                    title: Text("Refer & Earn",style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16)),
                  ): Container(),

                  user_type != 'Hospital' ?  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ): Container(),
                  user_type != 'Hospital' ? ListTile(
                    onTap: () {
                      Navigator.popAndPushNamed(context, Coupons.tag);
                    },
                    leading: Image.asset('assets/images/coupons.png', height: 25, width: 25,),
                    title: Text("Coupons",style: TextStyle(fontWeight: FontWeight.w500,
                        color: Colors.black, fontSize: 16)),
                  ): Container(),

                  user_type != 'Hospital' ?  Container(
                    margin: EdgeInsets.only(left: 70),
                    color: Color(0xffdedede),
                    height: 0.5,
                  ): Container(),

                 progress? ListTile(
                   onTap: logout,
                   title: SpinKitThreeBounce(
                     color: Color(0xff01d35a),
                     size: 30.0,
                   ),
                    ): ListTile(
                    onTap: logout,
                    leading:  Image.asset('assets/images/nav/logout.png', height: 25, width: 25,),
                    title: Text("Log out",style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 16)),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, Nearyou.tag);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      color: Color(0xffdedede),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("People availing offers near you",
                          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),),
                      )),
                  )

                ],
              ),
            ),
          ),
        ],
      ),
    );

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title:user_type != 'Hospital' ? Text(_selectedIndex == 1?"PLOCKR":_selectedIndex == 2? "Notification": _selectedIndex == 3? "My Profile":'',
        style: TextStyle(
            color: Color(0xff333333),
            fontWeight: FontWeight.normal,
            fontSize: 17),
      ): Text(_selectedIndex == 1?"Notification":_selectedIndex == 2? "My Profile": '',
        style: TextStyle(
            color: Color(0xff333333),
            fontWeight: FontWeight.normal,
            fontSize: 17),
      ),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    );

    final select_widgets = Container(
      color: Colors.white,
      child: user_type!='Hospital'? _widgetOptions[_selectedIndex]: _widgetOptionsHospital[_selectedIndex]
    );


    final No_Internet = Container(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,

          children: <Widget>[
            Text(
              "Can't connect to the Internet", style: TextStyle(fontSize: 16),),
            SizedBox(height: 15,),
            InkWell(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              onTap: () {
                getSharedPreferences();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: Color(0xff01d35a)),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 8, bottom: 8),
                  child: Text(
                    "Try Again", style: TextStyle(color: Colors.white),),
                ),
              ),
            )

          ],
        ),
      ),
    );

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: app_bar,

        key: _scaffoldKey,
        drawer: drawer,
        body: no_internet ? No_Internet : select_widgets,
        bottomNavigationBar:   user_type != 'Hospital' ? getBottomNavigationView(): getBottomNavigationHospitalView()
      )
    );
  }
  Widget getBottomNavigationHospitalView(){
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      items: <BottomNavigationBarItem>[

        BottomNavigationBarItem(

          icon: Image.asset(
            'assets/images/bottom_tabs/bid.png',
            height: 32,
            width: 32,
          ),
          title: Text(
            'SOLUTION',
            style: TextStyle(fontSize: 11),
          ),
          activeIcon: Image.asset(
            'assets/images/bottom_tabs/bid_active.png',
            height: 32,
            width: 32,
          ),
        ),

//            BottomNavigationBarItem(
//              icon: Image.asset(
//                'assets/images/bottom_tabs/solution.png',
//                height: 32,
//                width: 32,
//              ),
//              title: Text(
//                'ENQUIRY',
//                style: TextStyle(fontSize: 11),
//              ),
//              activeIcon: Image.asset(
//                'assets/images/bottom_tabs/solution-active.png',
//                height: 32,
//                width: 32,
//              ),
//            ),

        BottomNavigationBarItem(
          activeIcon: Image.asset(
            'assets/images/bottom_tabs/notification_active.png',
            height: 32,
            width: 32,
          ),
          icon: show_badge
              ? new Stack(
            children: <Widget>[
              new Image.asset(
                'assets/images/bottom_tabs/notification.png',
                height: 32,
                width: 32,
              ),
              new Positioned(
                right: 0,
                child: new Container(
                  height: 18,
                  width: 18,
                  padding: EdgeInsets.all(5),
                  decoration: new BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: new Text(
                    count.toString(),
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          )
              : Image.asset(
            'assets/images/bottom_tabs/notification.png',
            height: 32,
            width: 32,
          ),
          title: Text('NOTIFICATION', style: TextStyle(fontSize: 11)),
        ),

        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/bottom_tabs/profile.png',
            height: 32,
            width: 32,
          ),
          activeIcon: Image.asset(
            'assets/images/bottom_tabs/profile-active.png',
            height: 32,
            width: 32,
          ),
          title: Text('PROFILE', style: TextStyle(fontSize: 11)),
        ),

      ],

      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      //selectedFontSize: 10,
      selectedItemColor: Color(0xff34d767),
      currentIndex: _selectedIndex,
      onTap: (index){
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }


  Widget getBottomNavigationView(){
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      items: <BottomNavigationBarItem>[

        BottomNavigationBarItem(

          icon: Image.asset(
            'assets/images/bottom_tabs/bid.png',
            height: 32,
            width: 32,
          ),
          title: Text(
            'SOLUTION',
            style: TextStyle(fontSize: 11),
          ),
          activeIcon: Image.asset(
            'assets/images/bottom_tabs/bid_active.png',
            height: 32,
            width: 32,
          ),
        ),

//            BottomNavigationBarItem(
//              icon: Image.asset(
//                'assets/images/bottom_tabs/solution.png',
//                height: 32,
//                width: 32,
//              ),
//              title: Text(
//                'ENQUIRY',
//                style: TextStyle(fontSize: 11),
//              ),
//              activeIcon: Image.asset(
//                'assets/images/bottom_tabs/solution-active.png',
//                height: 32,
//                width: 32,
//              ),
//            ),

       BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/plockr/plockr_unselected.png',
            height: 32,
            width: 32,
          ),
          title: Text(
            'PLOCKR',
            style: TextStyle(fontSize: 11),
          ),
          activeIcon: Image.asset(
            'assets/images/plockr/plockr_selected.png',
            height: 32,
            width: 32,
          ),
        ),

        BottomNavigationBarItem(
          activeIcon: Image.asset(
            'assets/images/bottom_tabs/notification_active.png',
            height: 32,
            width: 32,
          ),
          icon: show_badge
              ? new Stack(
            children: <Widget>[
              new Image.asset(
                'assets/images/bottom_tabs/notification.png',
                height: 32,
                width: 32,
              ),
              new Positioned(
                right: 0,
                child: new Container(
                  height: 18,
                  width: 18,
                  padding: EdgeInsets.all(5),
                  decoration: new BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: new Text(
                    count.toString(),
                    style: new TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          )
              : Image.asset(
            'assets/images/bottom_tabs/notification.png',
            height: 32,
            width: 32,
          ),
          title: Text('NOTIFICATION', style: TextStyle(fontSize: 11)),
        ),

        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/bottom_tabs/profile.png',
            height: 32,
            width: 32,
          ),
          activeIcon: Image.asset(
            'assets/images/bottom_tabs/profile-active.png',
            height: 32,
            width: 32,
          ),
          title: Text('PROFILE', style: TextStyle(fontSize: 11)),
        ),

      ],

      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      //selectedFontSize: 10,
      selectedItemColor: Color(0xff34d767),
      currentIndex: _selectedIndex,
      onTap: (index){
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  confirmationDialog(BuildContext context, String action) {
    return showGeneralDialog<bool>(
        barrierColor: Colors.black.withOpacity(0.3),
        transitionBuilder: (context, a1, a2, widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Container(
                    margin: EdgeInsets.fromLTRB(25, 10, 10, 0),
                    child: Text(action)),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(
                      "No",
                      style: TextStyle(color: Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false); // showDialog() returns false
                    },
                  ),
                  new FlatButton(
                    child: new Text(
                      "Yes",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async{
                      Navigator.pop(context);
                      setState(() {
                        progress = true;
                      });

                    await logout_api( user_id, user_token).catchError((error){
                        config.Config.showLongToast("Something went wrong!");

                        setState(() {
                          progress = false;
                          _logout();
                        });
                      });
                      _logout();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
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
    ) ??
        false;
  }
}
