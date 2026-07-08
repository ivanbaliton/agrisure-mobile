import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // ── Palette ────────────────────────────────────────────────
  static const _forest = Color(0xff1a3a2a);
  static const _forestLight = Color(0xff2a5c40);
  static const _gold = Color(0xffc8963e);
  static const _goldSoft = Color(0xfffff8ed);
  static const _surface = Color(0xfffafaf8);
  static const _textPrimary = Color(0xff111e17);
  static const _textSecondary = Color(0xff6b7d72);
  static const _divider = Color(0xffe2e8e4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _forest,
      body: Stack(
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
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Data Privacy Act of 2012',
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

                // ── Icon area ────────────────────────────────
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
                          Icons.privacy_tip_outlined,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your Privacy Matters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: January 2026',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.45),
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

                          // ── Overview ───────────────────────
                          _sectionLabel('Overview'),
                          const SizedBox(height: 8),
                          _textCard(
                            'AgriSure respects and protects the privacy of all its users. This policy explains how we collect, use, and safeguard your personal information in compliance with the Data Privacy Act of 2012.',
                          ),

                          const SizedBox(height: 20),

                          // ── Data collected ─────────────────
                          _sectionLabel('Data We Collect'),
                          const SizedBox(height: 8),
                          _listCard([
                            _dataItem(
                              Icons.person_outline_rounded,
                              'Personal Information',
                              'Full name, birthdate, sex, and extension name.',
                            ),
                            _dataItem(
                              Icons.contact_phone_outlined,
                              'Contact Information',
                              'Email address and phone number.',
                            ),
                            _dataItem(
                              Icons.agriculture_outlined,
                              'Farm Information',
                              'Farm name, area, crop type, and farm photos.',
                            ),
                            _dataItem(
                              Icons.description_outlined,
                              'Insurance & Claims Records',
                              'Crop insurance applications and damage claims history.',
                            ),
                            _dataItem(
                              Icons.location_on_outlined,
                              'Geolocation Data',
                              'GPS coordinates of your registered farm location.',
                              isLast: true,
                            ),
                          ]),

                          const SizedBox(height: 20),

                          // ── How we use it ──────────────────
                          _sectionLabel('How We Use Your Data'),
                          const SizedBox(height: 8),
                          _listCard([
                            _purposeItem(
                              'Crop insurance application and verification',
                            ),
                            _purposeItem(
                              'Account verification by MAO personnel',
                            ),
                            _purposeItem(
                              'Claims processing and damage assessment',
                            ),
                            _purposeItem(
                              'Agricultural assistance program management',
                            ),
                            _purposeItem(
                              'RSBSA registration and compliance',
                              isLast: true,
                            ),
                          ]),

                          const SizedBox(height: 20),

                          // ── Data access ────────────────────
                          _sectionLabel('Data Access'),
                          const SizedBox(height: 8),
                          _textCard(
                            'Your information is accessible only to authorized Municipal Agriculture Office (MAO) personnel. Data is never sold, shared, or disclosed to unauthorized third parties.',
                          ),

                          const SizedBox(height: 20),

                          // ── Your rights ────────────────────
                          _sectionLabel('Your Rights'),
                          const SizedBox(height: 8),
                          _listCard([
                            _purposeItem('Right to access your personal data'),
                            _purposeItem(
                              'Right to correct inaccurate information',
                            ),
                            _purposeItem('Right to request data deletion'),
                            _purposeItem(
                              'Right to object to data processing',
                              isLast: true,
                            ),
                          ]),

                          const SizedBox(height: 20),

                          // ── Compliance badge ───────────────
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _goldSoft,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _gold.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: _gold.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.verified_outlined,
                                    size: 22,
                                    color: _gold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Data Privacy Act of 2012',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: _gold,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'AgriSure is fully compliant with Republic Act No. 10173.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _gold,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
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

  Widget _sectionLabel(String title) => Text(
    title.toUpperCase(),
    style: TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: _textSecondary.withOpacity(0.6),
      letterSpacing: 1.2,
    ),
  );

  Widget _textCard(String text) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _divider),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 13.5, color: _textSecondary, height: 1.7),
    ),
  );

  Widget _listCard(List<Widget> items) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _divider),
    ),
    child: Column(children: items),
  );

  Widget _dataItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isLast = false,
  }) => Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _forest.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: _forestLight),
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
      if (!isLast)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: _divider),
        ),
    ],
  );

  Widget _purposeItem(String text, {bool isLast = false}) => Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: isLast ? 0 : 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: _forest.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 12,
                color: _forestLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, color: _divider),
        ),
    ],
  );

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
