import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;
import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';


Future all_enquiries(String token) async {
  print(token);
  String url = config.Config.enquiry;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {

    print("AllEnquiries=>"+response.body);
    print("AllEnquiries=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return AllEnquiriesPost.fromJson(error_body);
    }
    return AllEnquiriesPost.fromJson(json.decode(response.body));

  });
}

class AllEnquiriesPost {
  final bool success;
  final String message;
  List<EnquiriesData> enquiries = [];

  AllEnquiriesPost({this.success, this.message, this.enquiries});

  factory AllEnquiriesPost.fromJson(Map<String, dynamic> json) {

    return AllEnquiriesPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
      enquiries: List<EnquiriesData>.from(json['enquiries'].map((i) =>
          EnquiriesData.fromJson(i)))


    );

  }
}



class EnquiriesData {
  final bool private;
  final int createdTime;
  final String id;
  final String fromUserId;
  final String toUserId;
  final String enquiry;

  final String fromUserName;
  final String toUserName;

  final String toUserimageUrl;
  final String fromUserimageUrl;

  List<RepliesData> replies = [];


  EnquiriesData({this.private, this.createdTime, this.id, this.fromUserId,
    this.toUserId, this.enquiry, this.replies,this.fromUserName, this.toUserName,
  this.toUserimageUrl, this.fromUserimageUrl});

  factory EnquiriesData.fromJson(Map<String, dynamic> parsedJson) {
    return new EnquiriesData(
      private: parsedJson['private'] != null ? parsedJson['private'] : '',
      createdTime: parsedJson['createdTime'] != null ? parsedJson['createdTime'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'].toString() : '',
      fromUserId: parsedJson['fromUserId'] != null ? parsedJson['fromUserId'] : '',
      toUserId: parsedJson['toUserId'] != null ? parsedJson['toUserId'] : '',
      enquiry: parsedJson['enquiry'] != null ? parsedJson['enquiry'].toString() : '',
        fromUserName: parsedJson['fromUserName'] != null ? parsedJson['fromUserName'] : 'NA',
        toUserName: parsedJson['toUserName'] != null ? parsedJson['toUserName'].toString() : 'NA',

        fromUserimageUrl: parsedJson['fromUserImageUrl'] != null ? parsedJson['fromUserImageUrl'] : '',
        toUserimageUrl: parsedJson['toUserImageUrl'] != null ? parsedJson['toUserImageUrl'].toString() : '',

        replies: List<RepliesData>.from(parsedJson['replies'].map((i) =>
            RepliesData.fromJson(i)))
    );
  }
}



class RepliesData {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String reply;
  final int createdTime;
  final String fromimageUrl;

  RepliesData({this.id, this.fromUserId, this.fromUserName, this.reply, this.createdTime, this.fromimageUrl});

  factory RepliesData.fromJson(Map<String, dynamic> parsedJson) {
    return new RepliesData(
        id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
      fromUserId: parsedJson['fromUserId'] != null ? parsedJson['fromUserId'] : '',
      fromUserName: parsedJson['fromUserName'] != null ? parsedJson['fromUserName'] : 'NA',
      reply: parsedJson['reply'] != null ? parsedJson['reply'] : '',
      createdTime: parsedJson['createdTime'] != null ? parsedJson['createdTime'] : '',
      fromimageUrl: parsedJson['fromUserImageUrl'] != null ? parsedJson['fromUserImageUrl'] : '',
    );
  }
}

