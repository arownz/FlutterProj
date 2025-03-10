import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/user_service.dart';

class ChildProgressDetail extends StatefulWidget {
  final String childId;

  const ChildProgressDetail({super.key, required this.childId});

  @override
  State<ChildProgressDetail> createState() => _ChildProgressDetailState();
}

class _ChildProgressDetailState extends State<ChildProgressDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserProfile? _child;
  GameProgress? _gameProgress;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChildData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChildData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final child = await userService.getUserProfile(widget.childId);
      final progress =
          await userService.getGameProgressForChild(widget.childId);

      setState(() {
        _child = child;
        _gameProgress = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading child data: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(_child?.name ?? 'Child Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChildData,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Skills'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(isDesktop),
                    _buildSkillsTab(isDesktop),
                    _buildHistoryTab(isDesktop),
                  ],
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
            onPressed: _loadChildData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDesktop) {
    if (_gameProgress == null) {
      return const Center(
        child: Text('No game progress data available yet.'),
      );
    }

    final progress = _gameProgress!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  isDesktop
                      ? Row(
                          children: [
                            _buildProgressStatCard(
                              'Current Level',
                              '${progress.level}',
                              Icons.trending_up,
                              Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            _buildProgressStatCard(
                              'Total Score',
                              '${progress.score}',
                              Icons.stars,
                              Colors.amber,
                            ),
                            const SizedBox(width: 16),
                            _buildProgressStatCard(
                              'Accuracy Rate',
                              '${progress.accuracyRate.toStringAsFixed(1)}%',
                              Icons.check_circle,
                              _getColorForAccuracy(progress.accuracyRate),
                            ),
                            const SizedBox(width: 16),
                            _buildProgressStatCard(
                              'Challenges Completed',
                              '${progress.completedChallenges}',
                              Icons.emoji_events,
                              Colors.purple,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildProgressStatCard(
                              'Current Level',
                              '${progress.level}',
                              Icons.trending_up,
                              Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressStatCard(
                              'Total Score',
                              '${progress.score}',
                              Icons.stars,
                              Colors.amber,
                            ),
                            const SizedBox(height: 16),
                            _buildProgressStatCard(
                              'Accuracy Rate',
                              '${progress.accuracyRate.toStringAsFixed(1)}%',
                              Icons.check_circle,
                              _getColorForAccuracy(progress.accuracyRate),
                            ),
                            const SizedBox(height: 16),
                            _buildProgressStatCard(
                              'Challenges Completed',
                              '${progress.completedChallenges}',
                              Icons.emoji_events,
                              Colors.purple,
                            ),
                          ],
                        ),
                  const SizedBox(height: 24),
                  Text(
                    'Last Active: ${DateFormat.yMMMMd().add_jm().format(progress.lastActivity)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity Snapshot',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const Text('The chart will be displayed here...'),
                  // In a real app, you would implement a chart here using fl_chart or similar package
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('Chart Placeholder'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommendations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendation(
                    'Encourage Regular Practice',
                    'Based on activity patterns, try to schedule regular 15-minute sessions.',
                    Icons.timer,
                  ),
                  _buildRecommendation(
                    'Focus on Spelling Exercises',
                    'Your child shows room for improvement in spelling challenges.',
                    Icons.spellcheck,
                  ),
                  _buildRecommendation(
                    'Celebrate Recent Progress',
                    'Your child has improved their reading fluency by 15% this month!',
                    Icons.celebration,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(bool isDesktop) {
    if (_gameProgress == null) {
      return const Center(
        child: Text('No skills data available yet.'),
      );
    }

    final skills = _gameProgress!.skillsProgress;
    final skillsList = skills.entries.toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills Breakdown',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Track your child\'s progress across different reading and spelling skills',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          skillsList.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_stories,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No skill data available yet. Your child will start developing skills as they play the game.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 3 : 1,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: skillsList.length,
                  itemBuilder: (context, index) {
                    final skill = skillsList[index];
                    final skillName = skill.key;
                    final skillData = skill.value as Map<String, dynamic>;
                    final level = skillData['level'] ?? 1;
                    final progress = (skillData['progress'] ?? 0.0) * 100;

                    return _buildSkillCard(
                      title: _formatSkillName(skillName),
                      level: level,
                      progress: progress.toDouble(),
                      icon: _getIconForSkill(skillName),
                      color: _getColorForSkill(skillName),
                    );
                  },
                ),

          const SizedBox(height: 24),

          // Skill recommendations
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skill Recommendations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // Show recommendations based on the skills data
                  _buildSkillRecommendation(
                    'Continue with Phonetic Awareness',
                    'Your child is doing well in phonetic recognition. Encourage more practice with complex sounds.',
                    Icons.trending_up,
                  ),
                  _buildSkillRecommendation(
                    'Focus on Word Recognition',
                    'This skill needs more practice. Try the word recognition exercises in the game.',
                    Icons.warning_amber,
                  ),
                  _buildSkillRecommendation(
                    'Celebrate Reading Fluency Progress',
                    'Your child has made significant improvement in reading fluency!',
                    Icons.celebration,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity History',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Track your child\'s engagement over time',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Calendar heatmap would go here in a real app
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text('Activity Calendar Heatmap'),
                const SizedBox(height: 8),
                const Text(
                  'A visualization of play frequency would appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent sessions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Sessions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Sample session data - in a real app, this would come from the database
                  _buildSessionRow(
                    date: DateTime.now().subtract(const Duration(days: 1)),
                    duration: '15 minutes',
                    score: 240,
                    modules: ['Spelling', 'Word Recognition'],
                  ),
                  const Divider(),
                  _buildSessionRow(
                    date: DateTime.now().subtract(const Duration(days: 3)),
                    duration: '22 minutes',
                    score: 320,
                    modules: ['Reading Fluency', 'Phonetics'],
                  ),
                  const Divider(),
                  _buildSessionRow(
                    date: DateTime.now().subtract(const Duration(days: 5)),
                    duration: '18 minutes',
                    score: 280,
                    modules: ['Spelling', 'Phonetics'],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Progress over time
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress Over Time',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Placeholder for progress chart
                  Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text('Progress Line Chart'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The chart shows improvement in accuracy and completion time over the last 30 days.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendation(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue.shade700),
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
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard({
    required String title,
    required int level,
    required double progress,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Level $level',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.shade200,
                color: color,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text('${progress.toStringAsFixed(1)}% Mastery'),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillRecommendation(
      String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: icon == Icons.warning_amber
              ? Colors.amber.shade100
              : (icon == Icons.celebration
                  ? Colors.green.shade100
                  : Colors.blue.shade100),
          child: Icon(
            icon,
            color: icon == Icons.warning_amber
                ? Colors.amber.shade800
                : (icon == Icons.celebration
                    ? Colors.green.shade800
                    : Colors.blue.shade800),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(description),
        ),
      ),
    );
  }

  Widget _buildSessionRow({
    required DateTime date,
    required String duration,
    required int score,
    required List<String> modules,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMd().format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(DateFormat.jm().format(date)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(duration),
          ),
          Expanded(
            flex: 1,
            child: Text(
              score.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: score > 300 ? Colors.green : Colors.blue,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 4,
              children: modules.map((module) {
                return Chip(
                  label: Text(
                    module,
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  backgroundColor: _getModuleColor(module),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSkillName(String skillName) {
    // Convert camelCase or snake_case to Title Case with spaces
    String result = skillName.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => ' ${match.group(0)}',
    );
    result = result.replaceAll('_', ' ');
    return result
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  IconData _getIconForSkill(String skillName) {
    final skill = skillName.toLowerCase();
    if (skill.contains('phon')) {
      return Icons.hearing;
    } else if (skill.contains('read') || skill.contains('fluency')) {
      return Icons.menu_book;
    } else if (skill.contains('spell')) {
      return Icons.spellcheck;
    } else if (skill.contains('word') || skill.contains('vocab')) {
      return Icons.text_fields;
    } else if (skill.contains('grammar')) {
      return Icons.text_format;
    }
    return Icons.psychology; // Default icon for cognitive skills
  }

  Color _getColorForSkill(String skillName) {
    final skill = skillName.toLowerCase();
    if (skill.contains('phon')) {
      return Colors.purple;
    } else if (skill.contains('read') || skill.contains('fluency')) {
      return Colors.blue;
    } else if (skill.contains('spell')) {
      return Colors.green;
    } else if (skill.contains('word') || skill.contains('vocab')) {
      return Colors.orange;
    } else if (skill.contains('grammar')) {
      return Colors.brown;
    }
    return Colors.teal; // Default color
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

  Color _getModuleColor(String module) {
    switch (module.toLowerCase()) {
      case 'spelling':
        return Colors.green.shade100;
      case 'phonetics':
        return Colors.purple.shade100;
      case 'reading fluency':
        return Colors.blue.shade100;
      case 'word recognition':
        return Colors.orange.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}
