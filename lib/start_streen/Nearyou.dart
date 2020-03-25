import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config.dart';

class Nearyou extends StatefulWidget {
  static const tag = 'near_you';
  @override
  _NearyouState createState() => _NearyouState();
}

class _NearyouState extends State<Nearyou> {
  List images = new List();
  List info = new List();
  List name = new List();
  List name_ = new List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    images.add('assets/images/nearyou/Dentist.png');
    images.add('assets/images/nearyou/Dermatology.png');
    images.add('assets/images/nearyou/Gynecology.png');

    images.add('assets/images/nearyou/Opthemalogist.png');
    images.add('assets/images/nearyou/Orthopedic.png');
    images.add('assets/images/nearyou/Pathology.png');

    images.add('assets/images/nearyou/Physiotherapy.png');
    images.add('assets/images/nearyou/Physotherepy.png');
    images.add('assets/images/nearyou/Radiology.png');

    info.add("Root Canal Treatment (RCT)\n"
        " Teeth Whitening\n"
    "Scaling & Polishing\n"
        "Dental Filling\n"
        "Wisdom Tooth Removal\n"
      "Braces & Aligners\n"
        "Dentures\n"
        "Bridges & Crowns\n"
        "Smile Makeover\n"
        "Gum Treatment\n"
    );

    info.add("Acne Scar Treatment\n"
   " Anti-Aging\n"
   " Acne Scars\n"
    "Pigmentation\n"
    "Hairfall\n"
   " Dermoscopy\n"
   " Chemical Peel\n"
       "Wart Removal\n"
        "Wart Removal\n"
        "Baldness Treatment\n"
       " Skin Polishing\n"
       " Wrinkle Treatment\n"
       " Mole Removal\n"
        "Melasma\n"
        "Eczema\n"
    );


    info.add("Caesarean Section\n"
        "Colposcopy\n"
        "Cervical Cerclage\n"
        "Ovary Removal Surgery\n"
        "Female Infertility Treatment\n"
        "PCOD & Fibroids Management\n"
        "Hyteroscopy\n"
        "Dilation & Curettage\n"
        "Iud Placement\n"
    );



    info.add(
        "Lasik Surgery\n"
        "Refractive Surgery\n"
       " Cataract Eye Surgery\n"
        "Oculoplasty\n"
        "Glaucoma Treatment\n"
        "Keratoconus Treatment\n"
        "Laser Photocoagulation\n"
        "Phacoemulsification\n"
       "Vitreoretinal Surgery\n");


    info.add("Joint Replacement\n"
        "Spinal Disc Problem\n"
        "Fracture Treatment\n"
        "Revision Surgery\n"
        "Asthoscopic Surgery\n"
        "Osteoporosis\n"
        "Sports Injuries\n"
        "Spondylitis\n"
        "Arthritis\n"
        "Trauma Injuries\n");



    info.add("Full Body Check-Up\n"
        "Complete Blood Count (CBC)\n"
    "Lipid Profile\n"
    "Fasting Blood Sugar Test (FBS)\n"
    "Thyroid Stimulating Harmone (TSH)\n"
    "Liver Function Tests (LFT)\n"
    "H1n1 Test (Swine Flu)\n"
    "Mp Test (Malarial Parasite)\n"
    "Haemoglobin Test\n"
    "Hiv Antibody Test\n"
    "Kft (Kidney Funtion Test)\n"
    "Hba1c (Sugar Test)\n"
    "Vitamin D / B12 Test\n");


    info.add("Electro Therapy\n"
        "Laser Therapy\n"
        "Speech Therapy\n"
        "Neck Pain\n"
        "Back Pain\n"
        "Shoulder Pain & Frozen Shoulder\n"
        "Paralysis\n"
        "Sports Injury\n"
        "Spine Correction");


    info.add("Cognitive Behavioural Therapy (CBT)\n"
        "De-Addiction\n"
        "Marriage Counselling\n"
        "Obsessive Compulsive Disorder (OCD)\n"
        "Mood Disorders\n"
        "Stress Management Counselling\n"
        "Psychoanalysis\n"
        "Anger Management\n"
        "Life Skill Training");

    info.add("CT Scan\n"
        "MRI\n"
        "X-Ray\n"
        "Ultrasound\n"
        "ECG\n"
        "Colour Doppler\n"
        "ECHO\n"
        "Ultrasonography\n"
        "Carotid Ultrasound");

    name.add("Dentist");
    name.add("Dermatology");
    name.add("Gynaecology");
    name.add("Ophthalmologist");
    name.add("Orthopedic");
    name.add("Pathology");
    name.add("Physiotherapy");
    name.add("Phychotherapy");
    name.add("Radiology");


    name_.add("Dental");
    name_.add("Dermatology");
    name_.add("Gynae");

    name_.add("Ophthalmology");
    name_.add("Orthopedic");
    name_.add("Pathology Tests");

    name_.add("Physiotherapy Treatments");
    name_.add("Psychotherapy Treatments");
    name_.add("Radiology Tests");

  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;

    var size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 60) / 2;
    final double itemWidth = size.width / 2;


    final app_bar = AppBar(
      backgroundColor: Colors.white,
      brightness: Brightness.light,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      centerTitle: true,
      title: Text(
        "Avail upto 50% discount",
        style: TextStyle(
            color: Color(0xff757575), fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );

    return Scaffold(
      appBar: app_bar,
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        child: GridView.builder(
            physics: ScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount:   images.length,
            itemBuilder: (BuildContext context, int index) {
//              final item = items[index];
              return Container(
                margin: EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.all(8.0),

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(width: 0.5, color: Colors.grey)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10,),
                      Image.asset(images[index], width: 70),
                      SizedBox(height: 10),
                      Text(
                        name[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        child: Text(info[index], maxLines: 4, textAlign: TextAlign.center, style: TextStyle(fontSize: 13),),
                      ),

                     Expanded(child:  InkWell(
                       onTap: () {
                         showDialog(
                           context: context,
                           builder: (BuildContext context,) =>
                               _popup_dialoge(context, name_[index], info[index], images[index]),
                         );
                       },
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Text(
                           "view more",
                           style: TextStyle(color: Color(0xff01d35a)),
                         ),
                       ),
                     ))
                    ],
                  ),
                ),
              );
            },
            gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:6.0 / 9.0)
        )


        /*GridView.count(
          shrinkWrap: true,
//          childAspectRatio: (itemWidth / itemHeight),
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this produces 2 rows.
          crossAxisCount: 2,
          // Generate 100 widgets that display their index in the List.
          children: List.generate(
            images.length,
            (index) {
              return Container(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          border: Border.all(width: 0.5, color: Colors.grey)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 10,),
                            Image.asset(images[index], width: 70,),
                            SizedBox(height: 10,),
                            Text(
                              name[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 10,),
                            Container(
                              child: Text(info[index], maxLines: 4, textAlign: TextAlign.center, style: TextStyle(fontSize: 13),),
                            ),

                            InkWell(
                              onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context,) =>
                                        _popup_dialoge(context, name_[index], info[index], images[index]),
                                  );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "view more",
                                  style: TextStyle(color: Color(0xff01d35a)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              );
            },
          ),
        ),*/
      ),
    );
  }


  Widget _popup_dialoge(BuildContext context,String name,  String info, String image) {
    return new CupertinoAlertDialog(
      content: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
              GestureDetector(

                onTap:(){
                  Navigator.pop(context);
               },
                 child: Container(
                  child:Icon(Icons.close),
                  alignment: Alignment.topRight,
                ),
            ),


            Center(
              child: Image.asset(image),
            ),

            SizedBox(height: 20,),

            Container(
              child: Text("$name Procedures as", textAlign: TextAlign.center,
                style: TextStyle(   fontSize: 16,
                    fontWeight: FontWeight.w500),),
            ),

            SizedBox(height: 20,),

            Center(
              child: Text(info, maxLines: 6, style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w100
              ),),
            ),

            Center(
              child: Text("& many more", maxLines: 6, style: TextStyle(
                color: Color(0xff01d35a), fontSize: 16, fontWeight: FontWeight.w100
              ),),
            ),

            SizedBox(height: 20,),

            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(height: 35,
              width: 200,
              decoration: BoxDecoration(borderRadius:  BorderRadius.all(Radius.circular(10)),color: Color(0xff01d35a)),
              alignment: Alignment.center,
              child: Text("Ok", style: TextStyle(color: Colors.white),),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
