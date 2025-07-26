import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Utils/app_colors.dart';
import '../Utils/custome_app_bar.dart';
import '../Utils/custome_btn.dart';
import '../Utils/date_formater.dart' hide DateUtils;
import '../Utils/form_containers.dart';
import '../Utils/forms_&_menuitems.dart';
import '../Utils/responsive_utils.dart';
import '../Utils/side_menu.dart';
import '../Utils/status_card.dart';
// Import your custom widgets and utils files
// import 'widgets/custom_widgets.dart';
// import 'utils/validators.dart';
// import 'utils/formatters.dart';
// import 'utils/date_utils.dart';
// import 'utils/snackbar_utils.dart';
// import 'constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  
  // Text controllers for KYC form
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  
  // Menu items
  final List<MenuItem> menuItems = [
    MenuItem(title: 'KYC', icon: Icons.verified_user, color: AppColors.primary),
    MenuItem(title: 'Dashboard', icon: Icons.dashboard, color: AppColors.secondary),
    MenuItem(title: 'Reports', icon: Icons.analytics, color: AppColors.accent),
    MenuItem(title: 'Settings', icon: Icons.settings, color: Colors.purple),
  ];

  @override
  void dispose() {
    cnicController.dispose();
    nameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Persistent Sidebar
          _buildSidebar(),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Navigation Bar
                CustomAppBar(
                  currentItem: menuItems[selectedIndex],
                  subtitle: _getSubtitle(selectedIndex),
                ),
                
                // Main Content Area
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'KYC Portal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Verify your identity',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Menu Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return SidebarMenuItem(
                    item: menuItems[index],
                    isSelected: selectedIndex == index,
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          
          // User Profile Footer
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Verification Pending',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _getSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Complete your identity verification';
      case 1:
        return 'View your verification status';
      case 2:
        return 'Check verification reports';
      case 3:
        return 'Manage account settings';
      default:
        return '';
    }
  }
  
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return _buildKYCForm();
      case 1:
        return _buildDashboard();
      case 2:
        return _buildReports();
      case 3:
        return _buildSettings();
      default:
        return _buildKYCForm();
    }
  }
  
  Widget _buildKYCForm() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.getMaxContentWidth(context),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                GradientHeader(
                  title: 'Complete Your KYC Verification',
                  subtitle: 'Please provide the following information to verify your identity',
                  icon: Icons.verified_user,
                  primaryColor: AppColors.primary,
                ),
                
                const SizedBox(height: 32),
                
                // KYC Form
                FormContainer(
                  title: 'Personal Information',
                  children: [
                    // Full Name Field
                    CustomTextField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name as per CNIC',
                      icon: Icons.person_outline,
                      validator: ValidationUtils.validateName,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // CNIC Number Field
                    CustomTextField(
                      controller: cnicController,
                      label: 'CNIC Number',
                      hint: '12345-1234567-1',
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CNICFormatter(),
                      ],
                      validator: ValidationUtils.validateCNIC,
                      helperText: 'Format: 12345-1234567-1',
                      maxLength: 15,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Date of Birth Field
                    CustomTextField(
                      controller: dobController,
                      label: 'Date of Birth',
                      hint: 'DD/MM/YYYY',
                      icon: Icons.calendar_today_outlined,
                      readOnly: true,
                      validator: ValidationUtils.validateDateOfBirth,
                      onTap: () => _selectDate(),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Phone Number Field
                    CustomTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      hint: '0300-123-4567',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        PhoneFormatter(),
                      ],
                      validator: ValidationUtils.validatePhone,
                      maxLength: 13,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email Field
                    CustomTextField(
                      controller: emailController,
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: ValidationUtils.validateEmail,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    CustomButton(
                      text: 'Submit KYC Information',
                      onPressed: _submitKYC,
                      isLoading: isLoading,
                      icon: Icons.send,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        // dobController.text = DateUtils.formatDate(picked);
      });
    }
  }
  
  Future<void> _submitKYC() async {
    if (!_formKey.currentState!.validate()) {
      SnackBarUtils.showError(context, 'Please fill in all fields correctly');
      return;
    }
    
    setState(() {
      isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      isLoading = false;
    });
    
    SnackBarUtils.showSuccess(context, 'KYC information submitted successfully!');
    
    // Clear form after successful submission
    _clearForm();
  }
  
  void _clearForm() {
    nameController.clear();
    cnicController.clear();
    dobController.clear();
    phoneController.clear();
    emailController.clear();
    _formKey.currentState?.reset();
  }
  
  Widget _buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Status Cards Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveUtils.isMobile(context) ? 1 : 
                           ResponsiveUtils.isTablet(context) ? 2 : 3,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              StatusCard(
                title: 'KYC Status',
                value: 'Pending',
                icon: Icons.pending_actions,
                color: AppColors.warning,
                subtitle: 'Awaiting verification',
              ),
              StatusCard(
                title: 'Documents',
                value: '3/5',
                icon: Icons.description,
                color: AppColors.info,
                subtitle: '2 more required',
              ),
              StatusCard(
                title: 'Verification Level',
                value: 'Basic',
                icon: Icons.verified,
                color: AppColors.success,
                subtitle: 'Level 1 completed',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildReports() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Reports Coming Soon',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Verification reports and analytics will be available here',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettings() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          FormContainer(
            title: 'Profile Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Profile'),
                subtitle: const Text('Update your personal information'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  SnackBarUtils.showInfo(context, 'Edit profile feature coming soon');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security Settings'),
                subtitle: const Text('Manage your account security'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  SnackBarUtils.showInfo(context, 'Security settings coming soon');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Notifications'),
                subtitle: const Text('Configure notification preferences'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  SnackBarUtils.showInfo(context, 'Notification settings coming soon');
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Help & Support'),
                subtitle: const Text('Get help with your account'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  SnackBarUtils.showInfo(context, 'Help & support coming soon');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}