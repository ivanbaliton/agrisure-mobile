import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/utils/storage_helper.dart';
import '../../providers/farm_provider.dart';

class RegisterFarmScreen extends StatefulWidget {
  const RegisterFarmScreen({super.key});

  @override
  State<RegisterFarmScreen> createState() => _RegisterFarmScreenState();
}

class _RegisterFarmScreenState extends State<RegisterFarmScreen>
    with SingleTickerProviderStateMixin {
  final farmNameController = TextEditingController();
  final farmAreaController = TextEditingController();

  String? selectedCropType;
  File? farmImage;

  double? latitude;
  double? longitude;
  bool isGettingLocation = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) => pickImage());
  }

  @override
  void dispose() {
    _animController.dispose();
    farmNameController.dispose();
    farmAreaController.dispose();
    super.dispose();
  }

  Future<bool> getCurrentLocation() async {
    setState(() => isGettingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => isGettingLocation = false);
      _showSnack('Please enable location services.', isError: true);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() => isGettingLocation = false);
      _showSnack('Location permission is required.', isError: true);
      return false;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      isGettingLocation = false;
    });

    return true;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      final locationCaptured = await getCurrentLocation();
      if (!locationCaptured) return;
      setState(() => farmImage = File(pickedImage.path));
    } else {
      if (!mounted) return;
      _showSnack('Farm image is required.', isError: true);
    }
  }

  Future<void> submitFarm() async {
    if (farmImage == null ||
        selectedCropType == null ||
        farmNameController.text.trim().isEmpty ||
        farmAreaController.text.trim().isEmpty) {
      _showSnack('Please complete all farm details.', isError: true);
      return;
    }

    if (latitude == null || longitude == null) {
      _showSnack(
        'Unable to get GPS location. Please capture the farm image again.',
        isError: true,
      );
      return;
    }

    final token = await StorageHelper.getToken();
    final farmerProfileId = await StorageHelper.getFarmerProfileId();

    if (token == null || farmerProfileId == null) {
      _showSnack('Login session missing. Please login again.', isError: true);
      return;
    }

    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    final response = await farmProvider.registerFarm(
      token: token,
      farmerProfileId: int.parse(farmerProfileId),
      farmName: farmNameController.text.trim(),
      cropType: selectedCropType!,
      farmArea: farmAreaController.text.trim(),
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      farmImage: farmImage!,
    );

    if (!mounted) return;

    if (response['farm'] != null || response['success'] == true) {
      _showSnack(response['message'] ?? 'Farm registered successfully.');
      Navigator.pop(context);
    } else {
      _showSnack(
        response['message'] ?? 'Farm registration failed.',
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
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: _forest,
      body: Stack(
        children: [
          // Decorative bg circles
          Positioned(
            top: -50,
            right: -50,
            child: _bgCircle(180, Colors.white.withOpacity(0.04)),
          ),
          Positioned(
            top: 60,
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
                            'Register Farm',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Fill in your farm details',
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

                const SizedBox(height: 20),

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
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: _divider,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),

                              // ── Farm photo ───────────────────
                              _sectionLabel('Farm Photo'),
                              const SizedBox(height: 8),
                              _farmImageCard(),

                              // ── GPS status ───────────────────
                              const SizedBox(height: 10),
                              _locationStatus(),

                              const SizedBox(height: 20),

                              // ── Farm name ────────────────────
                              _sectionLabel('Farm Name'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: farmNameController,
                                hint: 'e.g. Dela Cruz Farm',
                                icon: Icons.landscape_outlined,
                              ),

                              const SizedBox(height: 16),

                              // ── Farm area ────────────────────
                              _sectionLabel('Farm Area (hectares)'),
                              const SizedBox(height: 8),
                              _inputField(
                                controller: farmAreaController,
                                hint: 'e.g. 2.5',
                                icon: Icons.straighten_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),

                              const SizedBox(height: 16),

                              // ── Crop type ────────────────────
                              _sectionLabel('Crop Type'),
                              const SizedBox(height: 8),
                              _cropDropdown(),

                              const SizedBox(height: 28),

                              // ── Submit ───────────────────────
                              _submitButton(farmProvider),

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

  // ── Farm image card ─────────────────────────────────────────
  Widget _farmImageCard() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: farmImage != null ? Colors.transparent : _inputBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: farmImage != null ? _forestLight : _divider,
            width: farmImage != null ? 2 : 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: farmImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _forest.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 26,
                      color: _forestLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Take a photo of your farm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to open camera',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _textSecondary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _forest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Open Camera',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  // Full image
                  Image.file(
                    farmImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  // Dark gradient at bottom
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Retake button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Retake',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // GPS indicator on image
                  if (latitude != null && longitude != null)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  // ── Location status ─────────────────────────────────────────
  Widget _locationStatus() {
    if (isGettingLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xfffff8ed),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _gold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
            ),
            const SizedBox(width: 10),
            Text(
              'Capturing GPS location...',
              style: TextStyle(
                fontSize: 12.5,
                color: _gold.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // ── Section label ───────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
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
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 4,
          ),
        ),
      ),
    );
  }

  // ── Crop dropdown ───────────────────────────────────────────
  Widget _cropDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonFormField<String>(
        value: selectedCropType,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _textSecondary,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.grass_outlined, size: 20, color: _textSecondary),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
        hint: Text(
          'Select crop type',
          style: TextStyle(
            color: _textSecondary.withOpacity(0.5),
            fontSize: 14.5,
          ),
        ),
        style: const TextStyle(
          fontSize: 15,
          color: _textPrimary,
          fontWeight: FontWeight.w400,
        ),
        dropdownColor: _surface,
        borderRadius: BorderRadius.circular(14),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'Rice', child: Text('🌾  Rice')),
          DropdownMenuItem(value: 'Corn', child: Text('🌽  Corn')),
        ],
        onChanged: (value) => setState(() => selectedCropType = value),
      ),
    );
  }

  // ── Submit button ───────────────────────────────────────────
  Widget _submitButton(FarmProvider farmProvider) {
    return GestureDetector(
      onTap: farmProvider.isLoading ? null : submitFarm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: farmProvider.isLoading ? _gold.withOpacity(0.7) : _gold,
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
          child: farmProvider.isLoading
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
                      'Register Farm',
                      style: TextStyle(
                        fontSize: 16,
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

  // ── Info note ───────────────────────────────────────────────
  Widget _infoNote() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _inputBg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _divider),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline_rounded, size: 16, color: _textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your farm photo and GPS coordinates are used to verify coverage eligibility and assess crop risk.',
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

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
