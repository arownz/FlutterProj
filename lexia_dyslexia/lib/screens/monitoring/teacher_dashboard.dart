import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'child_progress_detail.dart';
import 'link_student_screen.dart';
import '../../widgets/hover_effect_card.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  List<UserProfile> _students = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = authService.user!.uid;

      final students = await userService.getStudentsForTeacher(userId);

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading students: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : isDesktop
                  ? _buildDesktopLayout()
                  : _buildMobileLayout(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LinkStudentScreen(),
            ),
          ).then((_) => _loadStudents());
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Link Student'),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadStudents,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Students',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your students\' progress in the Lexia game',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          _buildClassSummary(),
          const SizedBox(height: 32),
          Expanded(
            child: _students.isEmpty
                ? _buildNoStudentsView()
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      return _buildStudentCard(_students[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Students',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your students\' progress in the Lexia game',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _buildClassSummary(),
          const SizedBox(height: 24),
          Expanded(
            child: _students.isEmpty
                ? _buildNoStudentsView()
                : ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildStudentCard(_students[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSummary() {
    // A summary card showing stats about the entire class
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Class Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  title: 'Students',
                  value: _students.length.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _buildSummaryItem(
                  title: 'Avg. Level',
                  value: '3.2',  // In a real app, calculate this from student data
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                _buildSummaryItem(
                  title: 'Active Today',
                  value: '5',    // In a real app, calculate this from student data
                  icon: Icons.date_range,
                  color: Colors.orange,
                ),
                _buildSummaryItem(
                  title: 'Need Attention',
                  value: '2',    // In a real app, calculate this from student data
                  icon: Icons.warning_amber,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Latest class activity: Yesterday at 3:45 PM'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color..withValues(alpha: .2),
          radius: 24,
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNoStudentsView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.school,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Students Linked Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            'Link your first student to start monitoring their progress in Lexia',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LinkStudentScreen(),
                ),
              ).then((_) => _loadStudents());
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Link Student'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(UserProfile student) {
    return HoverEffectCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildProgressDetail(childId: student.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  radius: 24,
                  child: Text(
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<GameProgress?>(
                        future: Provider.of<UserService>(context, listen: false)
                            .getGameProgressForChild(student.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text('Loading progress...');
                          }

                          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                            return const Text('No game activity yet');
                          }

                          final progress = snapshot.data!;
                          return Text(
                            'Level ${progress.level} • Last active: ${DateFormat.MMMd().format(progress.lastActivity)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<GameProgress?>(
              future: Provider.of<UserService>(context, listen: false)
                  .getGameProgressForChild(student.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Text('No progress data available');
                }

                final progress = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Overall Progress:'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.accuracyRate / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: _getColorForAccuracy(progress.accuracyRate),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Score: ${progress.score}'),
                        Text('${progress.accuracyRate.toStringAsFixed(1)}%'),
                      ],
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChildProgressDetail(childId: student.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Details'),
                ),
                _buildUnlinkButton(student)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlinkButton(UserProfile student) {
    return IconButton(
      icon: const Icon(Icons.link_off),
      onPressed: () => _confirmUnlinkStudent(student),
      tooltip: 'Unlink student',
      color: Colors.red,
    );
  }

  void _confirmUnlinkStudent(UserProfile student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Student'),
        content: Text(
          'Are you sure you want to unlink ${student.name} from your dashboard? '
          'This will remove access to their progress data but won\'t delete their account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Capture ScaffoldMessengerState before the async gap
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              
              final authService = Provider.of<AuthService>(context, listen: false);
              final userService = Provider.of<UserService>(context, listen: false);
              
              try {
                await userService.unlinkChildFromTeacher(
                  student.id,
                  authService.user!.uid,
                );
                
                if (mounted) {
                  _loadStudents(); // Refresh the list
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('${student.name} has been unlinked'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error unlinking student: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }

  Color _getColorForAccuracy(double accuracy) {
    if (accuracy < 40) {
      return Colors.red;
    } else if (accuracy < 70) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
