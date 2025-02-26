import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String course;
  final String section;
  final String birthday;
  final String sex;
  final String email;
  final String cpNumber;

  User({
    required this.id,
    required this.name,
    required this.course,
    required this.section,
    required this.birthday,
    required this.sex,
    required this.email,
    required this.cpNumber,
  });

  // Convert to Firebase data
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'course': course,
      'section': section,
      'birthday': birthday,
      'sex': sex,
      'email': email,
      'cpNumber': cpNumber,
    };
  }

  // Create from Firebase data
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      course: data['course'] ?? '',
      section: data['section'] ?? '',
      birthday: data['birthday'] ?? '',
      sex: data['sex'] ?? '',
      email: data['email'] ?? '',
      cpNumber: data['cpNumber'] ?? '',
    );
  }
}
