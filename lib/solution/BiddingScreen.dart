import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/get_procedure.dart';
import 'package:plunes/model/solution/find_solution.dart';
import 'package:plunes/solution/BiddingActivity.dart';
import 'package:plunes/solution/BiddingLoading.dart';
import 'package:plunes/start_streen/LocationFetch.dart';
import 'package:plunes/start_streen/Nearyou.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

///Geo_coder issues resolved

class BiddingPage extends StatefulWidget {
  static const tag = '/biddingscreen';

  @override
  _BiddingPageState createState() => _BiddingPageState();
}

class _BiddingPageState extends State<BiddingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _searchcontroller = TextEditingController();
  bool btn = false;
  bool cancel = false;
  String latitude = "0.0";
  String longitude = "0.0";
  bool show = false;
  bool show_hint = false;
  String rating_id = "";
  String rating_no = "";
  Map<MarkerId, Marker> marker = <MarkerId, Marker>{};

  String _locality = '';

  bool isGurugramCity = false;
  String FORYOU;

  bool progress = false;
  List data = new List();
  List selected_procedure = new List();
  List selectedSolutionDataList = new List();
  List testList = new List();
  Set submit_procedure = new Set();

  String user_id = "";
  String user_token = "";
  String user_type = "";
  String user_name = "";
  var location = new Location();
  double bottom_space = 0;
  String user_location = "";
  List<bool> selected = new List();
  int PAGE_NUM = 1;
  int downloadsPageNumber = 0;
  ScrollController solutionScrollController;
  int count = 0;
  bool _loadingMore = true;
  Timer _timer;
  String error_message = " ";
  final int PER_PAGE_COUNT = 100;
  void showInSnackBar(String value, MaterialColor color) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      backgroundColor: color,
    ));
  }

  @override
  void initState() {
    moving();
    tool_tip();
    solutionScrollController = ScrollController();
    solutionScrollController.addListener(solutionScrollListener);
    super.initState();
    getSharedPreferences();
    data = new List();
  }

  void moving() {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        setState(() {
          if (bottom_space == 0) {
            bottom_space = 15;
          } else {
            bottom_space = 0;
          }
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    solutionScrollController.dispose();
    _searchcontroller.dispose();
    if(data!=null && data.length>0)
      data.clear();
  }

  tool_tip() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bid_tip = prefs.getString("bid_tip");
    if (bid_tip != 'done2') {
      setState(() {
        show_hint = true;
      });
      Timer(Duration(seconds: 5), () {
        setState(() {
          show_hint = false;
        });
      });

      prefs.setString("bid_tip", "done2");
    } else if (bid_tip == 'done2') {
      setState(() {
        show_hint = false;
      });
    }
  }

  filter_data(String text) {
    setState(() {
      if(data!=null && _searchcontroller.text.length == 0)
        data.clear();
    });
    if(text.length>2)
    getPaginationContentForSearch(text, (downloadsPageNumber).toString());
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String location_ = prefs.getString("user_location");
    String uid = prefs.getString("uid");
    String name = prefs.getString('name');
    String image = prefs.getString('image');
    String type = prefs.getString("user_type");

    setState(() {
      user_id = uid;
      user_token = token;
      user_name = name;
      user_type = type;
      latitude = latitude;
    });

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      var location_ = await location.getLocation();
      latitude = location_.latitude.toString();
      longitude = location_.longitude.toString();
    }
    get_location();
  }

  void get_location() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      var location_ = await location.getLocation();
      latitude = location_.latitude.toString();
      longitude = location_.longitude.toString();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("latitude", latitude);
      prefs.setString("longitude", longitude);
      print(latitude + "," + longitude);
    }
    setState(() {
      getGeoAddress();
    });
  }

  Future getGeoAddress() async {
    await Future.delayed(Duration(milliseconds: 100), () async {
      final coordinates = new Coordinates(double.parse(latitude), double.parse(longitude));
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var address = addresses.first;
      _locality = address.locality;
      isGurugramCity = _locality == 'Gurugram' || _locality == 'Gurgaon';
      var full_address = address.addressLine;
    });
  }
  void apply_bid() async {
    List<ServicesData> service_data = new List();
    if (selectedSolutionDataList.length > 1) {
  /*    for (int i = 0; i < selected_procedure.length; i++) {
        String procedure_id = selected_procedure[i];
        if (selected_procedure[i].contains(" (Procedure)")) {
          int pos = config.Config.procedure_name.indexOf(selected_procedure[i].replaceAll(" (Procedure)", ""));
          procedure_id = config.Config.procedure_id[pos];
        } else if (selected_procedure[i].contains(" (Test)")) {
          int pos = config.Config.procedure_name.indexOf(selected_procedure[i].replaceAll(" (Test)", ""));
          procedure_id = config.Config.procedure_id[pos];
        } else if (selected_procedure[i].contains(" (Speciality)")) {
          int pos = config.Config.procedure_name.indexOf(selected_procedure[i].replaceAll(" (Speciality)", ""));
          procedure_id = config.Config.procedure_id[pos];
        } else if (selected_procedure[i].contains(" (Consultation)")) {
          int pos = config.Config.procedure_name.indexOf(selected_procedure[i].replaceAll(" (Consultation)", ""));
          procedure_id = config.Config.procedure_id[pos];
        }
        setState(() {
          progress = true;
        });
        FindSolutionPost findSolutionPost = await find_solution(user_id, procedure_id, user_token).catchError((error) {
          config.Config.showLongToast("Something went wrong!");
          print(error);
          setState(() {
            progress = false;
          });
        });
      }
*/
      for (int i = 0; i < selectedSolutionDataList.length; i++) {
        setState(() {
          progress = true;
        });
        FindSolutionPost findSolutionPost = await find_solution(user_id, selectedSolutionDataList[i].id, user_token).catchError((error) {
          config.Config.showLongToast("Something went wrong!");
          print(error);
          setState(() {
            progress = false;
          });
        });
      }
      setState(() {
        progress = false;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BiddingLoading(screen: "multiple")));
      });
    } else {
     /* String procedure_id = selected_procedure[0];
      if (selected_procedure[0].contains(" (Procedure)")) {
        int pos = config.Config.procedure_name.indexOf(selected_procedure[0].replaceAll(" (Procedure)", ""));
        procedure_id = config.Config.procedure_id[pos];
      } else if (selected_procedure[0].contains(" (Test)")) {
        int pos = config.Config.procedure_name.indexOf(selected_procedure[0].replaceAll(" (Test)", ""));
        procedure_id = config.Config.procedure_id[pos];
      } else if (selected_procedure[0].contains(" (Speciality)")) {
        int pos = config.Config.procedure_name.indexOf(selected_procedure[0].replaceAll(" (Speciality)", ""));
        procedure_id = config.Config.procedure_id[pos];
      } else if (selected_procedure[0].contains(" (Consultation)")) {
        int pos = config.Config.procedure_name.indexOf(selected_procedure[0].replaceAll(" (Consultation)", ""));
        procedure_id = config.Config.procedure_id[pos];
      }*/

      var _solutionType = '';
      if (selected_procedure[0].contains("Consultation")) {
        _solutionType = 'Consultation';
      } else if (selected_procedure[0].contains("Test")) {
        _solutionType = 'Test';
      } else if (selected_procedure[0].contains("Speciality")) {
        _solutionType = 'Speciality';
      } else if (selected_procedure[0].contains("Procedure")) {
        _solutionType = 'Procedure';
      }
      setState(() {
        progress = true;
      });
      FindSolutionPost findSolutionPost = await find_solution(user_id, selectedSolutionDataList[0].id, user_token).catchError((error) {
        config.Config.showLongToast("Something went wrong!");
        setState(() {
          progress = false;
        });
      });

      setState(() {
        progress = false;
        if (findSolutionPost.success) {
          for (int i = 0; i < findSolutionPost.services.length; i++) {
            service_data.add(findSolutionPost.services[i]);
          }

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BiddingLoading(
                      service_data: service_data,
                      createdTime: findSolutionPost.createdTime,
                      serviceId: findSolutionPost.serviceId,
                      id_: findSolutionPost.id,
                      screen: "single",
                      solutionType: _solutionType)));
        } else {
          config.Config.showInSnackBar(
              _scaffoldKey, findSolutionPost.message, Colors.red);
        }
      });
    }
  }

  Widget confirmed(BuildContext context) {
    return CupertinoAlertDialog(
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              child: GestureDetector(
                child: Icon(Icons.clear),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              alignment: Alignment.topRight,
            ),
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      border: Border.all(width: 1, color: Color(0xff01d35a))),
                ),
                Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Image.asset(
                      'assets/images/bottom_tabs/bid.png',
                      height: 50,
                      width: 50,
                    )),
              ],
            ),
            Container(
                margin: EdgeInsets.only(top: 40),
                child: Text(
                  "Your concern has been submitted!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Container(
                margin: EdgeInsets.only(top: 10, bottom: 30),
                child: Text(
                  "You will receive the solution within 24 hours.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ))
          ],
        ),
      ),
    );
  }


  Future getPaginationContentForSearch(String searchKey, String pageCount) async{
    var header = {
      "Content-Type": "application/json",
      "Authorization":"Bearer "+ user_token
    };
    var body = {
      'expression': searchKey,
      'limit':PER_PAGE_COUNT.toString(),
      'page': pageCount
    };
    return http.post(config.Config.solutionSearch, headers: header, body: json.encode(body)).then((http.Response response) {
      var errorBody = {
        "success": false,
        "message": "Something went wrong!"
      };
      print('result===${response.body}');
     /*
     if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
        return SearchSolutionModel.fromJson(errorBody);
      }*/
      SearchSolutionModel result = SearchSolutionModel.fromJson(json.decode(response.body));
      if(result.status){
        setState(() {
//          data.clear();
         List newList = List();
          newList = result.procedureData;
          if (newList.length == 0) {
            _loadingMore = false;
          } else {
//            if(!_loadingMore){
              data = newList;
          /*  }else {
              for (int i = 0; i < newList.length; i++) {
                data.add(newList[i]);
              }
            }*/
            _loadingMore = newList.length % PER_PAGE_COUNT == 0;
          }
        });
      }

      print(result);
    });
  }

  void solutionScrollListener() {
   /* if (data == null || data.length == 0 || data.length % PER_PAGE_COUNT != 0 || !_loadingMore)
      return;
    if (solutionScrollController.position.maxScrollExtent == solutionScrollController.offset) {
      getPaginationContentForSearch(_searchcontroller.text, (++downloadsPageNumber).toString());
    }*/
  }
  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final message = Container(
      margin: EdgeInsets.only(left: 50, right: 50),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Search for the best price",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Text(
              "solution near you",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );

    final get_bids_list = btn
        ? ListView.builder(
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  children: <Widget>[
                    index != 0
                        ? Container(
                            height: 0.5,
                            color: Colors.grey,
                            margin: EdgeInsets.only(top: 5))
                        : Container(margin: EdgeInsets.only(top: 5)),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 5),
                                alignment: Alignment.centerLeft,
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          style: TextStyle(color: Colors.black),
                                          text: selected_procedure[index].toString().contains('(Procedure)')
                                              ? selected_procedure[index].toString().split('(Procedure)')[0]
                                              : (selected_procedure[index].toString().contains('(Test)') ? selected_procedure[index].toString().split('(Test)')[0] : selected_procedure[index]),
                                        ),
                                        TextSpan(
                                          style: TextStyle(
                                              color: Color(0xff01d35a)),
                                          text: selected_procedure[index].toString().contains('(Procedure)') ? '(Procedure)' : (selected_procedure[index].toString().contains('(Test)') ? '(Test)' : ''),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    InkWell(
                                      child: Icon(
                                        Icons.info_outline,
                                        color: Color(0xff757575),
                                      ),
                                      onTap: () {
                                        int pos = config.Config.procedure_lists.indexOf(selected_procedure[index]);
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                _popup_dialoge(
                                                    context,
                                                    selectedSolutionDataList[index].details, selected_procedure[index]));
                                      },
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _searchcontroller.text = '';
                                          selected_procedure.removeAt(index);
                                          selectedSolutionDataList.removeAt(index);
                                          if (selected_procedure.length == 0) {
                                            cancel = false;
                                            btn = false;
                                          }
                                        });
                                      },
                                      child: Container(
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0,
                                                right: 10,
                                                top: 3,
                                                bottom: 3),
                                            child: Icon(
                                              Icons.clear,
                                              size: 25,
                                              color: Color(0xff757575),
                                            )),
                                        margin: EdgeInsets.only(
                                            top: 10, bottom: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.centerRight,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            shrinkWrap: true,
            itemCount: selected_procedure.length,
            physics: ClampingScrollPhysics(),
          )
        : Container();

    final bidding_activity = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Text(
              "Solution Activities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              margin: EdgeInsets.only(bottom: bottom_space),
              child: Icon(Icons.keyboard_arrow_down, color: Color(0xff01d35a)),
            ),
          )
        ],
      ),
    );

    final search_procedure = Container(
        margin: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                getSearchRowView(),
                Visibility(
                  visible: show_hint,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          width: 250,
                          margin: EdgeInsets.only(top: 10),
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text("Get Started",
                                    style: TextStyle(color: Color(0xffBFF3D5))),
                                Text("Type the test or procedure",
                                    style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3)),
                              color: Color(0xff65D45A)),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 8),
                          width: 250,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                              onTap: () async {
                                setState(() {
                                  show_hint = false;
                                });
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setString("bid_tip", "done2");
                              },
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/arrow.png',
                          color: Color(0xff65D45A),
                          height: 30,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(bottom: 0, top: 5),
                    child: _searchcontroller.text.length > 0
                        ? ListView.builder(
                            itemCount: data.length,
                            physics: NeverScrollableScrollPhysics(),
//                        controller: solutionScrollController,
                        shrinkWrap: true,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return rowLayout(index);
                            })
                        : Container(),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5.0)]))
              ],
            ),
            cancel
                ? Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          cancel = false;
                          _searchcontroller.text = '';
                          if(data!=null&&_searchcontroller.text == '')
                            data.clear();
                        });
                      },
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: Container(
                        margin: EdgeInsets.only(top: 8, bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.clear),
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        ));

    final bid_activity = Container(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BiddingActivity(
                  screen: 0,
                ),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              bidding_activity,
            ],
          ),
        ),
      ),
      margin: EdgeInsets.only(top: 100),
    );

    final upload_desc = InkWell(
      onTap: () {
        get_location();
        if (!isGurugramCity) {
          showDialog(
              context: context,
              builder: (
                BuildContext context,
              ) =>
                  _popup_loacation_not_available(context));
        } else {
          apply_bid();
        }
      },
      child: progress
          ? SpinKitThreeBounce(
              color: Color(0xff01d35a),
              size: 30.0,
              // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
            )
          : Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 20, top: 30, left: 80, right: 80),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xff01d35a)),
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('  Proceed  ',
                      style: TextStyle(color: Colors.white))),
            ),
    );

    final form = Center(
        child: Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 80,
            child: Visibility(
              visible: !btn,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Nearyou.tag);
                },
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Health Solutions Near you",
                        style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Avail upto 50% Discount",
                        style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: btn ? Container() : bid_activity,
        ),
        Container(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              color: Colors.white,
              child: ListView(
                controller: solutionScrollController,

                shrinkWrap: true,
                children: <Widget>[
                  message,
                  search_procedure,
                  get_bids_list,
                  btn ? upload_desc : Container(),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: form);
  }

  Widget _popup_loacation_not_available(BuildContext context) {
    return new CupertinoAlertDialog(
      content: Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 200,
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: GoogleMap(
                      onTap: (LatLng latlng) {
                        print(latlng.latitude.toString() +
                            "," +
                            latlng.longitude.toString());
                      },
                      mapType: MapType.normal,
                      myLocationButtonEnabled: true,
                      rotateGesturesEnabled: true,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      myLocationEnabled: true,
                      compassEnabled: true,
                      tiltGesturesEnabled: true,
                      markers: Set<Marker>.of(marker.values),
                      onCameraMoveStarted: () {
                        print("Started to move");
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(double.parse(latitude), double.parse(longitude)),
                        zoom: 15.0,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(PageRouteBuilder(
                            opaque: false,
                            pageBuilder: (BuildContext context, _, __) =>
                                LocationFetch(
                                  latitude: latitude,
                                  longitude: longitude,
                                )))
                        .then((val) {
                      List address_list = new List();
                      address_list = val.toString().split(":");
                      String address_get = address_list[0] +
                          " " +
                          address_list[1] +
                          " " +
                          address_list[2];
                      user_location = address_get;
                      setState(() {
                        latitude = address_list[3];
                        longitude = address_list[4];
                      });

                      Navigator.pop(context);
                      showDialog(
                          context: context,
                          builder: (
                            BuildContext context,
                          ) =>
                              _popup_dialoge_address_confirm(
                                  context, user_location));

                      print("getting loc" + latitude + ", " + longitude);
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(10),
                    height: 45,
                    alignment: Alignment.centerLeft,
                    child: Text("   Search Location",
                        style: TextStyle(color: Colors.black, fontSize: 12)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Color(0xffffffff)),
                  ),
                ),
              ],
            ),
            Container(
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "We are bringing the best health",
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    "care solution at your location soon.",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "For now check it in Gurugram.",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 45,
                      width: 200,
                      alignment: Alignment.center,
                      child: Text(
                        "Ok",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Color(0xff01d35a)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _popup_dialoge_address_confirm(BuildContext context, String address) {
    return new CupertinoAlertDialog(
      title: Text("Address"),
      content: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(address),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () async {
                final coordinates = new Coordinates(
                    double.parse(latitude), double.parse(longitude));
                var addresses = await Geocoder.local
                    .findAddressesFromCoordinates(coordinates);
                var address = addresses.first;
                _locality = address.locality;

                isGurugramCity = _locality == 'Gurugram' || _locality == 'Gurgaon';
                var full_address = address.addressLine;
                print('address=====================${addresses.first}' + ', ' + '${address.addressLine}');
                Navigator.pop(context);
                if (!isGurugramCity) {
                  showDialog(
                      context: context,
                      builder: (
                        BuildContext context,
                      ) =>
                          _popup_loacation_not_available(context));
                } else {
                  apply_bid();
                }
              },
              child: Container(
                height: 35,
                width: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
                alignment: Alignment.center,
                child: Text(
                  "Proceed",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getSearchRowView() {
    return Container(
        child: TextField(
            controller: _searchcontroller,
            onChanged: (text) {
              setState(() {
                filter_data(text);
                if (text.length != 0) {
                  cancel = true;
                } else {
                  cancel = false;
                }
              });
            },
            decoration: InputDecoration(
              hintText: "Medical Procedures, Tests, Appointments",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(width: 0.1, color: Color(0xff01d35a))),
            )));
  }

  Widget rowLayout(int index) {
    return GestureDetector(
        onTap: () {
          setState(() {
            btn = true;
            cancel = false;
            _searchcontroller.text = '';
            if (!selected_procedure.contains((data[index].service +" ("+data[index].category+")"))) {
              selected_procedure.add((data[index].service +" ("+data[index].category+")"));
              selectedSolutionDataList.add(new ProcedureData(id: data[index].id, service: data[index].service,details: data[index].details,description: data[index].description,
                category: data[index].category, tags: data[index].tags,dnd: data[index].dnd));

            }
            if(_searchcontroller.text == '')
            data.clear();
          });
        },
        child: Container(
          child: Container(
            color: Colors.white,
            child: ListTile(
              title: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      style: TextStyle(color: Colors.black),
                      text: (data[index].service +" ("+data[index].category+")").contains('(Procedure)') ? (data[index].service +" ("+data[index].category+")").toString().split('(Procedure)')[0] : ((data[index].service +" ("+data[index].category+")").contains('(Test)')
                          ? (data[index].service +" ("+data[index].category+")").split('(Test)')[0] : (data[index].service +" ("+data[index].category+")")),
                    ),
                    TextSpan(
                      style: TextStyle(color: Color(0xff01d35a)),
                      text: (data[index].service +" ("+data[index].category+")").contains('(Procedure)') ? '(Procedure)' : ((data[index].service +" ("+data[index].category+")").contains('(Test)') ? '(Test)' : ''),
                    ),
                  ],
                ),
              ) /*Text(suggestion)*/,
              // subtitle: Text('\$${suggestion['price']}'),
            ),
          ),
        ));
  }
}

Widget _popup_dialoge(BuildContext context, String def, String name) {
  return new CupertinoAlertDialog(
    content: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              def,
//              maxLines: 6,
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
