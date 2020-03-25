import 'package:flutter/material.dart';
import 'package:zoomable_image/zoomable_image.dart';



class ProfileImage extends StatefulWidget {
  final String image_url;
  final String text;

  ProfileImage({Key key, this.image_url, this.text}) : super(key: key);

  @override
  _ProfileImageState createState() => _ProfileImageState(image_url, text);
}

class _ProfileImageState extends State<ProfileImage> {
  String image_url;
  String text;
  _ProfileImageState(this.image_url, this.text);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Stack(
          children: <Widget>[
            ZoomableImage(
              new NetworkImage(image_url),
              maxScale: 5,
              backgroundColor: Colors.black,
              placeholder: const Center(
                child: const CircularProgressIndicator(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                " " + text,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
                margin: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.white,
                    ),
                  ),
                )),

          ],
        ));
  }
}