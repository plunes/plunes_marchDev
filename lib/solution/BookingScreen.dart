import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plunes/model/CouponsModel.dart';
import 'package:plunes/model/profile/get_profile_info.dart';
import 'package:plunes/model/profile/user_profile.dart';
import 'package:plunes/profile/UserProfile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plunes/config.dart' as config;
import 'package:url_launcher/url_launcher.dart';

class BookingScreen extends StatefulWidget {
  final String prof_id;
  final String screen;
  final String price, solutionType;
  final List<TimeSlotsData> timeslots_data;

  BookingScreen(
      {Key key,
      this.prof_id,
      this.screen,
      this.price,
      this.timeslots_data,
      this.solutionType})
      : super(key: key);

  @override
  _BookingScreenState createState() =>
      _BookingScreenState(prof_id, screen, price, timeslots_data);
}

class _BookingScreenState extends State<BookingScreen> {
  String prof_id;
  final String screen;
  final String price;
  final List<TimeSlotsData> timeslots_data;

  bool hasCoupons = false;

  _BookingScreenState(
      this.prof_id, this.screen, this.price, this.timeslots_data);

  List<dynamic> couponsList = new List();

  String user_token = "";
  String user_id = "";
  bool call = false;
  bool valid_time = false;
  bool apply_credit = false;
  String credit = "0";
  double final_price = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getshareference();
//    showDialog(context: context, barrierDismissible: true, builder: (BuildContext context) => offerAvailablePopup(context, 2, 1));
  }

  getshareference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String uid = prefs.getString("uid");

    setState(() {
      user_token = token;
      user_id = uid;
      final_price = double.parse(price);
    });

    get_doc_data(prof_id, user_id, user_token);
    getCouponsHistory();
  }

  String speciality = "";
  List from_1 = new List();
  List to_1 = new List();
  List from_2 = new List();
  List to_2 = new List();
  List slot_day = new List();

  UserProfilePost userProfilePost;

  getuser_data(String token) async {
    MyProfile myProfileData = await my_profile_data(token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
    });

    setState(() {
      credit = myProfileData.credits;
    });
  }

  void get_doc_data(
      String professional_id, String user_id, String token) async {
    List speciality_name = new List();
    userProfilePost =
        await user_profile(professional_id, token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
    });

    if (userProfilePost.success) {
      for (int i = 0; i < userProfilePost.user.specialities.length; i++) {
        String speciality_id =
            userProfilePost.user.specialities[i].specialityId;
        int pos = config.Config.specialist_id.indexOf(speciality_id);
        if (pos != -1) speciality_name.add(config.Config.specialist_lists[pos]);
      }
      speciality = speciality_name.join(",");

      if (timeslots_data.length > 0) {
        for (int i = 0; i < timeslots_data.length; i++) {
          if (timeslots_data[i].closed) {
            _times.add("NA");
            _times.add("NA");
          } else {
            if (timeslots_data[i].slots.length > 1) {
              String slot_from1 =
                  timeslots_data[i].slots[0].toString().split("-")[0];
              String slot_to1 =
                  timeslots_data[i].slots[0].toString().split("-")[1];
              String slot_from2 =
                  timeslots_data[i].slots[1].toString().split("-")[0];
              String slot_to2 =
                  timeslots_data[i].slots[1].toString().split("-")[1];

              slot_day.add(timeslots_data[i].day.toLowerCase());
              from_1.add(slot_from1);
              to_1.add(slot_to1);
              from_2.add(slot_from2);
              to_2.add(slot_to2);
            } else {
              String slot_from1 =
                  timeslots_data[i].slots[0].toString().split("-")[0];
              String slot_to1 =
                  timeslots_data[i].slots[0].toString().split("-")[1];

              slot_day.add(timeslots_data[i].day.toLowerCase());
              from_1.add(slot_from1);
              to_1.add(slot_to1);
              from_2.add("00:00");
              to_2.add("00:00");
            }
          }
        }
      } else {
        for (int i = 0; i < 7; i++) {
          _times.add("NA");
          _times.add("NA");
        }
      }

      var now = new DateTime.now();

      for (int i = 0; i < 100; i++) {
        var next_days = now.add(Duration(days: i));
        selected.add(false);

        var formatter = new DateFormat("dd MMM yyyy");
        String formattedDate = formatter.format(next_days);

        var formatter3 = new DateFormat("yyy MM dd");
        String formattedDate3 = formatter3.format(next_days);

        var formatter2 = new DateFormat("dd MMM");
        String formattedDate2 = formatter2.format(next_days);
        String day = new DateFormat('EEEE').format(next_days);

        selected_times.add(formattedDate3);
        _day_s.add(formattedDate2 + " " + day.substring(0, 3));
        _day_name.add(day);
        _dates.add(formattedDate + " (" + day.substring(0, 3) + ")");
      }
      selected[0] = true;

      if (slot_day.length > 0) {
        selected_date = _dates[0];
        selected_day_name = _day_name[0];
        selected_time = selected_times[0];

        get_slots(selected_day_name);
      }

      setState(() {
        call = true;
      });
    } else {
      config.Config.showInSnackBar(
          _scaffoldKey, userProfilePost.message, Colors.red);
    }
  }

  ///
  String selected_date = "";
  String selected_day_name = "";
  String exact_time = "00:00";
  int _radioValue1 = 0;

  List<bool> selected = new List();
  List _dates = new List();
  List _day_s = new List();
  List _day_name = new List();
  List _times = new List();

  List selected_times = new List();
  String selected_time = "";

  void get_slots(String day_name) {
    _times.clear();
    _times.add("NA");
    _times.add("NA");

    if (slot_day.length > 0) {
      if (slot_day.contains(day_name.toLowerCase())) {
        int pos = slot_day.indexOf(day_name.toLowerCase());

        _times[0] = from_1[pos] + "-" + to_1[pos];
        _times[1] = from_2[pos] + "-" + to_2[pos];
      } else {
        _times[0] = "NA";
        _times[1] = "NA";
      }
    } else {
      _times[0] = "NA";
      _times[1] = "NA";
    }
  }

  Future<Null> _selectdata(String time, String slot) async {
    print(slot);
    List time_slot = slot.split("-");

    TimeOfDay _startTime = TimeOfDay(
        hour: int.parse(time.split(":")[0]),
        minute: int.parse(time.split(":")[1].substring(0, 2)));

    final TimeOfDay picker = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
          child: child,
        );
      },
    );

    if (picker != null) {
      setState(() {
        TimeOfDay from = TimeOfDay(
            hour: int.parse(time_slot[0].split(":")[0]),
            minute: int.parse(time_slot[0].split(":")[1].substring(0, 2)));

        TimeOfDay to = TimeOfDay(
            hour: int.parse(time_slot[1].split(":")[0]),
            minute: int.parse(time_slot[1].split(":")[1].substring(0, 2)));

        int from_hour = from.hour;
        int from_min = from.minute;

        int to_hour = to.hour;
        int to_min = to.minute;

        if (time_slot[0].toUpperCase().contains("PM")) {
          from_hour = from_hour + 12;
        }

        if (time_slot[1].toUpperCase().contains("PM")) {
          to_hour = to_hour + 12;
        }

        print(from_min);
        print(picker.minute);

        var now = new DateTime.now();
        int curr_hour = now.hour;
        int curr_min = now.minute;
        String date_no = selected_date.substring(0, 2);

        print(date_no + "" + now.day.toString());

        if (date_no == now.day.toString()) {
          if (from_hour <= picker.hour &&
              to_hour > picker.hour &&
              picker.hour >= curr_hour) {
            if (curr_hour == picker.hour) {
              if (picker.minute >= curr_min) {
                exact_time = picker.format(context);
                valid_time = true;
                checkAndSetTimeIfNotIn12HourFormat(picker);
              }
            } else {
              exact_time = picker.format(context);
              valid_time = true;
              checkAndSetTimeIfNotIn12HourFormat(picker);
            }
          } else {
            valid_time = false;
            exact_time = picker.format(context);
            checkAndSetTimeIfNotIn12HourFormat(picker);
          }
        } else {
          if (from_hour <= picker.hour && to_hour > picker.hour) {
            exact_time = picker.format(context);
            valid_time = true;
            checkAndSetTimeIfNotIn12HourFormat(picker);
          } else {
            valid_time = false;
            exact_time = picker.format(context);
            checkAndSetTimeIfNotIn12HourFormat(picker);
          }
        }
      });
    }
  }

  void checkAndSetTimeIfNotIn12HourFormat(TimeOfDay picker) {
    if (picker.period == DayPeriod.pm &&
        int.parse(picker.format(context)?.split(":")[0]) > 12) {
      exact_time =
          "${(int.parse(picker.format(context)?.split(":")[0]) - 12) > 9 ? "${(int.parse(picker.format(context)?.split(":")[0]) - 12)}" : "0${int.parse(picker.format(context)?.split(":")[0]) - 12}"}:${picker.minute <= 9 ? "0${picker.minute}" : "${picker.minute}"} PM";
    } else if (picker.period == DayPeriod.pm &&
        int.parse(picker.format(context)?.split(":")[0]) == 12 &&
        !(exact_time.contains("PM"))) {
      exact_time = exact_time + " PM";
    } else if (picker.period == DayPeriod.am &&
        int.parse(picker.format(context)?.split(":")[0]) == 00) {
      exact_time =
          "12:${picker.minute <= 9 ? "0${picker.minute}" : "${picker.minute}"} AM";
    } else if (picker.period == DayPeriod.am && !(exact_time.contains("AM"))) {
      exact_time = exact_time + " AM";
    }
  }

  Future getCouponsHistory() async {
    if (couponsList != null && couponsList.length > 0) couponsList.clear();

    if (user_token.length > 0) {
      GetCouponsList result =
          await getCouponsListInfo(user_token).catchError((error) {
        config.Config.showLongToast("Something went wrong!");
      });
      if (result.info['coupons'].length > 0) {
        couponsList.add(result.info['coupons']);
      }
      setState(() {
        hasCoupons = couponsList.length > 0 ? true : false;
        if (hasCoupons) {
          for (var i = 0; i < couponsList.length; i++) {
            if (couponsList[0] != null) {
              String couponName = couponsList[0][i]['coupon'] != null
                  ? couponsList[0][i]['coupon']
                  : '';
              String consulCount = couponsList[0][i]['consultations'] != null
                  ? couponsList[0][i]['consultations'].toString()
                  : '';
              String testcount = couponsList[0][i]['tests'] != null
                  ? couponsList[0][i]['tests'].toString()
                  : '';
              if (consulCount == '0' && testcount == '0') {
                hasCoupons = false;
              } else if (widget.solutionType == 'Test' &&
                  consulCount == '0' &&
                  testcount != '0') {
                hasCoupons = true;
              } else if (widget.solutionType == 'Test' &&
                  consulCount != '0' &&
                  testcount == '0') {
                hasCoupons = false;
              } else if (widget.solutionType == 'Consultation' &&
                  consulCount != '0' &&
                  testcount == '0') {
                hasCoupons = true;
              } else if (widget.solutionType == 'Consultation' &&
                  consulCount != '0' &&
                  testcount != '0') {
                hasCoupons = true;
              } else if (widget.solutionType == 'Procedure' ||
                  widget.solutionType == 'Speciality') {
                hasCoupons = false;
              } else if (widget.solutionType == 'Consultation' &&
                  consulCount == '0') {
                hasCoupons = false;
              }

              if (hasCoupons) credit = '0';
            }
          }
        }
        if (!hasCoupons) getuser_data(user_token);
      });
      print('result$result');
    }
  }

  @override
  Widget build(BuildContext context) {
    config.Config.globalContext = context;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Container(
                  child: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 20, top: 10),
                ),
                Expanded(
                  child: Container(
                    child: Text(
                      "Confirm your Booking",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 20,
                  ),
                ),
              ],
            ),
            margin: EdgeInsets.only(top: 10, bottom: 10),
          ),
          call
              ? Expanded(
                  child: Container(
                  child: ListView(
                    children: <Widget>[
                      Container(
                          child: Text('Why Plunes?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Color(config.Config.getColorHexFromStr(
                                      '#434343'))))),
                      getWhyPlunesView(),
                      Container(
                        margin: EdgeInsets.all(20),
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
                                        user_id: prof_id,
                                      ),
                                    ));
                              },
                              child: userProfilePost.user.imageUrl != '' &&
                                      !userProfilePost.user.imageUrl
                                          .contains("defaul")
                                  ? CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                          userProfilePost.user.imageUrl),
                                    )
                                  : Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        config.Config.get_initial_name(
                                                userProfilePost.user.name)
                                            .toUpperCase(),
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
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      userProfilePost.user.name,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      speciality,
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      child: RichText(
                                        text: new TextSpan(
                                          // Note: Styles for TextSpans must be explicitly defined.
                                          // Child text spans will inherit styles from parent
                                          style: new TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text: 'Address -',
                                                style: new TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            new TextSpan(
                                                text: userProfilePost
                                                    .user.address,
                                                style: new TextStyle(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w200)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Container(
                                      height: 0.5,
                                      color: Colors.grey,
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10, left: 20, bottom: 10),
                        child: Text(
                          "Available Slots",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        height: 85,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            List days = _day_s[index].toString().split(" ");

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  for (int i = 0; i < 100; i++) {
                                    if (i == index) {
                                      selected[index] = true;
                                    } else {
                                      selected[i] = false;
                                    }
                                  }
                                  selected_date = _dates[index];
                                  selected_time = selected_times[index];
                                  print(selected_date);
                                  selected_day_name = _day_name[index];
                                  get_slots(selected_day_name);
                                });
                              },
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: selected[index]
                                            ? Color(0xff01d35a)
                                            : Colors.transparent),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            days[1],
                                            style: TextStyle(
                                                color: selected[index]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 12),
                                          ),
                                          Text(
                                            days[0],
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: selected[index]
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                          Text(
                                            days[2].toString().toUpperCase(),
                                            style: TextStyle(
                                                color: selected[index]
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: _dates.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, top: 30, right: 20),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Container(
                              child: Text("Slot 1"),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Container(
                              child: Text("Slot 2"),
                              alignment: Alignment.centerLeft,
                            )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: InkWell(
                              onTap: () {
                                setState(() {
                                  _radioValue1 = 0;
                                  exact_time = "00:00";
                                });

                                _selectdata(exact_time, _times[0]);
                              },
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: Container(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          width: 1,
                                          color: _radioValue1 == 0
                                              ? Color(0xff01d35a)
                                              : Colors.grey),
                                      color: _radioValue1 == 0
                                          ? Color(0xff01d35a)
                                          : Colors.transparent),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _times[0],
                                      style: TextStyle(
                                          color: _radioValue1 == 0
                                              ? Colors.white
                                              : Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: InkWell(
                              onTap: () {
                                setState(() {
                                  _radioValue1 = 1;
                                  exact_time = "00:00";
                                });

                                _selectdata(exact_time, _times[1]);
                              },
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: Container(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      border: Border.all(
                                          width: 1,
                                          color: _radioValue1 == 1
                                              ? Color(0xff01d35a)
                                              : Colors.grey),
                                      color: _radioValue1 == 1
                                          ? Color(0xff01d35a)
                                          : Colors.transparent),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      _times[1],
                                      style: TextStyle(
                                          color: _radioValue1 == 1
                                              ? Colors.white
                                              : Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: Text(
                          "Appointment time: ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        margin: EdgeInsets.only(left: 20),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _times.contains("Expired")
                          ? Container()
                          : Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                            width: 1,
                                            color: valid_time
                                                ? Colors.grey
                                                : Colors.red)),
                                    margin: EdgeInsets.only(
                                      left: 20,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      child: Text(
                                        "  " + exact_time,
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(),
                                  flex: 1,
                                ),
                              ],
                            ),
                      SizedBox(
                        height: 5,
                      ),
                      Visibility(
                          child: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Text(
                                "Please choose valid time.",
                                style: TextStyle(color: Colors.red),
                              )),
                          visible: !_times.contains("Expeired") && !valid_time),
                      SizedBox(
                        height: 20,
                      ),
                      Visibility(
                        visible: screen != 'appointment',
                        child: credit == "0"
                            ? Container()
                            : Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          apply_credit = !apply_credit;
                                          if (apply_credit) {
                                            final_price = double.parse(price) -
                                                double.parse(credit);
                                            if (final_price < 0) {
                                              final_price = 0;
                                            }
                                          } else {
                                            final_price = double.parse(price);
                                          }
                                        });
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text("Available Cash"),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Image.asset(
                                                  'assets/images/refer/credit.png',
                                                  height: 30,
                                                  width: 30,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "₹" + credit + "",
                                                  style: TextStyle(
                                                      color: Color(0xff5D5D5D),
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                apply_credit
                                                    ? Image.asset(
                                                        'assets/images/bid/check.png',
                                                        height: 20,
                                                        width: 20,
                                                      )
                                                    : Image.asset(
                                                        'assets/images/bid/uncheck.png',
                                                        height: 20,
                                                        width: 20,
                                                      ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text("Apply Cash")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
//                  Visibility(child: Text("You saved  ₹$credit"), visible: apply_credit,)
                                  ],
                                ),
                              ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Text(
                                "Make a payment of  $final_price/- to confirm the booking",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                child: Container(
                              child: InkWell(
                                onTap: _times.contains("Expired") ||
                                        exact_time == '00:00' ||
                                        !valid_time
                                    ? null
                                    : () async {
                                        if (screen == 'appointment') {
                                          Navigator.of(context).pop("pay" +
                                              _times[0] +
                                              "#" +
                                              selected_time +
                                              " " +
                                              exact_time +
                                              "#" +
                                              "same" "#" +
                                              (apply_credit ? credit : '0'));
                                        } else {
                                          if (final_price > 0) {
                                            if (hasCoupons) {
                                              for (var i = 0;
                                                  i < couponsList.length;
                                                  i++) {
                                                if (couponsList[0] != null) {
                                                  var couponName =
                                                      couponsList[0][i]
                                                                  ['coupon'] !=
                                                              null
                                                          ? couponsList[0][i]
                                                              ['coupon']
                                                          : '';
                                                  var consulCount = couponsList[
                                                                  0][i][
                                                              'consultations'] !=
                                                          null
                                                      ? couponsList[0][i]
                                                              ['consultations']
                                                          .toString()
                                                      : '';
                                                  var testcount = couponsList[0]
                                                              [i]['tests'] !=
                                                          null
                                                      ? couponsList[0][i]
                                                              ['tests']
                                                          .toString()
                                                      : '';
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (BuildContext
                                                              context) =>
                                                          CouponOffer(
                                                            consulCount,
                                                            testcount,
                                                            couponName,
                                                            selected_time,
                                                            exact_time,
                                                            (apply_credit
                                                                ? credit
                                                                : '0'),
                                                            _radioValue1,
                                                            _times,
                                                          )).then((val) {
                                                    if (val != null &&
                                                        val != '') {
                                                      Navigator.of(context).pop(
                                                          "pay" +
                                                              _times[0] +
                                                              "#" +
                                                              selected_time +
                                                              " " +
                                                              exact_time +
                                                              "#" +
                                                              val +
                                                              "#" +
                                                              (apply_credit
                                                                  ? credit
                                                                  : '0') +
                                                              '/$couponName');
                                                    }
                                                  });
                                                }
                                              }
                                            } else {
                                              showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (
                                                        BuildContext context,
                                                      ) =>
                                                          PopupChoose())
                                                  .then((val) {
                                                if (val != null && val != '') {
                                                  if (_radioValue1 == 1) {
                                                    Navigator.of(context).pop(
                                                        "pay" +
                                                            _times[1] +
                                                            "#" +
                                                            selected_time +
                                                            " " +
                                                            exact_time +
                                                            "#" +
                                                            val +
                                                            "#" +
                                                            (apply_credit
                                                                ? credit
                                                                : '0'));
                                                  } else if (_radioValue1 ==
                                                      0) {
                                                    Navigator.of(context).pop(
                                                        "pay" +
                                                            _times[0] +
                                                            "#" +
                                                            selected_time +
                                                            " " +
                                                            exact_time +
                                                            "#" +
                                                            val +
                                                            "#" +
                                                            (apply_credit
                                                                ? credit
                                                                : '0'));
                                                  }
                                                }
                                              });
                                            }
                                          } else {
                                            if (_radioValue1 == 1) {
                                              Navigator.of(context).pop("pay" +
                                                  _times[1] +
                                                  "#" +
                                                  selected_time +
                                                  " " +
                                                  exact_time +
                                                  "#" +
                                                  "100" +
                                                  "#" +
                                                  price);
                                            } else if (_radioValue1 == 0) {
                                              Navigator.of(context).pop("pay" +
                                                  _times[0] +
                                                  "#" +
                                                  selected_time +
                                                  " " +
                                                  exact_time +
                                                  "#" +
                                                  "100" +
                                                  "#" +
                                                  price);
                                            }
                                          }
                                        }
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Container(
                                    child: screen == 'appointment'
                                        ? Text("Reschedule",
                                            style:
                                                TextStyle(color: Colors.white))
                                        : Text("   Pay now   ",
                                            style:
                                                TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                              margin: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: _times.contains("Expired") ||
                                          exact_time == '00:00' ||
                                          !valid_time
                                      ? Colors.grey
                                      : Color(0xff01d35a)),
                            )),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      "100% Payments Refundable. ",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      String url = config.Config.pricing_terms;

                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                    child: Text(
                                      "T&C Apply.",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
              : Center(
                  child: Text("Loading..."),
                ),
        ],
      ),
    );
  }

  Widget getWhyPlunesView() {
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                child: getTagsView(
                    'assets/images/catIcon1.png', '100% Payments Refundable'),
              ),
              Expanded(
                child: getTagsView(
                    'assets/images/docIcon.png', 'First Consultation Free'),
              )
            ]),
            Row(
              children: <Widget>[
                Expanded(
                  child: getTagsView('assets/images/calandergrey.png',
                      'Prefered timing as per your availability'),
                ),
                Expanded(
                  child: getTagsView(
                      'assets/images/walletgrey.png', 'Make Partial Payments'),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  right: (MediaQuery.of(context).size.width / 2) - 10),
              child: getTagsView('assets/images/tellIcongrey2.png',
                  'Free telephonic consultations'),
            )
          ],
        ));
  }

  Widget getTagsView(String image, String text) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width / 2,
      margin: EdgeInsets.only(left: 10, right: 0, top: 10),
      padding: EdgeInsets.all(10),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 10),
                child: Image.asset(
                  image,
                  height: 21,
                  width: 21,
                )),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 12,
                    color: Color(config.Config.getColorHexFromStr('#434343'))),
              ),
            )
          ]),
      decoration: BoxDecoration(
          color: Color(config.Config.getColorHexFromStr('#F9F9F9')),
          borderRadius: BorderRadius.all(Radius.circular(5))),
    );
  }
}

class CouponOffer extends StatefulWidget {
  var consulCount,
      testcount,
      couponName,
      _times,
      selected_time,
      exact_time,
      credit,
      _radioValue1;

  CouponOffer(this.consulCount, this.testcount, this.couponName,
      this.selected_time, this.exact_time, this.credit, this._radioValue1,
      [this._times]);

  @override
  _CouponOfferState createState() => _CouponOfferState();
}

class _CouponOfferState extends State<CouponOffer> {
  bool isCouponSelected = false;

  Widget build(BuildContext context) {
    return offerAvailablePopup(
        context, widget.consulCount, widget.testcount, widget.couponName);
  }

  Widget offerAvailablePopup(context, consulCount, testCount, couponName) {
    return Theme(
      data: ThemeData(dialogBackgroundColor: Colors.white),
      child: Builder(
        builder: (context) {
          return new CupertinoAlertDialog(
            title: Row(
              children: <Widget>[
                Expanded(
                    child: new Text(
                  "Available Coupon",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color:
                          Color(config.Config.getColorHexFromStr('#333333'))),
                )),
              ],
            ),
            content: Container(
                height: isCouponSelected ? 310 : 50,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 2),
                        child: ListView(
                          shrinkWrap: true,
                          children: <Widget>[
                            FlatButton(
                              padding: EdgeInsets.only(top: 10),
                              onPressed: () {
                                isCouponSelected = !isCouponSelected;
                                setState(() {});
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    isCouponSelected
                                        ? Image.asset(
                                            'assets/images/check_icon.png',
                                            height: 25,
                                            width: 25,
                                          )
                                        : Image.asset(
                                            'assets/images/solution_result/unselected.png',
                                            height: 25,
                                            width: 25,
                                          ),
                                    Container(
                                        margin: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(couponName,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w100))),
                                  ],
                                ),
                              ),
                            ),
                            isCouponSelected
                                ? Container(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(
                                                left: 10, right: 10, top: 10),
                                            child: Text('Successfully Applied!',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(config.Config
                                                        .getColorHexFromStr(
                                                            '#333333'))))),
                                        Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(
                                                left: 10, right: 10, top: 30),
                                            child: Text('Now you have',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(config.Config
                                                        .getColorHexFromStr(
                                                            '#333333'))))),
                                        (consulCount != '' &&
                                                consulCount != '0')
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 20),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Stack(
                                                      alignment:
                                                          Alignment.center,
                                                      children: <Widget>[
                                                        Container(
                                                          child: Image.asset(
                                                            'assets/images/blue_bg.png',
                                                            height: 35,
                                                            width: 35,
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          'assets/images/consultaion_icon.png',
                                                          height: 32,
                                                          width: 32,
                                                        )
                                                      ],
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                        child: Text(
                                                            '$consulCount Free Consultations',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Color(config
                                                                        .Config
                                                                    .getColorHexFromStr(
                                                                        '#474747'))))),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                        (testCount != '' && testCount != '0')
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 20,
                                                    bottom: 20),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Image.asset(
                                                      'assets/images/test_icon.png',
                                                      height: 35,
                                                      width: 35,
                                                    ),
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                        child: Text(
                                                            '$testCount Free Diagnostic Test',
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                color: Color(config
                                                                        .Config
                                                                    .getColorHexFromStr(
                                                                        '#474747'))))),
                                                  ],
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ),
                    isCouponSelected
                        ? Container(
                            child: Column(
                              children: <Widget>[
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                        alignment: Alignment.bottomCenter,
                                        height: 50,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                                child: GestureDetector(
                                              onTap: () {
                                                isCouponSelected = false;
                                                Navigator.of(context)
                                                    .pop('100');
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  height: 45,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)),
                                                      color: Color(0xff01d35a)),
                                                  child: Text(
                                                    "Yes",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            )),
                                            Expanded(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  isCouponSelected = false;
                                                  Navigator.pop(context);
                                                  showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (
                                                        BuildContext context,
                                                      ) =>
                                                          PopupChoose()).then(
                                                      (val) {
                                                    if (val != null &&
                                                        val != '') {
                                                      if (widget._radioValue1 ==
                                                          1) {
                                                        Navigator.of(config
                                                                .Config
                                                                .globalContext)
                                                            .pop("pay" +
                                                                widget
                                                                    ._times[1] +
                                                                "#" +
                                                                widget
                                                                    .selected_time +
                                                                " " +
                                                                widget
                                                                    .exact_time +
                                                                "#" +
                                                                val +
                                                                "#" +
                                                                widget.credit);
                                                      } else if (widget
                                                              ._radioValue1 ==
                                                          0) {
                                                        Navigator.of(config
                                                                .Config
                                                                .globalContext)
                                                            .pop("pay" +
                                                                widget
                                                                    ._times[0] +
                                                                "#" +
                                                                widget
                                                                    .selected_time +
                                                                " " +
                                                                widget
                                                                    .exact_time +
                                                                "#" +
                                                                val +
                                                                "#" +
                                                                widget.credit);
                                                      }
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  height: 45,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20)),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.grey)),
                                                  child: Text(
                                                    "No",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ))
                                          ],
                                        )))
                              ],
                            ),
                          )
                        : Container()
                  ],
                )),
          );
        },
      ),
    );
  }
}

class PopupChoose extends StatefulWidget {
  @override
  _PopupChooseState createState() => _PopupChooseState();
}

class _PopupChooseState extends State<PopupChoose> {
  int radio_val = 0;
  bool val_1 = true;
  bool val_2 = false;

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Container(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Align(
              child: Icon(Icons.clear),
              alignment: Alignment.topRight,
            ),
          ),
        ),
      ),
      content: Container(
        child: Column(
          children: <Widget>[
            Text(
              "Now you can have multiple\n"
              "telephonic consultations & one free visit!",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(
              height: 20,
            ),
            Card(
              elevation: 0,
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    print(val_1);
                    val_1 = !val_1;
                    val_2 = !val_2;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    val_1
                        ? new Image.asset(
                            'assets/images/bid/check.png',
                            height: 20,
                            width: 20,
                          )
                        : Image.asset(
                            'assets/images/bid/uncheck.png',
                            height: 20,
                            width: 20,
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                        width: 150,
                        child: new Text('Pay 20%',
                            style: new TextStyle(fontSize: 16.0))),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Card(
              elevation: 0,
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    setState(() {
                      print(val_1);
                      val_1 = !val_1;
                      val_2 = !val_2;
                    });
                    print("val1==" + val_1.toString());
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    val_2
                        ? new Image.asset(
                            'assets/images/bid/check.png',
                            height: 20,
                            width: 20,
                          )
                        : Image.asset(
                            'assets/images/bid/uncheck.png',
                            height: 20,
                            width: 20,
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 150,
                      child: new Text(
                        'Pay full. No Hassle!',
                        style: new TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                if (val_1) {
                  Navigator.of(context).pop("20");
                } else {
                  Navigator.of(context).pop("100");
                }
              },
              child: Container(
                height: 35,
                width: double.infinity,
                margin: EdgeInsets.only(left: 5, right: 5),
                alignment: Alignment.center,
                child: Text(
                  "Continue",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Color(0xff01d35a)),
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
