import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/plocker/SharePlunes.dart';
import 'package:plunes/profile/ProfileImage.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';



class Prescriptions extends StatefulWidget {
  static const tag = '/prescription';
  @override
  _PrescriptionsState createState() => _PrescriptionsState();
}

class _PrescriptionsState extends State<Prescriptions> {

  final Map<String, IconData> _data = Map.fromIterables(
      ['Download', 'Add Notes'],
      [Icons.filter_1, Icons.filter_2]);

  List prescriptions_list = new List();

  List list_selected = new List();
  List selected = new List();
  bool selectable = false;
  bool loading = false;
  bool cross = false;

  String _message = "";
  String _path = "";
  String _mimeType = "";
  File _imageFile;
  int _progress = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    prescriptions_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    prescriptions_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
    prescriptions_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    prescriptions_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
    prescriptions_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    prescriptions_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
    prescriptions_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    prescriptions_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
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
        "Prescriptions",
        style: TextStyle(color: Colors.black),
      ),
    );


    return Scaffold(
      appBar: app_bar,
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(left:20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Container(
              height: 45,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[

                    Expanded(
                      child: TextField(

                        decoration: InputDecoration.collapsed(hintText: "Search"),
                        onChanged: (text){

                          setState(() {

                            if(text.length > 0){
                              cross = false;
                            }else{
                              cross = true;
                            }

                          });

                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right:8.0),
                      child: Icon(Icons.search),
                    ),

                  ],
                ),
              ),
              decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(5))),
            ),

            SizedBox(height: 10,),

            InkWell(
              onTap: (){
                setState(() {
                  list_selected.clear();
                  selectable = true;
                  selected[0] = true;
                  list_selected.add(prescriptions_list[0]);
                });
              },
              child: Container(
                height: 45,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
                child: Text("Share", style: TextStyle(color: Colors.white),),
              ),
            ),
            SizedBox(height: 10,),

            Expanded(child: Container(
              child: ListView.builder(itemBuilder: (context, index){
                selected.add(false);
                return Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: InkWell(
                    onTap: (){
                      if(selectable){
                        setState(() {

                          if(selected[index]){
                          selected[index] = false;
                            list_selected.remove(prescriptions_list[index]);
                            if(list_selected.length ==0){
                              selectable = false;
                            }
                          }else{
                            selected[index] = true;
                            list_selected.add(prescriptions_list[index]);
                          }

                        });
                      }else{
                        showDialog(
                          context: context,
                          builder: (BuildContext context,) =>
                              ShowPrescription(
                                image_url: prescriptions_list[index]
                              ),
                        );
                      }
                    },
                    child: Row(
                      children: <Widget>[

                        Visibility(
                          visible: selectable
                          ,child: Container(
                            child: selected[index]? Image.asset(
                                'assets/images/bid/check.png',
                                height: 20,
                                width: 20,
                              )
                                    : Image.asset(
                              'assets/images/bid/uncheck.png',
                              height: 20,
                              width: 20,
                            )
                          ),
                        ),


                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)),
                                border: Border.all(width: 0.5, color: Colors.black)),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height:100,
                                    width: 100,
                                    child: ClipRRect(
                                      borderRadius: new BorderRadius.circular(8.0),
                                      child: Image.network(prescriptions_list[index],
                                        fit: BoxFit.cover, height: double.infinity, width: double.infinity,),
                                    ),
                                  ),

                                  Expanded(child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(" ghjg khbkhbkjhbj", style: TextStyle(fontSize: 12),),
                                                Text("Santosh", style: TextStyle(fontSize: 12),),
                                                Text("Santosh", style: TextStyle(fontSize: 12),),
                                                Text("Santosh", style: TextStyle(fontSize: 12),),
                                                Text("Santosh", style: TextStyle(fontSize: 12),),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                iconEnabledColor: Colors.black,
                                                icon: Icon(Icons.more_horiz),
                                                elevation: 8,
                                                items: _data.keys.map((
                                                    String value) {
                                                  return new DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: new Text(value, style: TextStyle(fontSize: 12),),
                                                  );
                                                }).toList(),
                                                onChanged: (text) {
                                                  print(text);

                                                    if(text == 'Download'){
//                                                    _downloadImage(prescriptions_list[index],
//                                                        destination: AndroidDestinationType.directoryPictures
//                                                          ..inExternalFilesDir()
//                                                          ..subDirectory("plunes_report_"));
                                                  }else if(text == 'Add Notes'){
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context,) =>
                                                          AddComments(
                                                          ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  )),




                                ],
                              ),

                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, itemCount: prescriptions_list.length,),
            ),),

          selectable? Container(
              child: Row(
                children: <Widget>[

                  Expanded(child: InkWell(
                    onTap: (){
                      Navigator.pushNamed(context, SharePlunes.tag);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.cloud),
                          SizedBox(height: 10,),
                          Text("Plunes", style: TextStyle(fontSize: 12),)
                        ],
                      ),
                    ),
                  )),

                  Expanded(child: InkWell(
                    onTap: () async{
                          //  FlutterShareMe().shareToSystem(msg: list_selected.join(','),);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.share),
                          SizedBox(height: 10,),
                          Text("Share", style: TextStyle(fontSize: 12),)
                        ],
                      ),
                    ),
                  )),

                ],
              ),
            ): Container(),

          ],
        ),
      ),

    );
  }
}

class ShowPrescription extends StatefulWidget {

  final String image_url;
  ShowPrescription({Key key, this.image_url}) : super(key: key);

  @override
  _ShowPrescriptionState createState() => _ShowPrescriptionState(image_url);
}

class _ShowPrescriptionState extends State<ShowPrescription> {

  String image_url;

  _ShowPrescriptionState(this.image_url);
  final Map<String, IconData> _data = Map.fromIterables(
      ['Download', 'Add Notes'],
      [Icons.filter_1, Icons.filter_2]);


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 300,

        child: Column(
          children: <Widget>[
            Container(height: 40,
              child: Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  Container(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        iconEnabledColor: Colors.black,
                        icon: Icon(Icons.more_horiz, color: Colors.black,),
                        elevation: 8,
                        items: _data.keys.map((
                            String value) {
                          return new DropdownMenuItem<
                              String>(
                            value: value,
                            child: new Text(value, style: TextStyle(fontSize: 12),),
                          );
                        }).toList(),
                        onChanged: (text) {
                          print(text);
                          if(text == 'Download'){

                          }else if(text == 'Add Notes'){
                            showDialog(
                              context: context,
                              builder: (BuildContext context,) =>
                                  AddComments(
                                  ),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),

            Expanded(child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context,) =>
                      ProfileImage(
                        image_url: image_url,
                        text: " ",
                      ),
                );
              },
              child: Container(
                child: Image.network(image_url, fit: BoxFit.cover, ),
              ),
            )),
          ],
        ),

      ),
    );
  }
}


class AddComments extends StatefulWidget {
  @override
  _AddCommentsState createState() => _AddCommentsState();
}

class _AddCommentsState extends State<AddComments> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              autofocus: true,
              maxLines: 4,
              maxLength: 250,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  hintText: "Add Notes",
                  border:OutlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.grey))),
            ),

            SizedBox(height: 10,),

            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
                child: Text("Save", style: TextStyle(fontSize: 16, color: Colors.white),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




