import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart';
import 'package:plunes/config.dart' as config;


Future<AllNotificationsPost> all_notifications(String token) async {


  print(token);
  String url = config.Config.noti_fications;

  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };

  return http.get(url, headers: header).then((http.Response response) {

    print("AllNotificationsPost=>"+response.body);
    print("AllNotificationsPost=>"+response.statusCode.toString());

    var error_body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode > 400 || json == null) {
      return AllNotificationsPost.fromJson(error_body);
    }
    return AllNotificationsPost.fromJson(json.decode(response.body));
  });
}

class AllNotificationsPost {
  final bool success;
  final String message;
  List<PostsData> posts = [];

  AllNotificationsPost({this.success, this.message, this.posts});

  factory AllNotificationsPost.fromJson(Map<String, dynamic> json) {

    return AllNotificationsPost(
      success: json['success']!= null ? json['success']: false,
      message: json['message']!= null ? json['message']: '',
      posts: List<PostsData>.from(json['notifications'].map((i) =>
          PostsData.fromJson(i))),
    );

  }
}

class PostsData {
  final String Senderimageurl;
  final int Currtime;
  final String Notificationtype;
  final String senderUserId;
  final String id;
  final String notification;
  final String senderName;


  PostsData({this.Senderimageurl, this.Currtime,
    this.Notificationtype, this.senderUserId, this.id, this.notification,
  this.senderName});

  factory PostsData.fromJson(Map<String, dynamic> parsedJson) {
    return new PostsData(
      Senderimageurl: parsedJson['senderImageUrl'] != null ? parsedJson['senderImageUrl'] : '',
      Currtime: parsedJson['createdTime'] != null ? parsedJson['createdTime'] : '',
      Notificationtype: parsedJson['notificationType'] != null ? parsedJson['notificationType'] : '',
      senderUserId: parsedJson['senderUserId'] != null ? parsedJson['senderUserId'] : '',
      id: parsedJson['_id'] != null ? parsedJson['_id'] : '',
      notification: parsedJson['notification'] != null ? parsedJson['notification'] : '',
      senderName: parsedJson['senderName'] != null ? parsedJson['senderName'] : '',
    );
  }
}

