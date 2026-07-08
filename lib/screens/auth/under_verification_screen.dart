import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class UnderVerificationScreen extends StatelessWidget {
  /// When true, renders without Scaffold (used inside MainNavigationScreen).
  /// When false, renders as a full standalone screen (pushed from OTP).
  final bool isInline;

  const UnderVerificationScreen({super.key, this.isInline = false});

  // ── Palette ──────────────────────────────────────────────
  static const _forest = Color(0xff1a3a2a);
  static const _gold = Color(0xffc8963e);
  static const _goldSoft = Color(0xfffff8ed);
  static const _surface = Color(0xfffafaf8);
  static const _textPrimary = Color(0xff111e17);
  static const _textSecondary = Color(0xff6b7d72);
  static const _divider = Color(0xffe2e8e4);

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (isInline) return content;

    return Scaffold(backgroundColor: _forest, body: content);
  }

  Widget _buildContent(BuildContext context) {
    if (isInline) {
      // Inside the nav — plain surface background, no forest header
      return Container(
        color: _surface,
        child: SafeArea(child: _body(context)),
      );
    }

    // Standalone — full forest + card design matching other screens
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: _bgCircle(180, Colors.white.withOpacity(0.04)),
        ),
        Positioned(
          top: 70,
          right: 30,
          child: _bgCircle(70, Colors.white.withOpacity(0.05)),
        ),
        SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: _gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'AgriSure',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: _body(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 32),
            decoration: BoxDecoration(
              color: _divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _goldSoft,
              shape: BoxShape.circle,
              border: Border.all(color: _gold.withOpacity(0.25), width: 2),
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 44,
              color: _gold,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Account Under\nVerification',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _textPrimary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Your registration has been successfully submitted and is currently being reviewed by the Municipal Agriculture Office (MAO).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _textSecondary, height: 1.6),
          ),

          const SizedBox(height: 28),

          // Status steps
          _statusStep(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xff2a5c40),
            bgColor: const Color(0xffe8f2ec),
            title: 'Registration Submitted',
            subtitle: 'Your details have been received.',
          ),
          _stepConnector(),
          _statusStep(
            icon: Icons.pending_rounded,
            iconColor: _gold,
            bgColor: _goldSoft,
            title: 'MAO Review In Progress',
            subtitle: 'An officer is reviewing your account.',
            isActive: true,
          ),
          _stepConnector(),
          _statusStep(
            icon: Icons.lock_outline_rounded,
            iconColor: _textSecondary,
            bgColor: const Color(0xfff2f4f0),
            title: 'Access Granted',
            subtitle: 'You\'ll be notified once approved.',
            isDisabled: true,
          ),

          const SizedBox(height: 32),

          // Info note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xfff2f4f0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: _textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This process may take 1–3 business days. You may visit your nearest MAO office for faster assistance.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Back to login — only on standalone
          if (!isInline) _logoutButton(context),
        ],
      ),
    );
  }

  Widget _statusStep({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    bool isActive = false,
    bool isDisabled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isActive ? _goldSoft : const Color(0xfffafaf8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? _gold.withOpacity(0.3) : _divider,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? _textSecondary : _textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Now',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepConnector() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 19),
    child: Container(width: 2, height: 20, color: _divider),
  );

  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.logout();
        if (!context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      },
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider, width: 1.5),
        ),
        child: const Center(
          child: Text(
            'Back to Login',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
