import 'package:flutter/material.dart';
import 'screens/registration_screen.dart';
import 'screens/student_list_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Registry',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const RegistrationScreen(),
    const StudentListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Student Registration' : 'Student List'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('assets/nulogo.png'),
                  fit: BoxFit.contain,
                ),
              ),
              child: Text(
                'Student Registration',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.app_registration,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey,
              ),
              title: Text(
                'Registration',
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.blue : Colors.black,
                  fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.list,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey,
              ),
              title: Text(
                'Student List',
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.blue : Colors.black,
                  fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            activeIcon: Icon(Icons.app_registration_rounded),
            label: 'Registration',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            activeIcon: Icon(Icons.list_rounded),
            label: 'List',
          ),
        ],
      ),
    );
  }
}
