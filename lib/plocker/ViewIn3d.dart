import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';


class ViewIn3d extends StatefulWidget {
  static const tag = '/viewin3d';
  @override
  _ViewIn3dState createState() => _ViewIn3dState();
}

class _ViewIn3dState extends State<ViewIn3d> {

//https://mdn.github.io/webgl-examples/tutorial/sample8/
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "3D View",
        style: TextStyle(color: Colors.black),
      ),
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
      url: 'https://mdn.github.io/webgl-examples/tutorial/sample8/',
      appBar: app_bar,
    );


  }
}
