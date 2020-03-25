import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:plunes/model/solution/find_solution.dart';


Future searched_solution( String token) async {
  print(token);
  String url = config.Config.search_solution;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {

    print("SearchedSolutions=>"+response.body);
    print("SearchedSolutions=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return SearchedSolutions.fromJson(error_body);
    }
    return SearchedSolutions.fromJson(json.decode(response.body));
  });
}

class SearchedSolutions {
  final bool success;
  final String message;
  List<PersonelData> personal = [];
  List<BusinessData> business = [];


  SearchedSolutions({this.success, this.message, this.personal, this.business});

  factory SearchedSolutions.fromJson(Map<String, dynamic> json) {

    return SearchedSolutions(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',

      personal: List<PersonelData>.from(json['personal'].map((i) =>
          PersonelData.fromJson(i))),

      business: List<BusinessData>.from(json['business'].map((i) =>
          BusinessData.fromJson(i))),

    );
  }
}




class PersonelData {
  final int createdTime;
  final String serviceId;
  final String id;
  List<ServicesData> services = [];

  PersonelData({this.createdTime, this.serviceId, this.id, this.services});

  factory PersonelData.fromJson(Map<String, dynamic> parsedJson) {
    return new PersonelData(
      createdTime: parsedJson['createdTime'] != null ? parsedJson['createdTime'] : '',
      serviceId: parsedJson['serviceId'] != null ? parsedJson['serviceId'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
      services: List<ServicesData>.from(parsedJson['services'].map((i) =>
          ServicesData.fromJson(i))
      ),

    );
  }
}


class BusinessData {
  final int createdTime;
  final String serviceId;
  final String id;
  final String imageUrl;
  final String name;
  final String user_id;
  List<ServicesData> services = [];


  BusinessData({this.createdTime, this.serviceId, this.id, this.imageUrl, this.name,
    this.services, this.user_id});

  factory BusinessData.fromJson(Map<String, dynamic> parsedJson) {
    return new BusinessData(
      createdTime: parsedJson['createdTime'] != null ? parsedJson['createdTime'] : '',
      serviceId: parsedJson['serviceId'] != null ? parsedJson['serviceId'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'].toString() : '',
      imageUrl: parsedJson['imageUrl'] != null ? parsedJson['imageUrl']: '',
      name: parsedJson['name'] != null ? parsedJson['name']: 'NA',
      user_id: parsedJson['userId'] != null ? parsedJson['userId']: '',
      services: List<ServicesData>.from(parsedJson['services'].map((i) =>
          ServicesData.fromJson(i))
      ),
    );
  }
}
