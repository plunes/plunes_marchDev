import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class Check_Internet {
  Future<bool> check_net() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    bool net = connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;

    return net;
  }
}