import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:plunes/model/profile/get_profile_info.dart';


Future<UserProfilePost> user_profile(String user_id, String token) async {
  String url = config.Config.user+"?userId="+user_id;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {
    print("userprofile=>"+response.body);
    print("userprofile=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    print(url);
    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return UserProfilePost.fromJson(error_body);
    }
    return UserProfilePost.fromJson(json.decode(response.body));
  });
}

class UserProfilePost {
  bool success;
  String message;
  String token;
  User user;

  UserProfilePost({this.success, this.user, this.message, this.token});
  factory UserProfilePost.fromJson(Map<String, dynamic> json) {

    if (json.containsKey('user')){
      return UserProfilePost(
          success: json['success'] !=null?json['success']:false ,
          message: json['message'] !=null?json['message']:' ' ,
          token: json['token'] != null? json['token']:'',
          user: User.fromJson(json['user'])
      );
    }else{
      return UserProfilePost(
        success: json['success'] !=null? json['success']: false,
        message: json['message'] !=null?json['message']:' '
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
  List<AchievmentsData> achievments = [];
  String latitude;
  String longitude;
  List<DoctorsData> doctorsdata = [];
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
    this.achievments,
    this.latitude,
    this.longitude,
    this.doctorsdata,
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
      verifiedUser: json['verifiedUser']!= null ? json['verifiedUser']:true,
      userType: json['userType']!= null ? json['userType']:'',
      address: json['address']!= null ? json['address']:'',
      referralCode: json['referralCode']!= null ? json['referralCode']:'',
      coverImageUrl: json['coverImageUrl']!= null ? json['coverImageUrl']:'',
      specialities: List<ProcedureData>.from(json['specialities'].map((i) => ProcedureData.fromJson(i))),
      timeSlots: List<TimeSlotsData>.from(json['timeSlots'].map((i) => TimeSlotsData.fromJson(i))),
      achievments: List<AchievmentsData>.from(json['achievements'].map((i) => AchievmentsData.fromJson(i))),
      doctorsdata: List<DoctorsData>.from(json['doctors'].map((i) => DoctorsData.fromJson(i))),
      experience: json['experience']!= null ? json['experience'].toString():'',
      practising: json['practising']!= null ? json['practising']:'',
      college: json['college']!= null ? json['college']:'',
      biography: json['biography']!= null ? json['biography']:'',
      registrationNumber: json['registrationNumber']!= null ? json['registrationNumber']:'',
      qualification: json['qualification']!= null ? json['qualification']:'',
      imageUrl: json['imageUrl']!= null ? json['imageUrl']:'',
      latitude: json['geoLocation']['latitude'].toString()!= null ? json['geoLocation']['latitude'].toString():'',
      longitude: json['geoLocation']['longitude'].toString()!= null ? json['geoLocation']['longitude'].toString():'',

    );
  }
}

class ProcedureData {
  final String specialityId;

  ProcedureData({this.specialityId});

  factory ProcedureData.fromJson(Map<String, dynamic> parsedJson) {
    return new ProcedureData(
        specialityId: parsedJson['specialityId'] != null ? parsedJson['specialityId'] : '');
  }
}



class TimeSlotsData {
  final List slots;
  final String day;
  final bool closed;

  TimeSlotsData({this.slots, this.day, this.closed});

  factory TimeSlotsData.fromJson(Map<String, dynamic> parsedJson) {
    return new TimeSlotsData(
      slots: parsedJson['slots'] != null ? parsedJson['slots'] : '',
      day: parsedJson['day'] != null ? parsedJson['day'] : '',
      closed: parsedJson['closed'] != null ? parsedJson['closed']: '',
    );
  }
}

class AchievmentsData {
  final String title;
  final String imageUrl;
  final String id;

  AchievmentsData({this.title, this.imageUrl, this.id});

  factory AchievmentsData.fromJson(Map<String, dynamic> parsedJson) {
    return new AchievmentsData(
      title: parsedJson['title'] != null ? parsedJson['title'] : '',
      imageUrl: parsedJson['imageUrl'] != null ? parsedJson['imageUrl'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'].toString() : '',
    );
  }
}