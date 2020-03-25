import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/model/helpquery_post.dart';
import 'package:plunes/model/profile/user_profile.dart';
import 'package:plunes/model/solution/update_price.dart';
import 'package:plunes/profile/ProfileImage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plunes/config.dart' as config;
import 'package:shimmer/shimmer.dart';

class UserDetailsScreen extends StatefulWidget {
  static const tag = '/userdetailsscreen';

  String user_id = "";
  List price;
  List categories;
  String diagnose = "";
  String recommendation;
  String solution_id;
  String service_id;

  UserDetailsScreen({Key key, this.user_id, this.price, this.diagnose,
    this.solution_id, this.service_id, this.categories, this.recommendation}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState(user_id, price,
      diagnose, solution_id, service_id, categories, recommendation);
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {

  String user_id = "";
  List price;
  List categories;
  String diagnose = "";
  String recommendation;
  String solution_id;
  String service_id;

  _UserDetailsScreenState( this.user_id, this.price, this.diagnose,
      this.solution_id, this.service_id, this.categories, this.recommendation);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String user_token = "";
  bool progress = true;
  String image_url = "";
  String initial_name = "";
  String name = "";
  String address = "";

  TextEditingController price_ = new TextEditingController();
  List update_prices = new List();
  bool enable = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    update_prices.addAll(price);
    getSharedPreferences();
  }


  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    setState(() {
      user_token = token;

/*
      if(int.parse(recommendation)> 25){

          recommendation = "25";

      }
*/


    });

    get_profile_info(token);
  }


  updateprice() async{
    setState(() {
      progress = true;
    });

    List get_price = new List();

    print(update_prices);

    for(int i =0;i< update_prices.length; i++){
      get_price.add(update_prices[i].round());
    }

    var body = {
      "solutionId": solution_id,
      "serviceId": service_id,
      "updatedPrice": get_price
    };

    print(body);

    UpdatePrice updatePrice = await update_price(body, user_token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });


  setState(() {
    progress = false;
    Navigator.pop(context);
    if(updatePrice.success){
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (
            BuildContext context,
            ) =>
            _popup_saved(context),
      );
    }else{
      config.Config.showLongToast("Something went wrong!");
    }
  });


  }



  get_profile_info(String token) async{
    UserProfilePost userProfilePost = await user_profile(user_id, token).catchError((error){
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        progress = false;
      });
    });

    image_url = userProfilePost.user.imageUrl;
    initial_name = config.Config.get_initial_name(userProfilePost.user.name);
    name = userProfilePost.user.name;
    address = userProfilePost.user.address;




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

                    if(image_url != ''){
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
                  address,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),),

        ],
      ),
    );


    final diagnostic = Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Test or procedure requested",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),

          Text(
            diagnose,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500),
          ),

        ],
      ),
    );

    final sol_price = Padding(padding: const EdgeInsets.only(bottom: 20),
    child: ListView.builder(itemBuilder: (context, index){
      return  InkWell(
        onTap: (){
          showDialog(
              context: context,
              builder: (
                  BuildContext context,
                  ) =>
                  Widget_update(index));
        },
        child: Container(

          margin: EdgeInsets.only(left:10, bottom: 10, right: 10),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            categories[index] == "Basic"? Text("Enter Amount"):  Text(
                  categories[index],
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 5,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(width: 0.3, color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("₹ "+
                        update_prices[index].round().toString(),
                      style: TextStyle(
                          color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }, itemCount: price.length,shrinkWrap: true, physics: ScrollPhysics(),),
    );



    final apply =  Padding(
      padding: const EdgeInsets.only(left:36.0, right: 36.0,),
      child:  ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 10),
          child: FlatButton(
            child:  Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Text("We recommend you to update your fee upto $recommendation%, to maximize the patient bookings.", textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black)),
                 SizedBox(height: 10,),
                  InkWell(
                    onTap:enable? (){
                      setState(() {
                        for(int i =0; i< update_prices.length; i++){
                          update_prices[i] = (price[i] - (price[i] * double.parse(recommendation)/100.0));
                          price[i] = update_prices[i];
                        }
                        enable = false;
                      });
                    }:null,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left:15.0, top: 8, bottom: 8, right: 15),
                        child: Text("Apply Here", style: TextStyle(color: enable? Color(0xff01d35a):Colors.grey,
                          decoration: TextDecoration.underline,
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );

    final change =  Padding(
      padding: const EdgeInsets.only(left:36.0, right: 36.0, bottom: 30, top: 20),
      child:  ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: Container(
          margin: EdgeInsets.only(right: 20, left: 10),
          child: FlatButton(
            onPressed:updateprice,
            color: Color(0xff01d35a),
            child:  Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Submit", style: TextStyle(color: Colors.white)),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: app_bar,
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: progress? loading: Container(

        child: ListView(

          children: <Widget>[

            profile,
            diagnostic,
            Container(
              margin: EdgeInsets.only(left:20, right: 20, top: 20),
              child: Text("Solution fees", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            sol_price,
            int.parse(recommendation) > 10 ? apply: Container(),
//            apply,
            change,
          ],
        ),
      )
    );
  }


  Widget_update(int position){
    return CupertinoAlertDialog(
        title: new Text("Price"),
        content: Container(
          child: Column(
            children: <Widget>[
              Center(child: Text(" Please Enter your price")),
              Card(
                elevation: 0,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    controller: price_,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration.collapsed(
                      hintText: "Enter Price",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          progress? SpinKitThreeBounce(
            color: Color(0xff01d35a),
            size: 30.0,
            // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
          ):  CupertinoDialogAction(
            textStyle: TextStyle(color: Color(0xff01d35a)),
            isDefaultAction: true,
            child: new Text("Done"),
            onPressed: (){
              if(price_.text != '' && config.Config.isNumeric(price_.text)){
               setState(() {
                 update_prices[position] = double.parse( price_.text.toString());
                 price[position] = update_prices[position];
                 price_.text = '';
               });
                Navigator.pop(context);
              }else{
                config.Config.showLongToast("Please enter valid price");
              }
            },
          ),
        ]);
  }

  Widget _popup_saved(BuildContext context) {
    return new CupertinoAlertDialog(
      title: new Text('Success'),
      content: new Text('Successfully Updated..'),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            Navigator.pop(context);

          },
          child: new Text(
            'OK',
            style: TextStyle(color: Color(0xff01d35a)),
          ),
        ),
      ],
    );
  }

}