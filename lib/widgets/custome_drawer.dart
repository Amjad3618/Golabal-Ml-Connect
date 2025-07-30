import 'package:flutter/material.dart';
import 'package:global_ml_connect/screens/dashboard_screens/dashboard_screen.dart';

import 'package:global_ml_connect/screens/setting_screens/settings_screen.dart';
import '../screens/kyc_screens/kyc_screen.dart';

class CustomDrawer extends StatelessWidget {
  final Function(Widget) onItemSelected;

  const CustomDrawer({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Fixed width for the drawer
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.person, size: 40, color: Colors.blue),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildCustomListTile(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  onTap: () {
                    onItemSelected(const DashboardScreen());
                  },
                ),
                _buildCustomListTile(
                  icon: Icons.verified_user,
                  title: 'KYC Screen',
                  onTap: () {
                    onItemSelected(const KycScreen());
                  },
                ),

                _buildCustomListTile(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () {
                    onItemSelected(const SettingScreen());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: Colors.purple.withOpacity(0.1), // Purple hover effect
          splashColor: Colors.purple.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(icon, color: Colors.purple),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
