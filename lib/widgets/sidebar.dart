import 'package:flutter/material.dart';
import 'package:postopcare/data/models/user.dart';
import 'package:postopcare/screens/surgery_template_screen.dart'; // Import SurgeryScreen
import 'package:postopcare/screens/pacient_screen.dart'; // Import PacientScreen

import 'package:postopcare/screens/auth_screen.dart'; // Importă AuthScreen pentru logout

class CustomDrawer extends StatelessWidget {
  final AppUser user; // Modifică să primești un obiect complet de tip AppUser

  // Constructor corectat pentru a primi obiectul user
  const CustomDrawer({
    super.key,
    required this.user, // Adaugă user ca argument obligatoriu
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header-ul sidebar-ului
          UserAccountsDrawerHeader(
            accountName: Text(
              user.name,
              style: TextStyle(color: Colors.black),
            ), // Folosește user.name
            accountEmail: Text(
              user.email,
              style: TextStyle(color: Colors.black),
            ), // Folosește user.email
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name[0].toUpperCase(), // Folosește prima literă a numelui
                style: TextStyle(fontSize: 40.0, color: Colors.black),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/medical_image.png',
                ), // Fundalul cu imaginea aleasă
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Buton pentru Surgery Templates
          _buildDrawerItem(
            context,
            title: 'Surgery Templates',
            icon: Icons.medical_services,
            onTap: () => _navigateToSurgeryTemplateScreen(context),
          ),

          // Buton pentru Pacients
          _buildDrawerItem(
            context,
            title: 'Pacients',
            icon: Icons.people,
            onTap: () => _navigateToPacientScreen(context),
          ),

          // Buton de logout
          _buildDrawerItem(
            context,
            title: 'Log Out',
            icon: Icons.logout,
            onTap: () => _logOut(context),
          ),
        ],
      ),
    );
  }

  // Funcție pentru a construi fiecare item din sidebar
  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Function onTap,
  }) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () => onTap(),
    );
  }

  // Navighează la SurgeryTemplateScreen
  void _navigateToSurgeryTemplateScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SurgeryTemplateScreen(user: user), // Transmitere obiect user
      ),
    );
  }

  // Navighează la PacientScreen
  void _navigateToPacientScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => 
                PacientScreen(user: user), // Transmite userul
  ),
);

  }

  // Redirecționează utilizatorul la AuthScreen pentru logout
  void _logOut(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }
}
