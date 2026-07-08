import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Palette ────────────────────────────────────────────────
  static const _forest = Color(0xff1a3a2a);
  static const _gold = Color(0xffc8963e);
  static const _surface = Color(0xfffafaf8);
  static const _inputBg = Color(0xfff2f4f0);
  static const _textPrimary = Color(0xff111e17);
  static const _textSecondary = Color(0xff6b7d72);
  static const _divider = Color(0xffe2e8e4);
  static const _errorRed = Color(0xffb84040);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ProfileProvider>();

    if (newPasswordController.text != confirmPasswordController.text) {
      _showSnack('New passwords do not match.', isError: true);
      return;
    }

    if (newPasswordController.text.length < 8) {
      _showSnack('Password must be at least 8 characters.', isError: true);
      return;
    }

    final success = await provider.changePassword(
      token: auth.token!,
      userId: auth.userId!,
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      newPasswordConfirmation: confirmPasswordController.text,
    );

    if (!mounted) return;

    _showSnack(
      success
          ? 'Password changed successfully.'
          : provider.errorMessage ?? 'Failed to change password.',
      isError: !success,
    );

    if (success) Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

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
                            'Change Password',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Keep your account secure',
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

                // ── Lock icon ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),

                // ── Bottom card ──────────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
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

                              // ── Current password ─────────────
                              _fieldLabel('Current Password'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: currentPasswordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscureCurrent,
                                onToggle: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Divider
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: _divider),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'New Password',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: _textSecondary.withOpacity(0.6),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: _divider),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // ── New password ─────────────────
                              _fieldLabel('New Password'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: newPasswordController,
                                hint: '••••••••',
                                icon: Icons.lock_open_rounded,
                                obscure: _obscureNew,
                                onToggle: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                              ),

                              const SizedBox(height: 16),

                              // ── Confirm password ─────────────
                              _fieldLabel('Confirm New Password'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: confirmPasswordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscureConfirm,
                                onToggle: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Password tip
                              _passwordTip(),

                              const SizedBox(height: 28),

                              // ── Submit button ─────────────────
                              _submitButton(provider),
                            ],
                          ),
                        ),
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

  // ── Field label ─────────────────────────────────────────────
  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _textSecondary,
      letterSpacing: 0.3,
    ),
  );

  // ── Input field ─────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: _textSecondary.withOpacity(0.5),
            fontSize: 14.5,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(icon, size: 20, color: _textSecondary),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: onToggle,
              child: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
                color: _textSecondary,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // ── Password tip card ───────────────────────────────────────
  Widget _passwordTip() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _inputBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _divider),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.tips_and_updates_outlined,
          size: 16,
          color: _textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Use at least 8 characters with a mix of letters, numbers, and symbols for a stronger password.',
            style: TextStyle(
              fontSize: 12,
              color: _textSecondary.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Submit button ───────────────────────────────────────────
  Widget _submitButton(ProfileProvider provider) {
    return GestureDetector(
      onTap: provider.isLoading ? null : changePassword,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: provider.isLoading ? _gold.withOpacity(0.7) : _gold,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: provider.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Update Password',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
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
