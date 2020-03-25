import 'package:flutter/material.dart';
import 'package:plunes/manage_payment/AddBankDetails.dart';

import '../config.dart';

class ManagePayments extends StatefulWidget {
  static const tag = '/manage_payment';
  @override
  _ManagePaymentsState createState() => _ManagePaymentsState();
}

class _ManagePaymentsState extends State<ManagePayments> {
  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text("Manage Payment", style: TextStyle(color: Colors.black),),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );

    return  Scaffold(
        backgroundColor: Colors.white,
        appBar:app_bar,
        body: Container(

          child: Column(

            children: <Widget>[

              InkWell(
                onTap: (){
                  Navigator.pushNamed(context, AddBankDetails.tag);
                },
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Image.asset('assets/payments2.png', height: 25, width: 25,),
                      ),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Add/Edit Bank Details"),
                          Text("Wallet Account Settings", style: TextStyle(color:Colors.grey, fontSize: 12),)
                        ],
                      )),
                      Icon(Icons.keyboard_arrow_right, color: Colors.black,)
                    ],
                  ),
                ),
              ),

              Container(
                color: Color(0xffbdbdbd),
                height: 0.3,
              ),

            ],
          ),
        )
    );
  }
}








