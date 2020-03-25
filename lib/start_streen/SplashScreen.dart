import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:plunes/model/get_procedure.dart';
import 'package:plunes/start_streen/EnterPhoneScreen.dart';
import 'dart:async';
import '../config.dart';
import 'GuidedTour.dart';
import 'Allevents.dart';
import 'Registration.dart';
import 'HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:plunes/config.dart' as config;
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';

class SplashScreen extends StatefulWidget {
  static const tag = 'splash';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String guided_tour = prefs.getString("guide_tour");
    String home_screen = prefs.getString("home");
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi ) {
      tim(guided_tour, home_screen);
    }else{
      print("No Internet");
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _popup_no_internet(context));
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
  }


  void device() {
    if (Platform.isIOS) {
      print("this is ios device");
    } else if (Platform.isAndroid) {
      print('is a Andriod');
    }
  }

  void tim(String tour, String home)async {
    ProcedureLists procedureLists = await get_procedure().catchError((error){
      config.Config.showLongToast("Something went wrong!");
    });

    for(int i = 0; i< procedureLists.data.length; i++){
      for(int j =0; j< procedureLists.data[i].procedureData.length; j++){
        /// solution search
        config.Config.procedure_lists.add(procedureLists.data[i].procedureData[j].service +" ("+procedureLists.data[i].procedureData[j].category+")");
        config.Config.procedure_speciality.add(procedureLists.data[i].speciality+ procedureLists.data[i].procedureData[j].service);
        config.Config.solution_search.add(procedureLists.data[i].procedureData[j].details+""+ procedureLists.data[i].procedureData[j].service+""+ procedureLists.data[i].procedureData[j].category);
        config.Config.procedure_id.add(procedureLists.data[i].procedureData[j].id);
        config.Config.procedure_type.add(procedureLists.data[i].procedureData[j].category);
        config.Config.procedure_name.add(procedureLists.data[i].procedureData[j].service);
        config.Config.procedure_tags.add(procedureLists.data[i].procedureData[j].tags);
        config.Config.procedure_dnd.add(procedureLists.data[i].procedureData[j].dnd);
        config.Config.procedure_description.add(procedureLists.data[i].procedureData[j].details);
      }
      config.Config.specialist_lists.add(procedureLists.data[i].speciality);
      config.Config.specialist_id.add(procedureLists.data[i].speciality_id);
      config.Config.catalogueLists.add(procedureLists.data[i]);

    }

    if(tour == 'done' && home == 'done'){
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(screen: 'bids'),
          ));
    } else {
      Navigator.popAndPushNamed(context, Guidedtour.tag);
    }
  }



  Widget _popup_no_internet(BuildContext context){
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



  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    return  Scaffold(
      backgroundColor: Color(0xff04cf5a),
      body: Center(
        child: Image.asset('assets/images/splash_final.jpg',),
      )
    );

  }
}


