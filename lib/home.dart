import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin/student_list_page.dart';
import 'package:harmonia_flutter/parent/parent_album_page.dart';
import 'package:harmonia_flutter/privacy_page.dart';
import 'package:harmonia_flutter/services/db_service.dart';
import 'package:harmonia_flutter/services/google_drive_service.dart';
import 'package:harmonia_flutter/terms_page.dart';

class HarmoniaScreen extends StatefulWidget {
  const HarmoniaScreen({super.key});

  @override
  State<HarmoniaScreen> createState() => _HarmoniaScreenState();
}

class _HarmoniaScreenState extends State<HarmoniaScreen> {
  bool isParent = false;
  bool isLoading = false;
  final controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  FirebaseException? _error;
  bool initialized = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    final database = FirebaseDatabase.instance;
    database.setLoggingEnabled(false);

    if (!kIsWeb) {
      database.setPersistenceEnabled(true);
      database.setPersistenceCacheSizeBytes(10000000);
    }

    setState(() {
      initialized = true;
    });

    _focus.addListener(() {
      setState(() {
        isParent = _focus.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> search(BuildContext context, {String text = ""}) async {
    if (text.isEmpty) {
      text = controller.text;
    }
    if (text.isNotEmpty && !isLoading) {
      setState(() {
        isLoading = true;
      });
      var student = await dbService().searchStudent(text);
      if (!context.mounted) return;

      if (student != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ParentAlbumPage(student: student)));
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0.2, -0.1), radius: 1.2, colors: [Color(0xFF153D7C), Color(0xFF04193F)]),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              top: isParent ? -300 : 0,
              left: 0,
              right: 0,
              bottom: 0,
              duration: Duration(milliseconds: 800),
              curve: Curves.easeOutExpo,
              child: Container(
                width: width,
                height: height,
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 600,
                            padding: const EdgeInsets.all(50),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F8F8),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 30, offset: const Offset(0, 18))],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo
                                Container(
                                  width: 92,
                                  height: 92,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF07113A),
                                    borderRadius: BorderRadius.circular(4),
                                    image: const DecorationImage(image: AssetImage("assets/logo.png"), fit: BoxFit.cover),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                const Text(
                                  "Harmonia Language Lab",
                                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Color(0xFF0F1733)),
                                ),

                                const SizedBox(height: 10),

                                const Text("Student moments, shared with care", style: TextStyle(fontSize: 20, color: Color(0xFF7A7A7A))),

                                const SizedBox(height: 30),

                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "STUDENT ID",
                                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.blueGrey.shade900),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                TextField(
                                  focusNode: _focus,
                                  onSubmitted: (text) {
                                    search(context, text: text);
                                  },
                                  controller: controller,
                                  decoration: InputDecoration(
                                    hintText: "Enter student nickname",
                                    filled: true,
                                    fillColor: const Color(0xFFF4F3EF),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 34),

                                SizedBox(
                                  width: double.infinity,
                                  height: 76,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      search(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDDBE42),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    ),
                                    child: isLoading
                                        ? CircularProgressIndicator()
                                        : Text(
                                            "Search",
                                            style: TextStyle(color: Color(0xFF07113A), fontSize: 28, fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 50),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TermsPage()));
                      },
                      child: const Text('Terms of Service'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyPage()));
                      },
                      child: const Text('Privacy Policy'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
