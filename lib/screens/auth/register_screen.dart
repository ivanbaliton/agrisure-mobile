import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/barangay_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final emailOrPhoneController = TextEditingController();
  final birthdateController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedExtension = 'None';
  String? selectedSex;
  int? selectedBarangayId;
  String? selectedAddress;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Multi-step
  int _currentStep = 0;
  final PageController _pageController = PageController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Palette ────────────────────────────────────────────────
  static const _forest = Color(0xff1a3a2a);
  static const _forestLight = Color(0xff2a5c40);
  static const _gold = Color(0xffc8963e);
  static const _surface = Color(0xfffafaf8);
  static const _inputBg = Color(0xfff2f4f0);
  static const _textPrimary = Color(0xff111e17);
  static const _textSecondary = Color(0xff6b7d72);
  static const _divider = Color(0xffe2e8e4);
  static const _errorRed = Color(0xffb84040);

  final List<String> extensions = [
    'None',
    'Jr.',
    'Sr.',
    'II',
    'III',
    'IV',
    'V',
  ];

  final List<Map<String, String>> _steps = [
    {'title': 'Personal Info', 'subtitle': 'Your full name and identity'},
    {'title': 'Contact & Address', 'subtitle': 'How we can reach you'},
    {'title': 'Account Setup', 'subtitle': 'Secure your account'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    Future.microtask(() {
      context.read<BarangayProvider>().fetchBarangays();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    lastNameController.dispose();
    firstNameController.dispose();
    middleNameController.dispose();
    emailOrPhoneController.dispose();
    birthdateController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _forest,
            onPrimary: Colors.white,
            surface: _surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      birthdateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> register() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (selectedBarangayId == null) {
      _showSnack('Please select your barangay.', isError: true);
      return;
    }
    final response = await auth.register({
      'last_name': lastNameController.text.trim(),
      'first_name': firstNameController.text.trim(),
      'middle_name': middleNameController.text.trim(),
      'extension_name': selectedExtension == 'None'
          ? ''
          : selectedExtension ?? '',
      'sex': selectedSex ?? '',
      'email_or_phone': emailOrPhoneController.text.trim(),
      'birthdate': birthdateController.text.trim(),
      'address': addressController.text.trim(),
      'barangay_id': selectedBarangayId.toString(),
      'password': passwordController.text.trim(),
      'password_confirmation': confirmPasswordController.text.trim(),
    });

    if (!mounted) return;

    if (response['success'] == true || response['user'] != null) {
      _showSnack(
        response['message'] ??
            'Registration successful. Awaiting MAO verification.',
      );
      Navigator.pop(context);
    } else {
      _showSnack(response['message'] ?? 'Registration failed.', isError: true);
    }
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
    final auth = Provider.of<AuthProvider>(context);

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
                            'Create Account',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            _steps[_currentStep]['subtitle']!,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _gold.withOpacity(0.3)),
                        ),
                        child: Text(
                          'Step ${_currentStep + 1} of 3',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Step indicator ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _stepIndicator(),
                ),

                const SizedBox(height: 16),

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
                        child: Column(
                          children: [
                            // Drag handle
                            Container(
                              width: 36,
                              height: 4,
                              margin: const EdgeInsets.only(top: 14, bottom: 8),
                              decoration: BoxDecoration(
                                color: _divider,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),

                            // ── Page content ──────────────────
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _step1PersonalInfo(),
                                  _step2ContactAddress(),
                                  _step3AccountSetup(auth),
                                ],
                              ),
                            ),
                          ],
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

  // ── Step indicator ──────────────────────────────────────────
  Widget _stepIndicator() {
    return Row(
      children: List.generate(3, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return Expanded(
          child: GestureDetector(
            onTap: isDone ? () => _goToStep(i) : null,
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone || isActive
                          ? _gold
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Step 1: Personal Info ───────────────────────────────────
  Widget _step1PersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading('Personal Information', 'Enter your full legal name'),
          const SizedBox(height: 20),

          _sectionLabel('Last Name'),
          const SizedBox(height: 8),
          _inputField(
            controller: lastNameController,
            hint: 'e.g. Dela Cruz',
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 16),
          _sectionLabel('First Name'),
          const SizedBox(height: 8),
          _inputField(
            controller: firstNameController,
            hint: 'e.g. Juan',
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 16),
          _sectionLabel('Middle Name'),
          const SizedBox(height: 8),
          _inputField(
            controller: middleNameController,
            hint: 'e.g. Santos (optional)',
            icon: Icons.person_outline_rounded,
          ),

          const SizedBox(height: 16),

          // Extension + Sex in a row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Extension'),
                    const SizedBox(height: 8),
                    _dropdownField<String>(
                      value: selectedExtension,
                      hint: 'None',
                      icon: Icons.badge_outlined,
                      items: extensions
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedExtension = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Sex'),
                    const SizedBox(height: 8),
                    _dropdownField<String>(
                      value: selectedSex,
                      hint: 'Select',
                      icon: Icons.wc_outlined,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'Female',
                          child: Text('Female'),
                        ),
                      ],
                      onChanged: (v) => setState(() => selectedSex = v),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          _nextButton('Next: Contact Info', () => _goToStep(1)),
        ],
      ),
    );
  }

  // ── Step 2: Contact & Address ───────────────────────────────
  Widget _step2ContactAddress() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading('Contact & Address', 'How we can reach you'),
          const SizedBox(height: 20),

          _sectionLabel('Email or Phone Number'),
          const SizedBox(height: 8),
          _inputField(
            controller: emailOrPhoneController,
            hint: 'you@example.com or 09XX',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),
          _sectionLabel('Birthdate'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: pickBirthdate,
            child: Container(
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: birthdateController,
                readOnly: true,
                onTap: pickBirthdate,
                style: const TextStyle(fontSize: 15, color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  hintStyle: TextStyle(
                    color: _textSecondary.withOpacity(0.5),
                    fontSize: 14.5,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.cake_outlined,
                      size: 20,
                      color: _textSecondary,
                    ),
                  ),
                  suffixIcon: const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: _textSecondary,
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
            ),
          ),

          const SizedBox(height: 16),
          _sectionLabel('Address'),
          const SizedBox(height: 8),
          Consumer<BarangayProvider>(
            builder: (context, barangayProvider, child) {
              if (barangayProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (barangayProvider.errorMessage != null) {
                return Text(
                  barangayProvider.errorMessage!,
                  style: const TextStyle(color: _errorRed),
                );
              }

              return _dropdownField<int>(
                value: selectedBarangayId,
                hint: 'Select your barangay',
                icon: Icons.location_on_outlined,
                items: barangayProvider.barangays.map((barangay) {
                  return DropdownMenuItem<int>(
                    value: barangay['id'],
                    child: Text(
                      barangay['name'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  final selected = barangayProvider.barangays.firstWhere(
                    (b) => b['id'] == v,
                  );

                  setState(() {
                    selectedBarangayId = v;
                    selectedAddress = selected['name'];
                    addressController.text = selected['name'];
                  });
                },
              );
            },
          ),

          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _backButton(() => _goToStep(0))),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _nextButton('Next: Account', () => _goToStep(2)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 3: Account Setup ───────────────────────────────────
  Widget _step3AccountSetup(AuthProvider auth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepHeading('Account Setup', 'Create a strong password'),
          const SizedBox(height: 20),

          _sectionLabel('Password'),
          const SizedBox(height: 8),
          _inputField(
            controller: passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffix: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
                color: _textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),
          _sectionLabel('Confirm Password'),
          const SizedBox(height: 8),
          _inputField(
            controller: confirmPasswordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            suffix: GestureDetector(
              onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              child: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19,
                color: _textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Verification note
          Container(
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
                  Icons.info_outline_rounded,
                  size: 16,
                  color: _textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your account will be reviewed by the Municipal Agriculture Office (MAO) before activation.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _textSecondary.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(child: _backButton(() => _goToStep(1))),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _submitButton(auth)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared widgets ──────────────────────────────────────────

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _stepHeading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: _textSecondary.withOpacity(0.8)),
      ),
    ],
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

  Widget _dropdownField<T>({
    required T? value,
    required String hint,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonFormField<T>(
        value: value,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _textSecondary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(icon, size: 20, color: _textSecondary),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          isDense: true,
        ),
        hint: Text(
          hint,
          style: TextStyle(
            color: _textSecondary.withOpacity(0.5),
            fontSize: 14.5,
          ),
        ),
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        dropdownColor: _surface,
        borderRadius: BorderRadius.circular(14),
        isExpanded: true,
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _nextButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: _gold,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _backButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _divider, width: 1.5),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_rounded, size: 16, color: _textSecondary),
              SizedBox(width: 6),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitButton(AuthProvider auth) {
    return GestureDetector(
      onTap: auth.isLoading ? null : register,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          color: auth.isLoading ? _forestLight : _forest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _forest.withOpacity(0.3),
              blurRadius: 14,
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
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
