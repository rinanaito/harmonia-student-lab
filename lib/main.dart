import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:harmonia_flutter/home.dart';
import 'package:harmonia_flutter/services/dbService.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'admin.dart';
import 'firebase_options.dart';

late DatabaseReference dbRef;
final db = dbService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  usePathUrlStrategy();
  final uri = Uri.base;
  Widget page;

  switch (uri.path) {
    case '/':
      page =  HarmoniaScreen();
      break;

    case '/admin':
      page =  AdminScreen();
      break;

    default:
      page =  HarmoniaScreen();
  }

  runApp( MyApp(page));
}

class MyApp extends StatefulWidget {
  late Widget page;
  MyApp(this.page, {super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseException? _error;

  bool initialized = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> init() async {
    dbRef = FirebaseDatabase.instance.ref();

    final database = FirebaseDatabase.instance;

    database.setLoggingEnabled(false);

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    if (!kIsWeb) {
      await dbRef.keepSynced(true);
    }

  }

  @override
  void dispose() {
    super.dispose();
    dbRef.onDisconnect();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Harmonia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: widget.page
    );
  }
}
