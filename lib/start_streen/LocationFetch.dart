import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:plunes/config.dart' as config;

import '../config.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: config.Config.google_location_api_key);

class LocationFetch extends StatefulWidget {
  static const tag = '/location_fetch';
   var latitude, longitude;
  LocationFetch({this.latitude, this.longitude});
  @override
  _LocationFetchState createState() => _LocationFetchState();
}

class _LocationFetchState extends State<LocationFetch> {
  Map<MarkerId, Marker> marker = <MarkerId, Marker>{};
  var location = new loc.Location();

  List coordinate_list = new List();
  String latitude = '0.0';
  String longitude = '0.0';
  String address = "";
  bool addr_fetch = false;
  GoogleMapController mapController;
  TextEditingController house = new TextEditingController();
  TextEditingController land_mark = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getLocation();
  }




  void getLocation() async {
    latitude = widget.latitude==null? '0.0':widget.latitude;
    longitude = widget.longitude ==null? '0.0':widget.longitude;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lat = prefs.getString("latitude");
    String lng = prefs.getString('longitude');

    final coordinates = new Coordinates(double.parse(lat), double.parse(lng));
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var addr = addresses.first;
    String full_address = addr.addressLine;

    setState(() {
      latitude = lat;
      longitude = lng;
      address = full_address;
    });
  }

  void save_lat_lng() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("latitude", latitude);
    prefs.setString("longitude", longitude);
    String home = house.text;
    String land = land_mark.text;
    print(home +","+ land +","+ address+","+latitude+","+longitude);
    Navigator.of(context).pop(home +":"+ land +":"+ address+":"+latitude+":"+longitude);
//    if (house.text == '' && land_mark.text == '') {
//      Navigator.of(context).pop(address);
//    } else if (house.text != '' && land_mark.text == '') {
//      Navigator.of(context).pop(home + address);
//    } else if (house.text == '' && land_mark.text != '') {
//      Navigator.of(context).pop(land + address);
//    } else {
//      Navigator.of(context).pop(home + land + address);
//    }


  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    final app_bar = AppBar(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      title: Text(
        "Location",
        style: TextStyle(color: Colors.black),
      ),
      elevation: 2,
      iconTheme: IconThemeData(color: Colors.black),
    );

    final save = Container(
      margin: EdgeInsets.only(top: 10, ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: RaisedButton(
          onPressed: () {
            save_lat_lng();
          },
          color: Color(0xff01d35a),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text('PROCEED', style: TextStyle(color: Colors.white)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

    final house_flat = Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: 14),
        controller: house,
        decoration: InputDecoration(labelText: 'HOUSE/FLAT NO.'),
      ),
    );

    final landmark_loc = Container(
      margin: EdgeInsets.all(10),
      child: TextFormField(
        keyboardType: TextInputType.text,
        style: TextStyle(fontSize: 14),
        controller: land_mark,
        decoration: InputDecoration(labelText: 'LANDMARK'),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child:Container(
                child: Stack(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Container(
                              height: 330,
                              child: GoogleMap(
                                onTap: (LatLng latlng) {
                                  print(latlng.latitude.toString() + "," + latlng.longitude.toString());
                                },
                                mapType: MapType.normal,
                                myLocationButtonEnabled: true,
                                rotateGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                scrollGesturesEnabled: true,
                                myLocationEnabled: true,
                                compassEnabled: true,
                                tiltGesturesEnabled: true,
                                markers: Set<Marker>.of(marker.values),
                                onCameraMoveStarted: () {
                                  print("Started to move");
                                },
                                onCameraIdle: () async {
                                  print("now hit hit");
                                  if (coordinate_list.length != 0) {
                                    setState(() {
                                      addr_fetch = true;
                                    });
                                    Coordinates coordinates = coordinate_list[coordinate_list.length - 1];
                                    latitude = coordinates.latitude.toString();
                                    longitude = coordinates.longitude.toString();


                                    var addresses = await Geocoder.local
                                        .findAddressesFromCoordinates(
                                        coordinate_list[
                                        coordinate_list.length - 1]);

                                    var addr = addresses.first;
                                    String full_address = addr.addressLine;

                                    setState(() {
                                      address = full_address;
                                      addr_fetch = false;
                                    });
                                  }
                                  },
                                onCameraMove: ((_p) async {
                                  print(_p.target.latitude.toString() + "--" + _p.target.longitude.toString());
                                  final coordinates = new Coordinates(_p.target.latitude, _p.target.longitude);
                                  coordinate_list.add(coordinates);
                                  print(coordinate_list.length);
                                }),
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(double.parse(latitude), double.parse(longitude)),
                                  zoom: 15.0,
                                ),
                                onMapCreated: (GoogleMapController controller) {
                                  mapController = controller;
                                },
                              ),
                            ),





                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                margin: EdgeInsets.only(left: 10, top: 25),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 330,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 50,
                                    color: Colors.black,
                                  ),
                                  alignment: Alignment.center,
                                )),
                          ],
                        ),
                      ],
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        height: 340,
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 5,
                              child: Visibility(
                                visible: addr_fetch,
                                child: Container(
                                  height: 5,
                                  child: LinearProgressIndicator(),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                "Set Location",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),


                            InkWell(
                              onTap: ()async{
                                Prediction p = await PlacesAutocomplete.show(
                                    context: context,
                                    apiKey: config.Config
                                        .google_location_api_key);
                                displayPrediction(p);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 30),
                                    child: Text(
                                      "ADDRESS",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 11),
                                    ),),

                                  Container(
                                    child: Text(
                                      address,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                    margin: EdgeInsets.only(
                                      top: 5,
                                      left: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),



                            Container(
                              color: Color(0xffE0E0E0),
                              height: 0.3,

                            ),

                            house_flat,
                            landmark_loc,
                            save

                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
      double lat = detail.result.geometry.location.lat;
      double lng = detail.result.geometry.location.lng;
      setState(() {
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 15, target: LatLng(lat, lng))));
        latitude = lat.toString();
        longitude = lng.toString();
        address = detail.result.formattedAddress;
      });
    }
  }

//  Future<void> _goToTheLake() async {
//    final GoogleMapController controller = await mapController.future;
//  }
}
