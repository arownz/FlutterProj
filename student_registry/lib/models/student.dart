class Student {
  final String studentNumber;
  final String fullName;
  final String birthday;
  final String course;
  final String email;
  final String cpNumber;

  Student({
    required this.studentNumber,
    required this.fullName,
    required this.birthday,
    required this.course,
    required this.email,
    required this.cpNumber,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentNumber: json['student_number'],
      fullName: json['full_name'],
      birthday: json['birthday'],
      course: json['course'],
      email: json['email'],
      cpNumber: json['cp_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_number': studentNumber,
      'full_name': fullName,
      'birthday': birthday,
      'course': course,
      'email': email,
      'cp_number': cpNumber,
    };
  }
}
