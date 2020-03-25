import 'package:flutter/material.dart';


class SharePlunes extends StatefulWidget {
  static const tag = '/shareplunes';
  @override
  _SharePlunesState createState() => _SharePlunesState();
}

class _SharePlunesState extends State<SharePlunes> {


  List user_name = new List();

  List selected = new List();
  List selected_users = new List();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    user_name.add("asfd");
    user_name.add("sdf");
    user_name.add("er");
    user_name.add("rt");
    user_name.add("yu");
    user_name.add("jkl");


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
        "Share",
        style: TextStyle(color: Colors.black),
      ),
    );



    return Scaffold(
      appBar: app_bar,
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(left:20, right: 20),
        child: Column(
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

            Expanded(child: Container(
              child: ListView.builder(itemBuilder: (context, index){
                selected.add(false);
                return Container(
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        if(selected[index]){
                          selected[index] = false;
                          selected_users.remove(user_name[index]);
                        }else{
                          selected[index] = true;
                          selected_users.add(user_name[index]);
                        }
                      });
                    },
                    child: Row(
                      children: <Widget>[

                        Container(
                            child: selected[index]?Image.asset(
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

                        SizedBox(width: 10,),

                        Expanded(child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(left:8.0, right: 8, top: 8),
                            child: Column(
                              children: <Widget>[

                                Container(
                                  child: Row(
                                    children: <Widget>[

                                      CircleAvatar(radius: 30,),

                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(user_name[index]),
                                          Text("Designations")
                                        ],
                                      )
                                    ],
                                  ),
                                ),

                                SizedBox(height: 8),

                                Container(
                                  height: 0.3,
                                  color: Colors.grey,
                                ),

                              ],
                            ),
                          ),
                        ),),

                      ],
                    ),
                  ),
                );
              }, itemCount: user_name.length,),
            )),


           Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(height: 35,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: selected_users.length ==0? Colors.grey:Colors.green),
                child: Text("Share", style: TextStyle(color: Colors.white,),),
                alignment: Alignment.center,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
