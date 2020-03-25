import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:plunes/model/profile/user_profile.dart';

Future<MyProfile> my_profile_data(String token) async {
  String url = config.Config.my_profile;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {

    print("My Profile =>"+response.body);
    print("My Profile=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return MyProfile.fromJson(error_body);
    }
    return MyProfile.fromJson(json.decode(response.body));

  });
}


class MyProfile{
  String uid;
  String name;
  String coverImageUrl;
  String gender;
  String birthDate;
  String mobileNumber;
  String email;
  bool verifiedUser;
  String userType;
  String address;
  String referralCode;
  String credits;
  String experience;
  String practising;
  String college;
  String biography;
  String registrationNumber;
  String qualification;
  String imageUrl;
  List<DoctorsData> doctorsdata = [];
  String userReferralCode;
  List<ProcedureData> specialities = [];
  List<AchievmentsData> achievments = [];
  List<String> otherFields;
  String latitude;
  String longitude, prescriptionLogoUrl, prescriptionLogoText;


  MyProfile({
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
    this.experience,
    this.practising,
    this.college,
    this.biography,
    this.registrationNumber,
    this.qualification,
    this.imageUrl,
    this.specialities,
    this.achievments,
    this.latitude,
    this.longitude,
    this.doctorsdata,
    this.coverImageUrl,
    this.credits,
    this.userReferralCode,
    this.prescriptionLogoUrl,
    this.prescriptionLogoText,
    this.otherFields
  });

  factory MyProfile.fromJson(Map<String, dynamic> json) {
    return MyProfile(
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
      credits: json['credits'].toString()!= null ? json['credits'].toString():'',
      userReferralCode: json['userReferralCode'].toString()!= null ? json['userReferralCode'].toString():'',
      specialities: List<ProcedureData>.from(json['specialities'].map((i) => ProcedureData.fromJson(i))),
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
        prescriptionLogoUrl: json['prescription']!= null ? (json['prescription']['logoUrl']!=null? json['prescription']['logoUrl']:''):'',
      prescriptionLogoText: json['prescription']!= null ? (json['prescription']['logoText']!=null? json['prescription']['logoText']:''):'',
      otherFields: List<String>.from( json['prescription']!= null ? json['prescription']['otherFields']!= null ? json['prescription']['otherFields']: List(): List()),


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



class DoctorsData {

  List<ProcedureData> specialities = [];
  List<TimeSlotsData> timeSlots = [];

  String name;
  String education;
  String designation;
  String department;
  String experience;
  String id;
  String imageUrl;

  DoctorsData({this.specialities, this.timeSlots,this.name, this.education, this.id,
    this.designation, this.department, this.experience, this.imageUrl});
  factory DoctorsData.fromJson(Map<String, dynamic> parsedJson) {
    return new DoctorsData(

      name: parsedJson['name']!= null ? parsedJson['name']:'NA',
      education: parsedJson['education']!= null ? parsedJson['education']:'',
      designation: parsedJson['designation']!= null ? parsedJson['designation']:'',
      department: parsedJson['department']!= null ? parsedJson['department']:'',
      experience: parsedJson['experience'].toString()!= null ? parsedJson['experience'].toString():'',

      specialities: List<ProcedureData>.from(parsedJson['specialities'].map((i) =>
          ProcedureData.fromJson(i))),

      id: parsedJson['_id']!= null ? parsedJson['_id']:'',
      imageUrl: parsedJson['imageUrl']!= null ? parsedJson['imageUrl']:'',
      timeSlots: List<TimeSlotsData>.from(parsedJson['timeSlots'].map((i) =>
          TimeSlotsData.fromJson(i))),
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