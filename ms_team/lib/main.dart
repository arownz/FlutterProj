import 'package:flutter/material.dart';

void main() {
  runApp(const MSTeamsDashboard());
}

class MSTeamsDashboard extends StatelessWidget {
  const MSTeamsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.group, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Teams',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: const Row(
          children: [
            // Left Fixed Navigation Menu
            FixedLeftNav(),
            Expanded(
              child: DashboardBody(),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }
}

// Left Fixed Navigation Menu
class FixedLeftNav extends StatelessWidget {
  const FixedLeftNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.white,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 16), // Top margin
          NavItem(icon: Icons.group, label: 'Teams', isSelected: true),
          NavItem(icon: Icons.notifications_none, label: 'Activity'),
          NavItem(icon: Icons.chat_bubble_outline, label: 'Chat'),
          NavItem(icon: Icons.assignment_outlined, label: 'Assignments'),
          NavItem(icon: Icons.calendar_today_outlined, label: 'Calendar'),
          NavItem(icon: Icons.call, label: 'Calls'),
          NavItem(icon: Icons.cloud_outlined, label: 'OneDrive'),
          NavItem(icon: Icons.group_work_outlined, label: 'Viva Engage'),
          NavItem(icon: Icons.more_horiz, label: 'More'),
          Spacer(),
          NavItem(icon: Icons.apps, label: 'Apps'),
          SizedBox(height: 16), // Bottom margin
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const NavItem({super.key, 
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// Dashboard body content
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Classes',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: 5,
              itemBuilder: (context, index) {
                return TeamCard(index: index);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Teams',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for individual team cards
class TeamCard extends StatelessWidget {
  final int index;

  const TeamCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      "JCB_CTMOBPG1_INF221",
      "JCB_CTMOBPG1_INF223",
      "JCB_CTSYSIN_INF221",
      "JCB_CCPROG11_COM242",
      "JCB_CTMOBPG1_INF222",
    ];

    final List<String> images = [
      "web/class_icon1.png",
      "assets/class_icon2.png",
      "assets/class_icon3.png",
      "assets/class_icon4.png",
      "assets/class_icon5.png",
    ];

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            images[index],
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              titles[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
