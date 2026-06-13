import 'package:flutter/foundation.dart';
import '../models/student.dart';

class AppState extends ChangeNotifier {
  Student? currentStudent;
  bool isAdmin = false;

  void loginAsParent(Student student) {
    currentStudent = student;
    isAdmin = false;
    notifyListeners();
  }

  void loginAsAdmin() {
    currentStudent = null;
    isAdmin = true;
    notifyListeners();
  }

  void logout() {
    currentStudent = null;
    isAdmin = false;
    notifyListeners();
  }
}
