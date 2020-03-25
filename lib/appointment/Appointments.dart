import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:plunes/OpenMap.dart';
import 'package:plunes/profile/EditDoctors.dart';
import 'package:plunes/profile/EditProfile.dart';
import 'package:plunes/profile/UserProfile.dart';
import 'package:plunes/solution/BookingScreen.dart';
import 'package:plunes/model/appointments/all_appointments.dart';
import 'package:plunes/model/appointments/cancel_appointment.dart';
import 'package:plunes/model/appointments/invoice_appointment.dart';
import 'package:plunes/model/appointments/reschedule_appointment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:plunes/config.dart' as config;

import 'CreatePrescription.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Appointments extends StatefulWidget {
  static const tag = '/appointemnts';
  final int screen;

  Appointments({Key key, this.screen}) : super(key: key);

  @override
  _AppointmentsState createState() => _AppointmentsState(screen);
}

class _AppointmentsState extends State<Appointments> {
  int screen;
  _AppointmentsState(this.screen);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String user_name = "";
  String user_token = "";
  String user_id = "";
  String user_type = "", prescriptionLogoUrl = '', prescriptionLogoText = '';

  bool call = false, isPrescriptionCreated = false;

  List<BookingsData> business = new List();
  List<BookingsData> personel = new List();

  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  getSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("token");
    String name = prefs.getString("name");
    String image = prefs.getString("image");
    String email = prefs.getString("email");
    String uid = prefs.getString("uid");
    String activated = prefs.getString("phone_number_verified");
    String phoneno = prefs.getString("phoneno");
    String type = prefs.getString("user_type");

    setState(() {
      user_name = name;
      user_token = token;
      user_id = uid;
      user_type = type;
      prescriptionLogoUrl = prefs.getString("PRESCRIPTION_LOGO_URL")!=null? prefs.getString("PRESCRIPTION_LOGO_URL"):'';
      prescriptionLogoText = prefs.getString("PRESCRIPTION_LOGO_TEXT")!=null? prefs.getString("PRESCRIPTION_LOGO_TEXT"):'';

      isPrescriptionCreated = (prescriptionLogoUrl != '' || prescriptionLogoText != '' )? true : false;

      ///check prescription is created or not.
    });
    get_data();
  }

  void get_data() async {
    business.clear();
    personel.clear();

    AppointmentsPost appointmentsPost = await all_appointments(user_token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      print(error.toString());
      setState(() {
        call = true;
      });
    });
    setState(() {
      call = true;
      if (appointmentsPost != null && appointmentsPost.success) {
        for (int i = 0; i < appointmentsPost.bookings.length; i++) {
          if (appointmentsPost.bookings[i].professionalId.contains(user_id)) {
            if (appointmentsPost.bookings[i].userName != null)
              business.add(appointmentsPost.bookings[i]);
          } else {
            personel.add(appointmentsPost.bookings[i]);
          }
        }
        if (personel.length == 0)
          noAppointments = 'No appointments yet';
        else
          noAppointments = '';
      } else if (appointmentsPost != null) {
        config.Config.showInSnackBar(_scaffoldKey, appointmentsPost.message, Colors.red);
      }
    });
  }

  cancel(String booking_id) async {
    setState(() {
      call = false;
    });
    CancelAppointment cancelAppointment = await cancel_appointment(booking_id, user_token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        call = true;
      });
    });

    setState(() {
      call = true;
      if (cancelAppointment.success) {
//        config.Config.showInSnackBar(_scaffoldKey,  cancelAppointment.message, Colors.green);
        getSharedPreferences();
      } else
        config.Config.showInSnackBar(_scaffoldKey, cancelAppointment.message, Colors.red);

    });
  }

  request_invoice(String booking_id) async {
    setState(() {
      call = false;
    });

    InvoiceAppointment invoiceAppointment =
        await invoice_appointment(booking_id, user_token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        call = true;
      });
    });

    setState(() {
      call = true;
      if (invoiceAppointment.success)
        getSharedPreferences();
       else
        config.Config.showInSnackBar(_scaffoldKey, invoiceAppointment.message, Colors.red);
    });
  }

  reschedule(String appointmentTime, String timeSlot, String booking_id,
      String apply_credit) async {
    setState(() {
      call = false;
    });
    var body = {
      "bookingStatus": "Reschedule",
      "appointmentTime": appointmentTime,
      "timeSlot": timeSlot,
      "applyCredit": apply_credit
    };
    RescheduleAppointment rescheduleAppointment = await reschedule_appointment(body, booking_id, user_token).catchError((error) {
      config.Config.showLongToast("Something went wrong!");
      setState(() {
        call = true;
      });
    });

    setState(() {
      call = true;
      if (rescheduleAppointment.success) {
        getSharedPreferences();
      } else {
        config.Config.showInSnackBar(_scaffoldKey, rescheduleAppointment.message, Colors.red);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text(
        "Appointments",
        style: TextStyle(color: Colors.black),
      ),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    );

    final loading = ListView.builder(itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Color(0xffF5F5F5),
        highlightColor: Color(0xffFAFAFA),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 0.5, color: Colors.black12),
            ),
          ),
          child: Container(
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 20, top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 10,
                              color: Color(0xffF5F5F5),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 10,
                              color: Color(0xffF5F5F5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: CircleAvatar(
                          radius: 25,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 10, top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 10,
                                color: Color(0xffF5F5F5),
                              ),
                              SizedBox(
                                height: 5,
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
                      ),
                      Container(
                          child: Image.asset(
                        'assets/images/profile/location.png',
                        height: 22,
                        width: 22,
                      )),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(2)),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xffEEEEEE),
                            blurRadius: 1,
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 10,
                                  color: Color(0xffF5F5F5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });

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
                      call ? _business() : loading,
                      call ? _personel() : loading
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: app_bar,
      key: _scaffoldKey,
      body: user_type == 'User' ? call ? _personel() : loading : options_tabs,
    );
  }

  Widget _business() {
    return business.length == 0
        ? Container(
            child: Center(
              child: Text(noAppointments),
            ),
          )
        : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: business.length,
              physics: ClampingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                int pos = 0;
                try {
                  pos = int.parse(business[index].solutionServiceId.split('|')[2]);
                } catch (e) {
                  print('error==$e');
                }

                String initial_name = business[index].userName != '' ? config.Config.get_initial_name(business[index].userName) : "";

                String diagnostic = "";
                for (int i = 0; i < config.Config.procedure_id.length; i++) {
                  int pos = config.Config.procedure_id.indexOf(business[index].serviceId);
                  diagnostic = config.Config.procedure_name[pos];
                }
                var newDateTimeObj = new DateFormat("yyyy MM dd hh:mm a").parse(business[index].appointmentTime);
                String appointment_day = new DateFormat('dd MMM').format(newDateTimeObj);
                String appointment_time = new DateFormat('hh:mm a').format(newDateTimeObj);
                double paid_amount = (double.parse(business[index].newPrice[pos].toString()) - double.parse(business[index].creditsUsed)) * (double.parse(business[index].paymentPercent) / 100);
                double rest_amount = (double.parse(business[index].newPrice[pos].toString()) - double.parse(business[index].creditsUsed)) - paid_amount;

                return Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1.5, color: Colors.black12))),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8, top: 20, bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          appointment_day,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text(
                                          appointment_time,
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => UserProfile(
                                              user_id: business[index].userId),
                                        ));
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    margin: EdgeInsets.only(top: 5),
                                    alignment: Alignment.center,
                                    child: Container(
                                      child: business[index].userimageUrl != '' && !business[index].userimageUrl.contains("default")
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(
                                                  business[index].userimageUrl),
                                            )
                                          : Container(
                                              height: 40,
                                              width: 40,
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
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(23)),
                                      gradient: new LinearGradient(
                                          colors: [
                                            Color(0xffababab),
                                            Color(0xff686868)
                                          ],
                                          begin: FractionalOffset.topCenter,
                                          end: FractionalOffset.bottomCenter,
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10, top: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          business[index].userName,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          diagnostic,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          business[index].paymentStatus,
                                          style: TextStyle(
                                              color: business[index].paymentStatus == 'Cancelled'
                                                  ? Colors.red
                                                  : Color(0xff01d35a),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Booking Id: " + business[index].referenceId,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Total amount: ₹" + business[index].newPrice[pos].toString()),
                                        Text("Remaining amount: ₹" + rest_amount.round().toString()),
                                        Text("Credit Used: ₹" + business[index].creditsUsed.toString()),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text("Paid amount: ₹" + paid_amount.round().toString()),
//                                business[index].category[0] == "Basic" ? Container():
                                        Text("Category: " + business[index].category[pos].toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            user_type == 'Doctor'
                                ? InkWell(
                                    onTap: () {
                                      if (isPrescriptionCreated) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CreatePrescription(
                                                from: 'Appointment',
                                                patientId:
                                                    business[index].userId,
                                              ),
                                            ));
                                      } else {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (BuildContext context) =>
                                                _showAlertPopup(context,
                                                    'Kindly Create your Template from the website to send Prescription directly.'));
                                      }
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(top: 10),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Create Prescription',
                                          style: TextStyle(
                                            color: Color(0xff01d35a),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        )))
                                : Container()
                          ],
                        ),
                      ),
                    ));
              },
            ),
          );
  }

  Widget _showAlertPopup(BuildContext context, String text) {
    return new CupertinoAlertDialog(
      content: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  "",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                Align(
                  alignment: FractionalOffset.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      child: Icon(
                        Icons.clear,
                        color: Color(config.Config.getColorHexFromStr('#585858')),
                      ),
                      alignment: Alignment.topRight,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 20),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    wordSpacing: 1.2),
              ),
            )
          ],
        ),
      ),
    );
  }

  var noAppointments = '';

  Widget _personel() {
    return personel.length == 0
        ? Container(
            child: Center(
              child: Text(noAppointments),
            ),
          )
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              int pos = 0;
              try {
                pos = int.parse(personel[index].solutionServiceId.split('|')[2]);
              } catch (e) {
                print('error==$e');
              }
              String initial_name = personel[index].professionalName != ''
                  ? config.Config.get_initial_name(
                      personel[index].professionalName)
                  : "";
              String diagnostic = "";
              for (int i = 0; i < config.Config.procedure_id.length; i++) {
                int pos = config.Config.procedure_id
                    .indexOf(personel[index].serviceId);
                diagnostic = config.Config.procedure_name[pos];
              }
              var newDateTimeObj2 = new DateFormat("yyyy MM dd hh:mm a").parse(personel[index].appointmentTime);
              String appointment_day = new DateFormat('dd MMM').format(newDateTimeObj2);
              String appointment_time = new DateFormat('hh:mm a').format(newDateTimeObj2);
              double paid_amount = (double.parse(personel[index].newPrice[pos].toString()) - double.parse(personel[index].creditsUsed)) * (double.parse(personel[index].paymentPercent) / 100);
              double rest_amount = (double.parse(personel[index].newPrice[pos].toString()) - double.parse(personel[index].creditsUsed)) - paid_amount;
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 0.5, color: Colors.black12),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(right: 20, top: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 50,
                                    child: Text(
                                      appointment_day,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    width: 80,
                                    child: Text(
                                      appointment_time,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfile(
                                          user_id:
                                              personel[index].professionalId),
                                    ));
                              },
                              child: personel[index].professionalimageUrl !=
                                          '' &&
                                      !personel[index]
                                          .professionalimageUrl
                                          .contains("default")
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                          personel[index].professionalimageUrl),
                                    )
                                  : Container(
                                      height: 40,
                                      width: 40,
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
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 10, top: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserProfile(
                                                  user_id: personel[index]
                                                      .professionalId),
                                            ));
                                      },
                                      child: Text(
                                        personel[index].professionalName,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      child: Text(
                                        personel[index].professionalAddress,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              onTap: () {
                                MapUtils.openMap(
                                    double.parse(
                                        personel[index].professional_latitude),
                                    double.parse(personel[index]
                                        .professional_longitude));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Image.asset(
                                    'assets/images/profile/location.png',
                                    height: 22,
                                    width: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  personel[index].paymentStatus,
                                  style: TextStyle(
                                      color: personel[index].paymentStatus ==
                                              'Cancelled'
                                          ? Colors.red
                                          : Color(0xff01d35a),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ),
                              personel[index].paymentStatus == 'Cancelled'
                                  ? Container()
                                  : InkWell(
                                      onTap: () {
                                        showDialog(
                                                context: context,
                                                builder: (
                                                  BuildContext context,
                                                ) =>
                                                    BookingScreen(
                                                        prof_id: personel[index]
                                                            .professionalId,
                                                        screen: "appointment",
                                                        timeslots_data:
                                                            personel[index]
                                                                .timeSlots,
                                                        price: personel[index]
                                                            .newPrice[pos]
                                                            .toString()))
                                            .then((val) {
                                          if (val.toString().contains('pay')) {
                                            String time =
                                                val.toString().substring(3);
                                            List time_get = time.split("#");

                                            String percentage = time_get[2];
                                            String appointmentTime =
                                                time_get[1];
                                            String timeSlot = time_get[0];
                                            String apply_credit = time_get[3];

                                            reschedule(
                                                appointmentTime,
                                                timeSlot,
                                                personel[index].id,
                                                apply_credit);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Reschedule",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                              SizedBox(
                                width: 30,
                              ),
                              personel[index].paymentStatus == 'Cancelled'
                                  ? Container()
                                  : InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (
                                            BuildContext context,
                                          ) =>
                                              _popup_cancelled(
                                                  context, personel[index].id),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20, bottom: 10),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xffEEEEEE),
                                  blurRadius: 1,
                                ),
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2)),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        child: Text(diagnostic),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        alignment: Alignment.topRight,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text("Total Amount: Rs. " +
                                                personel[index]
                                                    .newPrice[pos]
                                                    .toString()),
                                            Text("Paid Amount: Rs. " +
                                                paid_amount.round().toString()),
                                            Text("Remaining Amount: Rs. " +
                                                rest_amount.round().toString()),
                                            Text("Credit Used: Rs. " +
                                                personel[index]
                                                    .creditsUsed
                                                    .toString()),

                                            /*  personel[index].category[0] == 'Basic'? Text(""):*/
                                            Text("Category: " +
                                                personel[index].category[pos])
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                            child: Text(
                          "Booking Id: " + personel[index].referenceId,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        )),
                        Container(
                          child: CupertinoButton(
                              child: Container(
                                child: Text(
                                  "Request Invoice",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Color(0xff01d35a),
                                      fontSize: 14),
                                ),
                              ),
                              onPressed: () {
                                request_invoice(personel[index].id);
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: personel.length,
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
          );
  }

  Widget _popup_cancelled(BuildContext context, String booking_id) {
    return new CupertinoAlertDialog(
//      title: new Text('Success'),
      content: Column(
        children: <Widget>[
          Text(
            "Are You Sure?",
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 5,
          ),
          Text("Your appointment will be cancelled."),
          SizedBox(
            height: 30,
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  child: Text(
                    "No",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  alignment: Alignment.center,
                  height: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(width: 1, color: Colors.grey)),
                ),
              )),
              SizedBox(
                width: 20,
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  cancel(booking_id);
                },
                child: Container(
                  child: Text(
                    "Yes",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  alignment: Alignment.center,
                  height: 35,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xff01d35a)),
                ),
              )),
            ],
          )
        ],
      ),
    );
  }
}
