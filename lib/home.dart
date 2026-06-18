import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin/student_list_page.dart';



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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.2, -0.1),
            radius: 1.2,
            colors: [
              Color(0xFF153D7C),
              Color(0xFF04193F),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.18),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                ),
              ],
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
                    image: const DecorationImage(
                      image: AssetImage("assets/logo.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  "Harmonia Language Lab",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F1733),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Student moments, shared with care",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF7A7A7A),
                  ),
                ),

                // Info box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EDF9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        width: 4,
                        child: ColoredBox(
                          color: Color(0xFF203A79),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Enter your child's full name or student ID to view their gallery.",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF243252),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "STUDENT NAME OR ID",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "e.g. Emma Johnson or S-1042",
                    filled: true,
                    fillColor: const Color(0xFFF4F3EF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 22,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  height: 76,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentListPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDDBE42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "View Gallery →",
                      style: TextStyle(
                        color: Color(0xFF07113A),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}