import 'dart:io';

import 'package:flutter/material.dart';
import 'package:plunes/plocker/Annotate.dart';
import 'package:plunes/plocker/Prescriptions.dart';
import 'package:plunes/plocker/SharePlunes.dart';


class LabReports extends StatefulWidget {
  static const tag = '/labreports';
  @override
  _LabReportsState createState() => _LabReportsState();
}

class _LabReportsState extends State<LabReports> {


  final Map<String, IconData> _data = Map.fromIterables(
      ['Download', 'Add Notes', 'Annotate'],
      [Icons.filter_1, Icons.filter_2, Icons.filter_3]);

  List reports_list = new List();

  List list_selected = new List();
  List selected = new List();
  bool selectable = false;
  bool loading = false;



  String _message = "";
  String _path = "";
  String _mimeType = "";
  File _imageFile;
  int _progress = 0;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reports_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    reports_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
    reports_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    reports_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
    reports_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    reports_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
    reports_list.add('https://www.wikihow.com/images/thumb/0/02/Write-a-Prescription-Step-15.jpg/aid5679943-v4-1200px-Write-a-Prescription-Step-15.jpg');
    reports_list.add('https://www.rbcinsurance.com/group-benefits/_assets-custom/images/prescription-drug-sample-receipt-en.jpg');
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
        "Reports",
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
                  list_selected.add(reports_list[0]);
                });
              },
              child: Container(
                height: 45,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.green),
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
                            list_selected.remove(reports_list[index]);
                            if(list_selected.length ==0){
                              selectable = false;
                            }
                          }else{
                            selected[index] = true;
                            list_selected.add(reports_list[index]);
                          }
                        });
                      }else{
                        showDialog(
                          context: context,
                          builder: (BuildContext context,) =>
                              ShowPrescription(
                                  image_url: reports_list[index]
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
                                      child: Image.network(reports_list[index],
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


                                                  }else if(text == 'Add Notes'){
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context,) =>
                                                          AddComments(
                                                          ),
                                                    );
                                                  }else if(text == 'Annotate'){


                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => Annotate(
                                                            image_url: reports_list[index],
                                                          ),
                                                        ));


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
              }, itemCount: reports_list.length,),
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
                     // FlutterShareMe().shareToSystem(msg: list_selected.join(','),);
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
