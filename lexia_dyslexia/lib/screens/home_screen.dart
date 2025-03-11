import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import 'profile/user_profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/interactive_feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedIn = authService.isSignedIn;
    final userRole = authService.userRole;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1100;
    final isTablet = screenWidth > 650 && screenWidth <= 1100;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lexia - Dyslexia'),
        actions: [
          if (!isLoggedIn) ...[
            if (isDesktop || isTablet) ...[
              TextButton(
                onPressed: () => context.push('/login'),
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => context.push('/register'),
                child: const Text('Register', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.login),
                onPressed: () => context.push('/login'),
                tooltip: 'Login',
              ),
            ]
          ] else ...[
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                // Show user profile options
                showUserProfileMenu(context, authService);
              },
              tooltip: 'Profile',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => authService.signOut(),
              tooltip: 'Logout',
            ),
            const SizedBox(width: 8),
          ]
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 650) {
            // Desktop/Tablet Layout
            return _buildDesktopLayout(context, isLoggedIn, userRole, constraints.maxWidth);
          } else {
            // Mobile Layout
            return _buildMobileLayout(context, isLoggedIn, userRole);
          }
        },
      ),
    );
  }
  
  // Desktop/Tablet Layout
  Widget _buildDesktopLayout(BuildContext context, bool isLoggedIn, UserRole? userRole, double width) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                SizedBox(
                  height: 400,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to Lexia',
                              style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'A supportive community platform for parents, teachers, and children managing dyslexia through our interactive Pokémon-style game.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 32),
                            if (!isLoggedIn)
                              ElevatedButton(
                                onPressed: () => context.push('/register'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('Join the Community'),
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Image placeholder - you'll need to add an actual image asset
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(Icons.games, size: 120, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Features Section
                Center(
                  child: Text(
                    'Features',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Three feature cards in a row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: 'Community Forum',
                        description: 'Connect with parents, teachers, and experts to share experiences and get advice.',
                        icon: Icons.forum,
                        onTap: () => context.push('/forum'),
                        color: Colors.blue.shade100,
                        isLocked: !isLoggedIn,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: 'Parental Monitoring',
                        description: 'Track your child\'s progress in the Lexia game and see their improvement over time.',
                        icon: Icons.insights,
                        onTap: () => context.push('/parent-dashboard'),
                        color: Colors.green.shade100,
                        isLocked: !isLoggedIn || (userRole != UserRole.parent && userRole != UserRole.admin),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildFeatureCard(
                        context,
                        title: 'Teacher Dashboard',
                        description: 'Monitor multiple students and their progress with the Lexia game.',
                        icon: Icons.school,
                        onTap: () => context.push('/teacher-dashboard'),
                        color: Colors.purple.shade100,
                        isLocked: !isLoggedIn || (userRole != UserRole.teacher && userRole != UserRole.admin),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 80),
                
                // About Section
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        Text(
                          'About Lexia',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Lexia is a Capybara Go!-style game designed specifically for children with dyslexia. '
                          'Our game incorporates cutting-edge technologies to provide an engaging and '
                          'effective learning experience for dyslexia person.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // Footer
                const Divider(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('© 2025 Lexia - Dyslexia'),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Privacy Policy'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Terms of Service'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Contact Us'),
                        ),
                        IconButton(
                          onPressed: () => _launchUrl('https://github.com/arownz/FlutterProj'),
                          icon: const Icon(Icons.code),
                          tooltip: 'GitHub Repository',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Mobile Layout
  Widget _buildMobileLayout(BuildContext context, bool isLoggedIn, UserRole? userRole) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Lexia',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'A supportive community for dyslexia management',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  // Continue fixing the rest of the mobile layout...
                  // Image placeholder
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.games, size: 80, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isLoggedIn)
                    Center(
                      child: ElevatedButton(
                        onPressed: () => context.push('/register'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Join the Community'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Features Section
            Center(
              child: Text(
                'Features',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildFeatureCard(
              context,
              title: 'Community Forum',
              description: 'Connect with parents, teachers, and experts to share experiences and get advice.',
              icon: Icons.forum,
              onTap: () => context.push('/forum'),
              color: Colors.blue.shade100,
              isLocked: !isLoggedIn,
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Parental Monitoring',
              description: 'Track your child\'s progress in the Lexia game and see their improvement over time.',
              icon: Icons.insights,
              onTap: () => context.push('/parent-dashboard'),
              color: Colors.green.shade100,
              isLocked: !isLoggedIn || (userRole != UserRole.parent && userRole != UserRole.admin),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              title: 'Teacher Dashboard',
              description: 'Monitor multiple students and their progress with the Lexia game.',
              icon: Icons.school,
              onTap: () => context.push('/teacher-dashboard'),
              color: Colors.purple.shade100,
              isLocked: !isLoggedIn || (userRole != UserRole.teacher && userRole != UserRole.admin),
            ),
            const SizedBox(height: 40),
            
            // About Section
            Center(
              child: Text(
                'About Lexia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Lexia is a Pokémon-style game designed specifically for children with dyslexia. '
              'Our game incorporates cutting-edge technologies like Google Digital Ink Recognition for '
              'spelling practice, Text-to-Speech, Speech-to-Text, and NLP to provide an engaging and '
              'effective learning experience.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Mobile Footer
            const Divider(),
            const SizedBox(height: 16),
            const Center(
              child: Text('© 2025 Lexia - Dyslexia'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text('Privacy'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Terms'),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Contact'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            IconButton(
              onPressed: () => _launchUrl('https://github.com/arownz/FlutterProj'),
              icon: const Icon(Icons.code),
              tooltip: 'GitHub Repository',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isLocked = false,
  }) {
    // Get theme colors
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.primary;
    
    // Define hover colors based on the base color
    final hoverColor = color.withValues(alpha: 0.7);
    
    return InteractiveFeatureCard(
      title: title,
      description: description,
      icon: icon,
      onTap: onTap,
      baseColor: color,
      iconColor: iconColor,
      hoverColor: hoverColor,
      isLocked: isLocked,
      onLockTap: () => _showLoginDialog(context),
    );
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to be logged in to access this feature. Would you like to log in or register now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/register');
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  void showUserProfileMenu(BuildContext context, AuthService authService) {
    final role = authService.userRole;
    String roleText = 'User';
    
    switch (role) {
      case UserRole.child:
        roleText = 'Child Account';
        break;
      case UserRole.parent:
        roleText = 'Parent';
        break;
      case UserRole.teacher:
        roleText = 'Teacher';
        break;
      case UserRole.admin:
        roleText = 'Administrator';
        break;
      default:
        roleText = 'User';
    }
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Profile Options'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, ${authService.user?.displayName ?? 'User'}'),
                Text('Email: ${authService.user?.email ?? 'Not available'}'),
                Text('Role: $roleText'),
                const SizedBox(height: 16),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
            child: const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Account Settings'),
            ),
          ),
          if (role == UserRole.parent)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                context.push('/parent-dashboard');
              },
              child: const ListTile(
                leading: Icon(Icons.dashboard),
                title: Text('Parent Dashboard'),
              ),
            ),
          if (role == UserRole.teacher)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                context.push('/teacher-dashboard');
              },
              child: const ListTile(
                leading: Icon(Icons.school),
                title: Text('Teacher Dashboard'),
              ),
            ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              authService.signOut();
            },
            child: const ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}