import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sochem/models/notification_model.dart';
import 'package:sochem/utils/constants.dart';
import 'package:sochem/utils/dialog.dart';
import 'package:sochem/utils/endpoints.dart';
import 'package:sochem/widgets/bar.dart';
import 'package:sochem/widgets/carousel.dart';
import 'package:sochem/widgets/gridcards.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool newNotifExist = false;
  String userName = '';
  String initials = '';
  bool loggedIn = false;
  String token = "";
  late SharedPreferences prefs;

  Future<void> fetchNotifs() async {
    var response = await http.get(
      Uri.parse(Endpoints.notif),
      headers: {HttpHeaders.authorizationHeader: token},
    );
    List<Notifications> notifs = [];
    if (response.statusCode == 200) {
      var peopleJson = json.decode(response.body);
      for (var peoplesJson in peopleJson) {
        notifs.add(Notifications.fromJson(peoplesJson));
      }
    }
    if (notifs.isNotEmpty) {
      int newId = int.parse(notifs.last.id);
      int oldId = 0;
      if (prefs.containsKey(lastNotifId)) {
        oldId = prefs.getInt(lastNotifId)!;
      } else {
        prefs.setInt(lastNotifId, 0);
      }
      newNotifExist = oldId < newId;
    }
  }

  void refreshAfterNotificationScreen() {
    setState(() {
      newNotifExist = false;
    });
  }

  @override
  void initState() {
    _initialising();
    super.initState();
  }

  void _initialising() async {
    prefs = await SharedPreferences.getInstance();
    loggedIn = prefs.getBool(isLoggedIn)!;
    if (loggedIn) {
      token = prefs.getString(DjangoToken)!;
      userName = prefs.getString(UserName)!;
      var temp = "";
      for (var y in userName.split(' ')) {
        if (y[0] == '4')
          break;
        else
          temp += y + ' ';
      }
      userName = temp;
      await fetchNotifs();
    } else {
      token = dotenv.get(GuestToken);
      userName = "Guest";
    }
    setState(() {
      initials = userName.substring(0, 1).toUpperCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screensize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromARGB(1, 0, 2, 20),
      body: Column(
        children: <Widget>[
          Container(
            height: screensize.height * 0.3,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      15.0,
                      8,
                      10.0,
                      screensize.height * 0.005,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: screensize.width * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Hey " + initials,
                                  style: GoogleFonts.montserrat(
                                    textStyle: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(children: [
                          Stack(
                            children: [
                              IconButton(
                                alignment: Alignment.centerRight,
                                onPressed: () => loggedIn
                                    ? Navigator.pushNamed(context, NotifRoute)
                                        .then((value) =>
                                            refreshAfterNotificationScreen())
                                    : signinDialog(context),
                                icon: Icon(
                                  CupertinoIcons.bell,
                                  size: 30.0,
                                  color: Colors.white,
                                ),
                              ),
                              if (newNotifExist)
                                Positioned(
                                  right: 10,
                                  top: 7,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    maxRadius: 6,
                                    minRadius: 6,
                                  ),
                                ),
                            ],
                          ),
                          // IconButton(
                          //   alignment: Alignment.centerRight,
                          //   onPressed: () =>
                          //       Navigator.pushNamed(context, InfoRoute),
                          //   icon: Icon(
                          //     CupertinoIcons.info_circle,
                          //     size: 30.0,
                          //     color: Colors.white,
                          //   ),
                          // ),
                        ]),
                      ],
                    ),
                  ),
                  Divider(
                    color: Color.fromRGBO(42, 107, 255, 1),
                    thickness: 0.4,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                    child: Text("Upcoming",
                        style: TextStyle(
                            color: Color.fromRGBO(83, 141, 255, 1),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,)),
                  ),
                  Container(
                    height: 70,
                    child: ListView(

                    ),
                  )
                  // Container(
                  //   alignment: Alignment.centerLeft,
                  //   child: Padding(
                  //     padding: EdgeInsets.only(
                  //       left: 25.0,
                  //       top: screensize.height * 0.01,
                  //     ),
                  //     child: Text(
                  //       "Society Of",
                  //       textAlign: TextAlign.left,
                  //       style: GoogleFonts.raleway(
                  //         textStyle: TextStyle(
                  //           fontSize: screensize.width * 0.087,
                  //           fontWeight: FontWeight.w600,
                  //           color: Colors.white,
                  //           // letterSpacing: 1.2,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   alignment: Alignment.centerLeft,
                  //   child: Padding(
                  //     padding: EdgeInsets.only(left: 25.0),
                  //     child: Text(
                  //       "Chemical Engineers",
                  //       textAlign: TextAlign.left,
                  //       style: GoogleFonts.raleway(
                  //         textStyle: TextStyle(
                  //           fontSize: screensize.width * 0.082,
                  //           fontWeight: FontWeight.w600,
                  //           color: Colors.white,
                  //           // letterSpacing: 1.2,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Divider(
            color: Color.fromRGBO(211, 226, 255, 1),
            thickness: 0.065,
          ),
          Container(
            height: screensize.height * 0.5,
            child: HomeScreenGrid(),
          ),
          Container(
            child: Column(
              children: [
                Divider(
                  color: Color.fromRGBO(42, 107, 255, 1),
                  thickness: 0.5,
                ),
                HomeScreenBar()
              ],
            ),
          )
          //HomeScreenCarousel(),
        ],
      ),
    );
  }
}
