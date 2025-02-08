import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';

class ApiService {
  static const String baseUrl = 'http://localhost/student_registry_backend/api.php';

  Future<List<Student>> getStudents() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      print('GET Response status: ${response.statusCode}');
      print('GET Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Student.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load students: ${response.body}');
      }
    } catch (e) {
      print('Error in getStudents: $e');
      throw Exception('Failed to load students: $e');
    }
  }

  Future<void> registerStudent(Student student) async {
    try {
      final jsonData = student.toJson();
      print('Sending data: $jsonData');
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonData),
      );
      
      print('POST Response status: ${response.statusCode}');
      print('POST Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to register student: ${response.body}');
      }
    } catch (e) {
      print('Error in registerStudent: $e');
      throw Exception('Failed to register student: $e');
    }
  }

  Future<bool> checkExistingUser(String studentNumber, String email) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?check=true&student_number=$studentNumber&email=$email'),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['exists'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error checking existing user: $e');
      return false;
    }
  }
}