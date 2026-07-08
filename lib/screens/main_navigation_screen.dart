import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/damage_report_provider.dart';
import '../core/utils/storage_helper.dart';

import 'dashboard/dashboard_screen.dart';
import 'farm/farm_screen.dart';
import 'claims/claim_screen.dart';
import 'profile/profile_screen.dart';
import 'auth/under_verification_screen.dart';
import 'auth/rejected_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  static const int _profileIndex = 3;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const FarmScreen(),
    const ClaimsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final token = await StorageHelper.getToken();

      if (token != null && mounted) {
        await context.read<DamageReportProvider>().syncPendingReports(
          token: token,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final status = auth.accountStatus;

    final isVerified = status == 'verified';
    final isBlocked = !isVerified && currentIndex != _profileIndex;

    return Scaffold(
      body: isBlocked ? _statusScreen(status) : _pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: !isVerified ? Colors.grey : null,
            ),
            selectedIcon: const Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.agriculture_outlined,
              color: !isVerified ? Colors.grey : null,
            ),
            selectedIcon: const Icon(Icons.agriculture),
            label: 'Farms',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.description_outlined,
              color: !isVerified ? Colors.grey : null,
            ),
            selectedIcon: const Icon(Icons.description),
            label: 'Claims',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _statusScreen(String? status) {
    if (status == 'rejected') {
      return const RejectedScreen(isInline: true);
    }
    return const UnderVerificationScreen(isInline: true);
  }
}
