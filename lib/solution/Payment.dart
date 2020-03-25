import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:plunes/config.dart' as config;

import '../config.dart';

class Payment extends StatefulWidget {
  static const tag = '/payment';

  final String id;

  Payment({Key key, this.id}) : super(key: key);

  @override
  _PaymentState createState() => _PaymentState(id);
}



class _PaymentState extends State<Payment> {

  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  final String id;
  _PaymentState(this.id);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    check();
  }

  void check() async {
    flutterWebviewPlugin.onUrlChanged.listen((String url) {


      print(url);

      if (url.contains("success")) {
        Navigator.of(context).pop(url);
      } else if (url.contains("error")) {
        Navigator.of(context).pop("fail");
      }
      else if (url.contains("cancelled")) {
        Navigator.of(context).pop("cancel");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;
    return WebviewScaffold(
        withZoom: true,
      clearCache: true,
        withLocalStorage: true,
        allowFileURLs: true,
        withJavascript: true,
        supportMultipleWindows: true,
        primary: true,
        hidden: true,

        initialChild: Container(
          color: Colors.white,
          child: const Center(
            child: Text(
              "Waiting...",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ),

      appBar: new AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          "Payment",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.black),
      ),

      url: config.Config.payment + "/" + id,
    );
  }
}
