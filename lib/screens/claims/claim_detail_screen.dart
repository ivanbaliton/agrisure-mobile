import 'package:flutter/material.dart';

import '../../models/claim_model.dart';

class ClaimDetailScreen extends StatelessWidget {
  final ClaimModel claim;

  const ClaimDetailScreen({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _statusCard(),

            const SizedBox(height: 16),

            _sectionTitle('Farm Information'),
            _detailRow('Farm Name', claim.farmName),
            _detailRow('Crop Type', claim.cropType),
            _detailRow('Farm Area', '${claim.farmArea} ha'),

            const SizedBox(height: 16),

            _sectionTitle('Damage Information'),
            _detailRow('Damage Cause', claim.damageCause),
            _detailRow('Damage Date', claim.damageDate),

            const SizedBox(height: 16),

            _sectionTitle('Claim Information'),
            _detailRow(
              'Inspection Date',
              claim.inspectionDate ?? 'Not scheduled yet',
            ),
            _detailRow(
              'Claim Amount',
              claim.claimAmount == null
                  ? 'Not available yet'
                  : '₱${claim.claimAmount}',
            ),
            _detailRow(
              'Claim Schedule',
              claim.claimSchedule ?? 'Not scheduled yet',
            ),
            _detailRow('Claim Venue', claim.claimVenue ?? 'Not available yet'),

            const SizedBox(height: 16),

            _sectionTitle('Status Tracker'),
            _statusTracker(),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    final statusText = _formatStatus(claim.status);
    final color = _statusColor(claim.status);

    return Card(
      color: color.withOpacity(0.10),
      child: ListTile(
        leading: Icon(Icons.verified, color: color),
        title: const Text('Claim Status'),
        subtitle: Text(
          statusText,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _statusTracker() {
    final steps = [
      'submitted_to_mao',
      'under_validation',
      'submitted_to_pcic',
      'approved',
      'ready_for_claiming',
      'claimed',
    ];

    final currentIndex = steps.indexOf(claim.status);

    if (claim.status == 'rejected') {
      return Column(
        children: [
          _trackerItem('Submitted to MAO', true),
          _trackerItem('Under Validation', true),
          _trackerItem('Rejected', true, isRejected: true),
        ],
      );
    }

    return Column(
      children: steps.map((step) {
        final index = steps.indexOf(step);
        final isDone = currentIndex >= index;

        return _trackerItem(_formatStatus(step), isDone);
      }).toList(),
    );
  }

  Widget _trackerItem(String title, bool isDone, {bool isRejected = false}) {
    final color = isRejected
        ? Colors.red
        : isDone
        ? Colors.green
        : Colors.grey;

    return ListTile(
      leading: Icon(
        isDone ? Icons.check_circle : Icons.radio_button_unchecked,
        color: color,
      ),
      title: Text(title),
    );
  }

  Widget _detailRow(String label, String value) {
    return Card(
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'submitted_to_mao':
        return 'Submitted to MAO';
      case 'under_validation':
        return 'Under Validation';
      case 'submitted_to_pcic':
        return 'Submitted to PCIC';
      case 'approved':
        return 'Approved';
      case 'ready_for_claiming':
        return 'Ready for Claiming';
      case 'claimed':
        return 'Claimed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'submitted_to_mao':
        return Colors.orange;
      case 'under_validation':
        return Colors.blue;
      case 'submitted_to_pcic':
        return Colors.indigo;
      case 'approved':
      case 'ready_for_claiming':
      case 'claimed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
