import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapViewScreen extends StatefulWidget {
  final List latitude;
  final List longitude;
  final List distance;
  final List name;

  MapViewScreen({Key key,this.latitude, this.longitude, this.distance, this.name}) : super(key: key);
  @override
  _MapViewScreenState createState() => _MapViewScreenState(latitude, longitude, distance, name);
}

class _MapViewScreenState extends State<MapViewScreen> {

  final List latitude;
  final List longitude;
  final List distance;
  final List name;

  _MapViewScreenState(this.latitude,this.longitude, this.distance, this.name);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  var location = new Location();
  String lati = "";
  String longi = "";

  bool call = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getshareference();
  }


  getshareference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lat = prefs.getString("latitude");
    String lng = prefs.getString('longitude');


    for(int i = 0; i< latitude.length; i++){
      final MarkerId markerId = MarkerId(i.toString());
      // creating a new MARKER
      final Marker marker = Marker(
        markerId: markerId,
        // icon: BitmapDescriptor.fromAsset('assets/images/bid/check.png',),
        position: LatLng(
            double.parse(latitude[i].toString()),
            double.parse(longitude[i].toString())),

        infoWindow: InfoWindow(
            title:name[i],
            snippet: distance[i] +
                " Kms away"),
        onTap: () {
          print("on click marker ");
        },
      );

      markers[markerId] = marker;
    }

    setState(() {
      lati = lat;
      longi = lng;
      call= true;

    });

    print("location======"+lati+","+longi);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Stack(

        children: <Widget>[

          Container(
            child: call? Container(
              child:GoogleMap(
                onTap: (LatLng latlng) {
                  print(latlng.latitude.toString() +
                      "," +
                      latlng.longitude.toString());
                },
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                rotateGesturesEnabled: true,
                zoomGesturesEnabled: true,
                scrollGesturesEnabled: true,
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: true,
                markers: Set<Marker>.of(markers.values),
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      double.parse(lati), double.parse(longi),),
                  zoom: 10.0,
                ),
                onMapCreated: (GoogleMapController controller) {},
              ),
            ):Center(
              child: Text("Loading..."),
            ),
          ),

          InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(Icons.close, color: Colors.black,),
            ),
          ),

        ],
      ),
    );
  }
}
