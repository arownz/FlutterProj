// Import Flutter packages
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
            // New Join or Create Team Button
            // Popup Menu with Horizontal Icon
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz, color: Colors.black),
              onSelected: (value) {
                if (value == 'settings') {
                  // Action for settings
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Your teams and channels'),
                      ],
                    ),
                  ),
                ];
              },
            ),
                        TextButton.icon(
              onPressed: () {
                // Action for join or create team
              },
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'Join or create team',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        body: const Row(
          children: [
            LeftNavBar(),
            Expanded(child: DashboardBody()),
          ],
        ),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }
}

class LeftNavBar extends StatefulWidget {
  const LeftNavBar({super.key});

  @override
  State<LeftNavBar> createState() => _LeftNavBarState();
}

class _LeftNavBarState extends State<LeftNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          NavItem(icon: Icons.group, label: 'Teams', isSelected: _selectedIndex == 0, onTap: () => _onItemTapped(0)),
          NavItem(icon: Icons.notifications_none, label: 'Activity', isSelected: _selectedIndex == 1, onTap: () => _onItemTapped(1)),
          NavItem(icon: Icons.chat_bubble_outline, label: 'Chat', isSelected: _selectedIndex == 2, onTap: () => _onItemTapped(2)),
          NavItem(icon: Icons.assignment_outlined, label: 'Assignments', isSelected: _selectedIndex == 3, onTap: () => _onItemTapped(3)),
          NavItem(icon: Icons.calendar_today_outlined, label: 'Calendar', isSelected: _selectedIndex == 4, onTap: () => _onItemTapped(4)),
          NavItem(icon: Icons.call, label: 'Calls', isSelected: _selectedIndex == 5, onTap: () => _onItemTapped(5)),
          NavItem(icon: Icons.cloud_outlined, label: 'OneDrive', isSelected: _selectedIndex == 6, onTap: () => _onItemTapped(6)),
          NavItem(icon: Icons.group_work_outlined, label: 'Viva Engage', isSelected: _selectedIndex == 7, onTap: () => _onItemTapped(7)),
          NavItem(icon: Icons.more_horiz, label: 'More', isSelected: _selectedIndex == 8, onTap: () => _onItemTapped(8)),
          const Spacer(),
          NavItem(icon: Icons.apps, label: 'Apps', isSelected: _selectedIndex == 9, onTap: () => _onItemTapped(9)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here
    print('Tapped on item $index');
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
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
      ),
    );
  }
}


// Body for the dashboard layout
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
            const SizedBox(height: 5),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: 5, // Number of tiles on the screen
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Action for tapping the card
                  },
                  child: TeamCard(index: index),
                );
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

// Widget to create individual team cards
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
      "assets/class_icon1.png",
      "assets/class_icon2.png",
      "assets/class_icon3.png",
      "assets/class_icon4.png",
      "assets/class_icon5.png",
    ];

    return GestureDetector(
      onTap: () {
        // Action when clicking on the card
      },
      child: Card(
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
      ),
    );
  }
}
