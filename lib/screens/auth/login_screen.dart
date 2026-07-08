import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'otp_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
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
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await auth.login(
      loginController.text.trim(),
      passwordController.text.trim(),
    );
    if (!mounted) return;
    if (response['requires_otp'] == true ||
        response['requires_otp'] == 'true') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpScreen(userId: int.parse(response['user_id'].toString())),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response['message'] ?? 'Login failed'),
        backgroundColor: _forest,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _forest,
      body: Stack(
        children: [
          // ── Decorative background circles ──────────────────
          Positioned(
            top: -60,
            right: -60,
            child: _bgCircle(220, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            top: 80,
            right: 40,
            child: _bgCircle(80, Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            top: 40,
            left: -30,
            child: _bgCircle(130, Colors.white.withOpacity(0.03)),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top brand section ──────────────────────────
                SizedBox(
                  height: size.height * 0.30,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo pill
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
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome\nback.',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Sign in to manage your farm coverage',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.55),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom sheet card ──────────────────────────
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Drag handle ─────────────────
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

                              // ── Email field ──────────────────
                              _sectionLabel('Email or Phone'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: loginController,
                                hint: 'you@example.com',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              const SizedBox(height: 20),

                              // ── Password field ───────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _sectionLabel('Password'),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Forgot?',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _gold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: passwordController,
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                obscure: _obscurePassword,
                                suffix: GestureDetector(
                                  onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  child: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 19,
                                    color: _textSecondary,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ── Sign In button ───────────────
                              _signInButton(auth),

                              const SizedBox(height: 24),

                              // ── Divider ──────────────────────
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: _divider),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                    ),
                                    child: Text(
                                      'New here?',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: _textSecondary.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: _divider),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // ── Register button ──────────────
                              _registerButton(),

                              const SizedBox(height: 28),

                              // ── Trust row ────────────────────
                              _trustRow(),
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

  // ── Helpers ──────────────────────────────────────────────────

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _textSecondary,
      letterSpacing: 0.3,
    ),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          color: _textPrimary,
          fontWeight: FontWeight.w400,
        ),
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
          suffixIcon: suffix != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: suffix,
                )
              : null,
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

  Widget _signInButton(AuthProvider auth) {
    return GestureDetector(
      onTap: auth.isLoading ? null : login,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: auth.isLoading ? _gold.withOpacity(0.7) : _gold,
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
          child: auth.isLoading
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
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      ),
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
            'Create an account',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _trustRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _trustItem(Icons.shield_outlined, 'SSL Secured'),
        _dividerDot(),
        _trustItem(Icons.lock_outline_rounded, 'Private'),
        _dividerDot(),
        _trustItem(Icons.verified_outlined, 'Trusted'),
      ],
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: _textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: _textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _dividerDot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(color: _divider, shape: BoxShape.circle),
    ),
  );
}
