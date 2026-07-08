import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';

import 'main_navigation_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      checkLogin();
    });
  }

  Future<void> checkLogin() async {
    final auth = context.read<AuthProvider>();

    await auth.loadAuthData();

    if (!mounted) return;

    if (auth.token != null && auth.userId != null) {
      try {
        final profileProvider = context.read<ProfileProvider>();

        await profileProvider.fetchProfile(
          token: auth.token!,
          userId: auth.userId!,
        );

        final latestStatus = profileProvider.profile?['account_status'];

        if (latestStatus != null) {
          await auth.updateAccountStatus(latestStatus);
        }
      } catch (_) {
        // If offline or server unavailable, use saved auth data.
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
