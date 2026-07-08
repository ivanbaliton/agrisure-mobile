import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/storage_helper.dart';
import '../../models/farm_model.dart';
import '../../providers/insurance_application_provider.dart';
import '../../providers/profile_provider.dart';

class ApplyInsuranceWizardScreen extends StatefulWidget {
  final FarmModel farm;
  final bool isResubmit;

  const ApplyInsuranceWizardScreen({
    super.key,
    required this.farm,
    this.isResubmit = false,
  });

  @override
  State<ApplyInsuranceWizardScreen> createState() =>
      _ApplyInsuranceWizardScreenState();
}

class _ApplyInsuranceWizardScreenState
    extends State<ApplyInsuranceWizardScreen> {
  int currentStep = 0;

  String? civilStatus;
  String? farmType;
  String? isLandOwner;
  String? tenureStatus;

  File? signatureFile;
  File? paymentProofFile;

  int? activeSeasonId;
  String? activeSeasonName;
  bool loadingCoverage = true;

  double freeCoverageLimit = 3.0;
  double usedFreeArea = 0.0;

  final insuredAreaController = TextEditingController();
  final beneficiaryController = TextEditingController();
  final spouseController = TextEditingController();
  final parentGuardianController = TextEditingController();
  final varietyController = TextEditingController();
  final sowingDateController = TextEditingController();
  final transplantingDateController = TextEditingController();
  final northController = TextEditingController();
  final eastController = TextEditingController();
  final westController = TextEditingController();
  final southController = TextEditingController();
  final gcashReferenceController = TextEditingController();

  final double premiumRate = 1000.0;

  double get registeredFarmArea => double.tryParse(widget.farm.farmArea) ?? 0;
  double get insuredArea => double.tryParse(insuredAreaController.text) ?? 0;

  double get remainingFreeArea {
    final remaining = freeCoverageLimit - usedFreeArea;
    return remaining < 0 ? 0 : remaining;
  }

  double get coveredFreeArea {
    if (insuredArea <= 0) return 0;
    return insuredArea > remainingFreeArea ? remainingFreeArea : insuredArea;
  }

  double get excessArea {
    final excess = insuredArea - coveredFreeArea;
    return excess < 0 ? 0 : excess;
  }

  double get premiumAmount => excessArea * premiumRate;
  bool get requiresPayment => premiumAmount > 0;

  final SignatureController signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await loadFreeCoverage();
    });
  }

  Future<void> loadFreeCoverage() async {
    try {
      final token = await StorageHelper.getToken();
      final userId = await StorageHelper.getUserId();

      if (token == null || userId == null) {
        setState(() => loadingCoverage = false);
        return;
      }

      final data = await context.read<InsuranceProvider>().getFreeCoverage(
        token: token,
        userId: int.parse(userId),
      );

      if (!mounted) return;

      setState(() {
        usedFreeArea =
            double.tryParse(data['used_free_area'].toString()) ?? 0.0;
        freeCoverageLimit =
            double.tryParse(data['free_coverage_limit'].toString()) ?? 3.0;
        activeSeasonId = data['season']?['id'];
        activeSeasonName = data['season']?['season_name'];
        loadingCoverage = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loadingCoverage = false);
    }
  }

  Future<void> pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      controller.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Future<void> pickPaymentProof() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      paymentProofFile = File(image.path);
    });
  }

  Future<void> openGcash() async {
    final uri = Uri.parse('gcash://');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      _showSnack('GCash app is not installed on this device.');
    }
  }

  void nextStep(List<Widget> questions) {
    if (!_validateCurrentStep()) return;

    if (currentStep < questions.length - 1) {
      setState(() => currentStep++);
    } else {
      submitApplication();
    }
  }

  bool _validateCurrentStep() {
    if (currentStep == 0) {
      if (insuredArea <= 0) {
        _showSnack('Please enter area to insure.');
        return false;
      }

      if (insuredArea > registeredFarmArea) {
        _showSnack('Area to insure cannot exceed registered farm area.');
        return false;
      }
    }

    return true;
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  Future<File?> saveSignature() async {
    if (signatureController.isEmpty) return null;

    final Uint8List? data = await signatureController.toPngBytes();
    if (data == null) return null;

    final dir = await getTemporaryDirectory();

    final file = File(
      '${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(data);
    return file;
  }

  Future<void> submitApplication() async {
    final token = await StorageHelper.getToken();

    if (token == null) {
      _showSnack('Login session missing.');
      return;
    }

    if (widget.farm.id == null) {
      _showSnack('This farm is not yet synced. Please connect first.');
      return;
    }

    if (insuredArea <= 0 || insuredArea > registeredFarmArea) {
      _showSnack('Please enter a valid area to insure.');
      return;
    }

    if (civilStatus == null ||
        farmType == null ||
        isLandOwner == null ||
        tenureStatus == null) {
      _showSnack('Please complete all required fields.');
      return;
    }

    if (beneficiaryController.text.trim().isEmpty ||
        varietyController.text.trim().isEmpty ||
        northController.text.trim().isEmpty ||
        eastController.text.trim().isEmpty ||
        westController.text.trim().isEmpty ||
        southController.text.trim().isEmpty) {
      _showSnack('Please complete all required text fields.');
      return;
    }

    if (requiresPayment) {
      if (gcashReferenceController.text.trim().isEmpty) {
        _showSnack('Please enter GCash reference number.');
        return;
      }

      if (paymentProofFile == null) {
        _showSnack('Please upload GCash receipt.');
        return;
      }
    }

    signatureFile = await saveSignature();

    if (signatureFile == null) {
      _showSnack('Please provide your signature.');
      return;
    }

    final provider = Provider.of<InsuranceProvider>(context, listen: false);

    final response = await provider.applyInsurance(
      token: token,
      farmId: widget.farm.id!,

      insuredArea: insuredArea,
      civilStatus: civilStatus!,
      beneficiaryName: beneficiaryController.text.trim(),
      spouseName: spouseController.text.trim(),
      parentGuardianName: parentGuardianController.text.trim(),
      variety: varietyController.text.trim(),
      farmType: farmType!,
      sowingDate: sowingDateController.text.trim(),
      transplantingDate: transplantingDateController.text.trim(),
      northBoundary: northController.text.trim(),
      eastBoundary: eastController.text.trim(),
      westBoundary: westController.text.trim(),
      southBoundary: southController.text.trim(),
      isLandOwner: isLandOwner == 'Yes',
      tenureStatus: tenureStatus!,
      signature: signatureFile!,
      paymentProof: paymentProofFile,
      gcashReferenceNumber: gcashReferenceController.text.trim(),
    );

    if (!mounted) return;

    _showSnack(response['message'] ?? 'Application submitted.');

    if (response['application'] != null || response['offline'] == true) {
      Navigator.pop(context);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (loadingCoverage) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final questions = [
      _coveragePage(),
      _dropdownQuestion(
        title: 'Ano ang iyong civil status?',
        subtitle: 'What is your civil status?',
        value: civilStatus,
        items: ['Single', 'Married', 'Widowed', 'Separated'],
        onChanged: (value) => setState(() => civilStatus = value),
      ),
      _textQuestion(
        title: 'Sino ang iyong beneficiary?',
        subtitle: 'Who is your beneficiary?',
        controller: beneficiaryController,
      ),
      civilStatus == 'Married'
          ? _textQuestion(
              title: 'Ano ang pangalan ng iyong asawa?',
              subtitle: "What is your spouse's name?",
              controller: spouseController,
            )
          : _textQuestion(
              title: 'Ano ang pangalan ng iyong magulang o guardian?',
              subtitle: "What is your parent or guardian's name?",
              controller: parentGuardianController,
            ),
      _textQuestion(
        title: 'Anong variety ang iyong itinanim?',
        subtitle: 'What crop variety did you plant?',
        controller: varietyController,
      ),
      _dropdownQuestion(
        title: 'Anong uri ng sakahan ang mayroon ka?',
        subtitle: 'What type of farm do you have?',
        value: farmType,
        items: ['Irrigated', 'Rainfed'],
        onChanged: (value) => setState(() => farmType = value),
      ),
      _dateQuestion(
        title: 'Kailan ka nagsimulang maghasik?',
        subtitle: 'When did you start sowing?',
        controller: sowingDateController,
      ),
      _dateQuestion(
        title: 'Kailan isinagawa ang transplanting?',
        subtitle: 'When was transplanting done?',
        controller: transplantingDateController,
      ),
      _textQuestion(
        title: 'Sino ang may-ari ng katabing sakahan sa Hilaga?',
        subtitle: 'Who owns the farm on the North side?',
        controller: northController,
      ),
      _textQuestion(
        title: 'Sino ang may-ari ng katabing sakahan sa Silangan?',
        subtitle: 'Who owns the farm on the East side?',
        controller: eastController,
      ),
      _textQuestion(
        title: 'Sino ang may-ari ng katabing sakahan sa Kanluran?',
        subtitle: 'Who owns the farm on the West side?',
        controller: westController,
      ),
      _textQuestion(
        title: 'Sino ang may-ari ng katabing sakahan sa Timog?',
        subtitle: 'Who owns the farm on the South side?',
        controller: southController,
      ),
      _dropdownQuestion(
        title: 'Ikaw ba ang may-ari ng lupang sinasaka?',
        subtitle: 'Are you the owner of the land?',
        value: isLandOwner,
        items: ['Yes', 'No'],
        onChanged: (value) => setState(() => isLandOwner = value),
      ),
      _dropdownQuestion(
        title: 'Ano ang iyong tenure status?',
        subtitle: 'What is your land tenure status?',
        value: tenureStatus,
        items: ['Owner Cultivator', 'Tenant', 'Leaseholder', 'Others'],
        onChanged: (value) => setState(() => tenureStatus = value),
      ),
      if (requiresPayment) _paymentPage(),
      _signaturePage(),
      _reviewPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Insurance'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentStep + 1) / questions.length,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Step ${currentStep + 1} of ${questions.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(child: questions[currentStep]),
            Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousStep,
                      child: const Text('Back'),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => nextStep(questions),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      currentStep == questions.length - 1 ? 'Submit' : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coveragePage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _questionHeader(
            'Insurance Coverage',
            'Select how many hectares you want to insure.',
          ),
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.calendar_month),
              title: Text(activeSeasonName ?? 'Dry Season 2026'),
              subtitle: const Text('Current Insurance Season'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.green.shade50,
            child: Column(
              children: [
                _coverageTile(
                  'Total Free Coverage',
                  '${freeCoverageLimit.toStringAsFixed(2)} ha',
                ),
                _coverageTile(
                  'Used Free Coverage',
                  '${usedFreeArea.toStringAsFixed(2)} ha',
                ),
                _coverageTile(
                  'Available Free Coverage',
                  '${remainingFreeArea.toStringAsFixed(2)} ha',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _paymentInfoCard(
            'Registered Farm Area',
            '${registeredFarmArea.toStringAsFixed(2)} ha',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: insuredAreaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Area To Insure (ha)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final value = remainingFreeArea > registeredFarmArea
                    ? registeredFarmArea
                    : remainingFreeArea;

                insuredAreaController.text = value.toStringAsFixed(2);
                setState(() {});
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Use Available Free Coverage'),
            ),
          ),
          const SizedBox(height: 16),
          _coverageSummaryCard(),
        ],
      ),
    );
  }

  Widget _coverageSummaryCard() {
    return Card(
      color: requiresPayment ? Colors.orange.shade50 : Colors.green.shade50,
      child: Column(
        children: [
          _coverageTile(
            'Area To Insure',
            '${insuredArea.toStringAsFixed(2)} ha',
          ),
          _coverageTile(
            'Free Covered Area',
            '${coveredFreeArea.toStringAsFixed(2)} ha',
          ),
          _coverageTile('Paid Coverage', '${excessArea.toStringAsFixed(2)} ha'),
          _coverageTile(
            'Premium Amount',
            '₱${premiumAmount.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _coverageTile(String title, String value) {
    return ListTile(
      dense: true,
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _paymentPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _questionHeader(
            'Insurance Premium Payment',
            'Payment is required when free coverage is exceeded.',
          ),
          _paymentInfoCard(
            'Premium Amount',
            '₱${premiumAmount.toStringAsFixed(2)}',
          ),
          Card(
            child: ListTile(
              title: const Text('GCash Payment Details'),
              subtitle: const Text(
                'GCash Name: Municipal Agriculture Office\nGCash Number: 0917-XXX-XXXX',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.account_balance_wallet),
                onPressed: openGcash,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: openGcash,
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('Open GCash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: gcashReferenceController,
            decoration: const InputDecoration(
              labelText: 'GCash Reference Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: pickPaymentProof,
              icon: const Icon(Icons.upload_file),
              label: Text(
                paymentProofFile == null
                    ? 'Upload GCash Receipt'
                    : 'Receipt Uploaded',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentInfoCard(String title, String value) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _signaturePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _questionHeader('Lagda ng Aplikante', 'Applicant Signature'),
        Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
          child: Signature(
            controller: signatureController,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            signatureController.clear();
          },
          icon: const Icon(Icons.clear),
          label: const Text('Clear Signature'),
        ),
      ],
    );
  }

  Widget _textQuestion({
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _questionHeader(title, subtitle),
        TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _dateQuestion({
    required String title,
    required String subtitle,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _questionHeader(title, subtitle),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () => pickDate(controller),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_month),
          ),
        ),
      ],
    );
  }

  Widget _dropdownQuestion({
    required String title,
    required String subtitle,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _questionHeader(title, subtitle),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _questionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _reviewPage() {
    final profile = context.watch<ProfileProvider>().profile;
    final personal = profile?['personal_information'] ?? {};

    final farmerName = profile?['full_name'] ?? 'Not available';
    final rsbsa = profile?['rsbsa_reference'] ?? 'Not available';
    final contact = personal['contact'] ?? 'Not available';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _questionHeader(
            'Suriin ang iyong aplikasyon',
            'Review your application before submitting.',
          ),
          const Text(
            'Farmer Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Name: $farmerName'),
          Text('RSBSA No.: $rsbsa'),
          Text('Contact: $contact'),
          const Divider(),
          const Text(
            'Season Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Season: ${activeSeasonName ?? 'Will be assigned automatically'}',
          ),
          const Divider(),
          const Text(
            'Farm Information',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Farm: ${widget.farm.farmName}'),
          Text('Crop: ${widget.farm.cropType}'),
          Text('Registered Area: ${registeredFarmArea.toStringAsFixed(2)} ha'),
          Text('Area To Insure: ${insuredArea.toStringAsFixed(2)} ha'),
          const Divider(),
          const Text(
            'Coverage Summary',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Total Free Coverage: ${freeCoverageLimit.toStringAsFixed(2)} ha',
          ),
          Text('Used Free Coverage: ${usedFreeArea.toStringAsFixed(2)} ha'),
          Text(
            'Available Before Application: ${remainingFreeArea.toStringAsFixed(2)} ha',
          ),
          Text('Free Covered Area: ${coveredFreeArea.toStringAsFixed(2)} ha'),
          Text('Paid Coverage: ${excessArea.toStringAsFixed(2)} ha'),
          Text('Premium Amount: ₱${premiumAmount.toStringAsFixed(2)}'),
          if (requiresPayment) ...[
            const Divider(),
            const Text(
              'Payment Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('GCash Reference: ${gcashReferenceController.text}'),
            Text(
              paymentProofFile == null
                  ? 'Receipt: Not uploaded'
                  : 'Receipt: Uploaded',
            ),
          ],
          const Divider(),
          const Text(
            'Application Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Civil Status: $civilStatus'),
          Text('Beneficiary: ${beneficiaryController.text}'),
          Text('Variety: ${varietyController.text}'),
          Text('Farm Type: $farmType'),
          Text('Sowing Date: ${sowingDateController.text}'),
          Text('Transplanting Date: ${transplantingDateController.text}'),
          Text('North: ${northController.text}'),
          Text('East: ${eastController.text}'),
          Text('West: ${westController.text}'),
          Text('South: ${southController.text}'),
          Text('Land Owner: $isLandOwner'),
          Text('Tenure Status: $tenureStatus'),
          const Divider(),
          const Text('Signature: Provided'),
        ],
      ),
    );
  }
}
