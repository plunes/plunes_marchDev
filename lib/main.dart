import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plunes/aboutus/AboutUs.dart';
import 'package:plunes/appointment/Appointments.dart';
import 'package:plunes/availability/Businesshours.dart';
import 'package:plunes/config.dart';
import 'package:plunes/enquiry/MainSolutionScreen.dart';
import 'package:plunes/enquiry/PostConcern.dart';
import 'package:plunes/enquiry/Replies.dart';
import 'package:plunes/help/HelpOption.dart';
import 'package:plunes/manage_payment/AddBankDetails.dart';
import 'package:plunes/manage_payment/ManagePayment.dart';
import 'package:plunes/plocker/Annotate.dart';
import 'package:plunes/plocker/LabReports.dart';
import 'package:plunes/plocker/PlockerScreen.dart';
import 'package:plunes/plocker/PlockrMainScreen.dart';
import 'package:plunes/plocker/Prescriptions.dart';
import 'package:plunes/plocker/SharePlunes.dart';
import 'package:plunes/profile/AddDoctors.dart';
import 'package:plunes/profile/DoctorDetails.dart';
import 'package:plunes/profile/EditDoctors.dart';
import 'package:plunes/profile/EditProfile.dart';
import 'package:plunes/profile/MyProfileScreen.dart';
import 'package:plunes/profile/UserProfile.dart';
import 'package:plunes/profile/achievemnts/AchievemntsScreen.dart';
import 'package:plunes/profile/catlogue/AddCatalogue.dart';
import 'package:plunes/profile/catlogue/ViewCatalogue.dart';
import 'package:plunes/refer/ReferScreen.dart';
import 'package:plunes/settings/AccountSetting.dart';
import 'package:plunes/settings/ChangePassword.dart';
import 'package:plunes/settings/SecuritySetting.dart';
import 'package:plunes/settings/SettingsScreen.dart';
import 'package:plunes/solution/BiddingActivity.dart';
import 'package:plunes/solution/BiddingLoading.dart';
import 'package:plunes/solution/BiddingScreen.dart';
import 'package:plunes/solution/Payment.dart';
import 'package:plunes/solution/UserDetailsScreen.dart';
import 'package:plunes/start_streen/Allevents.dart';
import 'package:plunes/start_streen/CheckOTP.dart';
import 'package:plunes/start_streen/EnterPhoneScreen.dart';
import 'package:plunes/start_streen/GuidedTour.dart';
import 'package:plunes/start_streen/HomeScreen.dart';
import 'package:plunes/start_streen/LocationFetch.dart';
import 'package:plunes/start_streen/Nearyou.dart';
import 'package:plunes/start_streen/OTPVerification.dart';
import 'package:plunes/start_streen/Registration.dart';
import 'package:plunes/start_streen/SplashScreen.dart';
import 'package:plunes/start_streen/forgot/Foget_password.dart';

import 'Coupons.dart';
import 'FirebaseNotification.dart';

void main(){

   //  ----- show error page -----
  
  ErrorWidget.builder = (FlutterErrorDetails details) => Container(
    height: double.infinity,
    width: double.infinity,
    child: InkWell(onTap: (){
      Navigator.popAndPushNamed(Config.globalContext, HomeScreen.tag);
    },child: Image.asset('assets/error_page.png', fit: BoxFit.fill)),

  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    FirebaseNotification().setUpFireBase(Config.globalContext, _scaffoldKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Config.globalContext = context;
    return MaterialApp(
      key: _scaffoldKey,
      theme: ThemeData(
       fontFamily: 'ProximaNova',
       accentColor: Color(0xff01d35a),
        highlightColor: Color(0xff01d35a),
        indicatorColor: Color(0xff01d35a),
        primaryColor: Color(0xff01d35a),
        cursorColor: Color(0xff01d35a),
        appBarTheme: AppBarTheme(
            brightness: Brightness.dark,
          actionsIconTheme: IconThemeData(
            color: Colors.black,
          ),
          color: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: Color(0xff01d35a),),
      ),

      debugShowCheckedModeBanner: false,
      routes: {

        Registration.tag: (context)=> Registration(),
        SplashScreen.tag: (context) => SplashScreen(),
        Guidedtour.tag: (context) => Guidedtour(),
        HomeScreen.tag:(context) => HomeScreen(),
        Allevents.tag:(context) => Allevents(),

        BiddingPage.tag:(context) => BiddingPage(),
        SettingScreen.tag: (context) => SettingScreen(),

        ManagePayments.tag:(context) => ManagePayments(),
        OTPVerification.tag:(context) => OTPVerification(),

        CheckOTP.tag:(context)=> CheckOTP(),
        ForgetPassword.tag:(context) => ForgetPassword(),
        EditProfile.tag:(context) => EditProfile(),

        AccountSetting.tag:(context) => AccountSetting(),
        SecuritySetting.tag:(context)=> SecuritySetting(),
        ChangePassword.tag:(context) => ChangePassword(),
        AboutUs.tag:(context) => AboutUs(),


        AchievemntsScreen.tag:(context) => AchievemntsScreen(),
        BiddingActivity.tag:(context) => BiddingActivity(),
        BiddingLoading.tag:(context) => BiddingLoading(),

        Payment.tag: (context) => Payment(),

        BusinessHours.tag: (context) => BusinessHours(),
        LocationFetch.tag: (context) => LocationFetch(),
        AddBankDetails.tag: (context) => AddBankDetails(),
        MainSolutionScreen.tag: (context) => MainSolutionScreen(),
        PostConcern.tag: (context) => PostConcern(),
        EnterPhoneScreen.tag: (context) => EnterPhoneScreen(),
        Nearyou.tag: (context) => Nearyou(),
        ChooseSpeciality.tag: (context) => ChooseSpeciality(),
        PlockerScreen.tag: (context) => PlockerScreen(),
        LabReports.tag: (context) => LabReports(),
        Prescriptions.tag: (context) => Prescriptions(),
        SharePlunes.tag: (context) => SharePlunes(),
        Annotate.tag: (context)  => Annotate(),
        Appointments.tag: (context) => Appointments(),
        Replies.tag: (context) => Replies(),
        MyProfileScreen.tag: (context) => MyProfileScreen(),
        ViewCatalogue.tag: (context) => ViewCatalogue(),
        UserProfile.tag: (context) => UserProfile(),
        HelpOptions.tag: (context) => HelpOptions(),
        EditDoctors.tag: (context) => EditDoctors(),
        DoctorDetails.tag: (context) => DoctorDetails(),
        UserDetailsScreen.tag: (context) => UserDetailsScreen(),
        AddDoctors.tag: (context) => AddDoctors(),
        PlockrMainScreen.tag: (context) => PlockrMainScreen(),
        ReferScreen.tag: (context) => ReferScreen(),
        Coupons.tag: (context) => Coupons(),

      },
      initialRoute:  SplashScreen.tag,
    );
  }
}
