import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../core/utils/storage_helper.dart';
import '../auth/login_screen.dart';

import 'change_password_screen.dart';
import 'about_agrisure_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_contact_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
  static const _errorRed = Color(0xffb84040);
  static const _errorSoft = Color(0xfffff0f0);

  @override
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await refreshProfile();
    });
  }

  String displayValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) return '—';
    return value.toString();
  }

  Future<void> pickAndUploadPhoto() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.userId == null) return;
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (pickedImage == null) return;
    await context.read<ProfileProvider>().uploadPhoto(
      token: auth.token!,
      userId: auth.userId!,
      imagePath: pickedImage.path,
    );
  }

  Future<void> refreshProfile() async {
    final auth = context.read<AuthProvider>();

    await auth.loadAuthData();

    if (auth.token != null && auth.userId != null) {
      await context.read<ProfileProvider>().fetchProfile(
        token: auth.token!,
        userId: auth.userId!,
      );

      final latestStatus = context
          .read<ProfileProvider>()
          .profile?['account_status'];

      if (latestStatus != null) {
        await auth.updateAccountStatus(latestStatus);
      }
    }
  }

  Future<void> openEditRejectedProfile(Map<String, dynamic> personal) async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ProfileProvider>();

    final controllers = {
      'first_name': TextEditingController(text: personal['first_name'] ?? ''),
      'middle_name': TextEditingController(text: personal['middle_name'] ?? ''),
      'last_name': TextEditingController(text: personal['last_name'] ?? ''),
      'extension_name': TextEditingController(
        text: personal['extension_name'] ?? '',
      ),
      'birthdate': TextEditingController(text: personal['birthdate'] ?? ''),
      'email_or_phone': TextEditingController(text: personal['contact'] ?? ''),
      'address': TextEditingController(text: personal['address'] ?? ''),
    };

    final labels = {
      'first_name': 'First Name',
      'middle_name': 'Middle Name',
      'last_name': 'Last Name',
      'extension_name': 'Extension Name',
      'birthdate': 'Birthdate',
      'email_or_phone': 'Contact / Email',
      'address': 'Address',
    };

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _surface,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _forest.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: _forest,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: _divider),
              const SizedBox(height: 10),
              SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Column(
                    children: labels.entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _inputBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: controllers[e.key],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: e.value,
                                  labelStyle: TextStyle(
                                    fontSize: 12.5,
                                    color: _textSecondary,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _dialogBtn(
                      'Cancel',
                      false,
                      context,
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _dialogBtn('Save Changes', true, context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldSave != true) return;

    final success = await provider.updateRejectedProfile(
      token: auth.token!,
      userId: auth.userId!,
      data: controllers.map((k, v) => MapEntry(k, v.text)),
    );

    if (!mounted) return;
    _showSnack(
      success
          ? 'Profile updated successfully.'
          : provider.errorMessage ?? 'Failed to update profile.',
    );
  }

  Future<void> resubmitVerification() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ProfileProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _goldSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: _gold, size: 26),
              ),
              const SizedBox(height: 16),
              const Text(
                'Resubmit Verification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to resubmit your profile for MAO verification?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _dialogBtn(
                      'Cancel',
                      false,
                      context,
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dialogBtn('Resubmit', true, context, isGold: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    final success = await provider.resubmitVerification(
      token: auth.token!,
      userId: auth.userId!,
    );

    if (!mounted) return;
    _showSnack(
      success
          ? 'Profile resubmitted for verification.'
          : provider.errorMessage ?? 'Failed to resubmit.',
    );
  }

  Widget _dialogBtn(
    String label,
    bool value,
    BuildContext context, {
    bool isOutline = false,
    bool isGold = false,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, value),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isOutline
              ? Colors.transparent
              : isGold
              ? _gold
              : _forest,
          borderRadius: BorderRadius.circular(12),
          border: isOutline ? Border.all(color: _divider, width: 1.5) : null,
          boxShadow: !isOutline
              ? [
                  BoxShadow(
                    color: (isGold ? _gold : _forest).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isOutline ? _textSecondary : Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _errorRed : _forest,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _surface,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _errorSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: _errorRed,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out from AgriSure?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _dialogBtn(
                      'Cancel',
                      false,
                      context,
                      isOutline: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dialogBtn('Sign Out', true, context, isGold: false),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;
    await context.read<AuthProvider>().logout();
    await StorageHelper.clearLoginData();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, auth, profileProvider, child) {
        final profile = profileProvider.profile;
        final personal = profile?['personal_information'] ?? {};
        final farmer = profile?['farmer_information'] ?? {};
        final isRejected = profile?['account_status'] == 'rejected';
        final status = profile?['account_status'] ?? '';

        if (auth.token == null || auth.userId == null) {
          return const Scaffold(body: Center(child: Text('Not logged in')));
        }

        if (profileProvider.isLoading) {
          return const Scaffold(
            backgroundColor: _surface,
            body: Center(child: CircularProgressIndicator(color: _forest)),
          );
        }

        if (profileProvider.errorMessage != null || profile == null) {
          return Scaffold(
            backgroundColor: _surface,
            body: _errorState(
              profileProvider.errorMessage ?? 'Profile not found.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: _inputBg,
          body: RefreshIndicator(
            color: _forest,
            onRefresh: refreshProfile,
            child: CustomScrollView(
              slivers: [
                // ── Header ────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader(profile, status)),

                // ── Content ───────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),

                      // Rejected banner
                      if (isRejected) ...[
                        _rejectedBanner(),
                        const SizedBox(height: 16),
                      ],

                      // Personal info
                      _sectionLabel('Personal Information'),
                      const SizedBox(height: 8),
                      _infoCard([
                        _infoRow('Last Name', personal['last_name']),
                        _infoRow('First Name', personal['first_name']),
                        _infoRow('Middle Name', personal['middle_name']),
                        _infoRow('Extension', personal['extension_name']),
                        _infoRow('Sex', personal['sex']),
                        _infoRow('Birthdate', personal['birthdate']),
                        _infoRow('Contact / Email', personal['contact']),
                        _infoRow('Address', personal['address'], isLast: true),
                      ]),

                      if (isRejected) ...[
                        const SizedBox(height: 10),
                        _outlineBtn(
                          Icons.edit_outlined,
                          'Edit Personal Information',
                          () => openEditRejectedProfile(personal),
                        ),
                        const SizedBox(height: 8),
                        _goldBtn(
                          Icons.send_rounded,
                          'Resubmit Verification',
                          resubmitVerification,
                        ),
                      ],

                      const SizedBox(height: 20),

                      _sectionLabel('Farmer Information'),
                      const SizedBox(height: 8),
                      _infoCard([
                        _infoRow('RSBSA Number', farmer['rsbsa_reference']),
                        _infoRow(
                          'Verification Status',
                          farmer['verification_status'],
                          isLast: true,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _sectionLabel('Security'),
                      const SizedBox(height: 8),
                      _menuCard([
                        _menuRow(
                          Icons.lock_outline_rounded,
                          'Change Password',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangePasswordScreen(),
                            ),
                          ),
                          isLast: true,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _sectionLabel('App Info'),
                      const SizedBox(height: 8),
                      _menuCard([
                        _menuRow(
                          Icons.info_outline_rounded,
                          'About AgriSure',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutAgriSureScreen(),
                            ),
                          ),
                        ),
                        _menuRow(
                          Icons.privacy_tip_outlined,
                          'Privacy Policy',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          ),
                        ),
                        _menuRow(
                          Icons.support_agent_outlined,
                          'Help / Contact MAO',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HelpContactScreen(),
                            ),
                          ),
                          isLast: true,
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _logoutTile(context),

                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'AgriSure v1.0.0',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _textSecondary.withOpacity(0.45),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Header: side-by-side avatar + info ─────────────────────
  Widget _buildHeader(Map<String, dynamic> profile, String status) {
    final photoUrl = profile['profile_photo'];

    Color statusColor;
    Color statusBg;
    String statusLabel;

    switch (status) {
      case 'verified':
        statusColor = const Color(0xff2a5c40);
        statusBg = const Color(0xffe8f2ec);
        statusLabel = 'Verified';
        break;
      case 'rejected':
        statusColor = _errorRed;
        statusBg = _errorSoft;
        statusLabel = 'Rejected';
        break;
      default:
        statusColor = _gold;
        statusBg = _goldSoft;
        statusLabel = 'Pending';
    }

    return Container(
      color: _forest,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: _bgCircle(140, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: _bgCircle(60, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            bottom: 40,
            left: -20,
            child: _bgCircle(100, Colors.white.withOpacity(0.03)),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top label
                  Text(
                    'MY PROFILE',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.45),
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Side by side ──────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: pickAndUploadPhoto,
                        child: Stack(
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                  width: 2.5,
                                ),
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: ClipOval(
                                child:
                                    photoUrl != null &&
                                        photoUrl.toString().isNotEmpty
                                    ? Image.network(photoUrl, fit: BoxFit.cover)
                                    : Icon(
                                        Icons.person_rounded,
                                        size: 40,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: _gold,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _forest, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Name + role + status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayValue(profile['full_name']),
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayValue(profile['role']),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'RSBSA: ${displayValue(profile['rsbsa_reference'])}',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.4),
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
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
                ],
              ),
            ),
          ),

          // Bottom curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 24,
              decoration: const BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── RSBSA chip row ──────────────────────────────────────────
  Widget _rsbsaChip(Map<String, dynamic> profile) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _divider),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _forest.withOpacity(0.07),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(
            Icons.badge_outlined,
            size: 17,
            color: _forestLight,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RSBSA Reference Number',
              style: TextStyle(fontSize: 11, color: _textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              displayValue(profile['rsbsa_reference']),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  // ── Section label ───────────────────────────────────────────
  Widget _sectionLabel(String title) => Text(
    title.toUpperCase(),
    style: TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: _textSecondary.withOpacity(0.6),
      letterSpacing: 1.2,
    ),
  );

  // ── Info card ───────────────────────────────────────────────
  Widget _infoCard(List<Widget> rows) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _divider),
    ),
    child: Column(children: rows),
  );

  Widget _infoRow(String label, dynamic value, {bool isLast = false}) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
            ),
            Expanded(
              child: Text(
                displayValue(value),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      if (!isLast)
        Divider(height: 1, color: _divider, indent: 16, endIndent: 16),
    ],
  );

  // ── Menu card ───────────────────────────────────────────────
  Widget _menuCard(List<Widget> rows) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _divider),
    ),
    child: Column(children: rows),
  );

  Widget _menuRow(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLast = false,
  }) => Column(
    children: [
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _forest.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: _forestLight),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: _textSecondary.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
      if (!isLast)
        Divider(height: 1, color: _divider, indent: 62, endIndent: 16),
    ],
  );

  // ── Rejected banner ─────────────────────────────────────────
  Widget _rejectedBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _errorSoft,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _errorRed.withOpacity(0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.warning_amber_rounded,
          size: 18,
          color: _errorRed.withOpacity(0.8),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your account was rejected. Update your information and resubmit for verification.',
            style: TextStyle(
              fontSize: 12.5,
              color: _errorRed.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _outlineBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _divider, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: _textPrimary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _goldBtn(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _gold.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _logoutTile(BuildContext context) => GestureDetector(
    onTap: () => logout(context),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _errorSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.logout_rounded, size: 18, color: _errorRed),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _errorRed,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: _errorRed.withOpacity(0.4),
          ),
        ],
      ),
    ),
  );

  Widget _errorState(String message) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _inputBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: _textSecondary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _textSecondary, height: 1.5),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: refreshProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _forest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
