import 'package:flutter/material.dart';
import 'package:postopcare/widgets/calendar.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/screens/auth_screen.dart'; // Importă AuthScreen pentru logout

class MainScreen extends StatelessWidget {
  final AppUser user;

  // Crearea unui GlobalKey pentru a controla Scaffold-ul
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Constructor pentru a primi utilizatorul
  MainScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Setăm key-ul pentru Scaffold
      appBar: AppBar(
        // title in the center
        title: Center(
          child: Text(
            'PostopCare',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 15, 172, 172),
        // Elimină butonul implicit din stânga care se folosește pentru back
        automaticallyImplyLeading: false,
        // Adaugă butonul de meniul de tip hamburger
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Deschide Drawer-ul (Sidebar-ul)
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Today\'s Schedule:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Calendarul pentru selectarea zilei
          const Expanded(
            child: CalendarWidget(), // Widgetul Calendarului
          ),
        ],
      ),
      // Sidebar (Drawer) pentru a adăuga butonul de logout
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header-ul sidebar-ului
            UserAccountsDrawerHeader(
              accountName: Text(user.name),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.name[0].toUpperCase(), // Prima literă a numelui
                  style: TextStyle(fontSize: 40.0, color: Colors.black),
                ),
              ),
            ),
            // Butonul de logout
            ListTile(
              title: Text('Log Out'),
              leading: Icon(Icons.logout),
              onTap: () {
                // Redirecționează utilizatorul la AuthScreen pentru logout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
