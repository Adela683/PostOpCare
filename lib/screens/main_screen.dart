import 'package:flutter/material.dart';
import 'package:postopcare/widgets/calendar.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/screens/auth_screen.dart'; // Importă AuthScreen pentru logout
import 'package:postopcare/screens/surgery_template_screen.dart'; // Import SurgeryScreen
import 'package:postopcare/screens/pacient_screen.dart'; // Import TemplateScreen

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
        // Mută butonul de meniul de tip hamburger în partea stângă
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Deschide Drawer-ul (Sidebar-ul)
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
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
              //accountName in black color
              accountName: Text(
                user.name,
                style: TextStyle(color: Colors.black),
              ),
              accountEmail: Text(
                user.email,
                style: TextStyle(color: Colors.black),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user.name[0].toUpperCase(), // Prima literă a numelui
                  style: TextStyle(fontSize: 40.0, color: Colors.black),
                ),
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/medical_image.png'), // Fundalul cu imaginea aleasă
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Buton pentru Surgery
            ListTile(
              title: Text('Surgery_templates'),
              leading: Icon(Icons.medical_services),
              onTap: () {
                // Navighează la SurgeryScreen
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SurgeryScreen()),
                // );
              },
            ),
            // Buton pentru Template
            ListTile(
              title: Text('Pacients'),
              leading: Icon(Icons.people),
              onTap: () {
                // Navighează la TemplateScreen
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => PacientScreen()),
                // );
              },
            ),
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
