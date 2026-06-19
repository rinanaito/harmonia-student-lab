import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:harmonia_flutter/main.dart';

import '../models/student.dart';
import 'student_edit_page.dart';

class StudentListPage extends StatelessWidget {
  StudentListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student List"), elevation: 0),
      backgroundColor: const Color(0xFFF8F6EF),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StudentEditPage(Student())));
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Student"),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<List<Student>>(
                  stream: db.getStudents(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final students = snapshot.data!;
                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final s = students[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.blue.shade50,
                                child: Text(
                                  s.name.isEmpty ? "*" : s.name.substring(0, 1),
                                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                                ),
                              ),

                              const SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 4),
                                    Text(s.code, style: TextStyle(color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),

                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentEditPage(s)));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
