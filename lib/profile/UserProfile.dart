import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/enquiry/PostConcern.dart';
import 'package:plunes/model/profile/user_profile.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/profile/DoctorDetails.dart';
import 'package:plunes/profile/EditDoctors.dart';
import 'package:plunes/profile/ProfileImage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';


class UserProfile extends StatefulWidget {
  static const tag = '/userprofile';

   String user_id = "";
  UserProfile({Key key, this.user_id}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState(user_id);
}

class _UserProfileState extends State<UserProfile> {

   String user_id = "";
  _UserProfileState( this.user_id);


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String user_token="";
  String specialities = "";


  String user_type = "";
  String email = "";
  String address = "";
  String experience = "";
  String practising = "";
  String qualification = "";
  String college = "";
  String biography = "";

  String image_url = "";
  String cover_url = "";

   String name = "";
  String initial_name = "";

  bool progress = true;

   String latitude = "";
   String longitude = "";
   int pro = 10;

  List achievment_img = new List();
  List achievment_title = new List();
  List achievment_id = new List();

   /// doctors list
   List doc_names = new List();
   List doc_edus = new List();
   List doc_designations = new List();
   List doc_experiences = new List();
   List doc_id = new List();
   List doc_imageUrl = new List();

   /// hospital specializations
   List<DropdownMenuItem<String>> _dropDownMenuItems;
   String _speciality="";
   Set _special_lities = new Set();
   List procedure_name = new List();

   UserProfilePost userProfilePost;
   // here we are creating the list needed for the DropDownButton
   List<DropdownMenuItem<String>> getDropDownMenuItems() {
     List<DropdownMenuItem<String>> items = new List();

     for (String speciality in _special_lities) {
       // here we are creating the drop down menu items, you can customize the item right here
       // but I'll just use a simple text for this
       items.add(new DropdownMenuItem(value: speciality,
           child: new Text(speciality,
             style: TextStyle(fontSize: 12, color: Colors.black,),)
       ),
       );
     }
     return items;
   }

   bool isPopup = false;
   var pName = '', pSpeciality = '', pId = '';

  @override
  void initState() {
    super.initState();
    getSharedPreferences();

  }

   void get_data() async{
     procedure_name.clear();
       for(int j =0; j< config.Config.procedure_speciality.length; j++){
         if(config.Config.procedure_speciality[j].contains(_speciality)){
           print(config.Config.procedure_name[j]);
           procedure_name.add(config.Config.procedure_name[j]);
         }
       }
   }

   getSharedPreferences() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     String token = prefs.getString("token");
     setState(() {
       user_token = token;
     });
     get_profile_info(token);
   }

  get_profile_info(String token) async{
    achievment_img.clear();
    achievment_title.clear();
    achievment_id.clear();

    doc_names.clear();
    doc_edus.clear();
    doc_designations.clear();
    doc_experiences.clear();
    doc_id.clear();
    doc_imageUrl.clear();


     userProfilePost = await user_profile(user_id, token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });

    image_url = userProfilePost.user.imageUrl;
    cover_url = userProfilePost.user.coverImageUrl;

    print(image_url);

    name = userProfilePost.user.name;
    user_type = userProfilePost.user.userType;
    email = userProfilePost.user.email;
    address = userProfilePost.user.address;
    experience = userProfilePost.user.experience;
    practising = userProfilePost.user.practising;
    qualification = userProfilePost.user.qualification;
    college = userProfilePost.user.college;
    biography = userProfilePost.user.biography;
    latitude = userProfilePost.user.latitude;
    longitude = userProfilePost.user.longitude;
    initial_name = config.Config.get_initial_name(name);

    for(int i =0; i< userProfilePost.user.achievments.length; i++){
      achievment_img.add(userProfilePost.user.achievments[i].imageUrl);
      achievment_title.add(userProfilePost.user.achievments[i].title);
      achievment_id.add(userProfilePost.user.achievments[i].id);
    }

    if(userProfilePost.user.doctorsdata.length > 0){

      for(int i =0; i< userProfilePost.user.doctorsdata.length; i++){

        doc_names.add(userProfilePost.user.doctorsdata[i].name);
        doc_edus.add(userProfilePost.user.doctorsdata[i].education);
        doc_designations.add(userProfilePost.user.doctorsdata[i].designation);
        doc_experiences.add(userProfilePost.user.doctorsdata[i].experience);
        doc_id.add(userProfilePost.user.doctorsdata[i].id);
        doc_imageUrl.add(userProfilePost.user.doctorsdata[i].imageUrl);
        _special_lities.add("Choose Speciality");

        for(int j =0; j< userProfilePost.user.doctorsdata[i].specialities.length; j++){
          int pos = config.Config.specialist_id.indexOf(userProfilePost.user.doctorsdata[i].specialities[j].specialityId);

          print(config.Config.specialist_lists[pos]);
          _special_lities.add(config.Config.specialist_lists[pos]);
        }

      }
      _dropDownMenuItems = getDropDownMenuItems();
      _speciality = _dropDownMenuItems[0].value;
      get_data();
    }



    List specilaity_id = new List();
    for(int i =0; i< userProfilePost.user.specialities.length; i++){
      specilaity_id.add(userProfilePost.user.specialities[i].specialityId);
    }

    List speciality = new List();
    for(int i =0; i< specilaity_id.length; i++){
      int pos = config.Config.specialist_id.indexOf(specilaity_id[i]);
      if(pos!=-1)
      speciality.add(config.Config.specialist_lists[pos]);
    }

    specialities = speciality.join(", ");


    setState(() {
      setState(() {
        progress = false;
      });

    });

  }



  @override
  Widget build(BuildContext context) {


    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text(
        "",
        style: TextStyle(color: Colors.black),
      ),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    );


    final profile = Container(
      margin: EdgeInsets.only(left: 15, right: 20),
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

                    if(image_url != '' && !image_url.contains("default")){
                      showDialog(
                        context: context,
                        builder: (BuildContext context,) =>
                            ProfileImage(
                              image_url: image_url,
                              text: " ",
                            ),
                      );
                    }

                  },
                  child:image_url !='' && !image_url.contains("default") ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(image_url),
                  ): Container(
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                      child:
                      Text(initial_name.toUpperCase(),
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
                  child: Text(name,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                ),
                Text(
                  user_type,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

              ],
            ),
          ),),



        ],
      ),
    );



    final loading = Container(
      child: Shimmer.fromColors(
        baseColor: Color(0xffF5F5F5),
        highlightColor: Color(0xffFAFAFA),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10, right: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Color(0xffF5F5F5),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              height: 10,
              color: Color(0xffF5F5F5),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              height: 10,
              color: Color(0xffF5F5F5),
            ),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              height: 10,
              color: Color(0xffF5F5F5),
            ),
          ],
        ),
      ),
    );




    final location = Container(
      margin: EdgeInsets.only(top:20, left: 20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[

          Image.asset(
            'assets/images/profile/location.png',
            height: 22,
            width: 22,
          ),

          SizedBox(
            width: 10,
          ),


          Expanded(
            child: RichText(
              text: new TextSpan(
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Location ', style: TextStyle(color: Colors.black)),
                  new TextSpan(text: address, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),


        ],
      ),
    );



    final expertise =   user_type == 'User' ?Container(): Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[

          Image.asset(
            'assets/images/profile/expertise.png',
            height: 22,
            width: 22,

          ),

          SizedBox(
            width: 10,
          ),


          Expanded(
            child: RichText(
              text: new TextSpan(
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Area of Expertise ', style: TextStyle(color: Colors.black)),
                  new TextSpan(text: specialities, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),


        ],
      ),
    );

    final exp = experience == ''? Container(): Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[

          Image.asset(
            'assets/clock.png',
            height: 22,
            width: 22,
            color: Colors.grey,
          ),

          SizedBox(
            width: 10,
          ),


          Expanded(
            child: RichText(
              text: new TextSpan(
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Experience of Practice ', style: TextStyle(color: Colors.black)),
                  new TextSpan(text: experience+" years", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),


        ],
      ),
    );

    final pract = practising == ''? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          Image.asset(
            'assets/images/profile/practise.png',
            height: 22,
            width: 22,
            color: Colors.grey,
          ),

          SizedBox(
            width: 10,
          ),



          Expanded(
            child: RichText(
              text: new TextSpan(
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Practising ', style: TextStyle(color: Colors.black)),
                  new TextSpan(text: practising, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),


        ],
      ),
    );

    final quali = qualification == ''? Container(): Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          Image.asset(
            'assets/images/profile/qualification.png',
            height: 25,
            width: 25,
            color: Colors.grey,
          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child: RichText(
              text: new TextSpan(
                children: <TextSpan>[
                  new TextSpan(
                      text: 'Qualifications ', style: TextStyle(color: Colors.black)),
                  new TextSpan(text: qualification, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        ],
      ),
    );

    final col = college== ''? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: <Widget>[
          Image.asset(
            'assets/images/profile/college.png',
            height: 22,
            width: 22,
            color: Colors.grey,
          ),
          SizedBox(
            width: 10,
          ),

          Expanded(
            child: RichText(
              text: new TextSpan(
                children: <TextSpan>[
                  new TextSpan(
                      text: 'College/University ',  style: TextStyle(color: Colors.black)),
                  new TextSpan(text: college, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

        ],
      ),
    );

    final introduction = biography == ''? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 10, top: 10),
      child:


      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text("Introduction", style: new TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black)),
          SizedBox(
            width: 10,
          ),
          Text(biography, style: TextStyle(color: Colors.grey))
        ],
      ),
    );

    final achievment = achievment_id.length == 0? Container():Container(
      margin: EdgeInsets.only(left:20, right: 20, bottom: 20),
      child: Text("Achievements", style: TextStyle(fontWeight: FontWeight.w600),),
    );

    final achievemnts = achievment_id.length == 0? Container():Container(
      margin: EdgeInsets.only(bottom: 20),
      height: 150,
      child: ListView.builder(itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.all(5.0),
          child: InkWell(
            onTap: (){

              showDialog(
                context: context,
                builder: (BuildContext context,) =>
                    ProfileImage(
                      image_url: achievment_img[index],
                      text: achievment_title[index],
                    ),
              );

            },
            child: Container(
              child: Stack(
                children: <Widget>[

                  Container(child: Image.network(achievment_img[index],
                    fit: BoxFit.cover,), height: 150,width: 200,
                  ),

                  Container(child: Text(achievment_title[index],
                    style: TextStyle(color: Colors.white),),
                    height: 150, width: 200,alignment: Alignment.center,),

                ],
              ),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(0)),
                  color: Colors.grey),
              height: 150,
              width: 200,

            ),
          ),
        );

      }, scrollDirection: Axis.horizontal,itemCount: achievment_id.length,),
    );



    final ask_btn =  user_type == 'User' ?Container():InkWell(
      onTap: (){

        setState(() {
          isPopup = !isPopup;
          pId = user_id;
        });

      },
      child: Container(
        margin: EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                width: 1,
                color: Color(0xffbdbdbd))),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 8.0, right: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Ask",
                style:
                TextStyle(color: Colors.black)),
          ),
        ),
      ),
    );

    final doctor_form =  Container(
      child: ListView(
        children: <Widget>[

          profile,
//          ask_btn,
          location,
          expertise,
          exp,
          pract,
          quali,
          col,
          introduction,
          achievment,
          achievemnts,
        ],
      ),
    );


    final hos_introduction = biography == ''? Container(): Container(

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[


          Text("Introduction", style: TextStyle(fontWeight: FontWeight.w600),),

          SizedBox(height: 10,),
          Text(biography)
        ],
      ),
    );

    final hos_cover = Container(
        width: double.infinity,
        height: 250,
        child:Stack(

          children: <Widget>[

            Container(
              color: Colors.grey,
              height: 250,
              width: double.infinity,
            ),

            Container(child: Image.network(cover_url, fit: BoxFit.cover,),
            height: 250,
            width: double.infinity,),

          ],

        )

    );



    final hos_profile = Container(

      child: Padding(
        padding: const EdgeInsets.all(8.0),
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

                      if(image_url !=''){
                        showDialog(
                          context: context,
                          builder: (BuildContext context,) =>
                              ProfileImage(
                                image_url: image_url,
                                text: " ",
                              ),
                        );
                      }
                    },
                    child:image_url !='' ? CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(image_url),
                    ): Container(
                        height: 60,
                        width: 60,
                        alignment: Alignment.center,
                        child:
                        Text(initial_name.toUpperCase(),
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
              margin: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                  SizedBox(height: 5,),
                  Text(address)
                ],
              ),
            ))

          ],
        ),
      ),

    );



    final hos_location = Container(
      margin: EdgeInsets.only(top:20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,

            children: <Widget>[

              Image.asset(
                'assets/images/profile/location.png',
                height: 22,
                width: 22,
              ),

              SizedBox(
                width: 10,
              ),


              Expanded(child: Text(address, style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.w300)))

            ],
          ),
          InkWell(
            onTap: (){
              MapUtils.openMap(double.parse(latitude), double.parse(longitude));
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(child: Text("View on Map", style: TextStyle(color: Color(0xff01d35a)),),
                margin: EdgeInsets.only(left: 30),),
            ),
          ),

          SizedBox(height: 10,),

          Container(height: 0.3,color: Colors.grey,),

          SizedBox(height: 10,),
        ],
      ),
    );

    final hos_specialization = Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Text("Specializations", style: TextStyle(fontWeight: FontWeight.w600),),
            SizedBox(
              height: 10,
            ),
            Container(
              // margin: EdgeInsets.only(left: 10, right: 10),

              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 1, color: Color(0xff01d35a))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                  hint: Text(
                    "Choose Speciality", style: TextStyle(color: Colors.white),),
                  value: _speciality,
                  decoration: InputDecoration.collapsed(hintText: "Choose Speciality",
                      hintStyle: TextStyle(color: Colors.black),
                      hasFloatingPlaceholder: true, fillColor: Colors.white),
                  items: _dropDownMenuItems,
                  onChanged: (val){

                    print(val);

                    setState(() {
                      _speciality = val;
                      get_data();

                    });
                  },
                ),
              ),
            ),


          _speciality == 'Choose Speciality'? Container(): ListView.builder(itemBuilder: (context, index){

              return Container(

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(

                    children: <Widget>[

                      Expanded(child: Text(procedure_name[index])),

                      SizedBox(width: 10,),

                      InkWell(child: Text("Know more", style: TextStyle(color: Colors.grey),),

                        onTap: (){

                          print(procedure_name[index]);

                          int pos = config.Config.procedure_name.indexOf(procedure_name[index]);

                          showDialog(
                              context: context,
                              builder: (
                                  BuildContext context,
                                  ) =>
                                  _popup_dialoge(
                                      context,
                                      config.Config
                                          .procedure_description[
                                      pos],
                                      procedure_name[index]));
                        },)
                    ],
                  ),
                ),
              );

            }, itemCount:procedure_name.length> pro? pro: procedure_name.length, shrinkWrap: true, physics: ScrollPhysics(),),

            _speciality == 'Choose Speciality'? Container(): Center(
              child: InkWell(
                onTap: (){

                  setState(() {


                    if(pro == 10){
                      pro = procedure_name.length;
                    }else{
                      pro = 10;
                    }


                  });

                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:pro ==10? Text("View More", style: TextStyle(color: Color(0xff01d35a)),):
                  Text("View Less", style: TextStyle(color: Color(0xff01d35a)),),
                ),
              ),
            )



          ],
        ),
      ),
    );



    final hos_doctors = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(child: Text("Team of Experts", style: TextStyle(fontWeight: FontWeight.w600),),
            margin: EdgeInsets.only(left: 20),),
          SizedBox(height:20,),

          Container(
            height: 100,
            child: ListView.builder(itemBuilder: (context, index){
              return InkWell(
                onTap: (){

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetails(
                            doctordata: userProfilePost.user.doctorsdata,
                            pos: index
                        ),
                      ));
                },
                child: Container(
                  margin: EdgeInsets.only(right: 10, left: 10),
                  width: 250,
                  child:Stack(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          doc_imageUrl[index]!= ''?
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(doc_imageUrl[index]),
                          ):

                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(25)),
                              gradient: new LinearGradient(
                                  colors: [Color(0xffababab), Color(0xff686868)],
                                  begin: FractionalOffset.topCenter,
                                  end: FractionalOffset.bottomCenter,
                                  stops: [0.0, 1.0],
                                  tileMode: TileMode.clamp
                              ),

                            ),
                            alignment: Alignment.center,
                            child: Text(config.Config.get_initial_name(doc_names[index]), style:
                            TextStyle(color: Colors.white, fontSize: 14),),
                          ),

                          SizedBox(
                            width: 10,
                          ),

                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: <Widget>[

                              Text(doc_names[index], style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                              Text(doc_edus[index]),
                              Text(doc_designations[index]),
                              Text(doc_experiences[index]+" years of experience")

                            ],
                          )),

                        ],

                      ),
                    ],
                  ),
                ),
              );
            }, itemCount: doc_id.length,scrollDirection: Axis.horizontal, ),
          ),
        ],
      ),
    );


    final hospital_form = ListView(

      children: <Widget>[
        hos_cover,
        hos_profile,
        Container(
          margin: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              hos_location,
              hos_introduction
            ],
          ),
        ),

        hos_specialization,
        hos_doctors,
        achievment,
        achievemnts,
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: app_bar,
      backgroundColor: Colors.white,
      body:progress? loading: Stack(
        children: <Widget>[
          user_type == "Hospital"?hospital_form: doctor_form,

          isPopup
              ? Container(
            alignment: FractionalOffset.center,
            color: const Color(0x88000000),
            height: MediaQuery.of(context).size.height,


            child: PostEnquiry(
                p_id: pId,
                onTap: (bool flag, String from) {
                  setState(() {
                    isPopup = false;
                  });
                  if (flag) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (
                          BuildContext context,
                          ) =>
                          _submittedDialog(context),
                    );
                  }
                }),



          )
              : Container()


        ],
      )


    );
  }

   Widget  _submittedDialog(BuildContext context) {
     return new AlertDialog(
       content: Container(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           // shrinkWrap: true,
           mainAxisSize: MainAxisSize.min,

           children: <Widget>[
             Container(
               child: InkWell(
                 child: Icon(
                   Icons.clear,
                   color: Colors.black,
                 ),
                 onTap: () {
                   Navigator.of(context).pop();
                   Navigator.of(context).pop();
                 },
               ),
               alignment: Alignment.topRight,
             ),

             Container(
               child: Image.asset(
                 'assets/concern.png',
                 height: 100,
               ),
             ),

             SizedBox(
               height: 10,
             ),

             Container(
               child: Text(
                 "Your Enquiry has been submitted",
                 textAlign: TextAlign.center,
                 style: TextStyle(fontWeight: FontWeight.bold),
               ),
             ),

             SizedBox(height: 20),

             Container(
               margin: EdgeInsets.only(left: 30, right: 30),
               child: Text(
                 "We will notify you soon.",
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 12),
               ),
             ),
           ],
         ),
       ),
     );
   }

   Widget _popup_dialoge(BuildContext context, String def, String name) {
     return new CupertinoAlertDialog(
       content: Container(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[
             Row(
               children: <Widget>[
                 SizedBox(
                   width: 10,
                 ),
                 Expanded(
                   child: Container(
                     child: Text(
                       name,
                       textAlign: TextAlign.center,
                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                     ),
                   ),
                 ),
                 SizedBox(
                   width: 10,
                 ),
                 GestureDetector(
                   onTap: () {
                     Navigator.pop(context);
                   },
                   child: Container(
                     child: Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Icon(Icons.close),
                     ),
                     alignment: Alignment.topRight,
                   ),
                 ),
               ],
             ),
             SizedBox(
               height: 20,
             ),
             Center(
               child: Text(
                 def,
                 maxLines: 6,
                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
               ),
             ),
             SizedBox(
               height: 20,
             ),
             GestureDetector(
               onTap: () {
                 Navigator.pop(context);
               },
               child: Container(
                 height: 35,
                 width: 100,
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.all(Radius.circular(10)),
                     color: Color(0xff01d35a)),
                 alignment: Alignment.center,
                 child: Text(
                   "Ok",
                   style: TextStyle(color: Colors.white),
                 ),
               ),
             ),
           ],
         ),
       ),
     );
   }

}
