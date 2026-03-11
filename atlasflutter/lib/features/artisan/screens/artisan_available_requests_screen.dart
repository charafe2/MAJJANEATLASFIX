import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/atlas_logo.dart';
import '../../../data/repositories/artisan_job_repository.dart';
import 'artisan_home_screen.dart';

class ArtisanAvailableRequestsScreen extends StatefulWidget {
  const ArtisanAvailableRequestsScreen({super.key});
  @override
  State<ArtisanAvailableRequestsScreen> createState() => _ArtisanAvailableRequestsScreenState();
}

class _ArtisanAvailableRequestsScreenState extends State<ArtisanAvailableRequestsScreen> {
  final _repo = ArtisanJobRepository();

  List<AvailableRequest> _requests = [];
  bool   _loading = true;
  String? _error;

  // Active filters
  String? _filterCategory;
  String? _filterServiceType;
  String  _filterPeriod = 'Tous'; // Tous | Aujourd'hui | Semaine | Mois

  List<AvailableRequest> get _filtered {
    return _requests.where((r) {
      if (_filterCategory != null && r.category != _filterCategory) return false;
      if (_filterServiceType != null && r.serviceType != _filterServiceType) return false;
      final now = DateTime.now();
      if (_filterPeriod == "Aujourd'hui") {
        if (r.createdAt.year != now.year ||
            r.createdAt.month != now.month ||
            r.createdAt.day != now.day) return false;
      } else if (_filterPeriod == 'Semaine') {
        if (now.difference(r.createdAt).inDays > 7) return false;
      } else if (_filterPeriod == 'Mois') {
        if (now.difference(r.createdAt).inDays > 30) return false;
      }
      return true;
    }).toList();
  }

  bool get _hasActiveFilter =>
      _filterCategory != null ||
      _filterServiceType != null ||
      _filterPeriod != 'Tous';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getAvailableRequests();
      if (mounted) setState(() { _requests = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = ArtisanJobRepository.errorMessage(e); _loading = false; });
    }
  }

  // ── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildBody()),
            ],
          ),
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 2)),
          ),
        ],
      ),
    );
  }

  // ── Orange header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
              // Logo + icons row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    GestureDetector(
                      onTap: () => context.push('/artisan/agenda'),
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_today_outlined, color: Color(0xFF393C40), size: 20),
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => context.push('/client/notifications'),
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(color: Color(0xFF393C40), shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16, right: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(children: [
                  const Icon(Icons.search_rounded, color: Color(0xFF494949), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Quelle demande recherchez-vous ?',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        letterSpacing: -0.14,
                        color: Color(0xFF494949),
                      ),
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF393C40),
                      borderRadius: BorderRadius.circular(1000),
                    ),
                    child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Demandes des clients',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: -0.3,
                          color: Color(0xFF191C24),
                        ),
                      ),
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.handyman_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _loading
                        ? 'Chargement...'
                        : '${_filtered.length} nouvelle${_filtered.length != 1 ? 's' : ''} demande${_filtered.length != 1 ? 's' : ''} disponible${_filtered.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 13,
                      color: Color(0xFF62748E),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter row
                  Row(children: [
                    // Badge dot when a filter is active
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: _openFilterSheet,
                          child: Container(
                            width: 46, height: 46,
                            decoration: BoxDecoration(
                              color: _hasActiveFilter
                                  ? const Color(0xFFFFF0E8)
                                  : Colors.white,
                              border: Border.all(
                                color: _hasActiveFilter
                                    ? AppColors.primary
                                    : const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Color(0x0A000000),
                                    blurRadius: 4, offset: Offset(0, 1)),
                              ],
                            ),
                            child: Icon(Icons.filter_alt_outlined,
                                color: _hasActiveFilter
                                    ? AppColors.primary
                                    : const Color(0xFF62748E),
                                size: 20),
                          ),
                        ),
                        if (_hasActiveFilter)
                          Positioned(
                            top: -3, right: -3,
                            child: Container(
                              width: 10, height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _openFilterSheet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          child: const Text(
                            'Filtrer',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── List / states ──────────────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_error != null)
            SliverFillRemaining(child: _buildError())
          else if (_filtered.isEmpty)
            SliverFillRemaining(child: _buildEmpty())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _RequestCard(
                      request: _filtered[i],
                      onTap: () => context.push(
                        '/artisan/request/${_filtered[i].id}',
                        extra: {'request': _filtered[i]},
                      ),
                    ),
                  ),
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openFilterSheet() {
    // Derive unique categories and service types from loaded requests
    final categories    = _requests.map((r) => r.category).toSet().toList()..sort();
    final serviceTypes  = (_filterCategory != null
        ? _requests.where((r) => r.category == _filterCategory)
        : _requests)
        .map((r) => r.serviceType)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
          ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RequestFilterSheet(
        categories:          categories,
        serviceTypes:        serviceTypes,
        selectedCategory:    _filterCategory,
        selectedServiceType: _filterServiceType,
        selectedPeriod:      _filterPeriod,
        onApply: (cat, st, period) {
          setState(() {
            _filterCategory    = cat;
            _filterServiceType = st;
            _filterPeriod      = period;
          });
        },
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text('Aucune demande disponible.',
        style: TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: Color(0xFF9CA3AF))),
    ]),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(_error!, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: Color(0xFF62748E))),
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
      ]),
    ),
  );
}

// ── Request card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final AvailableRequest request;
  final VoidCallback onTap;
  const _RequestCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Client info row ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + online dot
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFFFFE5D9),
                      backgroundImage: (request.clientAvatar != null &&
                              request.clientAvatar!.isNotEmpty)
                          ? NetworkImage(request.clientAvatar!)
                          : null,
                      child: (request.clientAvatar == null ||
                              request.clientAvatar!.isEmpty)
                          ? Text(
                              request.clientName?.isNotEmpty == true
                                  ? request.clientName![0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 1, bottom: 1,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name + date + time + city
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.clientName ?? 'Client',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF191C24),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(request.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(children: [
                        const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF62748E)),
                        const SizedBox(width: 3),
                        Text(_formatTime(request.createdAt),
                          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Color(0xFF62748E))),
                        const SizedBox(width: 14),
                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF62748E)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(request.city, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 12, color: Color(0xFF62748E))),
                        ),
                      ]),
                    ],
                  ),
                ),

                // Category → serviceType tag
                _CategoryTag(category: request.category, serviceType: request.serviceType),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Description box ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.serviceType.isNotEmpty
                        ? request.serviceType
                        : request.description,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      color: Color(0xFF62748E),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Photos ───────────────────────────────────────────────────────
          if (request.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  for (int i = 0; i < request.photos.take(2).length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          request.photos[i],
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ── "Voir le détail" button ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Voir le détail',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Category tag ──────────────────────────────────────────────────────────────
class _CategoryTag extends StatelessWidget {
  final String category;
  final String serviceType;
  const _CategoryTag({required this.category, required this.serviceType});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFC5A15), width: 1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              category,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFC5A15),
              ),
            ),
          ),
          if (serviceType.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: Icon(Icons.arrow_forward_rounded, size: 10, color: Color(0xFFFC5A15)),
            ),
            Flexible(
              child: Text(
                serviceType,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFC5A15),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────
class _RequestFilterSheet extends StatefulWidget {
  final List<String> categories;
  final List<String> serviceTypes;
  final String?      selectedCategory;
  final String?      selectedServiceType;
  final String       selectedPeriod;
  final void Function(String? category, String? serviceType, String period) onApply;

  const _RequestFilterSheet({
    required this.categories,
    required this.serviceTypes,
    required this.selectedCategory,
    required this.selectedServiceType,
    required this.selectedPeriod,
    required this.onApply,
  });

  @override
  State<_RequestFilterSheet> createState() => _RequestFilterSheetState();
}

class _RequestFilterSheetState extends State<_RequestFilterSheet> {
  String? _category;
  String? _serviceType;
  String  _period = 'Tous';

  static const _periods = ["Tous", "Aujourd'hui", "Semaine", "Mois"];

  @override
  void initState() {
    super.initState();
    _category    = widget.selectedCategory;
    _serviceType = widget.selectedServiceType;
    _period      = widget.selectedPeriod;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Service dropdown ──────────────────────────────────────────
          _FilterDropdown(
            label: 'Service',
            icon: Icons.home_repair_service_outlined,
            value: _category,
            items: widget.categories,
            onChanged: (v) => setState(() {
              _category    = v;
              _serviceType = null; // reset dependent filter
            }),
          ),
          const SizedBox(height: 16),

          // ── Type de service dropdown ──────────────────────────────────
          _FilterDropdown(
            label: 'Type de service',
            icon: Icons.build_outlined,
            value: _serviceType,
            items: widget.serviceTypes,
            onChanged: (v) => setState(() => _serviceType = v),
          ),
          const SizedBox(height: 20),

          // ── Period radio buttons ──────────────────────────────────────
          ..._periods.map((p) => _PeriodTile(
            label: p,
            selected: _period == p,
            onTap: () => setState(() => _period = p),
          )),
          const SizedBox(height: 24),

          // ── Apply button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onApply(_category, _serviceType, _period);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
              child: const Text('Appliquer',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.white,
                )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown field ────────────────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final String?      value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(label,
                style: const TextStyle(
                  fontFamily: 'Public Sans', fontSize: 14,
                  color: Color(0xFF9CA3AF))),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.primary),
              style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 14,
                color: Color(0xFF191C24)),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Tous',
                    style: TextStyle(
                      fontFamily: 'Public Sans', fontSize: 14,
                      color: Color(0xFF9CA3AF))),
                ),
                ...items.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                )),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Period radio tile ─────────────────────────────────────────────────────────
class _PeriodTile extends StatelessWidget {
  final String   label;
  final bool     selected;
  final VoidCallback onTap;

  const _PeriodTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Expanded(
            child: Text(label,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected
                    ? const Color(0xFF191C24)
                    : const Color(0xFF62748E),
              )),
          ),
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFD1D5DC),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
        ]),
      ),
    );
  }
}
