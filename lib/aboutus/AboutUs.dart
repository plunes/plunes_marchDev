import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/config.dart' as config;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../config.dart';

class AboutUs extends StatefulWidget {
  static const tag = '/aboutus';
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;
    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("About Us", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );


    return WebviewScaffold(
      clearCache: false,
      withZoom: true,
      hidden: true,
      initialChild: Container(
        color: Colors.white,
        child:  Center(
          child: SpinKitThreeBounce(
            color: Color(0xff01d35a),
            size: 30.0,
            // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
          )
        ),
      ),

      url: config.Config.about_us,
      appBar: app_bar,


    );

  }
}
