import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/farm_model.dart';
import '../../providers/damage_report_provider.dart';
import '../../providers/insurance_application_provider.dart';
import '../../core/utils/storage_helper.dart';

import '../insurance/apply_insurance_wizard_screen.dart';
import '../insurance/insurance_detail_screen.dart';
import '../insurance/insurance_history_screen.dart';
import '../damage/report_damage_screen.dart';

class FarmDetailScreen extends StatefulWidget {
  final FarmModel farm;
  const FarmDetailScreen({super.key, required this.farm});

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  static const String baseUrl = 'http://192.168.100.173:8000';

  static const _forest = Color(0xff1a3a2a);
  static const _forestLight = Color(0xff2a5c40);
  static const _surface = Color(0xfffafaf8);
  static const _divider = Color(0xffe2e8e4);
  static const _textPrimary = Color(0xff111e17);
  static const _textSecondary = Color(0xff6b7d72);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSync());
  }

  Future<void> _autoSync() async {
    final token = await StorageHelper.getToken();
    if (token == null || !mounted) return;
    await context.read<DamageReportProvider>().syncPendingReports(token: token);
    await context.read<InsuranceProvider>().syncPendingApplications(
      token: token,
    );
  }

  // ── Status helpers ─────────────────────────────────────────

  ({Color bg, Color text, Color border, IconData icon, String label})
  _statusStyle() {
    return switch (widget.farm.insuranceStatus) {
      'submitted_to_mao' => (
        bg: const Color(0xffdbeafe),
        text: const Color(0xff1e3a8a),
        border: const Color(0xff93c5fd),
        icon: Icons.hourglass_top_rounded,
        label: 'Submitted to MAO',
      ),
      'submitted_to_pcic' => (
        bg: const Color(0xffdbeafe),
        text: const Color(0xff1e3a8a),
        border: const Color(0xff93c5fd),
        icon: Icons.hourglass_top_rounded,
        label: 'Submitted to PCIC',
      ),
      'insured' => (
        bg: const Color(0xffd1fae5),
        text: const Color(0xff065f46),
        border: const Color(0xff6ee7b7),
        icon: Icons.verified_rounded,
        label: 'Insured',
      ),
      'rejected' => (
        bg: const Color(0xfffee2e2),
        text: const Color(0xff7f1d1d),
        border: const Color(0xfffca5a5),
        icon: Icons.cancel_rounded,
        label: 'Rejected',
      ),
      'pending' => (
        bg: const Color(0xfffff7ed),
        text: const Color(0xff92400e),
        border: const Color(0xfffcd34d),
        icon: Icons.pending_rounded,
        label: 'Pending',
      ),
      _ => (
        bg: Colors.white.withOpacity(0.18),
        text: Colors.white,
        border: Colors.white.withOpacity(0.3),
        icon: Icons.info_outline_rounded,
        label: 'Not Insured',
      ),
    };
  }

  bool get _isInsured => widget.farm.insuranceStatus == 'insured';
  bool get _isPending => widget.farm.insuranceStatus == 'pending';
  bool get _isRejected => widget.farm.insuranceStatus == 'rejected';
  bool get _isSubmittedToMao =>
      widget.farm.insuranceStatus == 'submitted_to_mao';
  bool get _isSubmittedToPcic =>
      widget.farm.insuranceStatus == 'submitted_to_pcic';
  bool get _isNotInsured =>
      !_isInsured &&
      !_isPending &&
      !_isRejected &&
      !_isSubmittedToMao &&
      !_isSubmittedToPcic;

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final imageUrl = '$baseUrl/storage/${widget.farm.farmImagePath}';
    final status = _statusStyle();

    return Scaffold(
      backgroundColor: _surface,
      body: CustomScrollView(
        slivers: [
          // ── Hero SliverAppBar ──────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: _forest,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _NotificationButton(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: GestureDetector(
                onTap: () => _openImageViewer(context, imageUrl),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Farm image
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _forestLight,
                        child: const Icon(
                          Icons.broken_image_rounded,
                          size: 60,
                          color: Colors.white30,
                        ),
                      ),
                    ),
                    // Dark overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                          stops: const [0.45, 1.0],
                        ),
                      ),
                    ),
                    // Name + status overlay
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status.bg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: status.border.withOpacity(0.6),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(status.icon, size: 12, color: status.text),
                                const SizedBox(width: 4),
                                Text(
                                  status.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: status.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.farm.farmName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                size: 12,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.farm.cropType,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.straighten_rounded,
                                size: 12,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.farm.farmArea} ha',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Farm info group
                  _sectionLabel('Farm details'),
                  const SizedBox(height: 8),
                  _infoGroup([
                    _InfoRow(
                      icon: Icons.grass_rounded,
                      label: 'Crop type',
                      value: widget.farm.cropType,
                    ),
                    _InfoRow(
                      icon: Icons.straighten_rounded,
                      label: 'Farm area',
                      value: '${widget.farm.farmArea} hectares',
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Pending sync banners (auto-synced, read-only)
                  Consumer<DamageReportProvider>(
                    builder: (context, dmgProvider, _) {
                      final count = dmgProvider.pendingReports
                          .where((r) => r['farm_id'] == widget.farm.id)
                          .length;
                      if (count == 0) return const SizedBox.shrink();
                      return _SyncBanner(
                        icon: Icons.cloud_upload_rounded,
                        color: Colors.orange,
                        title: 'Pending damage report',
                        subtitle:
                            '$count report(s) waiting for internet connection.',
                      );
                    },
                  ),

                  Consumer<InsuranceProvider>(
                    builder: (context, insProvider, _) {
                      final count = insProvider.pendingApplications
                          .where((a) => a['farm_id'] == widget.farm.id)
                          .length;
                      if (count == 0) return const SizedBox.shrink();
                      return _SyncBanner(
                        icon: Icons.assignment_late_rounded,
                        color: Colors.blue,
                        title: 'Pending insurance application',
                        subtitle:
                            '$count application(s) waiting for internet connection.',
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  _sectionLabel('Actions'),
                  const SizedBox(height: 8),

                  // View current insurance
                  if (_isInsured ||
                      _isPending ||
                      _isSubmittedToMao ||
                      _isSubmittedToPcic)
                    _ActionTile(
                      icon: Icons.file_copy_rounded,
                      iconBg: const Color(0xffeff6ff),
                      iconColor: const Color(0xff1d4ed8),
                      title: 'View current insurance',
                      subtitle: 'Active policy details',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InsuranceHistoryScreen(farm: widget.farm),
                        ),
                      ),
                    ),

                  // Report crop damage — insured only
                  if (_isInsured)
                    _ActionTile(
                      icon: Icons.report_problem_rounded,
                      iconBg: const Color(0xfffff7ed),
                      iconColor: const Color(0xffc2410c),
                      title: 'Report crop damage',
                      subtitle: 'File a damage claim with GPS & photo',
                      onTap: () {
                        if (widget.farm.id == null) {
                          _showSyncSnackBar(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportDamageScreen(farm: widget.farm),
                          ),
                        );
                      },
                    ),

                  // Resubmit — insured or rejected
                  if (_isInsured || _isRejected)
                    _ActionTile(
                      icon: Icons.refresh_rounded,
                      iconBg: const Color(0xfffffbeb),
                      iconColor: const Color(0xffb45309),
                      title: 'Resubmit for next cropping',
                      subtitle: _isInsured
                          ? 'Current season is covered'
                          : 'Previous application was rejected',
                      onTap: () {
                        if (widget.farm.id == null) {
                          _showSyncSnackBar(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ApplyInsuranceWizardScreen(
                              farm: widget.farm,
                              isResubmit: true,
                            ),
                          ),
                        );
                      },
                    ),

                  // Insurance history — always visible
                  _ActionTile(
                    icon: Icons.history_rounded,
                    iconBg: const Color(0xffeaf3de),
                    iconColor: const Color(0xff3b6d11),
                    title: 'Insurance history',
                    subtitle: 'Past applications & claims',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            InsuranceHistoryScreen(farm: widget.farm),
                      ),
                    ),
                  ),

                  // Apply — only if not insured/pending
                  if (_isNotInsured)
                    _ActionTile(
                      icon: Icons.assignment_rounded,
                      iconBg: const Color(0xffeaf3de),
                      iconColor: const Color(0xff2a5c40),
                      title: 'Apply crop insurance',
                      subtitle: 'Start a new insurance application',
                      onTap: () {
                        if (widget.farm.id == null) {
                          _showSyncSnackBar(context);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ApplyInsuranceWizardScreen(farm: widget.farm),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────

  Widget _sectionLabel(String title) => Text(
    title.toUpperCase(),
    style: TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: _textSecondary.withOpacity(0.6),
      letterSpacing: 1.2,
    ),
  );

  Widget _infoGroup(List<_InfoRow> rows) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _divider),
    ),
    child: Column(
      children: rows
          .asMap()
          .entries
          .map(
            (e) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xffeaf3de),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          e.value.icon,
                          size: 16,
                          color: const Color(0xff3b6d11),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.value.label,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: _textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.value.value,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (e.key < rows.length - 1)
                  Divider(height: 1, color: _divider),
              ],
            ),
          )
          .toList(),
    ),
  );

  void _showSyncSnackBar(BuildContext ctx) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text(
          'This farm is not yet synced. Please connect to the internet first.',
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext ctx, String imageUrl) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: InteractiveViewer(child: Image.network(imageUrl)),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _SyncBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _SyncBanner({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe2e8e4)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff111e17),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff6b7d72),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xff6b7d72),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Icon(
            Icons.notifications_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
        Positioned(
          top: 6,
          right: 7,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black26, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
