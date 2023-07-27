import 'package:acciendent_alert/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:sizer/sizer.dart';

double long = 73.079109;
double lat = 31.418715;
var notificationAppLaunchDetails;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("_firebaseMessagingBackgroundHandler");
  await Firebase.initializeApp();
  FirebaseMessaging.onMessageOpenedApp.listen((_handleMessage));
  print("message");
  print(message);

  long = message.data['long'];
  lat = message.data['lat'];
}

void _handleMessage(RemoteMessage message) {
  print("_handleMessage");
  print(message.data['link']);
  print("message");

  print(message);
  print("long");
  print(long);
  print("lat");
  print(lat);

  long = double.parse(message.data['long']);
  lat = double.parse(message.data['lat']);

  MapsLauncher.launchCoordinates(lat, long);
}

void onSelectNotification(String? payload) {
  print("onSelectNotification");
  print("Navigation_url");
  print("payload");
  print(payload);
  MapsLauncher.launchCoordinates(lat, long);
  print(payload);
}

Future<void> setupInteractedMessage() async {
  // Get any messages which caused the application to open from
  // a terminated state.
  print('setupInteractedMessage');
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  // If the message also contains a data property with a "type" of "chat",
  // navigate to a chat screen
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  // Also handle any interaction when the app is in the background via a
  // Stream listener
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
}

Future<void> _selectNotification(RemoteMessage message) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
          'high_importance_channel', 'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: "@mipmap/ic_launcher");
  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  print("_selectNotification");
  print(message.data);
  long = message.data['long'];
  lat = message.data['lat'];
  print('Testing something.');
  print('Testing something.');
  await FlutterLocalNotificationsPlugin().show(123, message.notification!.title,
      message.notification!.body, platformChannelSpecifics,
      payload: 'data');
  long = message.data['long'];
  lat = message.data['lat'];
  String initialRoute = '1';
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    initialRoute = '2';
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  FlutterLocalNotificationsPlugin().initialize(initializationSettings,
      onSelectNotification: onSelectNotification);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
  ));
  await Firebase.initializeApp();
  setupInteractedMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen((_handleMessage));
  FirebaseMessaging.onMessage.listen((_selectNotification));

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title // description
      importance: Importance.high,
      playSound: true);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.requestPermission(
      sound: true, badge: true, alert: true, provisional: true);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  // Locale _locale = Locale(DEVICE_LOCALE.value, '');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
      // _locale = Locale(DEVICE_LOCALE.value, '');
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
        locale: _locale,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "Kanit-R",
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    });
  }
}
