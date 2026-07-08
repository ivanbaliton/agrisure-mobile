import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/storage_helper.dart';
import '../../providers/claim_provider.dart';
import 'claim_detail_screen.dart';

class ClaimsScreen extends StatefulWidget {
  const ClaimsScreen({super.key});

  @override
  State<ClaimsScreen> createState() => _ClaimsScreenState();
}

class _ClaimsScreenState extends State<ClaimsScreen> {
  @override
  void initState() {
    super.initState();
    loadClaims();
  }

  Future<void> loadClaims() async {
    final token = await StorageHelper.getToken();
    final userId = await StorageHelper.getUserId();

    if (token == null || userId == null) return;

    if (!mounted) return;

    await Provider.of<ClaimProvider>(
      context,
      listen: false,
    ).fetchMyClaims(token: token, userId: int.parse(userId));
  }

  @override
  Widget build(BuildContext context) {
    final claimProvider = Provider.of<ClaimProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claims'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadClaims,
        child: claimProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : claimProvider.claims.isEmpty
            ? const Center(child: Text('No claims yet.'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: claimProvider.claims.length,
                itemBuilder: (context, index) {
                  final claim = claimProvider.claims[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.receipt_long,
                        color: Colors.green,
                      ),
                      title: Text(claim.farmName),
                      subtitle: Text(
                        '${claim.damageCause} • ${_formatStatus(claim.status)}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClaimDetailScreen(claim: claim),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
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
}
