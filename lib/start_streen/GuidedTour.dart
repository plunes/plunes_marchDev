import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:plunes/start_streen/Allevents.dart';
import 'package:plunes/start_streen/EnterPhoneScreen.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';


class Guidedtour extends StatefulWidget {

  static const tag = '/guided';
  @override
  _GuidedtourState createState() => _GuidedtourState();
}

class _GuidedtourState extends State<Guidedtour> {
  String latitude = "";
  String longitude = "";
  List<Slide> slides = new List();


  @override
  void initState() {
    super.initState();
    //share preference store data
    slides.add(
      new Slide(
        backgroundColor: Colors.white,
        backgroundOpacity: 0,
        backgroundImageFit: BoxFit.contain,
        backgroundOpacityColor: Colors.transparent,
        backgroundImage: "assets/images/sliders/bidding.png",
      )
    );

    slides.add(
      new Slide(
        backgroundColor: Colors.white,
        backgroundOpacity: 0,
        backgroundImageFit: BoxFit.contain,
        backgroundOpacityColor: Colors.transparent,
        backgroundImage: "assets/images/sliders/search.png",
      ),
    );

    slides.add(
      new Slide(
        backgroundColor: Colors.white,
        backgroundOpacity: 0,
        backgroundImageFit: BoxFit.contain,
        backgroundOpacityColor: Colors.transparent,
        backgroundImage: "assets/images/sliders/solution.png",
      ),
    );
    slides.add(
      new Slide(
        backgroundColor: Colors.white,
        backgroundOpacity: 0,
        backgroundImageFit: BoxFit.contain,
        backgroundOpacityColor: Colors.transparent,
        backgroundImage: "assets/images/sliders/near_you.png",
      ),
    );
  }

  void onDonePress() {
    Navigator.pushNamed(context, EnterPhoneScreen.tag);
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    return  WillPopScope(
      onWillPop: () async => false,
      child: new IntroSlider(
        slides: this.slides,
        colorDoneBtn: Color(0xff01d35a),
        colorActiveDot: Color(0xff01d35a),
        colorDot: Color(0xffd7ffe8),
        onDonePress: this.onDonePress

      ),
    );
  }
}
