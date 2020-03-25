
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plunes/config.dart' as config;

Future<PutCoupons> submitCoupon(var body, String token) async {
  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };
  return http.put(config.Config.user, body: json.encode(body), headers: header).then((http.Response response) {
    var body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return PutCoupons.fromJson(body);
    }
    return PutCoupons.fromJson(json.decode(response.body));
  });
}

Future<GetCouponsList> getCouponsListInfo(String token) async {
  var header = {
    "Content-Type": "application/json",
    "Authorization":"Bearer "+token
  };
  return http.get(config.Config.booking+'/info', headers: header).then((http.Response response) {
    var body = {
      "success": false,
      "message": "Something went wrong!"
    };

    if (response.statusCode < 200 || response.statusCode >= 400 || json == null) {
      return GetCouponsList.fromJson(body);
    }
    return GetCouponsList.fromJson(json.decode(response.body));//{\"success\":true,\"info\":{\"coupons\":[],\"count\":0}}
  });
}

class PutCoupons {
  final bool success;
  final String message;
  PutCoupons({this.success, this.message});

  factory PutCoupons.fromJson(Map<String, dynamic> json) {
    return PutCoupons(
        success: json['success'] != null ? json['success'] : false,
        message: json['message']!=null ? json['message']: ''
    );
  }

}

class GetCouponsList {
  final bool success;
  final String message;
  final dynamic info;

  GetCouponsList({this.success, this.message, this.info});

  factory GetCouponsList.fromJson(Map<String, dynamic> json) {
    return GetCouponsList(
        success: json['success'] != null ? json['success'] : false,
        message: json['message']!=null ? json['message']: '',
        info: json['info']!=null? json['info']:''

    );

  }

}


