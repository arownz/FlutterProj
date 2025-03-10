import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class LinkStudentScreen extends StatefulWidget {
  const LinkStudentScreen({super.key});

  @override
  State<LinkStudentScreen> createState() => _LinkStudentScreenState();
}

class _LinkStudentScreenState extends State<LinkStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Student'),
      ),
      body: Center(
        child: Container(
          width: isDesktop ? 600 : double.infinity,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Link a Student',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Link an existing student to your teacher dashboard to monitor their progress.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _studentIdController,
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        hintText: 'Enter student\'s unique ID',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a student ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ask parents for their child\'s unique ID from the parent dashboard.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 32),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        width: double.infinity,
                        color: Colors.red.shade100,
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Link Student'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ExpansionTile(
                title: const Text('About Student Linking'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoSection(
                          title: 'Finding the Student ID',
                          content: 'Parents can find their child\'s unique ID in the parent dashboard under their child\'s profile.',
                          icon: Icons.badge,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          title: 'Privacy',
                          content: 'Linking a student gives you access to view their progress data, but you won\'t have access to any personal information.',
                          icon: Icons.privacy_tip,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoSection(
                          title: 'Removing a Student',
                          content: 'You can unlink a student at any time from your teacher dashboard.',
                          icon: Icons.link_off,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Icon(icon, color: Colors.purple.shade800),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(content),
            ],
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);
      
      // Get teacher's ID
      final teacherId = authService.user!.uid;
      
      // Student ID from form
      final studentId = _studentIdController.text.trim();
      
      // Validate if student exists
      final student = await userService.getUserProfile(studentId);
      
      if (student == null) {
        setState(() {
          _isSubmitting = false;
          _error = 'Student ID not found. Please verify the ID and try again.';
        });
        return;
      }
      
      if (student.role != 'child') {
        setState(() {
          _isSubmitting = false;
          _error = 'The provided ID does not belong to a student account.';
        });
        return;
      }
      
      // Check if student is already linked to this teacher
      final currentStudents = await userService.getStudentsForTeacher(teacherId);
      if (currentStudents.any((s) => s.id == studentId)) {
        setState(() {
          _isSubmitting = false;
          _error = 'This student is already linked to your account.';
        });
        return;
      }
      
      // Link student to teacher
      final success = await userService.linkChildToTeacher(studentId, teacherId);
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.name} has been linked to your dashboard'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _isSubmitting = false;
          _error = userService.error ?? 'Failed to link student. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _error = 'Error: ${e.toString()}';
      });
    }
  }
}
