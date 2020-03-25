import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/start_streen/LocationFetch.dart';



class HospitalReg extends StatefulWidget {
  @override
  _HospitalRegState createState() => _HospitalRegState();
}

class _HospitalRegState extends State<HospitalReg> {

  bool show_mannual = false;
  TextEditingController hospital_name = new TextEditingController();
  TextEditingController address = new TextEditingController();
  TextEditingController phone = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController City = new TextEditingController();
  TextEditingController About = new TextEditingController();
  TextEditingController registration_no = new TextEditingController();
  List specialization_selected = new List();


  TextEditingController doc_name = new TextEditingController();
  TextEditingController doc_education = new TextEditingController();
  TextEditingController doc_designation = new TextEditingController();
  TextEditingController doc_department = new TextEditingController();
  TextEditingController doc_experience = new TextEditingController();
  TextEditingController doc_availability = new TextEditingController();




@override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  void registration(){


    var body = {
      "name": hospital_name.text,
      "user_location": hospital_name.text+ ", "+state.text+", "+City.text,
      "phone_number": phone.text,
    };

    print(body);

  }



  @override
  Widget build(BuildContext context) {

    final mannual_add = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Text("Profile Image", style: TextStyle(fontSize: 12),),
          SizedBox(height: 30,),

          Row(
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Align(
                    child: Icon(Icons.person, color: Colors.grey,),
                  ),
                  Container(decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(40)),
                      color: Color(0x90ffBDBDBD) ), height: 80, width: 80,),
                  Align(
                    child: Icon(Icons.camera_enhance, color: Colors.white,),
                  ),

                ],
              ),

              SizedBox(width: 10,),

              Container(
                height: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("File Name"),
                    SizedBox(height: 10,),
                    Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Upload"),
                      ),
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(width: 0.3, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ],
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
              child: TextField(
                controller: doc_name,
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
              child: TextField(
                controller: doc_education,
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
              child: TextField(
                controller: doc_designation,
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
              child: TextField(
                controller: doc_department,
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
              child: TextField(
                controller: doc_experience,
                decoration: InputDecoration.collapsed(hintText: ""),
              ),
            ),
          ),

          SizedBox(height: 20,),
          Container(width: 90, alignment: Alignment.center, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.all
              (Radius.circular(15)),
              color: Color(0xff01d35a)),
              child: Text("Add", style: TextStyle(color: Colors.white),),
          ),
        ],
      ),
    );


    return Expanded(
      child: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          child: ListView(

            children: <Widget>[
              SizedBox(height: 20,),
              Center(
                child: Text("Profile Information",
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 20,),
              Text("Hospital Name"),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(borderRadius:
                BorderRadius.all(Radius.circular(10)), border:
                Border.all(width: 0.3, color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    textCapitalization:  TextCapitalization.words,
                    controller: hospital_name,
                    decoration: InputDecoration.collapsed(hintText: ""),
                  ),
                ),
              ),


              SizedBox(height: 10,),
              Text("Address"),
              SizedBox(height: 10,),



              InkWell(
                onTap: (){
                  Navigator.of(context).push(PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          LocationFetch())).then((val) {
                    address.text = val;
                  });

                },
                child: Container(
                  decoration: BoxDecoration(borderRadius:
                  BorderRadius.all(Radius.circular(10)), border:
                  Border.all(width: 0.3, color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(

                      maxLines: null,
                      controller: address,
                      decoration: InputDecoration.collapsed(hintText: ""),
                    ),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start
                ,children: <Widget>[
                SizedBox(height: 10,),
                Text("Phone"),
                SizedBox(height: 10,),
                Container(
                  decoration: BoxDecoration(borderRadius:
                  BorderRadius.all(Radius.circular(10)), border:
                  Border.all(width: 0.3, color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: phone,
                      decoration: InputDecoration.collapsed(hintText: ""),
                    ),
                  ),
                ),
              ],),

              Row(
                children: <Widget>[
                 Expanded(
                   child: Column(
                crossAxisAlignment: CrossAxisAlignment.start
                     ,children: <Widget>[
                     SizedBox(height: 10,),
                     Text("State"),
                     SizedBox(height: 10,),
                     Container(
                       decoration: BoxDecoration(borderRadius:
                       BorderRadius.all(Radius.circular(10)), border:
                       Border.all(width: 0.3, color: Colors.grey)),
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: TextField(
                           controller: state,
                           decoration: InputDecoration.collapsed(hintText: ""),
                         ),
                       ),
                     ),
                   ],),
                 ),

                  SizedBox(width: 10,),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      SizedBox(height: 10,),
                      Text("City"),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(borderRadius:
                        BorderRadius.all(Radius.circular(10)), border:
                        Border.all(width: 0.3, color: Colors.grey)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: City,
                            decoration: InputDecoration.collapsed(hintText: ""),
                          ),
                        ),
                      ),
                    ],),
                  )

                ],
              ),


              SizedBox(height: 10,),
              Text("About Hospital"),
              SizedBox(height: 10,),
              Container(
                height: 100,
                decoration: BoxDecoration(borderRadius:
                BorderRadius.all(Radius.circular(10)), border:
                Border.all(width: 0.3, color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: About,
                    maxLines: null,
                    minLines: 3,
                    maxLength: 250,
                    decoration: InputDecoration.collapsed(hintText: ""),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              Text("Registration No"),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(borderRadius:
                BorderRadius.all(Radius.circular(10)), border:
                Border.all(width: 0.3, color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: registration_no,
                    decoration: InputDecoration.collapsed(hintText: ""),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              Center(
                child: Text("Add Specialization",
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10,),
              Center(
                child: Text("Add Specialization and service",
                  style: TextStyle(fontSize: 12,
                    color: Colors.grey),),
              ),

              SizedBox(height: 20,),

              InkWell(
                onTap: (){

                  showDialog(
                      context: context,
                      builder: (BuildContext context,) =>
                          Specialization()
                  ).then((selected_val){

                    setState(() {
                      specialization_selected.addAll(selected_val);
                      print(specialization_selected);
                    });


                  });
                },
                child: Container(alignment: Alignment.center, decoration:
                BoxDecoration(borderRadius: BorderRadius.all
                  (Radius.circular(12)), color: Color(0xff01d35a)),

                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("Add",style: TextStyle(color:
                    Colors.white, fontWeight: FontWeight.w600),),
                  ),
                ),
              ),

              SizedBox(height: 20,),

              ListView.builder(itemBuilder: (context, index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(child: Text(specialization_selected[index])),

                            InkWell(child: Container(child:
                            Icon(Icons.clear, color: Colors.black,), color: Colors.red,), onTap: (){


                              setState(() {
                                specialization_selected.removeAt(index);
                              });
                            },)
                          ],
                        ),
                        SizedBox(height: 10,),
                        Container(height: 0.3, color: Colors.grey,),
                      ],
                    ) ,
                  ),
                );
              }, itemCount: specialization_selected.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),),

              SizedBox(height: 10,),
              Center(
                child: Text("Add Doctor",
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10,),
              Center(
                child: Text("Add doctor by search or email",
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey),),
              ),


              SizedBox(height: 10,),
              Text("Search"),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(borderRadius:
                BorderRadius.all(Radius.circular(10)), border:
                Border.all(width: 0.3, color: Colors.grey)),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          decoration: InputDecoration.collapsed(
                              hintText: "Enter doctor name", hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey )),
                        ),
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(right:8.0),
                      child: Icon(Icons.search, color: Colors.grey,size: 18,),
                    )
                  ],
                ),
              ),


              SizedBox(height: 10,),

              InkWell(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                onTap: (){
                  setState(() {
                    show_mannual = !show_mannual;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(borderRadius:
                  BorderRadius.all(Radius.circular(10)), border:
                  Border.all(width: 0.3, color:show_mannual? Color(0xff01d35a): Colors.grey ), color:show_mannual? Color(0xff01d35a): Colors.transparent),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("Add Manually", style: TextStyle(fontSize: 12, color: show_mannual? Colors.white: Colors.black ),),
                         show_mannual? Icon(Icons.keyboard_arrow_up,  color: show_mannual? Colors.white: Colors.black ):
                         Icon(Icons.keyboard_arrow_down,
                        color: Colors.black,)
                        ],
                      ),
                    ),
                  ),
                ),
              ),


              SizedBox(height: 20,),
              show_mannual? mannual_add: Container(),

              SizedBox(height: 30,),
              Center(
                child: Text("Manage Account",
                  style: TextStyle(fontWeight: FontWeight.bold),),
              ),
              SizedBox(height: 10,),
              Center(
                child: Text("Add users",
                  style: TextStyle(fontSize: 12,
                      color: Colors.grey),),
              ),
              Text("Admin",
                style: TextStyle(fontSize: 12,
                    color: Colors.black)),

              Row(
                children: <Widget>[
                  Expanded(
                    child: Text("Ankit Garg",
                      style: TextStyle(fontSize: 12,
                          color: Colors.black),),
                  ),

                  Text("Edit", style: TextStyle(fontSize: 12, color: Color(0xff01d35a)),)

                ],
              ),

              SizedBox(height: 10,),
              Text("Add User",
                style: TextStyle(fontSize: 12,
                    color: Colors.black),),
              SizedBox(height: 10,),
              Container(
                decoration: BoxDecoration(borderRadius:
                BorderRadius.all(Radius.circular(10)), border:
                Border.all(width: 0.3, color: Colors.grey)),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration.collapsed(
                              hintText: "User email", hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey )),
                        )
                      )
                    ]
                  )
                )
              ),

              SizedBox(height: 20,width: 30,),

              Container(margin: EdgeInsets.only(left: 90, right: 90),
                height: 40,
                decoration:
              BoxDecoration(borderRadius: BorderRadius.all
                (Radius.circular(15)), color: Color(0xffD9D9D9),),
                child: FlatButton(
                    child: Text("Add", style: TextStyle(color: Colors.white),)),
              ),

              ListView.builder(itemBuilder: (context, index){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                   Padding(
                     padding: const EdgeInsets.all(10.0),
                     child: Row(
                       children: <Widget>[
                         Expanded(child: Text("Sanjay Sharma", style: TextStyle(fontSize: 12),)),
                         Container(
                           child: Text("Edit", style:
                           TextStyle(color: Color(0xff01d35a), fontSize: 12),),
                         ),
                       ],
                     ),
                   ),Container(height: 0.2, color: Colors.grey,)
                  ],
                );
              }, itemCount: 2, shrinkWrap: true, physics: ClampingScrollPhysics(),),

              SizedBox(height: 30,),

            ],
          ),
        ),
      )

    );
  }
}

class Specialization extends StatefulWidget {
  @override
  _SpecializationState createState() => _SpecializationState();
}

class _SpecializationState extends State<Specialization> {

  List select_procedure = new List();
  List<bool> select = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for(int i =0; i< config.Config.specialist_lists.length; i++){
      select.add(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: Container(
        height: 400,
        child: Column(
          children: <Widget>[


            Container(
              alignment: Alignment.topRight,
              child: FlatButton(

                onPressed: (){
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.close, color: Colors.black,
                  ),
                ),
              ),
            ),

            Text("Select", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
            config.Config.specialist_lists.length == 0? Expanded(child:

            Center(child: Text("No data",
              style: TextStyle(color: Colors.grey),),),):  Expanded(

              child: ListView.builder(itemBuilder: (BuildContext context, index){
                return FlatButton(
                  onPressed: (){
                  setState(() {
                    select[index] = !select[index];
                    if(select[index]){
                      select_procedure.add(config.Config.specialist_lists[index]);
                    }else{
                      select_procedure.removeAt(index);
                    }
                  });
                  },



                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      Container(child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Text(config.Config.specialist_lists[index],
                                  style: TextStyle(color: Colors.black, fontSize: 14),),
                                alignment: Alignment.centerLeft,
                              ),
                            ),

                            Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: Container(
                                width: 40,
                                child: FlatButton(
                                  child: Checkbox(value: select[index], onChanged: (val){
                                  }),
                                  onPressed: (){
                                    setState(() {
                                      select[index] = !select[index];
                                      if(select[index]){
                                        select_procedure.add(config.Config.specialist_lists[index]);
                                      }else{
                                        select_procedure.removeAt(index);
                                      }
                                    },);
                                  },
                                ),
                              ),
                            ),


                          ],
                        ),
                      ),),

                      Divider(height: 0.5, color: Colors.grey,),
                    ],
                  ),
                );
              }, itemCount: config.Config.specialist_lists.length,),
            ),


            GestureDetector(
              onTap: (){
                Navigator.of(context).pop(select_procedure);
              },
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: 80,
                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
                child: Text("Apply", style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.bold),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


