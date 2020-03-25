import 'package:flutter/material.dart';
import 'package:plunes/config.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/profile/ProfileImage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DoctorDetails extends StatefulWidget {
  static const tag = '/doctordetails';

  final List<DoctorsData> doctordata;
  final int pos;
  DoctorDetails({Key key, this.doctordata, this.pos}) : super(key: key);



  @override
  _DoctorDetailsState createState() => _DoctorDetailsState(doctordata, pos);
}

class _DoctorDetailsState extends State<DoctorDetails> {

  String user_token = "";
  String user_id = "";

  List<DoctorsData> doctordata = new List();
  int pos;
  _DoctorDetailsState( this.doctordata, this.pos);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();

    for(int i =0; i < doctordata[pos].specialities.length; i++){
      print(doctordata[pos].specialities[i].specialityId);
    }

  }


  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    setState(() {
      user_token = token;
      user_id = uid;
    });

  }




  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      elevation: 0,
      title: Text(
        "",
        style: TextStyle(color: Colors.black),
      ),
    );



    return Scaffold(

      appBar: app_bar,
      backgroundColor: Colors.white,


      body: Container(

        margin: EdgeInsets.only(left: 20, right: 20),

        child: ListView(

          children: <Widget>[
            Container(

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Stack(
                      children: <Widget>[
                        InkWell(
                          onTap: (){

                            if(doctordata[pos].imageUrl != ''){
                              showDialog(
                                context: context,
                                builder: (BuildContext context,) =>
                                    ProfileImage(
                                      image_url: doctordata[pos].imageUrl ,
                                      text: " ",
                                    ),
                              );
                            }

                          },
                          child:doctordata[pos].imageUrl  !='' ? CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(doctordata[pos].imageUrl ),
                          ): Container(
                              height: 60,
                              width: 60,
                              alignment: Alignment.center,
                              child:
                              Text(Config.get_initial_name(doctordata[pos].name).toUpperCase(),
                                style: TextStyle(color: Colors.white,
                                    fontSize: 22, fontWeight: FontWeight.normal),),

                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)),
                                gradient: new LinearGradient(
                                    colors: [Color(0xffababab), Color(0xff686868)],
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    stops: [0.0, 1.0],
                                    tileMode: TileMode.clamp
                                ),) ),
                        ),

                      ],
                    ),
                  ),

                  Expanded(child: Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(doctordata[pos].name,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 16),
                          ),
                        ),
                        Text(
                          "Dcctor",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),

                      ],
                    ),
                  ),),



                ],
              ),
            ),



            SizedBox(height: 20,),
            Text("Full Name"),
            SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(borderRadius:
              BorderRadius.all(Radius.circular(10)), border:
              Border.all(width: 0.3, color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: false,
                  initialValue: doctordata[pos].name,
                  decoration: InputDecoration.collapsed(hintText: ""),
                ),
              ),
            ),


            SizedBox(height: 10,),
            Text("Education Qualification"),
            SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(borderRadius:
              BorderRadius.all(Radius.circular(10)), border:
              Border.all(width: 0.3, color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: false,
                  initialValue: doctordata[pos].name,
                  decoration: InputDecoration.collapsed(hintText: ""),
                ),
              ),
            ),


            SizedBox(height: 10,),
            Text("Designation"),
            SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(borderRadius:
              BorderRadius.all(Radius.circular(10)), border:
              Border.all(width: 0.3, color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: false,
                  initialValue: doctordata[pos].designation,
                  decoration: InputDecoration.collapsed(hintText: ""),
                ),
              ),
            ),

            SizedBox(height: 10,),
            Text("Department"),
            SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(borderRadius:
              BorderRadius.all(Radius.circular(10)), border:
              Border.all(width: 0.3, color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: false,
                  initialValue: doctordata[pos].department,
                  decoration: InputDecoration.collapsed(hintText: ""),
                ),
              ),
            ),

            SizedBox(height: 10,),
            Text("Experience"),
            SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(borderRadius:
              BorderRadius.all(Radius.circular(10)), border:
              Border.all(width: 0.3, color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  enabled: false,
                  initialValue: doctordata[pos].experience+" years",
                  decoration: InputDecoration.collapsed(hintText: ""),
                ),
              ),
            ),

            SizedBox(height: 20,)


          ],
        ),
      ),

    );
  }
}
