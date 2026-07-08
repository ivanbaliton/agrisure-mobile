import 'package:flutter/material.dart';

class AboutAgriSureScreen extends StatelessWidget {
  const AboutAgriSureScreen({super.key});

  // ── Palette ────────────────────────────────────────────────
  static const _forest = Color(0xff1a3a2a);
  static const _forestLight = Color(0xff2a5c40);
  static const _gold = Color(0xffc8963e);
  static const _goldSoft = Color(0xfffff8ed);
  static const _surface = Color(0xfffafaf8);
  static const _inputBg = Color(0xfff2f4f0);
  static const _textPrimary = Color(0xff111e17);
  static const _textSecondary = Color(0xff6b7d72);
  static const _divider = Color(0xffe2e8e4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _forest,
      body: Stack(
        children: [
          // Decorative circles
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
                // ── Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About AgriSure',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Version 1.0.0 · Capstone 2026',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Logo area ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'AgriSure',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Agricultural Support System',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom card ──────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 36,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 28),
                              decoration: BoxDecoration(
                                color: _divider,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // ── About card ─────────────────────
                          _sectionLabel('About'),
                          const SizedBox(height: 8),
                          _contentCard(
                            child: const Text(
                              'AgriSure is a mobile and web-based agricultural support system designed to improve crop insurance application, claims processing, crop damage reporting, and agricultural assistance management for rice and corn farmers in San Agustin, Isabela.',
                              style: TextStyle(
                                fontSize: 14,
                                color: _textSecondary,
                                height: 1.7,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Features ───────────────────────
                          _sectionLabel('Key Features'),
                          const SizedBox(height: 8),
                          _contentCard(
                            child: Column(
                              children: [
                                _featureRow(
                                  Icons.verified_user_outlined,
                                  'Crop Insurance Applications',
                                  'Submit and track insurance applications easily.',
                                ),
                                _featureDivider(),
                                _featureRow(
                                  Icons.description_outlined,
                                  'Claims Processing',
                                  'File and monitor crop damage claims.',
                                ),
                                _featureDivider(),
                                _featureRow(
                                  Icons.report_outlined,
                                  'Damage Reporting',
                                  'Report crop damage with GPS and photo evidence.',
                                ),
                                _featureDivider(),
                                _featureRow(
                                  Icons.card_giftcard_outlined,
                                  'Assistance Management',
                                  'Access agricultural assistance programs from MAO.',
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Supported crops ────────────────
                          _sectionLabel('Supported Crops'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _cropChip('🌾', 'Rice')),
                              const SizedBox(width: 10),
                              Expanded(child: _cropChip('🌽', 'Corn')),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── App info ───────────────────────
                          _sectionLabel('App Information'),
                          const SizedBox(height: 8),
                          _contentCard(
                            child: Column(
                              children: [
                                _infoRow('Version', '1.0.0'),
                                _infoDivider(),
                                _infoRow('Project Type', 'Capstone Project'),
                                _infoDivider(),
                                _infoRow('Year', '2026'),
                                _infoDivider(),
                                _infoRow(
                                  'Coverage Area',
                                  'San Agustin, Isabela',
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── MAO note ───────────────────────
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _goldSoft,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _gold.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.agriculture_outlined,
                                  size: 18,
                                  color: _gold,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'This system is operated in partnership with the Municipal Agriculture Office (MAO) of San Agustin, Isabela.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _gold.withOpacity(0.85),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _sectionLabel(String title) => Text(
    title.toUpperCase(),
    style: TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: _textSecondary.withOpacity(0.6),
      letterSpacing: 1.2,
    ),
  );

  Widget _contentCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _divider),
    ),
    child: child,
  );

  Widget _featureRow(
    IconData icon,
    String title,
    String subtitle, {
    bool isLast = false,
  }) => Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _forest.withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: _forestLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: _textSecondary.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _featureDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1, color: _divider),
  );

  Widget _cropChip(String emoji, String label) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: _inputBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _divider),
    ),
    child: Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    ),
  );

  Widget _infoRow(String label, String value, {bool isLast = false}) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: _textSecondary)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
          ],
        ),
      ),
      if (!isLast) Divider(height: 1, color: _divider),
    ],
  );

  Widget _infoDivider() => const SizedBox.shrink();

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
