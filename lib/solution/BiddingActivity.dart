import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plunes/model/solution/searched_solutions.dart';
import 'package:plunes/solution/SolutionResults.dart';
import 'package:plunes/solution/UserDetailsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:shimmer/shimmer.dart';

import '../config.dart';

class BiddingActivity extends StatefulWidget {
  final String solutionType;
  final int screen;

  BiddingActivity({Key key, this.screen, this.solutionType}) : super(key: key);

  static const tag = '/bidding_activity';

  @override
  _BiddingActivityState createState() => _BiddingActivityState(screen);
}

class _BiddingActivityState extends State<BiddingActivity> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool progress = true;

  String user_token = "";
  String user_id = "";
  String user_type = "";
  String specialist = "";
  List status = new List();
  int i = 0;
  int screen;

  _BiddingActivityState(this.screen);

  SearchedSolutions searchedSolutions;

  List<PersonelData> personal = new List();
  List<BusinessData> business = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSharedPreferences();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    String type = prefs.getString("user_type");

    setState(() {
      user_token = token;
      user_id = uid;
      user_type = type;
    });

    get_searched_solutions(token);
  }

  get_searched_solutions(String token) async {
    searchedSolutions = await searched_solution(token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      print(error);
      setState(() {
        progress = false;
      });
    });

    setState(() {
      progress = false;
      if (searchedSolutions.success) {
        personal = searchedSolutions.personal;
        business = searchedSolutions.business;
      } else {
        config.Config.showInSnackBar(
            _scaffoldKey, searchedSolutions.message, Colors.red);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final options_tabs = Container(
        padding: EdgeInsets.all(10),
        child: DefaultTabController(
          length: 2,
          initialIndex: screen,
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                constraints: BoxConstraints.expand(height: 30),
                //  foregroundDecoration: BoxDecoration(color:Colors.red),
                child: TabBar(
                  tabs: [
                    Tab(text: "Business"),
                    Tab(
                      text: "Personal",
                    ),
                  ],
                  labelStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff262626)),
                  indicatorColor: Color(0xff01d35a),
                  unselectedLabelColor: Color(0xff808080),
                  labelColor: Colors.black,
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: TabBarView(
                    children: [
                      business_(),
                      personel_(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));

    final top = Container(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.popAndPushNamed(context, HomeScreen.tag);
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.clear,
                  size: 25,
                ),
              ),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text("Solutions",
                  style: TextStyle(color: Colors.black, fontSize: 18)),
            )),
          ],
        ),
      ),
    );

    final loading =
        Expanded(child: ListView.builder(itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Color(0xffF5F5F5),
        highlightColor: Color(0xffFAFAFA),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xffF5F5F5),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
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
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    }));

    final list_solutions = Expanded(
      child: user_type == 'User' ? personel_() : options_tabs,
    );

    final form = Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[top, progress ? loading : list_solutions],
      ),
    );

    return Scaffold(
        key: _scaffoldKey, backgroundColor: Colors.white, body: form);
  }

  Widget business_() {
    if (business.length == 0) {
      return Container(
        child: Center(
          child: Text("No Results"),
        ),
      );
    } else {
      return ListView.builder(
          itemBuilder: (context, index) {
            int pos;
            for (int i = 0; i < business.length; i++) {
              pos =
                  config.Config.procedure_id.indexOf(business[index].serviceId);
            }

            List price = new List();
            List categories = new List();
            String service_id;
            String recommendation = "";

            for (int i = 0; i < business[index].services.length; i++) {
              if (user_id == business[index].services[i].professionalId) {
                price.addAll(business[index].services[i].newPrice);
                service_id = business[index].services[i].id;
                recommendation = business[index].services[i].recommendation;
                categories = business[index].services[i].category;
              }
            }

            return price.length == 0
                ? Container(
                    child: Center(
                      child: Text(""),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailsScreen(
                              user_id: business[index].user_id,
                              price: price,
                              solution_id: business[index].id,
                              categories: categories,
                              recommendation: recommendation,
                              service_id: service_id,
                              diagnose: config.Config.procedure_name[pos],
                            ),
                          ));
                    },
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Row(
                            children: <Widget>[
                              business[index].imageUrl != ''
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                          business[index].imageUrl),
                                    )
                                  : Container(
                                      height: 40,
                                      width: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        config.Config.get_initial_name(
                                                business[index].name)
                                            .toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        gradient: new LinearGradient(
                                            colors: [
                                              Color(0xffababab),
                                              Color(0xff686868)
                                            ],
                                            begin: FractionalOffset.topCenter,
                                            end: FractionalOffset.bottomCenter,
                                            stops: [0.0, 1.0],
                                            tileMode: TileMode.clamp),
                                      )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Text(
                                          business[index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )),
                                        Text(
                                          config.Config.get_duration(
                                              business[index].createdTime),
                                          style: TextStyle(color: Colors.grey),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: Text(
                                            config.Config.procedure_name[pos],
                                            style:
                                                TextStyle(color: Colors.grey),
                                          )),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          price.length != 0
                                              ? Text("₹" + price[0].toString())
                                              : Text("")
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
          },
          itemCount: business.length);
    }
  }

  Widget personel_() {
    if (personal.length == 0) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "You have missed 35% on\n"
              "your Procedure Previously.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xff424242)),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Please make sure you book\n"
              "within 1 hour to proceed with the\n"
              "top doctors.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                int pos;
                for (int i = 0; i < personal.length; i++) {
                  pos = config.Config.procedure_id
                      .indexOf(personal[index].serviceId);
                }

                return Container(
                  child: InkWell(
                    onTap: () {
                      int mins = config.Config.get_minutes_diff(
                          personal[index].createdTime);

                      if (mins < 60) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SolutionResults(
                                      service_data: personal[index].services,
                                      createdTime: personal[index].createdTime,
                                      serviceId: personal[index].serviceId,
                                      id_: personal[index].id,
                                      position: index,
                                      solutionType: widget.solutionType,
                                    )));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 20,
                                top: 8,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      child: Text(
                                          config.Config.procedure_name[pos]),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          //  snapshot.toString() == '0' ?
                                          Text(
                                            personal[index]
                                                    .services
                                                    .length
                                                    .toString() +
                                                " received",
                                            style: TextStyle(
                                              color: Color(0xff01d35a),
                                              fontSize: 13,
                                            ),
                                          ),

                                          SizedBox(
                                            height: 10,
                                          ),

                                          Text(
                                            config.Config.get_duration(
                                                personal[index].createdTime),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 1,
                            color: Color(0xfff0f0f0),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: personal.length,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color(0xfff2f2f2),
            ),
            margin: EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Please make sure you book it within a short time, "
                "keeping in mind it is valid only for 1 hour.",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          )
        ],
      );
    }
  }
}
