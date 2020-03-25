import 'package:flutter/material.dart';



class Annotate extends StatefulWidget {
  static const tag = '/annotate';

  final String image_url;
  Annotate({Key key, this.image_url}) : super(key: key);

  @override
  _AnnotateState createState() => _AnnotateState(image_url);
}

class _AnnotateState extends State<Annotate> {

  String image_url;
  _AnnotateState(this.image_url);


  bool show_1=false;
  bool show_2=false;
  bool show_3 = false;



  @override
  Widget build(BuildContext context) {

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "",
        style: TextStyle(color: Colors.black),
      ),
    );



    return Scaffold(
      appBar: app_bar,
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.all(30),
        child: Stack(

          children: <Widget>[


            Container(
              height: double.infinity,
              width: double.infinity,
            ),

            Image.network(image_url, fit: BoxFit.cover),


            Positioned(child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      setState(() {
                        show_1 = !show_1;
                      });
                    },
                    child: Container(height: 30,width: 30,
                      alignment: Alignment.center,
                      child: Text("1", style: TextStyle(color: Colors.green, fontSize: 18),),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Color(0xff80ffffff), border: Border.all(color: Colors.green, width:2), ),),
                  ),

                  Visibility(
                    visible: show_1,
                    child: Container(
                      margin: EdgeInsets.only(top:10),
                      color: Colors.green,
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("sdfgdfgsdfg fdsfsdfgsdfgsdfgs dfgsdfg sdfgsdfg "
                            "sdfgdsfg sdfg dsfgsdfg dfg dfg", style: TextStyle(color: Colors.white, fontSize: 12),),
                      ),
                    ),
                  )
                ],
              ),
            ), top: 80, left: 30,
          ),

            Positioned(child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  InkWell(
                    onTap: (){
                      setState(() {
                        show_2 = !show_2;
                      });
                    },
                    child: Container(height: 30,width: 30,
                      alignment: Alignment.center,
                      child: Text("2", style: TextStyle(color: Colors.green, fontSize: 18),),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Color(0xff80ffffff), border: Border.all(color: Colors.green, width:2), ),),
                  ),

                  Visibility(
                    visible: show_2,
                    child: Container(
                      margin: EdgeInsets.only(top:10),
                      color: Colors.green,
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("sdfgdfgsdfg fdsfsdfgsdfgsdfgs dfgsdfg sdfgsdfg "
                            "sdfgdsfg sdfg dsfgsdfg dfg dfg", style: TextStyle(color: Colors.white, fontSize: 12),),
                      ),
                    ),
                  ),



                ],
              ),
            ), top: 250,
              left: 50,
            ),



            Positioned(child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[


                  InkWell(
                    onTap: (){
                      setState(() {
                        show_3 = !show_3;
                      });
                    },
                    child: Container(height: 30,width: 30,
                      alignment: Alignment.center,
                      child: Text("3", style: TextStyle(color: Colors.green, fontSize: 18),),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),
                        color: Color(0xff80ffffff), border: Border.all(color: Colors.green, width:2), ),),
                  ),

                  Visibility(
                    visible: show_3,
                    child: Container(
                      margin: EdgeInsets.only(top:10),
                      color: Colors.green,
                      width: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("sdfgdfgsdfg fdsfsdfgsdfgsdfgs dfgsdfg sdfgsdfg "
                            "sdfgdsfg sdfg dsfgsdfg dfg dfg", style: TextStyle(color: Colors.white, fontSize: 12),),
                      ),
                    ),
                  ),

                ],
              ),
            ), top: 150,
              left: 200,
            ),



          ],
        ),


      ),


    );
  }
}
