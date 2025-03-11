import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'child_progress_detail.dart';
import 'add_child_screen.dart';
import '../../widgets/hover_effect_card.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  List<UserProfile> _children = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);
      final userId = authService.user!.uid;

      final children = await userService.getChildrenForParent(userId);

      setState(() {
        _children = children;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading children: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChildren,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddChildScreen(),
            ),
          ).then((_) => _loadChildren());
        },
        tooltip: 'Add Child Account',
        child: const Icon(Icons.add),
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
            onPressed: _loadChildren,
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
            'Your Children',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your children\'s progress in the Lexia game',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _children.isEmpty
                ? _buildNoChildrenView()
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      return _buildChildCard(_children[index]);
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
            'Your Children',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your children\'s progress in the Lexia game',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _children.isEmpty
                ? _buildNoChildrenView()
                : ListView.builder(
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildChildCard(_children[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChildrenView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.child_care,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'No Children Added Yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text(
            'Add your child to start monitoring their progress in Lexia',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddChildScreen(),
                ),
              ).then((_) => _loadChildren());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Child'),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard(UserProfile child) {
    return HoverEffectCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChildProgressDetail(childId: child.id),
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  radius: 24,
                  child: Text(
                    child.name.isNotEmpty ? child.name[0].toUpperCase() : '?',
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
                        child.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<GameProgress?>(
                        future: Provider.of<UserService>(context, listen: false)
                            .getGameProgressForChild(child.id),
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
                  .getGameProgressForChild(child.id),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChildProgressDetail(childId: child.id),
                    ),
                  );
                },
                icon: const Icon(Icons.analytics),
                label: const Text('View Details'),
              ),
            ),
          ],
        ),
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
