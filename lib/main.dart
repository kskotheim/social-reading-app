import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:we_read/src/home.dart';
import 'package:we_read/src/logic/reward_tracker.dart';

void main() {
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(AppProvider());
}

class AppProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    RewardTracker tracker = RewardTracker();
    return Provider<RewardTracker>(
        create: (context) => tracker,
        dispose: (context, tracker) => tracker.dispose(),
        child: MyApp(tracker: tracker));
  }
}


class MyApp extends StatefulWidget {
  final RewardTracker tracker;
  MyApp({this.tracker});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.tracker.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.tracker.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.tracker.start();
    } else {
      widget.tracker.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We Read',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}