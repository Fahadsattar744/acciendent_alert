import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> fetchAlerts() async {
  try {
    var snapshot =
        await FirebaseFirestore.instance.collection('accident_alerts').get();
    List<Map<String, dynamic>> Alerts = [];
    snapshot.docs.forEach((doc) {
      Alerts.add(doc.data());
    });
    return Alerts;
  } catch (e) {
    // Handle any potential errors here
    print("Error fetching jobs: $e");
    return [];
  }
}
