import 'package:flutter/material.dart';
import 'package:harmonia_flutter/main.dart';
import 'package:harmonia_flutter/models/student.dart';

class StudentEditPage extends StatefulWidget {
  Student student;

  StudentEditPage(this.student, {super.key});

  @override
  State<StudentEditPage> createState() => _StudentEditPageState();
}

class _StudentEditPageState extends State<StudentEditPage> {
  final nameController = TextEditingController();
  final codeController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.student.name;
    codeController.text = widget.student.key;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),

      appBar: AppBar(title: Text("${widget.student.key.isEmpty ? "Add":"Edit"}  Student"), elevation: 0),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),

              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Student Name",
                      border: OutlineInputBorder(),
                    ),
                    controller: nameController,
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    decoration: InputDecoration(
                      labelText: "Student Code",
                      border: OutlineInputBorder(),
                    ),
                    controller: codeController,
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField(
                    value: widget.student.group.isEmpty
                        ? null
                        : widget.student.group,
                    items: const [
                      DropdownMenuItem(
                        value: "2026-06",
                        enabled: false,
                        child: Text("2026-06"),
                      ),
                      DropdownMenuItem(
                        value: "2026-07",
                        enabled: false,
                        child: Text("2026-07"),
                      ),
                    ],
                    onChanged: (v) {},
                    decoration: const InputDecoration(
                      labelText: "Group",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        save();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    var student = super.widget.student;
    student.name = nameController.text;
    student.key = codeController.text;
    student.group = "2026-06";

    try {
      await db.updateStudent(student);

      if (!context.mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text("Updated")),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Can't update: $e"),
        ),
      );
    }
  }
}
