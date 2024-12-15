// Import Flutter packages
import 'package:flutter/foundation.dart';
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
        backgroundColor: Colors.grey.shade200,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LeftNavBar(),
            Expanded(
              child: Column(
                children: [
                  Header(),
                  Expanded(child: DashboardBody()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// LEFT NAVIGATION MENU
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
        children: [
          const SizedBox(height: 16),
          _buildNavItem(icon: Icons.group, label: "Teams", index: 0),
          _buildNavItem(
              icon: Icons.notifications_none, label: "Activity", index: 1),
          _buildNavItem(
              icon: Icons.chat_bubble_outline, label: "Chat", index: 2),
          _buildNavItem(
              icon: Icons.assignment_outlined, label: "Assignments", index: 3),
          _buildNavItem(
              icon: Icons.calendar_today_outlined, label: "Calendar", index: 4),
          _buildNavItem(icon: Icons.phone, label: "Phone", index: 5),
          _buildNavItem(icon: Icons.cloud_outlined, label: "One Drive", index: 6),
          _buildNavItem(
              icon: Icons.people_outline, label: "Viva Engage", index: 7),
          _buildNavItem(icon: Icons.more_horiz, label: "More", index: 8),
          const Spacer(),
          _buildNavItem(icon: Icons.apps, label: "Apps", index: 9),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      hoverColor: Colors.blue.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Icon(icon,
                color: _selectedIndex == index ? Colors.blue : Colors.grey,
                size: 28),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  color: _selectedIndex == index ? Colors.blue : Colors.grey,
                )),
          ],
        ),
      ),
    );
  }
}

// HEADER BAR
class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.group, color: Colors.blue),
          SizedBox(width: 8),
          Text(
            "Teams",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Spacer(),
          IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.black),
              onPressed: () {}),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.person_add, color: Colors.black),
              label: Text(
                'Join or create team',
                style: TextStyle(color: Colors.black),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// BODY WITH CARDS
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(50.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                if (kDebugMode) {
                  print('Classes button clicked');
                }
              },
              icon: const Icon(
                Icons.arrow_drop_down_sharp,
                color: Colors.black,
              ),
              label: const Text(
                'Classes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 15),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = (constraints.maxWidth / 340).floor();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 0.25,
                    mainAxisSpacing: 25,
                    childAspectRatio: 1.6,
                  ),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return TeamCard(index: index);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                if (kDebugMode) {
                  print('Teams button clicked');
                }
              },
              icon: const Icon(
                Icons.keyboard_arrow_right_sharp,
                color: Colors.black,
              ),
              label: const Text(
                'Teams',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CARDS FOR TEAMS
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
      "assets/mobile-removebg-preview.png",
      "assets/mobile-removebg-preview.png",
      "assets/a_logo_of_machine_learning_inside_the_computer-removebg-preview.png",
      "assets/dasdadsa-removebg-preview.png",
      "assets/mobile-removebg-preview.png",
    ];

    return InkWell(
      onTap: () {
        if (kDebugMode) {
          print('Card ${index + 1} clicked');
        }
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Text(
                            titles[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: constraints.maxWidth < 150 ? 14 : 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_horiz, size: 24),
                      onPressed: () {
                        if (kDebugMode) {
                          print('More options for card ${index + 1}');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.note, size: 24, color: Colors.grey[600]),
                    onPressed: () {
                      if (kDebugMode) {
                        print('Note icon clicked for card ${index + 1}');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.work, size: 24, color: Colors.grey[600]),
                    onPressed: () {
                      if (kDebugMode) {
                        print('Work icon clicked for card ${index + 1}');
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.book, size: 24, color: Colors.grey[600]),
                    onPressed: () {
                      if (kDebugMode) {
                        print('Book icon clicked for card ${index + 1}');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



