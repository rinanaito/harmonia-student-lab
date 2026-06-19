import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin/student_list_page.dart';
import 'package:harmonia_flutter/parent_album_page.dart';
import 'package:harmonia_flutter/services/dbService.dart';

class HarmoniaScreen extends StatefulWidget {
  const HarmoniaScreen({super.key});

  @override
  State<HarmoniaScreen> createState() => _HarmoniaScreenState();
}

class _HarmoniaScreenState extends State<HarmoniaScreen> {
  bool isParent = true;
  final controller = TextEditingController();

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
  }

  Future<void> search(BuildContext context, {String text = ""}) async {
    if (text.isEmpty) {
      text = controller.text;
    }
    if (text.isNotEmpty) {
      var student = await dbService().searchStudent(text);
      if (student != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ParentAlbumPage(student: student)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0.2, -0.1), radius: 1.2, colors: [Color(0xFF153D7C), Color(0xFF04193F)]),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Container(
                  width: 600,
                  padding: const EdgeInsets.all(36),
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
                        onSubmitted: (text) {
                          search(context, text: text);
                        },
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: "Сурагчийн код оруулна уу",
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
                          child: const Text(
                            "View Gallery →",
                            style: TextStyle(color: Color(0xFF07113A), fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
