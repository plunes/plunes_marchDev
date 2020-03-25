import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:plunes/config.dart' as config;
import 'package:plunes/model/profile/user_profile.dart';

Future<dynamic> find_solution(String user_id, String procedure_id, String token) async {
  String url=  config.Config.find_solution+"?&serviceId="+procedure_id;
  print(url);

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http
      .get(url, headers: header)
      .then((http.Response response) {

    print("find solution=>"+response.statusCode.toString());
    print("find solutions=>" + response.body);

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return FindSolutionPost.fromJson(error_body);
    }
    return FindSolutionPost.fromJson(json.decode(response.body));
  });
}

class FindSolutionPost {
  final bool success;
  final String message;
  final int createdTime;
  final String serviceId;
  final String userId;
  final String id;
  List<ServicesData> services;

  FindSolutionPost({this.success, this.message, this.createdTime,
     this.serviceId,this.userId, this.services, this.id});

  factory FindSolutionPost.fromJson(Map<String, dynamic> parsedJson) {
    return new FindSolutionPost(
        success: parsedJson['success'] != null ? parsedJson['success']: false,
        message: parsedJson['message'] != null ? parsedJson['message']: '',

        createdTime: parsedJson['solution']['createdTime'] != null? parsedJson['solution']['createdTime']: '',
        serviceId: parsedJson['solution']['serviceId'] != null? parsedJson['solution']['serviceId']: '',
        userId: parsedJson['solution']['userId'] != null? parsedJson['solution']['userId']: '',
        id: parsedJson['solution']['_id'] != null? parsedJson['solution']['_id']: '',
        services: List<ServicesData>.from(parsedJson['solution']['services'].map((i) =>
            ServicesData.fromJson(i))),
    );
  }
}

class ServicesData {
  final String id;
  final String professionalId;
  final List price;
  final String discount;
  final List newPrice;
  final String latitude;
  final String longitude;
  final String distance;
  final String name;
  final String imageUrl;
  final bool negotiating;
  final List category;
  final String recommendation;
  List<TimeSlotsData> timeSlots = [];

  ServicesData({this.id, this.professionalId, this.price, this.discount,
    this.newPrice, this.latitude, this.longitude, this.distance, this.name,
    this.imageUrl, this.negotiating, this.category, this.timeSlots, this.recommendation});

  factory ServicesData.fromJson(Map<String, dynamic> parsedJson) {
    return new ServicesData(
        id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
        professionalId: parsedJson['professionalId'] != null ? parsedJson['professionalId'] : '',
        price: parsedJson['price'] != null ? parsedJson['price'] : '',
        discount: parsedJson['discount'].toString() != null ? parsedJson['discount'].toString() : '',
        newPrice: parsedJson['newPrice'] != null ? parsedJson['newPrice'] : '',
        latitude: parsedJson['latitude'].toString() != null ? parsedJson['latitude'].toString() : '',
        longitude: parsedJson['longitude'].toString() != null ? parsedJson['longitude'].toString() : '',
        distance: parsedJson['distance'].toString() != null ? parsedJson['distance'].toString() : '0',
        name: parsedJson['name'] != null ? parsedJson['name'] : '',
        category: parsedJson['category'] != null ? parsedJson['category'] : '',
        imageUrl: parsedJson['imageUrl'] != null ? parsedJson['imageUrl'] : '',
      recommendation: parsedJson['recommendation'].toString() != null ? parsedJson['recommendation'].toString(): '',
        negotiating: parsedJson['negotiating'] != null ? parsedJson['negotiating'] : '',
      timeSlots: List<TimeSlotsData>.from(parsedJson['timeSlots'].map((i) =>
          TimeSlotsData.fromJson(i)))
    );
  }
}
