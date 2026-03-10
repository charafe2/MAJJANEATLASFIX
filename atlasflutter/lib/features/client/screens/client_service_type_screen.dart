import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/service_request_repository.dart';

class ClientServiceTypeScreen extends StatefulWidget {
  final int    categoryId;
  final String categoryName;

  const ClientServiceTypeScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ClientServiceTypeScreen> createState() => _ClientServiceTypeScreenState();
}

class _ClientServiceTypeScreenState extends State<ClientServiceTypeScreen> {
  final _repo       = ServiceRequestRepository();
  final _searchCtrl = TextEditingController();

  List<ServiceType> _types    = [];
  List<ServiceType> _filtered = [];
  bool              _loading  = true;
  String?           _error;
  ServiceType?      _selected;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearch);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final types = await _repo.getServiceTypes(widget.categoryId);
      if (mounted) {
        setState(() { _types = types; _filtered = types; _loading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ServiceRequestRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _types
          : _types.where((t) => t.name.toLowerCase().contains(q)).toList();
    });
  }

  void _onContinue() {
    if (_selected == null) return;
    context.push('/client/nouvelle-demande', extra: {
      'categoryId':    widget.categoryId,
      'category':      widget.categoryName,
      'serviceTypeId': _selected!.id,
      'serviceType':   _selected!.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Warm gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.62],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              const _StepProgressBar(currentStep: 2, totalSteps: 3),
              _buildCategoryInfo(),
              Expanded(child: _buildBody()),
            ],
          ),

          // Bottom action buttons
          if (!_loading && _error == null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomBar(context),
            ),

          // Bottom nav
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: 2)),
          ),
        ],
      ),
    );
  }

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              // Top row: logo + icon buttons
              Row(children: [
                const AtlasLogo(),
                const Spacer(),
                _CircleBtn(
                  icon: Icons.calendar_today_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                _CircleBtn(
                  icon: Icons.notifications_outlined,
                  onTap: () => context.push('/client/notifications'),
                ),
              ]),
              const SizedBox(height: 16),

              // Search bar
              Container(
                height: 48,
                padding: const EdgeInsets.only(left: 16, right: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(children: [
                  const Icon(Icons.search, color: Color(0xFF494949), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        color: Color(0xFF494949),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Quelle service recherchez-vous ?',
                        hintStyle: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          color: Color(0xFF494949),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF393C40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category name + icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.categoryName,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.31,
                    color: Color(0xFF191C24),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.smartphone_outlined,
                  color: AppColors.primary, size: 25),
            ],
          ),
          const SizedBox(height: 6),

          // Info line
          const Row(children: [
            Icon(Icons.info_outline_rounded,
                color: AppColors.primary, size: 14),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  letterSpacing: -0.01,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // Section label
          const Text(
            'Choisissez un type de service',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: -0.31,
              color: Color(0xFF191C24),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: Color(0xFFD1D5DC)),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Color(0xFF62748E),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Réessayer',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'Public Sans')),
            ),
          ],
        ),
      );
    }
    if (_filtered.isEmpty) {
      return const Center(
        child: Text('Aucun service disponible pour cette catégorie.',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: Color(0xFF62748E),
            )),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 170),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final type    = _filtered[i];
        final checked = _selected?.id == type.id;
        return GestureDetector(
          onTap: () => setState(() => _selected = checked ? null : type),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 15),
            decoration: BoxDecoration(
              color: checked
                  ? AppColors.primary.withValues(alpha: 0.04)
                  : Colors.white,
              border: Border.all(
                color: checked ? AppColors.primary : const Color(0xFFE5E7EB),
                width: 1.44,
              ),
              borderRadius: BorderRadius.circular(11.52),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 4.32,
                  spreadRadius: -0.72,
                  offset: Offset(0, 2.88),
                ),
              ],
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  type.name,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: -0.32,
                    color: checked
                        ? AppColors.primary
                        : const Color(0xFF314158),
                  ),
                ),
              ),
              const SizedBox(width: 30),
              // Checkbox mark
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: checked ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: checked
                          ? AppColors.primary
                          : const Color(0xFFFFA077),
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: checked
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 13)
                      : null,
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 108),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white,
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Précédent',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primary,
                  )),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _selected == null ? null : _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Continuer',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Circle icon button ─────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final IconData      icon;
  final VoidCallback  onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF393C40)),
      ),
    );
  }
}

// ── Step progress bar ──────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i < currentStep;
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
        }),
      ),
    );
  }
}
