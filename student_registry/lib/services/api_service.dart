import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/student_registry_backend/api.php';

  Future<List<Student>> getStudents() async {
    final response = await http.get(Uri.parse(baseUrl));
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Student.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> registerStudent(Student student) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(student.toJson()),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to register student');
    }
  }
}