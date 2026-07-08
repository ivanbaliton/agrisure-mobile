import 'package:flutter/material.dart';

import '../../models/insurance_application_model.dart';

class InsuranceDetailScreen extends StatelessWidget {
  final InsuranceApplicationModel application;

  const InsuranceDetailScreen({super.key, required this.application});

  Color get statusColor {
    switch (application.status) {
      case 'insured':
        return Colors.green;
      case 'submitted_to_pcic':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String formatStatus(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insurance Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: statusColor.withOpacity(0.1),
              child: ListTile(
                leading: Icon(Icons.verified, color: statusColor),
                title: const Text('Application Status'),
                subtitle: Text(
                  formatStatus(application.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _sectionTitle('Coverage Information'),
            _infoCard([
              _row('Area Insured', '${application.insuredArea} ha'),
              _row('Free Covered Area', '${application.coveredFreeArea} ha'),
              _row('Paid Coverage', '${application.excessArea} ha'),
              _row(
                'Free Coverage Before',
                '${application.freeCoverageBefore} ha',
              ),
              _row(
                'Free Coverage After',
                '${application.freeCoverageAfter} ha',
              ),
              _row('Premium Amount', '₱${application.premiumAmount}'),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Payment Information'),
            _infoCard([
              _row('Payment Status', formatStatus(application.paymentStatus)),
              _row(
                'Payment Method',
                application.paymentMethod ?? 'Not required',
              ),
              _row(
                'GCash Reference',
                application.gcashReferenceNumber ?? 'Not available',
              ),
              _row(
                'Receipt',
                application.paymentProofPath == null
                    ? 'Not uploaded'
                    : 'Uploaded',
              ),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Applicant Information'),
            _infoCard([
              _row('Civil Status', application.civilStatus),
              _row('Beneficiary', application.beneficiaryName),
              _row('Spouse', application.spouseName ?? '—'),
              _row('Parent / Guardian', application.parentGuardianName ?? '—'),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Crop Information'),
            _infoCard([
              _row('Variety', application.variety),
              _row('Farm Type', application.farmType),
              _row('Sowing Date', application.sowingDate ?? '—'),
              _row('Transplanting Date', application.transplantingDate ?? '—'),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Boundaries'),
            _infoCard([
              _row('North', application.northBoundary),
              _row('East', application.eastBoundary),
              _row('West', application.westBoundary),
              _row('South', application.southBoundary),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Land Information'),
            _infoCard([
              _row('Land Owner', application.isLandOwner ? 'Yes' : 'No'),
              _row('Tenure Status', application.tenureStatus),
            ]),

            if (application.remarks != null &&
                application.remarks!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _sectionTitle('Remarks'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(application.remarks!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Card(child: Column(children: rows));
  }

  Widget _row(String label, String value) {
    return ListTile(
      dense: true,
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
