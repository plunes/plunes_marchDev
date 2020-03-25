import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/user_profile.dart';


Future<AppointmentsPost> all_appointments(String token) async {

  print(token);
  String url = config.Config.booking;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {

    print("Appointments=>"+response.body);
    print("Appointments=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return AppointmentsPost.fromJson(error_body);
    }
    return AppointmentsPost.fromJson(json.decode(response.body));
  });
}


class AppointmentsPost {
  final bool success;
  final String message;
  List<BookingsData> bookings = [];
  AppointmentsPost({this.success, this.message, this.bookings});
  factory AppointmentsPost.fromJson(Map<String, dynamic> json) {
    return AppointmentsPost(
      success: json['success']!= null ? json['success']: false,
      bookings: List<BookingsData>.from(json['bookings'].map((i) => BookingsData.fromJson(i))),
      message: json['message']!= null ? json['message']: '',
    );
  }
}

class BookingsData {
  final String currency;
  final String paymentStatus;
  final String id;
  final String solutionServiceId;
  final String serviceId;
  final String paymentPercent;
  final String referenceId;
  final String professionalId;
  final String appointmentTime;
  final String userId;

  final String user_latitude;
  final String user_longitude;
  final String professional_latitude;
  final String professional_longitude;


  final String userName;
  final String professionalName;
  final List newPrice;
  final List category;
  final String professionalAddress;
  final String userAddress;
  final String userimageUrl;
  final String creditsUsed;
  List<TimeSlotsData> timeSlots = [];
  final String professionalimageUrl;

  BookingsData({this.currency, this.paymentStatus, this.id, this.solutionServiceId,
    this.serviceId, this.paymentPercent, this.professionalId,
    this.appointmentTime, this.userId, this.category,
    this.user_latitude, this.user_longitude, this.professional_latitude,
    this.professional_longitude, this.userName, this.professionalName, this.newPrice,
  this.professionalAddress, this.userAddress, this.userimageUrl, this.professionalimageUrl,
    this.timeSlots, this.referenceId, this.creditsUsed});

  factory BookingsData.fromJson(Map<String, dynamic> parsedJson) {
    return new BookingsData(
      currency: parsedJson['currency'] != null ? parsedJson['currency'] : '',
      paymentStatus: parsedJson['bookingStatus'] != null ? parsedJson['bookingStatus'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
      solutionServiceId: parsedJson['solutionServiceId'] != null ? parsedJson['solutionServiceId'] : '',
      serviceId: parsedJson['serviceId'] != null ? parsedJson['serviceId'] : '',
      paymentPercent: parsedJson['paymentPercent'].toString() != null ? parsedJson['paymentPercent'].toString() : '',
      professionalId: parsedJson['professionalId'] != null ? parsedJson['professionalId'] : '',
      appointmentTime: parsedJson['appointmentTime'] != null ? parsedJson['appointmentTime'] : '',
      userId: parsedJson['userId'] != null ? parsedJson['userId'] : '',
      category: parsedJson['service']['category'] != null ? parsedJson['service']['category'] : '',
      user_latitude: parsedJson['userLocation']!=null?( parsedJson['userLocation']['latitude'].toString()!= null ? parsedJson['userLocation']['latitude'].toString(): ''):'',
      user_longitude: parsedJson['userLocation']!=null? (parsedJson['userLocation']['longitude'].toString()!= null ? parsedJson['userLocation']['longitude'].toString(): ''):'',
        professional_latitude: parsedJson['professionalLocation']!=null?(parsedJson['professionalLocation']['latitude'].toString() != null ? parsedJson['professionalLocation']['latitude'].toString(): ''):'',
      professional_longitude: parsedJson['professionalLocation']!=null? (parsedJson['professionalLocation']['longitude'].toString() != null ? parsedJson['professionalLocation']['longitude'].toString(): ''):'',
      userName: parsedJson['userName'] != null ? parsedJson['userName'] : null,
      professionalName: parsedJson['professionalName'] != null ? parsedJson['professionalName'] : '',
        professionalAddress: parsedJson['professionalAddress'] != null ? parsedJson['professionalAddress'] : '',
        userAddress: parsedJson['userAddress'] != null ? parsedJson['userAddress'] : '',
        timeSlots: List<TimeSlotsData>.from(parsedJson['service']['timeSlots'].map((i) => TimeSlotsData.fromJson(i))),
        professionalimageUrl: parsedJson['professionalImageUrl'] != null ? parsedJson['professionalImageUrl'] : '',
        userimageUrl: parsedJson['userImageUrl'] != null ? parsedJson['userImageUrl'] : '',
        newPrice: parsedJson['service']['newPrice'] != null ? parsedJson['service']['newPrice'] : '',
        creditsUsed: parsedJson['creditsUsed'] != null ? parsedJson['creditsUsed'].toString() : '',
        referenceId:parsedJson['referenceId'] != null ? parsedJson['referenceId'] : ''
    );
  }
}









