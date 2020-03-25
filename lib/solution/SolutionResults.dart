import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plunes/appointment/Appointments.dart';
import 'package:plunes/model/solution/searched_solutions.dart';
import 'package:plunes/profile/UserProfile.dart';
import 'package:plunes/solution/BookingScreen.dart';
import 'package:plunes/solution/MapViewScreen.dart';
import 'package:plunes/solution/Payment.dart';
import 'package:plunes/model/solution/find_solution.dart';
import 'package:plunes/model/solution/init_payment.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:plunes/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';

class SolutionResults extends StatefulWidget {
  static const tag = '/solutionresults';

  final List<ServicesData> service_data;
  final int createdTime;
  final String serviceId;
  final String id_,solutionType;
  final int position ;

  SolutionResults(
      {Key key,
      this.service_data,
      this.createdTime,
      this.serviceId,
      this.id_,
      this.position, this.solutionType})
      : super(key: key);

  @override
  _SolutionResultsState createState() => _SolutionResultsState(
      service_data, createdTime, serviceId, id_, position);
}

class _SolutionResultsState extends State<SolutionResults> {
  List<ServicesData> service_data;
  final int createdTime;
  final String serviceId;
  final String id_;
  final int position;

  int selectedPos = 0, serviceIndex = 0;

  BuildContext globalContext;

  _SolutionResultsState(this.service_data, this.createdTime, this.serviceId,
      this.id_, this.position);

  String procedure_name = "";
  String user_token = "", userType = '';
  String user_id = "";
  bool progress = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List latitude = new List();
  List longitude = new List();
  List distance = new List();
  List name = new List();
  List<bool> selected_ = new List();

  bool show_popup = false;
  bool hide_negociating = false;
  SharedPreferences prefs;
  Timer _timer;
  int _start = 600;


  @override
  void initState() {
    super.initState();
    getshareference();
  }

  getshareference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");
    userType = prefs.getString("user_type");
    setState(() {
      user_token = token;
      user_id = uid;
    });

    set_data();
  }

  set_data() {
    setState(() {
      if (service_data.length > 0) {
        if (config.Config.get_minutes_diff(createdTime) < 10) {
          for (int i = 0; i < service_data.length; i++) {
            if (service_data[i].negotiating) {
              show_popup = true;
              hide_negociating = true;
            }
          }
        } else {
          show_popup = false;
          hide_negociating = false;
        }
        int pos = config.Config.procedure_id.indexOf(serviceId);
        procedure_name = config.Config.procedure_name[pos];
        for (int i = 0; i < service_data.length; i++) {
          latitude.add(service_data[i].latitude);
          longitude.add(service_data[i].longitude);
          distance.add(service_data[i].distance);
          name.add(service_data[i].name);
        }
      }
    });
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) => setState(() {
          if (_start < 1) {
            timer.cancel();
            show_popup = false;
            hide_negociating = false;
          } else {
            _start = _start - 1;
            get_searched_solutions(user_token);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  get_searched_solutions(String token) async {
    SearchedSolutions searchedSolutions =
        await searched_solution(token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      print(error);
      setState(() {
        progress = false;
      });
    });

      progress = false;
      if (searchedSolutions.success && searchedSolutions.personal.length>0) {
        for (int i = 0; i < service_data.length; i++) {
          service_data[i] = searchedSolutions.personal[position].services[i];
          if (!service_data[i].negotiating) {
            show_popup = false;
            hide_negociating = false;
          }else {
            show_popup = true;
            hide_negociating = true;
          }
        }
      } else {
        config.Config.showInSnackBar(_scaffoldKey, searchedSolutions.message, Colors.red);
        _timer.cancel();
      }
  }

  initiate_Payment(String professional_id, String sol_id, String service_id, String time_slot, String appointmentTime, String percentage, int price_pos, int creditsUsed, [String couponName]) async {
    var body = {
      "solutionServiceId": sol_id + "|" + service_id + "|" + price_pos.toString(),
      "serviceId": serviceId,
      "paymentPercent": percentage,
      "timeSlot": time_slot,
      "professionalId": professional_id,
      "appointmentTime": appointmentTime,
      "userId": user_id,
      "creditsUsed": creditsUsed,
      'coupon': couponName
    };
    setState(() {
      progress = true;
    });
    InitPaymentPost initPaymentPost = await init_payment(body, user_token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        progress = false;
      });
    });

    if (initPaymentPost.success) {
      if (initPaymentPost.status.contains("Confirmed")) {
        showDialog(context: context, builder: (BuildContext context) => PaymentSuccess(bookingId: initPaymentPost.referenceId));
      } else {
        Navigator.of(context).push(PageRouteBuilder(opaque: false, pageBuilder: (BuildContext context, _, __) => Payment(id: initPaymentPost.id))).then((val) {
          if (val.toString().contains("success")) {
            showDialog(context: context, builder: (BuildContext context,) => PaymentSuccess(bookingId: initPaymentPost.referenceId));
          } else if (val.toString().contains("fail")) {
            config.Config.showLongToast("Payment Failed");
          } else if (val.toString().contains("cancel")) {
            config.Config.showLongToast("Payment Cancelled");
          }
        });
      }
    } else {
      config.Config.showInSnackBar(_scaffoldKey, initPaymentPost.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;

    final popup_hold_on = Container(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xff99000000)),
              padding: EdgeInsets.all(10),
              child: Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SpinKitCircle(
                        color: Color(0xff01d35a),
                        size: 50.0,
                        // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Hold on",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    ],
                                  )),
                          /*        GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        show_popup = false;
                                      });
                                    },
                                    child: Container(
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                      alignment: Alignment.centerRight,
                                    ),
                                  ),*/
                                ],
                              ),
                              Container(
                                child: Text(
                                  "We are negotiating the best fee for you."
                                  " It may take sometime, we'll update you.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );

    final app_bar = Container(
      height: 60,
      margin: EdgeInsets.only(top: 20),
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
                  Icons.arrow_back_ios,
                  size: 20,
                ),
              ),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Text("Solution Received",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ))
          ],
        ),
      ),
    );

    final top_tab = Container(
      alignment: Alignment.center,
      color: Color(0xff01d35a),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 50,
              margin: EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  procedure_name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            width: 20,
          ),
          Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.centerRight,
            child: Row(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    showDialog(
                        context: globalContext,
                        builder: (
                          BuildContext context,
                        ) =>
                            MapViewScreen(
                              latitude: latitude,
                              longitude: longitude,
                              distance: distance,
                              name: name,
                            ));
                  },
                  child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: Image.asset(
                        'assets/map_icon.png',
                        height: 25,
                        width: 25,
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final time = Row(
      children: <Widget>[
        Expanded(child: Container()),
        Container(
          child: Text(
            config.Config.get_duration(createdTime),
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          margin: EdgeInsets.only(right: 20, top: 10),
        ),
      ],
    );

    final doc_list = Expanded(
        child: service_data.length == 0
            ? Center(
                child: Text(
                  "Sorry, currently no doctors available near you.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : Container(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    String initial_name = service_data[index].name!=''?config.Config.get_initial_name(service_data[index].name):'';

                    int temp = 0;
                    int temp2 = 0;

                    double price = 0;
                    double new_price = 0;

                    List price_ = new List();

                    for (int i = 0; i < service_data[index].price.length; i++) {
                      price_.add(0);
                      price_[i] = service_data[index].price[i];
                    }

                    List price_new_ = new List();
                    for (int i = 0;
                        i < service_data[index].newPrice.length;
                        i++) {
                      price_new_.add(0);
                      price_new_[i] = service_data[index].newPrice[i];
                    }

                    for (int i = 0; i < price_.length; i++) {
                      for (int j = i + 1; j < price_.length; j++) {
                        if (price_[i] > price_[j]) {
                          temp = price_[i];
                          price_[i] = price_[j];
                          price_[j] = temp;
                        }
                      }
                    }
                    price = price_[0].toDouble();

                    for (int i = 0; i < price_new_.length; i++) {
                      for (int j = i + 1; j < price_new_.length; j++) {
                        if (price_new_[i] > price_new_[j]) {
                          temp2 = price_new_[i];
                          price_new_[i] = price_new_[j];
                          price_new_[j] = temp2;
                        }
                      }
                    }

                    new_price = price_new_[0].toDouble();

                    return Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15, bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                        user_id:
                                            service_data[index].professionalId,
                                      ),
                                    ));
                              },
                              child: service_data[index].imageUrl != '' &&
                                      !service_data[index]
                                          .imageUrl
                                          .contains("default")
                                  ? CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                          service_data[index].imageUrl),
                                    )
                                  : Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        initial_name.toUpperCase(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
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
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: service_data[index].negotiating &&
                                      hide_negociating
                                  ? Container(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              UserProfile(
                                                            user_id: service_data[index].professionalId,
                                                          ),
                                                        ));
                                                  },
                                                  child: Text(
                                                    service_data[index].name,
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                service_data[index].distance ==
                                                        "0"
                                                    ? Text(
                                                        "Few meters away",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                      )
                                                    : Text(
                                                        "${service_data[index].distance} kms away",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12),
                                                      ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: <Widget>[
                                              SpinKitThreeBounce(
                                                color: Color(0xff01d35a),
                                                size: 20.0,
                                                // controller: AnimationController(duration: const Duration(milliseconds: 1200)),
                                              ),
                                              Text("Negotiating...",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      color:
                                                          Color(0xff01d35a))),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: <Widget>[
                                        Row(children: <Widget>[
                                          Expanded(
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UserProfile(
                                                        user_id:
                                                            service_data[index].professionalId,
                                                      ),
                                                    ));
                                              },
                                              child: Text(
                                                service_data[index].name,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          (service_data[index].discount.contains('-')? 0: int.parse(service_data[index].discount!=''?service_data[index].discount:'0')) < 5 ? Text("") : userType == 'User'
                                                  ? Text("₹" + price.toString(),
                                                      style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)) : Container(),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text("₹" + new_price.toString())
                                        ]),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: service_data[index]
                                                            .distance ==
                                                        "0"
                                                    ? Text(
                                                        "Few meters away",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                      )
                                                    : Text(
                                                        "${service_data[index].distance.toString()} kms away",
                                                        style: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 12),
                                                      )),
                                            // procedure Name
                                            userType == 'User'
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            top: 8,
                                                            bottom: 8),
                                                    child: int.parse(service_data[index].discount) < 5 ? Text("")
                                                        : Text("Save ${service_data[index].discount.toString()}%", style: TextStyle(color: Color(0xff01d35a))),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Expanded(child: Container()),
                                            InkWell(
                                              onTap: () {
                                                int pos = config
                                                    .Config.procedure_id
                                                    .indexOf(serviceId);
                                                String dnd = config
                                                    .Config.procedure_dnd[pos];

                                                showDialog(context: globalContext, barrierDismissible: true, builder: (BuildContext context) => _popup_show_dnd(context, dnd));
                                              },
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 3, bottom: 3),
                                                  child: Text("View Details", style: TextStyle(color: Colors.grey),),),
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                                    border: Border.all(color: Colors.grey, width: 0.3)),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (service_data[index].price.length > 1) {
                                                  serviceIndex = index;
                                                  showDialog(context: globalContext, barrierDismissible: true, builder: (BuildContext context) => list_categories(index, BuildContext));
                                                } else {
                                                  showDialog(
                                                      context: globalContext,
                                                      builder: (BuildContext context,) =>
                                                          BookingScreen(
                                                            prof_id: service_data[index].professionalId,
                                                            screen: "booking", timeslots_data: service_data[index].timeSlots,
                                                            price: new_price.toString(),solutionType: widget.solutionType)).then((val) {
                                                    if (val.toString().contains('pay')) {
                                                      String couponName = '';
                                                      if(val.toString().contains('/')){
                                                        couponName = val.toString().split('/')[1];
                                                        val =  val.toString().split('/')[0];
                                                      }
                                                      String time = val.toString().substring(3);
                                                      List time_get = time.split("#");
                                                      String professional_id = service_data[index].professionalId;
                                                      String solutionId = id_;
                                                      String serviceId = service_data[index].id;
                                                      String percentage = time_get[2];
                                                      String appointmentTime = time_get[1].toString().trim();
                                                      String timeSlot = time_get[0];
                                                      int apply_credit = int.parse(time_get[3]);
                                                      int price_pos = 0;
                                                      initiate_Payment(professional_id, solutionId, serviceId, timeSlot,appointmentTime, percentage, price_pos, apply_credit, couponName);
                                                    }
                                                  });
                                                }
                                              },
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 3, bottom: 3),
                                                  child: Text("Book", style: TextStyle(color: Colors.white))),
                                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0xff01d35a)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 0.2,
                                          color: Colors.grey,
                                        )
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: service_data.length,
                ),
              ));

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[app_bar, top_tab, time, doc_list],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Visibility(
              child: popup_hold_on,
              visible: show_popup,
            ),
          ),
        ],
      ),
    );
  }

  Widget list_categories(int position, context) {
    position = serviceIndex;
    return new CupertinoAlertDialog(
      title: Row(
        children: <Widget>[
          Expanded(
              child: new Text(
            "Available Options",
            style: TextStyle(fontSize: 16),
          )),
        ],
      ),
      content: Container(
          height: 210,
          margin: EdgeInsets.only(top: 20),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    selected_.add(false);
                    selected_[0] = true;

                    return Container(
                      height: 50,
                      margin: EdgeInsets.only(bottom: 2),
                      child: FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          selectedPos = index;
                          Navigator.pop(context);

                          showDialog(
                              context: globalContext,
                              barrierDismissible: true,
                              builder: (BuildContext context) => list_categories(serviceIndex, BuildContext));

                          if (!selected_[selectedPos]) {
                            selected_[selectedPos] = true;
                          } else {
                            for (int i = 0; i < selected_.length; i++) {
                              selected_[i] = true;
                            }
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.all(0),
                          padding: EdgeInsets.all(0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Text(
                                        service_data[position].category[index],
                                        style: TextStyle(fontSize: 12))),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                      "Save " +
                                          service_data[position].discount +
                                          "%",
                                      style: TextStyle(
                                          color: Color(0xff01d35a),
                                          fontSize: 12)),
                                ),
                                SizedBox(
                                  width: 1,
                                ),
                                Expanded(
                                  child: Text(
                                    "Rs." +
                                        service_data[position]
                                            .newPrice[index]
                                            .toString(),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                SizedBox(
                                  width: 1,
                                ),
                                selectedPos == index
                                    ? Image.asset(
                                        'assets/images/solution_result/selected.png',
                                        height: 25,
                                        width: 25,
                                      )
                                    : Image.asset(
                                        'assets/images/solution_result/unselected.png',
                                        height: 25,
                                        width: 25,
                                      )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: service_data[position].price.length,
                  shrinkWrap: true,
                ),
              ),
              Container(
                height: 50,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Navigator.pop(globalContext);
                        showDialog(
                            context: globalContext,
                            builder: (BuildContext context) => BookingScreen(
                                  prof_id: service_data[position].professionalId,
                                  screen: "booking",
                                  timeslots_data: service_data[position].timeSlots,
                                  price: service_data[position].newPrice[selectedPos].toString(),solutionType: widget.solutionType
                                )).then((val) {
                          if (val.toString().contains('pay')) {
                            String time = val.toString().substring(3);
                            List time_get = time.split("#");
                            String professional_id = service_data[position].professionalId;
                            String solutionId = id_;
                            String serviceId = service_data[position].id;
                            String percentage = time_get[2];
                            String appointmentTime = time_get[1].toString().trim();
                            String timeSlot = time_get[0];
                            int apply_credit = int.parse(time_get[3]);
                            initiate_Payment(professional_id, solutionId, serviceId, timeSlot, appointmentTime, percentage, selectedPos, apply_credit);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), color: Color(0xff01d35a)),
                          child: Text(
                            "Upgrade",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(globalContext);
                          showDialog(context: globalContext,
                              builder: (BuildContext context) => BookingScreen(prof_id: service_data[position].professionalId, screen: "booking", timeslots_data: service_data[position].timeSlots,
                                    price: service_data[position].newPrice[0].toString(), solutionType: widget.solutionType,)).then((val) {
                            if (val.toString().contains('pay')) {
                              String time = val.toString().substring(3);
                              List time_get = time.split("#");
                              String professional_id = service_data[position].professionalId;
                              String solutionId = id_;
                              String serviceId = service_data[position].id;
                              String percentage = time_get[2];
                              String appointmentTime = time_get[1].toString().trim();
                              String timeSlot = time_get[0];
                              int apply_credit = int.parse(time_get[3]);
                              initiate_Payment(professional_id, solutionId, serviceId, timeSlot, appointmentTime, percentage, 0, apply_credit);
                            }
                          });
                        },
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), border: Border.all(width: 1, color: Colors.grey)),
                          child: Text("Skip", style: TextStyle(color: Colors.black),)),
                      ),
                    ))
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _popup_show_dnd(BuildContext context, String dnd) {
    return new CupertinoAlertDialog(
      content: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                child: Icon(
                  Icons.clear,
                  color: Colors.transparent,
                ),
                alignment: Alignment.topRight,
              ),
              Expanded(
                  child: Text(
                "Details",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Icon(Icons.clear),
                  alignment: Alignment.centerRight,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          dnd != ''
              ? Container(
                  child: Text(
                    dnd,
                    textAlign: TextAlign.left,
                  ),
                )
              : Container(
                  child: Text("No data available"),
                )
        ],
      ),
    );
  }
}

class PaymentSuccess extends StatefulWidget {
  final String bookingId;

  PaymentSuccess({Key key, this.bookingId}) : super(key: key);

  @override
  _PaymentSuccessState createState() => _PaymentSuccessState(bookingId);
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  final String bookingId;

  _PaymentSuccessState(this.bookingId);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
        title: new Text("Payment Success"),
        content: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Image.asset(
                "assets/images/bid/check.png",
                height: 50,
                width: 50,
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text("Your Booking ID is $bookingId"),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            textStyle: TextStyle(color: Color(0xff01d35a)),
            isDefaultAction: true,
            child: new Text("OK"),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Appointments(
                      screen: 1,
                    ),
                  ));
            },
          ),
        ]);
  }
}
