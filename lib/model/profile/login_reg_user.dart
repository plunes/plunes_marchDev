import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';

Future<RegistrationPost> registration_api(var body) async {
  String url = config.Config.registration;
  return http.post(url, body: json.encode(body), headers: {"Content-Type": "application/json"}).then((http.Response response) {
    print("registration responce =>"+response.body);
    print("registration responce =>"+response.statusCode.toString());
    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };
    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return RegistrationPost.fromJson(error_body);
    }
    return RegistrationPost.fromJson(json.decode(response.body));

  });
}

class RegistrationPost {
  final bool success;
  final String message;
  User user;
  String token;

  RegistrationPost({this.success, this.user, this.message, this.token});
  factory RegistrationPost.fromJson(Map<String, dynamic> json) {

    if (json.containsKey('user')){
      return RegistrationPost(
          success: json['success'] !=null?json['success']:false ,
          message: json['message'] !=null?json['message']:' ' ,
          token: json['token']!= null ? json['token']:'',
          user: User.fromJson(json['user']
          )
      );
    }else{
      return RegistrationPost(
          success: json['success'] !=null? json['success']: false,
          message: json['message'] !=null?json['message']:' ');
    }
  }
}


Future<dynamic> loginapi( var body) async {
  String url = config.Config.login_user;
  return http.post(url, body: json.encode(body), headers:{"Content-Type": "application/json"}).then((http.Response response) {
    print("login responce=>"+response.body);
    print("login responce=>"+response.statusCode.toString());
    var error_body = {
      "success":false,
      "message": "Something went wrong!"
    };
    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return LoginPost.fromJson(error_body);
    }
    return LoginPost.fromJson(json.decode(response.body));
  });
}


class LoginPost {
   bool success;
   String message;
   String token;
  User user;

  LoginPost({this.success, this.user, this.message, this.token});
  factory LoginPost.fromJson(Map<String, dynamic> json) {

    if (json.containsKey('user')){
      return LoginPost(
          success: json['success'] !=null?json['success']:false ,
          message: json['message'] !=null?json['message']:' ' ,
          token: json['token'] != null? json['token']:'',
          user: User.fromJson(json['user'],
          )
      );
    }else{
      return LoginPost(
        success: json['success'] !=null? json['success']: false,
        message: json['message'] !=null?json['message']:' ' ,

      );
    }
  }
}

class User{
  String uid;
  String name;
  String gender;
  String birthDate;
  String mobileNumber;
  String email;
  bool verifiedUser;
  String userType;
  String address;
  String referralCode;
  List<ProcedureData> specialities = [];
  List<TimeSlotsData> timeSlots = [];
  String experience;
  String practising;
  String college;
  String biography;
  String registrationNumber;
  String qualification;
  String imageUrl;
  String coverImageUrl;


  User({
    this.uid,
    this.name,
    this.gender,
    this.birthDate,
    this.mobileNumber,
    this.email,
    this.verifiedUser,
    this.userType,
    this.address,
    this.referralCode,
    this.specialities,
    this.timeSlots,

    this.experience,
    this.practising,
    this.college,
    this.biography,
    this.registrationNumber,
    this.qualification,
    this.imageUrl,
    this.coverImageUrl
  });

  factory User.fromJson(Map<String, dynamic> json) {


    return User(
        uid: json['_id']!= null ? json['_id']:'',
        name: json['name']!= null ? json['name']:'',
        gender: json['gender']!= null ? json['gender']:'',
        birthDate: json['birthDate']!= null ? json['birthDate']:'',
        mobileNumber: json['mobileNumber']!= null ? json['mobileNumber']:'',
        email: json['email']!= null ? json['email']:'',
        verifiedUser: json['verifiedUser']!= null ? json['verifiedUser']:'',
        userType: json['userType']!= null ? json['userType']:'',
        address: json['address']!= null ? json['address']:'',
        referralCode: json['referralCode']!= null ? json['referralCode']:'',
        coverImageUrl: json['coverImageUrl']!= null ? json['coverImageUrl']:'',

        specialities: List<ProcedureData>.from(json['specialities'].map((i) => ProcedureData.fromJson(i))),

      timeSlots: List<TimeSlotsData>.from(json['timeSlots'].map((i) => TimeSlotsData.fromJson(i))),

      experience: json['experience']!= null ? json['experience'].toString():'',
      practising: json['practising']!= null ? json['practising']:'',
      college: json['college']!= null ? json['college']:'',
      biography: json['biography']!= null ? json['biography']:'',
      registrationNumber: json['registrationNumber']!= null ? json['registrationNumber']:'',
      qualification: json['qualification']!= null ? json['qualification']:'',
      imageUrl: json['imageUrl']!= null ? json['imageUrl']:'',
    );
  }
}

class ProcedureData {
  final String specialityId;
  List<ServicesData> services = [];

  ProcedureData({this.specialityId, this.services});
  factory ProcedureData.fromJson(Map<String, dynamic> parsedJson) {
    return new ProcedureData(
        specialityId: parsedJson['specialityId'] != null ? parsedJson['specialityId'] : '',
      services: List<ServicesData>.from(parsedJson['services'].map((i) =>
          ServicesData.fromJson(i))),
    );
  }
}


class TimeSlotsData {
  final List slots;
  final String day;
  final String closed;

  TimeSlotsData({this.slots, this.day, this.closed});

  factory TimeSlotsData.fromJson(Map<String, dynamic> parsedJson) {
    return new TimeSlotsData(
        slots: parsedJson['slots'] != null ? parsedJson['slots'] : '',
      day: parsedJson['day'] != null ? parsedJson['day'] : '',
      closed: parsedJson['closed'] != null ? parsedJson['closed'].toString() : '',
    );
  }
}


class ServicesData {
  final String serviceId;
  final List price;
  final String variance;

  ServicesData({this.serviceId, this.price, this.variance});

  factory ServicesData.fromJson(Map<String, dynamic> parsedJson) {
    return new ServicesData(
      serviceId: parsedJson['serviceId'] != null ? parsedJson['serviceId'] : '',
      price: parsedJson['price'] != null ? parsedJson['price'] : '',
      variance: parsedJson['variance'] != null ? parsedJson['variance'].toString() : '',
    );
  }
}
