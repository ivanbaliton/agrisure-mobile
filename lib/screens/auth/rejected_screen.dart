import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class RejectedScreen extends StatelessWidget {
  /// When true, renders without Scaffold (used inside MainNavigationScreen).
  /// When false, renders as a full standalone screen (pushed from OTP).
  final bool isInline;

  const RejectedScreen({super.key, this.isInline = false});

  // ── Palette ──────────────────────────────────────────────
  static const _forest = Color(0xff1a3a2a);
  static const _gold = Color(0xffc8963e);
  static const _errorRed = Color(0xffb84040);
  static const _errorSoft = Color(0xfffff0f0);
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
      return Container(
        color: _surface,
        child: SafeArea(child: _body(context)),
      );
    }

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
              color: _errorSoft,
              shape: BoxShape.circle,
              border: Border.all(color: _errorRed.withOpacity(0.25), width: 2),
            ),
            child: const Icon(Icons.cancel_rounded, size: 44, color: _errorRed),
          ),

          const SizedBox(height: 24),

          const Text(
            'Verification\nRejected',
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
            'Unfortunately, your account verification was not approved by the Municipal Agriculture Office (MAO).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _textSecondary, height: 1.6),
          ),

          const SizedBox(height: 28),

          // What to do next card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _errorSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _errorRed.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 16,
                      color: _errorRed.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'What to do next',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _errorRed.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _nextStep('1', 'Visit your nearest MAO office in person.'),
                const SizedBox(height: 8),
                _nextStep(
                  '2',
                  'Bring a valid government ID and your farm documents.',
                ),
                const SizedBox(height: 8),
                _nextStep(
                  '3',
                  'Ask about the reason for rejection and how to appeal.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact note
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
                    'For assistance, contact the Municipal Agriculture Office (MAO) during office hours.',
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

  Widget _nextStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: _errorRed.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _errorRed.withOpacity(0.8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: _textSecondary, height: 1.4),
          ),
        ),
      ],
    );
  }

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
          color: _errorRed,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _errorRed.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Back to Login',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
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
