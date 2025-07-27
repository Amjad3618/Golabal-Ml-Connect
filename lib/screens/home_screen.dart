import 'package:flutter/material.dart';
import '../widgets/custome_drawer.dart';
import 'package:global_ml_connect/screens/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Show DashboardScreen by default
  Widget _selectedScreen = const DashboardScreen();

  void _updateScreen(Widget screen) {
    setState(() {
      _selectedScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Always visible drawer
          CustomDrawer(onItemSelected: _updateScreen),

          // Main content area
          Expanded(child: _selectedScreen),
        ],
      ),
    );
  }
}
