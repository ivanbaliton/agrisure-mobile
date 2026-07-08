import 'dart:async';

import 'package:agrisure/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/utils/storage_helper.dart';
import '../../../providers/profile_provider.dart';

import 'under_verification_screen.dart';
import 'rejected_screen.dart';

class OtpScreen extends StatefulWidget {
  final int userId;

  const OtpScreen({super.key, required this.userId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // 6 individual OTP box controllers & focus nodes
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Countdown — 3 minutes
  static const _countdownSeconds = 180;
  int _secondsLeft = _countdownSeconds;
  Timer? _timer;
  bool _canResend = false;
  bool _isResending = false;

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

    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _countdownSeconds;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() {
          _secondsLeft = 0;
          _canResend = true;
        });
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _clearBoxes() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes[5].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  Future<void> verifyOtp() async {
    if (_otpValue.length < 6) {
      _showSnack('Please enter the complete 6-digit OTP.', isError: true);
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final response = await auth.verifyLoginOtp(widget.userId, _otpValue);

    if (!mounted) return;

    if (response['access_token'] != null) {
      await StorageHelper.saveLoginData(
        token: response['access_token'],
        userId: response['user']['id'].toString(),
        role: response['user']['role'],
        accountStatus: response['user']['account_status'],
      );

      await auth.saveAuthData({
        'token': response['access_token'],
        'user': response['user'],
      });

      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      await profileProvider.fetchProfile(
        token: response['access_token'],
        userId: response['user']['id'],
      );

      final farmerProfileId = profileProvider.farmerProfileId;
      if (farmerProfileId != null) {
        await StorageHelper.saveFarmerProfileId(farmerProfileId.toString());
      }

      final status = response['user']['account_status'];

      if (status == 'verified' || status == 'pending' || status == 'rejected') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (route) => false,
        );
      } else {
        _showSnack(
          response['message'] ?? 'Invalid OTP. Please try again.',
          isError: true,
        );
      }
    } else {
      _showSnack(
        response['message'] ?? 'Invalid OTP. Please try again.',
        isError: true,
      );
    }
  }

  /// Resend — will be wired to AuthProvider once you share it
  Future<void> _resendOtp() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final response = await auth.resendOtp(widget.userId);

    if (!mounted) return;

    setState(() => _isResending = false);

    if (response['success'] == true ||
        (response['message'] != null && !response.containsKey('error'))) {
      _clearBoxes();
      _startCountdown();
      _showSnack(response['message'] ?? 'A new OTP has been sent.');
    } else {
      _showSnack(
        response['message'] ?? 'Failed to resend OTP. Please try again.',
        isError: true,
      );
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
          Positioned(
            top: 40,
            left: -30,
            child: _bgCircle(120, Colors.white.withOpacity(0.03)),
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
                            'OTP Verification',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Check your email or phone',
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

                // ── Icon + title ─────────────────────────────
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
                          Icons.mark_email_read_outlined,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Enter Verification Code',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A 6-digit code was sent to your\nregistered email or phone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.white.withOpacity(0.55),
                          height: 1.5,
                        ),
                      ),
                    ],
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
                          padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
                          child: Column(
                            children: [
                              // Drag handle
                              Container(
                                width: 36,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 28),
                                decoration: BoxDecoration(
                                  color: _divider,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),

                              // ── OTP boxes ───────────────────
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (i) => _otpBox(i)),
                              ),

                              const SizedBox(height: 28),

                              // ── Countdown ───────────────────
                              _countdownWidget(),

                              const SizedBox(height: 28),

                              // ── Verify button ────────────────
                              _verifyButton(auth),

                              const SizedBox(height: 20),

                              // ── Resend row ───────────────────
                              _resendRow(),

                              const SizedBox(height: 16),

                              // ── Info note ────────────────────
                              _infoNote(),
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

  // ── OTP digit box ───────────────────────────────────────────
  Widget _otpBox(int index) {
    final isFilled = _controllers[index].text.isNotEmpty;
    return SizedBox(
      width: 46,
      height: 56,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (e) => _onKeyEvent(index, e),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isFilled ? _forest : _textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: isFilled ? const Color(0xffe8f2ec) : _inputBg,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isFilled ? _forestLight : _divider,
                width: isFilled ? 2 : 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _gold, width: 2),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => _onOtpChanged(index, v),
        ),
      ),
    );
  }

  // ── Countdown widget ────────────────────────────────────────
  Widget _countdownWidget() {
    final progress = _secondsLeft / _countdownSeconds;
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: _divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _canResend ? _divider : _gold,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _canResend ? '00:00' : timeStr,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _canResend ? _textSecondary : _textPrimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'left',
                  style: TextStyle(
                    fontSize: 10,
                    color: _textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _canResend ? 'Code has expired.' : 'Code expires in $timeStr',
          style: TextStyle(
            fontSize: 12.5,
            color: _canResend ? _errorRed : _textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Verify button ───────────────────────────────────────────
  Widget _verifyButton(AuthProvider auth) {
    final isComplete = _otpValue.length == 6;
    return GestureDetector(
      onTap: (auth.isLoading || !isComplete) ? null : verifyOtp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: isComplete
              ? (auth.isLoading ? _gold.withOpacity(0.7) : _gold)
              : _inputBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isComplete
              ? [
                  BoxShadow(
                    color: _gold.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
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
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 18,
                      color: isComplete ? Colors.white : _textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Verify Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isComplete ? Colors.white : _textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Resend row ──────────────────────────────────────────────
  Widget _resendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive a code? ",
          style: TextStyle(
            fontSize: 13.5,
            color: _textSecondary.withOpacity(0.8),
          ),
        ),
        GestureDetector(
          onTap: _canResend && !_isResending ? _resendOtp : null,
          child: _isResending
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _gold,
                  ),
                )
              : Text(
                  'Resend',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: _canResend ? _gold : _textSecondary.withOpacity(0.4),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Info note ───────────────────────────────────────────────
  Widget _infoNote() {
    return Container(
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
              'The code is valid for 3 minutes. If you didn\'t receive it, check your spam folder or tap Resend after the timer expires.',
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
  }

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
