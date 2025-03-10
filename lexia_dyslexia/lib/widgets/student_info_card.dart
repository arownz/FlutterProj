import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';

class StudentInfoCard extends StatelessWidget {
  final UserProfile student;
  final VoidCallback onViewDetails;
  final VoidCallback? onUnlink;

  const StudentInfoCard({
    super.key,
    required this.student,
    required this.onViewDetails,
    this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewDetails,
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
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.analytics),
                    label: const Text('Details'),
                  ),
                  if (onUnlink != null)
                    IconButton(
                      icon: const Icon(Icons.link_off),
                      onPressed: onUnlink,
                      tooltip: 'Unlink student',
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
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
