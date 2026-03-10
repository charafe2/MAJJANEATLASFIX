import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/service_request_repository.dart';

// ── Filter tabs ───────────────────────────────────────────────────────────────

const _kStatuses = [
  _Tab('all',         'Tous'),
  _Tab('open',        'En attente'),
  _Tab('in_progress', 'Accepté'),
  _Tab('cancelled',   'Annulé'),
  _Tab('completed',   'Terminé'),
];

IconData _categoryIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('plomb'))    return Icons.water_drop_outlined;
  if (n.contains('élec') || n.contains('elec')) return Icons.bolt_outlined;
  if (n.contains('peinture')) return Icons.format_paint_outlined;
  if (n.contains('menuiser')) return Icons.carpenter_outlined;
  if (n.contains('nettoy'))   return Icons.cleaning_services_outlined;
  if (n.contains('jardinage')|| n.contains('jardin')) return Icons.yard_outlined;
  if (n.contains('restaur'))  return Icons.restaurant_outlined;
  if (n.contains('beauté') || n.contains('coiff')) return Icons.face_outlined;
  if (n.contains('déménag'))  return Icons.local_shipping_outlined;
  if (n.contains('climatis') || n.contains('clim')) return Icons.ac_unit_outlined;
  return Icons.build_outlined;
}

Color _categoryColor(String name) {
  final n = name.toLowerCase();
  if (n.contains('plomb'))                           return const Color(0xFF2B7FFF);
  if (n.contains('élec') || n.contains('elec'))      return const Color(0xFFF0B100);
  if (n.contains('restaur'))                         return const Color(0xFF00AA44);
  if (n.contains('beauté') || n.contains('coiff'))   return const Color(0xFFF6339A);
  if (n.contains('peinture'))                        return const Color(0xFF7C3AED);
  if (n.contains('menuiser'))                        return const Color(0xFF92400E);
  if (n.contains('nettoy'))                          return const Color(0xFF0891B2);
  if (n.contains('jardinage'))                       return const Color(0xFF16A34A);
  if (n.contains('déménag'))                         return const Color(0xFF8B5CF6);
  return const Color(0xFFFC5A15);
}

// ─────────────────────────────────────────────────────────────────────────────

class ClientMesDemandesScreen extends StatefulWidget {
  const ClientMesDemandesScreen({super.key});
  @override
  State<ClientMesDemandesScreen> createState() => _ClientMesDemandesScreenState();
}

class _ClientMesDemandesScreenState extends State<ClientMesDemandesScreen> {
  final _repo = ServiceRequestRepository();

  String _activeFilter = 'all';

  bool _isLoading = true;
  String? _error;
  List<ServiceRequest> _requests = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _repo.getRequests();
      if (mounted) {
        setState(() {
          _requests  = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ServiceRequestRepository.errorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  List<ServiceRequest> get _filtered {
    if (_activeFilter == 'all') return _requests;
    return _requests.where((r) => r.status == _activeFilter).toList();
  }

  Map<String, int> get _counts {
    final m = <String, int>{'all': _requests.length};
    for (final r in _requests) {
      m[r.status] = (m[r.status] ?? 0) + 1;
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Warm gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.55],
                  colors: [Color(0x33FC5A15), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              _buildTitleRow(),
              _buildFilterBar(),
              Expanded(child: _buildBody()),
            ],
          ),

          // Busy overlay
          if (_busy)
            const Positioned.fill(child: ColoredBox(
              color: Color(0x44000000),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )),

          // Bottom nav
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: 1)),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              // Logo + icon buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.push('/client/agenda'),
                      child: const _HeaderIconBtn(Icons.calendar_today_outlined),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => context.push('/client/notifications'),
                      child: const _HeaderIconBtn(Icons.notifications_none_rounded),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF393C40), size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Quelle service recherchez-vous ?',
                        style: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                            color: Color(0xFF494949))),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/client/service-categories'),
                      child: Container(
                        width: 36, height: 36,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF393C40),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Title row ───────────────────────────────────────────────────────────────
  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Mes demandes',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.306,
                    color: Color(0xFF191C24),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: Color(0xFF62748E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.assignment_outlined,
              color: AppColors.primary, size: 28),
        ],
      ),
    );
  }

  // ── Filter tab bar ─────────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    final counts = _counts;
    final tabs = _kStatuses.where((t) => t.key == 'all' || (counts[t.key] ?? 0) > 0).toList();

    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final tab    = tabs[i];
          final active = _activeFilter == tab.key;
          final count  = counts[tab.key] ?? 0;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = tab.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: active ? [const BoxShadow(
                  color: Color(0x29FC5A15), blurRadius: 8, offset: Offset(0, 3),
                )] : [],
              ),
              child: Text('${tab.label} ($count)',
                style: TextStyle(
                  fontFamily: 'Public Sans', fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF62748E),
                )),
            ),
          );
        },
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                    color: Color(0xFF62748E))),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filtered;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Aucune demande pour le moment.',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 15,
                  color: Color(0xFF9CA3AF))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/client/service-categories'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: const Text('Créer une demande',
                  style: TextStyle(fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final req = filtered[i];
          return _RequestCard(
            request:  req,
            onTap:    () {
              final isActive = req.status == 'in_progress' ||
                               req.status == 'completed';
              if (isActive) {
                context.push(
                  '/client/request-view/${req.id}',
                  extra: {'request': req},
                );
              } else {
                context.push(
                  '/client/request-offers/${req.id}',
                  extra: {'request': req},
                );
              }
            },
            onCancel: () => _showCancelDialog(req),
          );
        },
      ),
    );
  }

  // ── Dialogs & actions ──────────────────────────────────────────────────────
  void _showCancelDialog(ServiceRequest req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeleteBottomSheet(
        category: req.category,
        onConfirm: (reason) async {
          setState(() => _busy = true);
          try {
            await _repo.cancelRequest(req.id);
            await _load();
            if (mounted) _showSnack('Demande annulée.', success: true);
          } catch (e) {
            if (mounted) _showSnack(ServiceRequestRepository.errorMessage(e), success: false);
          } finally {
            if (mounted) setState(() => _busy = false);
          }
        },
      ),
    );
  }

  void _showSnack(String msg, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
        style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
      backgroundColor: success ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    ));
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback   onTap;
  final VoidCallback   onCancel;

  const _RequestCard({
    required this.request,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final color      = _categoryColor(request.category);
    final offerCount = request.offers.length;
    final avatarUrls = request.offers
        .where((o) => o.artisanAvatar != null && o.artisanAvatar!.isNotEmpty)
        .map((o) => o.artisanAvatar!)
        .take(3)
        .toList();
    final extraCount = (offerCount - 3).clamp(0, 99);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 19, 17, 19),
          child: Row(
            children: [
              // Colored rounded-square icon
              Container(
                width: 51, height: 51,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(_categoryIcon(request.category),
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),

              // Category name
              Expanded(
                child: Text(request.category,
                  style: const TextStyle(fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w500, fontSize: 20,
                      letterSpacing: -0.449, color: Color(0xFF314158)),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 10),

              // Response count + stacked avatars
              if (offerCount > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$offerCount réponse${offerCount > 1 ? 's' : ''}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12,
                          color: Color(0xFF314158))),
                    const SizedBox(height: 4),
                    _StackedAvatars(urls: avatarUrls, extra: extraCount),
                  ],
                ),
              const SizedBox(width: 10),

              // Trash button — stops propagation with its own GestureDetector
              if (request.status == 'open' || request.status == 'in_progress')
                GestureDetector(
                  onTap: onCancel,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 35, height: 35,
                    decoration: const BoxDecoration(
                      color: Color(0x1AE7000B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFE7000B), size: 18),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stacked avatars ───────────────────────────────────────────────────────────

class _StackedAvatars extends StatelessWidget {
  final List<String> urls;
  final int extra; // count beyond 3

  const _StackedAvatars({required this.urls, required this.extra});

  static const _size   = 26.0;
  static const _offset = 13.0; // overlap

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (int i = 0; i < urls.length; i++) {
      items.add(Positioned(
        left: i * _offset,
        child: _circle(child: Image.network(urls[i], fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(i))),
      ));
    }
    if (extra > 0) {
      items.add(Positioned(
        left: urls.length * _offset,
        child: _circle(
          color: const Color(0xFFFC5A15),
          child: Text('+$extra',
            style: const TextStyle(fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500, fontSize: 7,
                color: Color(0xFFFC5A15))),
        ),
      ));
    }
    final totalWidth = _offset * (urls.length - 1) + _size
        + (extra > 0 ? _offset : 0);
    return SizedBox(
      width: totalWidth.clamp(_size, 200),
      height: _size,
      child: Stack(children: items),
    );
  }

  Widget _circle({required Widget child, Color? color}) => Container(
    width: _size, height: _size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color ?? const Color(0xFFE5E7EB),
      border: Border.all(color: Colors.white, width: 0.93),
    ),
    child: ClipOval(child: child),
  );

  Widget _placeholder(int i) {
    const colors = [Color(0xFF93C5FD), Color(0xFF6EE7B7), Color(0xFFFCA5A5)];
    return Container(color: colors[i % colors.length]);
  }
}

// ── Delete bottom sheet ───────────────────────────────────────────────────────

class _DeleteBottomSheet extends StatefulWidget {
  final String category;
  final Future<void> Function(String reason) onConfirm;
  const _DeleteBottomSheet({required this.category, required this.onConfirm});

  @override
  State<_DeleteBottomSheet> createState() => _DeleteBottomSheetState();
}

class _DeleteBottomSheetState extends State<_DeleteBottomSheet> {
  final _ctrl   = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, -2))],
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(29, 28, 29, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Title row ──────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Supprimer la demande',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.31,
                      color: Color(0xFF191C24),
                    ),
                  ),
                  const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFE7000B), size: 25),
                ],
              ),
              const SizedBox(height: 8),

              // ── Breadcrumb ─────────────────────────────────────────────────
              Row(
                children: [
                  Text(widget.category,
                    style: const TextStyle(
                      fontFamily: 'Inter', fontSize: 8,
                      letterSpacing: -0.15, color: Color(0xFFFC5A15),
                    )),
                  const Text(' • ',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 10,
                        letterSpacing: -0.15, color: Color(0xFF62748E))),
                  const Text('Réparation',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 8,
                        letterSpacing: -0.15, color: Color(0xFF314158))),
                ],
              ),
              const SizedBox(height: 24),

              // ── Warning icon ───────────────────────────────────────────────
              Center(
                child: Container(
                  width: 79, height: 79,
                  decoration: const BoxDecoration(
                    color: Color(0x33E7000B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE7000B), size: 40),
                ),
              ),
              const SizedBox(height: 20),

              // ── Question text ──────────────────────────────────────────────
              const Center(
                child: Text(
                  'Souhaitez vraiment supprimer\ncette demande?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.25,
                    letterSpacing: -0.15,
                    color: Color(0xFFE7000B),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Reason field ───────────────────────────────────────────────
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bordered box
                  Container(
                    height: 107,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFFC5A15)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      maxLines: null,
                      expands: true,
                      enabled: !_loading,
                      style: const TextStyle(
                        fontFamily: 'Public Sans', fontSize: 14,
                        color: Color(0xFF000000),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Lorem ipsum...',
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans', fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      ),
                    ),
                  ),
                  // Floating label
                  Positioned(
                    top: -20, left: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Raison de l\'annulation (optionnel)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: -0.31,
                              color: Color(0xFFFC5A15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Buttons ────────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFFC5A15)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23)),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Garder la demande',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 11.2,
                            letterSpacing: -0.22,
                            color: Color(0xFFFC5A15),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _loading ? null : () async {
                          setState(() => _loading = true);
                          Navigator.pop(context);
                          await widget.onConfirm(_ctrl.text.trim());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE7000B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23)),
                          padding: EdgeInsets.zero,
                        ),
                        child: _loading
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Text(
                                'Supprimer la demande',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 11.2,
                                  letterSpacing: -0.22,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared header widgets ─────────────────────────────────────────────────────


class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const _HeaderIconBtn(this.icon);
  @override
  Widget build(BuildContext context) => Container(
    width: 38, height: 38,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Icon(icon, color: const Color(0xFF393C40), size: 19),
  );
}


// ── Filter tab ─────────────────────────────────────────────────────────────────

class _Tab {
  final String key;
  final String label;
  const _Tab(this.key, this.label);
}
