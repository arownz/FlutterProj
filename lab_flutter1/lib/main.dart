import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart'; // Model class for user data.
import 'firebase_options.dart'; // This is where the FirebaseOptions will be generated
import 'package:intl/intl.dart'; // Add this for date formatting
import 'package:logger/logger.dart';
import 'package:flutter/services.dart'; // Add this for input formatters

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Using the generated Firebase options
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase CRUD - Pasion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cpNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Add form key for validation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[700],
        titleTextStyle: const TextStyle(
            fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
        title: Text("Student Information System - Pasion"),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blue[700],
            padding: EdgeInsets.symmetric(
                vertical: 8, horizontal: 16), // Reduced padding
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/nulogo.png',
                    height: 100, // Reduced height from 200 to 100
                  ),
                  SizedBox(height: 8), // Reduced spacing
                  Text(
                    'Student Registration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            _buildInputDecoration('Full Name', Icons.person),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Name is required';
                          if (value!.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration:
                            _buildInputDecoration('Course', Icons.school),
                        items: ['BSIT', 'BSCS', 'BSIS'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) => _courseController.text = val ?? '',
                        validator: (value) =>
                            value == null ? 'Please select a course' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _sectionController,
                        decoration:
                            _buildInputDecoration('Section', Icons.group),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Section is required'
                            : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _birthdayController,
                        decoration:
                            _buildInputDecoration('Birthday', Icons.cake),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _birthdayController.text =
                                DateFormat('yyyy-MM-dd').format(date);
                          }
                        },
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Birthday is required'
                            : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration:
                            _buildInputDecoration('Sex', Icons.person_outline),
                        items: ['Male', 'Female'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (val) => _sexController.text = val ?? '',
                        validator: (value) =>
                            value == null ? 'Please select sex' : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration:
                            _buildInputDecoration('Email Address', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null; // Remove async email check from here
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _cpNumberController,
                        decoration: _buildInputDecoration(
                            'Contact Number', Icons.phone),
                        keyboardType: TextInputType.phone,
                        maxLength: 13, // Limit to 13 characters
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Contact number is required';
                          }
                          if (value!.length < 10) {
                            return 'Contact number must be at least 10 digits';
                          }
                          if (value.length > 13) {
                            return 'Contact number must not exceed 13 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async { // Make this async
                          if (_formKey.currentState?.validate() ?? false) {
                            // Store context before async operation
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            // Check email before creating user
                            bool emailExists = await isEmailRegistered(_emailController.text);
                            if (!mounted) return;  // Check if widget is still mounted
                            if (emailExists) {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text('This email is already registered'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // If email not registered, create user
                            createUser(
                              _nameController.text,
                              _courseController.text,
                              _sectionController.text,
                              _birthdayController.text,
                              _sexController.text,
                              _emailController.text,
                              _cpNumberController.text,
                            );
                            _formKey.currentState?.reset();
                            // Clear controllers
                            _nameController.clear();
                            _courseController.clear();
                            _sectionController.clear();
                            _birthdayController.clear();
                            _sexController.clear();
                            _emailController.clear();
                            _cpNumberController.clear();
                          }
                        },
                        child: Text(
                          'Add Student',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontFamily: 'Roboto'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<User>>(
              stream: getUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No students found"));
                }

                var users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    return ListTile(
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Course: ${user.course}'),
                          Text('Section: ${user.section}'),
                          Text('Birthday: ${user.birthday}'),
                          Text('Sex: ${user.sex}'),
                          Text('Email: ${user.email}'),
                          Text('CP Number: ${user.cpNumber}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(user);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => deleteUser(user.id),
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
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

    // Create user
  void createUser(String name, String course, String section, String birthday,
      String sex, String email, String cpNumber) async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': name,
        'course': course,
        'section': section,
        'birthday': birthday,
        'sex': sex,
        'email': email,
        'cpNumber': cpNumber,
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student registered successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating, // Makes it float above content
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      logger.e("Error adding user: $e");
      
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering student'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Get users
  Stream<List<User>> getUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return User.fromFirestore(doc);
      }).toList();
    });
  }

  final logger = Logger();

  // Delete user
  void deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    } catch (e) {
      logger.e("Error deleting user: $e");
    }
  }

  // In the HomeScreen class, add this method to check for existing email
  Future<bool> isEmailRegistered(String email) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return result.docs.isNotEmpty;
  }

  // Add this method to your _HomeScreenState class to handle user updates
  void updateUser(String userId, String name, String course, String section, String birthday,
                  String sex, String email, String cpNumber) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': name,
        'course': course,
        'section': section,
        'birthday': birthday,
        'sex': sex,
        'email': email,
        'cpNumber': cpNumber,
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student information updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error updating user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating student information'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add this method to show the edit dialog
  void _showEditDialog(User user) {
    // Create controllers with existing user data
    final TextEditingController nameController = TextEditingController(text: user.name);
    final TextEditingController courseController = TextEditingController(text: user.course);
    final TextEditingController sectionController = TextEditingController(text: user.section);
    final TextEditingController birthdayController = TextEditingController(text: user.birthday);
    final TextEditingController sexController = TextEditingController(text: user.sex);
    final TextEditingController emailController = TextEditingController(text: user.email);
    final TextEditingController cpNumberController = TextEditingController(text: user.cpNumber);
    
    // Form key for validation
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Student Information'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: _buildInputDecoration('Full Name', Icons.person),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Name is required';
                    if (value!.length < 2) return 'Name must be at least 2 characters';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _buildInputDecoration('Course', Icons.school),
                  value: user.course.isEmpty ? null : user.course,
                  items: ['BSIT', 'BSCS', 'BSIS'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => courseController.text = val ?? '',
                  validator: (value) => value == null ? 'Please select a course' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: sectionController,
                  decoration: _buildInputDecoration('Section', Icons.group),
                  validator: (value) => value?.isEmpty ?? true ? 'Section is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: birthdayController,
                  decoration: _buildInputDecoration('Birthday', Icons.cake),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(user.birthday) ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      birthdayController.text = DateFormat('yyyy-MM-dd').format(date);
                    }
                  },
                  validator: (value) => value?.isEmpty ?? true ? 'Birthday is required' : null,
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: _buildInputDecoration('Sex', Icons.person_outline),
                  value: user.sex.isEmpty ? null : user.sex,
                  items: ['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) => sexController.text = val ?? '',
                  validator: (value) => value == null ? 'Please select sex' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: _buildInputDecoration('Email Address', Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: cpNumberController,
                  decoration: _buildInputDecoration('Contact Number', Icons.phone),
                  keyboardType: TextInputType.phone,
                  maxLength: 13,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Contact number is required';
                    if (value!.length < 10) return 'Contact number must be at least 10 digits';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                // Check if email is already registered (but skip the current user's email)
                if (emailController.text != user.email) {
                  bool emailExists = await isEmailRegistered(emailController.text);
                  if (emailExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('This email is already registered'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }
                
                // Update user
                updateUser(
                  user.id,
                  nameController.text,
                  courseController.text,
                  sectionController.text,
                  birthdayController.text,
                  sexController.text,
                  emailController.text,
                  cpNumberController.text,
                );
                
                Navigator.of(context).pop();
              }
            },
            child: Text('Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
