import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../core/utils/storage_helper.dart';
import '../../models/farm_model.dart';
import '../../providers/damage_report_provider.dart';

class ReportDamageScreen extends StatefulWidget {
  final FarmModel farm;

  const ReportDamageScreen({super.key, required this.farm});

  @override
  State<ReportDamageScreen> createState() => _ReportDamageScreenState();
}

class _ReportDamageScreenState extends State<ReportDamageScreen> {
  File? damageImage;

  String? selectedCause;
  double? reportLatitude;
  double? reportLongitude;

  final List<String> damageCauses = [
    'Typhoon',
    'Flood',
    'Drought',
    'Pest Infestation',
    'Disease',
    'Rat Damage',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      captureDamageImage();
    });
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required.')),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      reportLatitude = position.latitude;
      reportLongitude = position.longitude;
    });
  }

  Future<void> captureDamageImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedImage != null) {
      await getCurrentLocation();

      setState(() {
        damageImage = File(pickedImage.path);
      });
    }
  }

  Future<void> submitDamageReport() async {
    if (damageImage == null ||
        selectedCause == null ||
        reportLatitude == null ||
        reportLongitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture damage photo and complete details.'),
        ),
      );
      return;
    }

    final token = await StorageHelper.getToken();

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login session missing.')));
      return;
    }

    final provider = Provider.of<DamageReportProvider>(context, listen: false);

    final response = await provider.submitDamageReport(
      token: token,
      farmId: widget.farm.id!,
      damageCause: selectedCause!,
      damageDate: DateTime.now().toIso8601String().substring(0, 10),

      damageImage: damageImage!,
      reportLatitude: reportLatitude.toString(),
      reportLongitude: reportLongitude.toString(),
    );

    if (!mounted) return;

    if (response['damage_report'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Damage report submitted successfully.',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Damage report failed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DamageReportProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Crop Damage'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.agriculture, color: Colors.green),
                title: Text(widget.farm.farmName),
                subtitle: Text(
                  '${widget.farm.cropType} • ${widget.farm.farmArea} ha',
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
                color: Colors.orange.shade50,
              ),
              child: damageImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        const Text('Opening camera...'),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: captureDamageImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Open Camera Again'),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(damageImage!, fit: BoxFit.cover),
                    ),
            ),

            const SizedBox(height: 12),

            if (reportLatitude != null && reportLongitude != null)
              Text(
                'Report location captured: $reportLatitude, $reportLongitude',
                style: const TextStyle(color: Colors.green, fontSize: 13),
              ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedCause,
              decoration: const InputDecoration(
                labelText: 'Ano ang sanhi ng pinsala? / Cause of Damage',
                border: OutlineInputBorder(),
              ),
              items: damageCauses
                  .map(
                    (cause) =>
                        DropdownMenuItem(value: cause, child: Text(cause)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCause = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : submitDamageReport,
                icon: const Icon(Icons.send),
                label: provider.isLoading
                    ? const Text('SUBMITTING...')
                    : const Text('SUBMIT DAMAGE REPORT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
