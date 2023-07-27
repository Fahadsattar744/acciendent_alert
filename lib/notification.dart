import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Container(
            height: 50,
            width: 50,
            color: Colors.red,
          ),
          ElevatedButton(
            onPressed: () => MapsLauncher.launchCoordinates(
                37.4220041, -122.0862462, 'Google Headquarters are here'),
            child: Text('LAUNCH COORDINATES'),
          ),
        ],
      ),
    );
  }
}
