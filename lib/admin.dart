import 'package:flutter/material.dart';
import 'package:harmonia_flutter/admin/student_list_page.dart';
import 'package:harmonia_flutter/services/google_drive_service.dart';

import 'admin/album/album_list_page.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  var islogged = false;
  @override
  void initState() {
    letSomeonSignin();
    super.initState();
  }

  void letSomeonSignin() {
    GoogleDriveService().signIn(callbackSignin);
  }

  void callbackSignin() {
    if (GoogleDriveService.logged) {
      setState(() {
        islogged = GoogleDriveService.logged;
      });
    } else {
      letSomeonSignin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (e, r){
        return;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(center: Alignment(0.2, -0.1), radius: 1.2, colors: [Color(0xFF153D7C), Color(0xFF04193F)]),
          ),
          child: Center(
            child: islogged
                ? Container(
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

                        const SizedBox(height: 34),
                        _tab(
                          r: true,
                          label: "👨‍👩‍👧 Students",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => StudentListPage()));
                          },
                        ),
                        _tab(
                          r: false,
                          label: "🔐 Albums",
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumListPage()));
                          },
                        ),

                        const SizedBox(height: 32),

                        const SizedBox(height: 34),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          letSomeonSignin();
                        },
                        child: Text("Login"),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _tab({required bool r, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: r ? Colors.yellow : Colors.blue, borderRadius: BorderRadius.circular(16)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 24, fontWeight: true ? FontWeight.w700 : FontWeight.w500, color: const Color(0xFF1A2138)),
            ),
          ),
        ),
      ),
    );
  }
}
