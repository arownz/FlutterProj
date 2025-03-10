import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isSaving = false;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    
    if (authService.user != null) {
      final profile = await userService.getUserProfile(authService.user!.uid);
      if (profile != null && mounted) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.name;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);
      
      if (authService.user != null) {
        final success = await userService.updateUserProfile(
          authService.user!.uid, 
          _nameController.text.trim(),
          null, // Not updating photo URL
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          setState(() {
            _isEditing = false;
            if (_profile != null) {
              _profile = UserProfile(
                id: _profile!.id,
                name: _nameController.text.trim(),
                email: _profile!.email,
                role: _profile!.role,
                photoUrl: _profile!.photoUrl,
                createdAt: _profile!.createdAt,
                studentIds: _profile!.studentIds,
                parentId: _profile!.parentId,
              );
            }
          });
        } else {
          // Show error if update failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(userService.error ?? 'Failed to update profile'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getRoleDisplayText(String role) {
    switch (role) {
      case 'parent':
        return 'Parent';
      case 'teacher':
        return 'Teacher';
      case 'child':
        return 'Child Account';
      case 'admin':
        return 'Administrator';
      default:
        return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Profile',
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isEditing = false),
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: isDesktop ? 800 : double.infinity,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile avatar
                CircleAvatar(
                  radius: 64,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _profile!.name.isNotEmpty ? _profile!.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Profile form or info
                _isEditing
                  ? Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 50),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save Changes'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          _profile!.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          _getRoleDisplayText(_profile!.role),
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: _getRoleColor(_profile!.role),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: const Text('Email'),
                                  subtitle: Text(_profile!.email.isEmpty ? 'Not available' : _profile!.email),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.calendar_today),
                                  title: const Text('Member Since'),
                                  subtitle: Text(
                                    '${_profile!.createdAt.day}/${_profile!.createdAt.month}/${_profile!.createdAt.year}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                
                const SizedBox(height: 48),
                
                // Account actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Actions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.lock),
                          title: const Text('Change Password'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showChangePasswordDialog(context),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(Icons.logout, color: Colors.red.shade300),
                          title: Text('Log Out', style: TextStyle(color: Colors.red.shade300)),
                          onTap: () => authService.signOut(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'parent':
        return Colors.green;
      case 'teacher':
        return Colors.purple;
      case 'child':
        return Colors.orange;
      case 'admin':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'A password reset link will be sent to your email address.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authService = Provider.of<AuthService>(context, listen: false);
              // Capture ScaffoldMessenger before async gap
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              if (_profile?.email != null && _profile!.email.isNotEmpty) {
                final success = await authService.resetPassword(_profile!.email);
                
                if (success && mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent. Please check your inbox.'),
                    ),
                  );
                } else if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(authService.error ?? 'Failed to send reset email'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
