import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:plunes/model/get_procedure.dart';
/// New 28/02/2020
class Config {
  /// Booking Status ['Pending' , 'Initiated' , 'Failed' , 'Cancelled', 'Successful']


  // static String base_url = 'https://plunes.co/v3/';  // production server

  static bool opt_verification = true; // true for production
  // static String base_url = 'http://3.85.183.248/'; // testing server

  static BuildContext globalContext ;

   // location
  static String google_location_api_key = 'AIzaSyAXz9PuBzPhMjAdUZmlyFdst6J8v6Vx1IU';

  // data save
  static int notification_count;
  static String otp_code;

  static List procedure_lists = new List();
  static List procedure_tags = new List();
  static List procedure_speciality= new List();
  static List procedure_description = new List();
  static List procedure_type= new List();

  // procedure
  static List procedure_name = new List();
  static List procedure_id = new List();
  static List procedure_dnd = new List();

  // specialist
  static List specialist_id = new List();
  static List solution_search = new List();
  static List specialist_lists = new List();

  static List catalogueLists = new List();

  static List speciality_proce = new List();


  // payment
  //static String payment = 'http://plunesrazorpay.s3-website.ap-south-1.amazonaws.com/';

  static String initiate_payment = base_url + 'payment/';
  static String managepayment = base_url + 'managepayment/';

  // rating
  static String rating = base_url+'ratings/';

  // help
  static String help = base_url+'help/';

  // hospital
  static String hospital = base_url+'hospital/';

  // data
  static String concern;
  static String device_id;
  static String sender_id = 'Plunes';
  static String otp_auth_key = '278069AIdfPwGj5ce79990';

  // bidding
  static String bidding = base_url+'bidding/';

  // search
  static String search = base_url+'plunessearch/';

  // appointmentopt_verification
  static String business_hours = base_url+'business_hours/';

  // notification
  static String solution_notification = '0';
  static String comment_notification = '1';
  static String appreciate_comment = '2';
  static String apreciate_solution = '3';

  static String bid_booking = '4';
  static String bid_payment = '5';
  static String bid_dynamic = '6';


  static String notification = base_url+'plunesnotifications/';

  // solutions
  static String solution = base_url+'plunessolutions/';

  // invoice
  static String invoice = base_url+'invoice/';

  // profile
  static String login_reg = base_url+'users/';
  static String profile = base_url + 'userprofile/';

  //resources
  static String aws_dir = 'https://profile-image-plunes.s3.amazonaws.com/';

  static String default_achiev = aws_dir+'profilephotos/';

  static String default_img = 'https://www.plunes.com/upload/pic/default-profile-pic.jpg';
  static String default_img2 = 'https://profile-image-plunes.s3.amazonaws.com/profilephotos/default_img.png';

  static String catalogue_img = aws_dir+'catalogue.png';

  static String about_us = 'https://plunes-html.s3.amazonaws.com/resources/about-us.html';
  static String terms = 'https://plunes-html.s3.amazonaws.com/resources/tnc.html';
  static String pricing_terms = 'https://terms-and-condition.s3.ap-south-1.amazonaws.com/termsandconditions.html';


  //catalogue
  static String catalogue = base_url+'catalogue/';
 // static String image_upload = base_url+'photo/';


  //achievements
   static String achievments = base_url+'achievement/';







/// --------------- constants ------------------------------------



/// ----------------------- New Backend ---------------------------


  static String get_initial_name(String get_name){

    String name  = get_name;

    String initial_name =  get_name.substring(0,1);
      List name_list = name.split(" ");

      print(name+name_list.length.toString());

      try{
        if (name.contains("Dr")) {
          if (name_list.length > 2) {
            initial_name = name_list[1].toString().substring(0, 1);
            if(name_list[2] != ''){
              initial_name = name_list[1].toString().substring(0, 1) +
                  name_list[2].toString().substring(0, 1);
            }
          } else if(name_list[1] !='') {

            initial_name = name_list[1].toString().substring(0, 1);
          }else{
            initial_name = name_list[0].toString().substring(0, 1);
          }
        } else {


          if(initial_name != ''){
            initial_name = name_list[0].toString().substring(0, 1);


            if(name_list.length>1){
              if(name_list[1] != ''){
                initial_name = name_list[0].toString().substring(0, 1) +
                    name_list[1].toString().substring(0, 1);
              }
            }
          }
        }
      }catch(Exception ){
        initial_name = get_name.substring(0,1).toUpperCase();
      }


    return initial_name;
  }


  static String get_specialisty_id(){


    List<ProcedureLists> procedure_list = new List();

    String speciality_id = procedure_id[0];


    return speciality_id;
  }



  static showLongToast(String message) {
    Fluttertoast.showToast(
        msg:message,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.transparent,
        textColor: Colors.grey,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2
    );
  }
  static showToast(String message, Color color) {
    Fluttertoast.showToast(
        msg:message,
        gravity: ToastGravity.BOTTOM,
        textColor: color,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 3
    );
  }
  ///Below method is here for convert string color code into Hex color code.
  static int getColorHexFromStr(String colorStr) {
    colorStr = 'FF' + colorStr;
    colorStr = colorStr.replaceAll("#", '');
    int val = 0;
    int len = colorStr.length;
    for (int i = 0; i < len; i++) {
      int hexDigit = colorStr.codeUnitAt(i);
      if (hexDigit >= 48 && hexDigit <= 57) {
        val += (hexDigit - 48) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 65 && hexDigit <= 70) {
        val += (hexDigit - 55) * (1 << (4 * (len - 1 - i)));
      } else if (hexDigit >= 97 && hexDigit <= 102) {
        val += (hexDigit - 87) * (1 << (4 * (len - 1 - i)));
      } else {
        throw new FormatException('error');
      }
    }
    return val;
  }
  ///Below method is used for open Alert Dialog with Animation and callback.



  static showInSnackBar(GlobalKey<ScaffoldState> _scaffoldKey, String value, Color color) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value, style: TextStyle(color: Colors.white),),
      backgroundColor: color,
    ));
  }

  static int get_minutes_diff(int epoch_time){
    var curr_time = new DateTime.now().millisecondsSinceEpoch;

    int time_diff = curr_time.round() -
        epoch_time;

    Duration fastestMarathon = new Duration(milliseconds: time_diff);

    int minutes = fastestMarathon.inMinutes;
    int hours = fastestMarathon.inHours;
    int days = fastestMarathon.inDays;
    int seconds = fastestMarathon.inSeconds;

    return minutes;
  }


  static String get_duration(int epoch_time){
    var curr_time = new DateTime.now().millisecondsSinceEpoch;

    int time_diff = curr_time.round() -
        epoch_time;

    Duration fastestMarathon = new Duration(milliseconds: time_diff);
    String s = "";

    int minutes = fastestMarathon.inMinutes;
    int hours = fastestMarathon.inHours;
    int days = fastestMarathon.inDays;
    int seconds = fastestMarathon.inSeconds;
    print(time_diff);


    if (days < 30) {
      s = days.toString() + " days ago";

      if (hours < 24) {
        s = hours.toString() + "h ago";

        if (minutes < 60) {
          s = minutes.toString() + "m ago";

          if (seconds < 60) {
            if(seconds< 0){
              s =   "0 sec ago";
            }else{
              s = seconds.toString() + " sec ago";

            }
          }
        }
      }
    } else {
      s = "month ago";
    }
    return s;
  }

 static int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
 static bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }


  /// ----------------------  API -----------------------------------

  // base url
  static String base_url = 'https://plunes.co/v4/';//production
//  static String base_url = 'http://3.6.212.85/v4/';//development

  // List of procedures
  static String list_of_procedure = base_url+'catalogue';

  // check user,  add catalogue,  get time slots, get doctors, edit_profile,
  static String user = base_url+'user';

  // registration
  static String registration = base_url+'user/register';

  //login
  static String login_user = base_url+'user/login';

  //update password
  static String update_password = base_url+'user/update_password';

  //get profile
  static String my_profile = base_url+'user/whoami';

  //logout
  static String logout = base_url+'user/logout';

  //logout
  static String logout_all = base_url+'user/logout_all';
  //find solution
  static String find_solution = base_url+'solution';
  //init payment
  static String booking = base_url+'booking';
  static String prescription = base_url + 'prescription/test';
  //payment
  static String payment = 'https://plunes.co/payment';
  //enquiry
  static String enquiry = base_url+'enquiry';
  //enquiry
  static String image_upload = base_url+'user/upload';
  //notification
  static String noti_fications = base_url+'notification/0';
  //searched solution
  static String search_solution = find_solution+"/search";
  // help post
  static String help_post = enquiry+"/help";
  // help post
  static String report = base_url+"report";
  static String prescriptionFileUrl = base_url+"prescription";
  static String solutionSearch = list_of_procedure+"/search";

//  POST plunes.co/v4/catalogue/search
//  Keys: expression, limit, page
}

