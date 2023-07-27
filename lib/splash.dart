import 'dart:io';

import 'package:acciendent_alert/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sizer/sizer.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import 'constant/firebase.dart';
import 'notification.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String deviceIdentity = '';
  String fcmToken = '';
  Future<String?> getDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceIdentity = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceIdentity = iosInfo.identifierForVendor!;
      return iosInfo.identifierForVendor;
    }
    return null;
  }

  storeFCMToken() async {
    await getDeviceID();
    fcmToken = (await FirebaseMessaging.instance.getToken())!;
    Map<String, String> map = {
      "FCM_Token": fcmToken.toString(),
    };
    await FirebaseFirestore.instance.collection("user").doc().set(map);
  }

  getState() async {
    storeFCMToken();
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 2), () {
        print('object123');
        MapsLauncher.launchCoordinates(lat, long);
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => const NotificationScreen());
        // Get.offAll(() => const CommonNavigationBar(index: 0));
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    storeFCMToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("notification"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAlerts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> AlertData = snapshot.data!;
            if (AlertData.isEmpty) {
              return Center(child: Text("No Alert Found"));
            }
            return buildListNotification();
          }
        },
      ),
    );
  }
}

Widget buildListNotification() {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  return StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('accident_alerts')
        .orderBy('time', descending: true)
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasData) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          itemCount: snapshot.data!.docs.length,
          reverse: false,
          itemBuilder: (context, index) {
            print("snapshot.data!.docs.length");
            print(snapshot.data!.docs.length);
            print(index);

            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: ZoomTapAnimation(
                onTap: () {
                  MapsLauncher.launchCoordinates(
                      double.parse(snapshot.data!.docs[index]["Lat"]),
                      double.parse(snapshot.data!.docs[index]["Long"]));
                },
                onLongTap: () {},
                enableLongTapRepeatEvent: false,
                longTapRepeatDuration: const Duration(milliseconds: 100),
                begin: 1.0,
                end: 0.93,
                beginDuration: const Duration(milliseconds: 20),
                endDuration: const Duration(milliseconds: 120),
                beginCurve: Curves.decelerate,
                endCurve: Curves.fastOutSlowIn,
                child: DelayedDisplay(
                  delay: const Duration(milliseconds: 150),
                  slidingBeginOffset: const Offset(0, 1),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.withOpacity(0.1)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Accident Alert:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Latitude:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      snapshot.data!.docs[index]["Lat"]
                                          .toString(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Longitude",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      snapshot.data!.docs[index]["Long"]
                                          .toString(),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                SizedBox(
                                  width: 54.w,
                                  child: Row(
                                    children: [
                                      Text(
                                        "Time:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        formatDateTime(
                                          snapshot.data!.docs[index]["time"],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      } else {
        return Container();
      }
    },
  );
}

formatDateTime(Timestamp firebaseTime) {
  Timestamp timestamp = firebaseTime;
  DateTime dateTime = timestamp.toDate();
  String formattedDateTime =
      DateFormat('yyyy-MM-dd | hh:mm a').format(dateTime);
  return formattedDateTime;
}
