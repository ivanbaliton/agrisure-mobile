import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpContactScreen extends StatelessWidget {
  const HelpContactScreen({super.key});

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

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

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
                            'Help & Contact',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Municipal Agriculture Office',
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
                          Icons.support_agent_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'We\'re here to help',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reach out to the MAO office',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.white.withOpacity(0.5),
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

                          // ── Office info ────────────────────
                          _sectionLabel('Office'),
                          const SizedBox(height: 8),
                          _contentCard(
                            child: Column(
                              children: [
                                _infoRow(
                                  Icons.account_balance_outlined,
                                  'Municipal Agriculture Office',
                                  'San Agustin, Isabela',
                                ),
                                _rowDivider(),
                                _infoRow(
                                  Icons.schedule_outlined,
                                  'Office Hours',
                                  'Monday – Friday\n8:00 AM – 5:00 PM',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Contact actions ────────────────
                          _sectionLabel('Contact'),
                          const SizedBox(height: 8),
                          _contentCard(
                            child: Column(
                              children: [
                                _actionRow(
                                  icon: Icons.call_outlined,
                                  label: 'Call MAO',
                                  value: '+63 XXX XXX XXXX',
                                  color: const Color(0xff2a5c40),
                                  bgColor: const Color(0xffe8f2ec),
                                  onTap: () => _launch('tel:+63XXXXXXXXXX'),
                                ),
                                _rowDivider(),
                                _actionRow(
                                  icon: Icons.email_outlined,
                                  label: 'Email MAO',
                                  value: 'mao.sanagustin@isabela.gov.ph',
                                  color: _gold,
                                  bgColor: _goldSoft,
                                  onTap: () => _launch(
                                    'mailto:mao.sanagustin@isabela.gov.ph',
                                  ),
                                ),
                                _rowDivider(),
                                _actionRow(
                                  icon: Icons.location_on_outlined,
                                  label: 'Visit Office',
                                  value: 'Municipal Hall, San Agustin, Isabela',
                                  color: const Color(0xff3a6090),
                                  bgColor: const Color(0xffe8f0f8),
                                  onTap: () => _launch(
                                    'https://maps.google.com/?q=San+Agustin+Isabela',
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Services ───────────────────────
                          _sectionLabel('Services Available'),
                          const SizedBox(height: 8),
                          _contentCard(
                            child: Column(
                              children: [
                                _serviceRow(
                                  Icons.shield_outlined,
                                  'Crop Insurance Assistance',
                                  'Apply for rice and corn crop insurance.',
                                ),
                                _rowDivider(),
                                _serviceRow(
                                  Icons.description_outlined,
                                  'Claims Processing',
                                  'File and follow up on damage claims.',
                                ),
                                _rowDivider(),
                                _serviceRow(
                                  Icons.badge_outlined,
                                  'RSBSA Registration',
                                  'Register or update your RSBSA number.',
                                ),
                                _rowDivider(),
                                _serviceRow(
                                  Icons.card_giftcard_outlined,
                                  'Assistance Distribution',
                                  'Receive agricultural assistance programs.',
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Note ───────────────────────────
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
                                  Icons.info_outline_rounded,
                                  size: 16,
                                  color: _gold,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'For urgent concerns outside office hours, you may send an email and an officer will respond on the next business day.',
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

  Widget _infoRow(IconData icon, String label, String value) => Row(
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
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                color: _textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _actionRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(fontSize: 12, color: _textSecondary),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color: color.withOpacity(0.5),
        ),
      ],
    ),
  );

  Widget _serviceRow(
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

  Widget _rowDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: _divider),
  );

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
