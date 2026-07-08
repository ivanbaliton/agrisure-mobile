import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/storage_helper.dart';
import '../../providers/farm_provider.dart';
import 'farm_detail_screen.dart';
import 'register_farm_screen.dart';

class FarmScreen extends StatefulWidget {
  const FarmScreen({super.key});

  @override
  State<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends State<FarmScreen> {
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
  static const _errorRed = Color(0xffb84040);

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadAndSync());
  }

  Future<void> _loadAndSync() async {
    final token = await StorageHelper.getToken();
    final userId = await StorageHelper.getUserId();
    if (token == null || userId == null || !mounted) return;

    final provider = context.read<FarmProvider>();

    // Auto-sync pending farms first
    if (provider.pendingFarms.isNotEmpty) {
      setState(() => _isSyncing = true);
      await provider.syncPendingFarms(token: token);
      setState(() => _isSyncing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pending farms synced successfully.'),
            backgroundColor: _forest,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }

    await provider.fetchFarms(token: token, userId: int.parse(userId));
  }

  Future<void> _refresh() async {
    final token = await StorageHelper.getToken();
    final userId = await StorageHelper.getUserId();
    if (token == null || userId == null || !mounted) return;

    final provider = context.read<FarmProvider>();

    if (provider.pendingFarms.isNotEmpty) {
      setState(() => _isSyncing = true);
      await provider.syncPendingFarms(token: token);
      setState(() => _isSyncing = false);
    }

    await provider.fetchFarms(token: token, userId: int.parse(userId));
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = context.watch<FarmProvider>();
    final syncedFarms = farmProvider.farms;
    final pendingFarms = farmProvider.pendingFarms;
    final hasNoFarms = syncedFarms.isEmpty && pendingFarms.isEmpty;

    return Scaffold(
      backgroundColor: _forest,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterFarmScreen()),
          );
          await _refresh();
        },
        backgroundColor: _gold,
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Farms',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${syncedFarms.length} registered farm${syncedFarms.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Bottom card ──────────────────────────────
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: farmProvider.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: _forest),
                          )
                        : RefreshIndicator(
                            color: _forest,
                            onRefresh: _refresh,
                            child: hasNoFarms
                                ? _emptyState()
                                : ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      24,
                                      20,
                                      100,
                                    ),
                                    children: [
                                      // Drag handle
                                      Center(
                                        child: Container(
                                          width: 36,
                                          height: 4,
                                          margin: const EdgeInsets.only(
                                            bottom: 20,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _divider,
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // ── Syncing banner ───────────
                                      if (_isSyncing) _syncingBanner(),

                                      // ── Pending farms ─────────────
                                      if (pendingFarms.isNotEmpty) ...[
                                        _sectionLabel(
                                          'Pending Sync',
                                          '${pendingFarms.length} farm${pendingFarms.length == 1 ? '' : 's'}',
                                        ),
                                        const SizedBox(height: 10),
                                        ...pendingFarms.map(
                                          (farm) => _pendingCard(farm),
                                        ),
                                        const SizedBox(height: 20),
                                      ],

                                      // ── Synced farms ──────────────
                                      if (syncedFarms.isNotEmpty) ...[
                                        _sectionLabel(
                                          'Registered Farms',
                                          '${syncedFarms.length} total',
                                        ),
                                        const SizedBox(height: 10),
                                        ...syncedFarms.map(
                                          (farm) => _farmCard(farm),
                                        ),
                                      ],
                                    ],
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

  // ── Farm photo card ─────────────────────────────────────────
  Widget _farmCard(dynamic farm) {
    final rawPath = farm.farmImagePath as String? ?? '';
    final storageBase = ApiConstants.baseUrl.replaceAll('/api', '');
    final imageUrl = rawPath.isNotEmpty
        ? rawPath.startsWith('http')
              ? rawPath
              : '$storageBase/storage/$rawPath'
        : '';
    final cropType = farm.cropType as String? ?? '';
    final cropEmoji = cropType.toLowerCase() == 'rice' ? '🌾' : '🌽';

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FarmDetailScreen(farm: farm)),
        );
        await _refresh();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _inputBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Farm image — network with cache, or local file for offline captured
            Positioned.fill(
              child: imageUrl.isNotEmpty
                  ? imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _imagePlaceholder(),
                            errorWidget: (_, __, ___) => _imagePlaceholder(),
                          )
                        : Image.file(
                            File(imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                  : _imagePlaceholder(),
            ),

            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.3, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Top right — crop badge
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cropEmoji, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 5),
                    Text(
                      cropType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom — farm info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            farm.farmName ?? 'Unnamed Farm',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.straighten_rounded,
                                size: 13,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${farm.farmArea} hectares',
                                style: const TextStyle(
                                  fontSize: 12.5,
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
          ],
        ),
      ),
    );
  }

  // ── Pending farm card ───────────────────────────────────────
  Widget _pendingCard(Map<String, dynamic> farm) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xfffff8ed),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _gold.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.sync_problem_rounded, size: 22, color: _gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                farm['farm_name'] ?? 'Unnamed Farm',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${farm['crop_type']} • ${farm['farm_area']} ha',
                style: TextStyle(fontSize: 12.5, color: _textSecondary),
              ),
              const SizedBox(height: 3),
              Text(
                'Waiting for internet connection',
                style: TextStyle(
                  fontSize: 11.5,
                  color: _gold.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.cloud_off_rounded, size: 18, color: _gold),
      ],
    ),
  );

  // ── Syncing banner ──────────────────────────────────────────
  Widget _syncingBanner() => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _goldSoft,
      borderRadius: BorderRadius.circular(12),
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
          'Syncing pending farms...',
          style: TextStyle(
            fontSize: 12.5,
            color: _gold.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  // ── Section label ───────────────────────────────────────────
  Widget _sectionLabel(String title, String count) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: _textSecondary.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: 10.5,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );

  // ── Empty state ─────────────────────────────────────────────
  Widget _emptyState() => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: _divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _forest.withOpacity(0.07),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.agriculture_outlined,
                  size: 38,
                  color: _forestLight,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Farms Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Register your first farm to start\nmanaging your crop insurance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterFarmScreen(),
                    ),
                  );
                  await _refresh();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _gold,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: _gold.withOpacity(0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Register Your First Farm',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ── Image placeholder ───────────────────────────────────────
  Widget _imagePlaceholder() => Container(
    color: _inputBg,
    child: const Center(
      child: Icon(Icons.landscape_outlined, size: 48, color: Color(0xffb8c4a8)),
    ),
  );

  Widget _bgCircle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
