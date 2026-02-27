import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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
  final _repo = ServiceRequestRepository();

  List<ServiceType> _types   = [];
  bool              _loading = true;
  String?           _error;
  ServiceType?      _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final types = await _repo.getServiceTypes(widget.categoryId);
      if (mounted) setState(() { _types = types; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error   = ServiceRequestRepository.errorMessage(e);
        _loading = false;
      });
    }
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
          // Warm gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody()),
            ],
          ),

          if (!_loading && _error == null)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildBottomBar(context),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('Retour',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 14,
                          color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.categoryName,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                    fontSize: 22, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Sélectionner un type de service',
                  style: TextStyle(
                    fontFamily: 'Public Sans', fontSize: 12,
                    color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFD1D5DC)),
            const SizedBox(height: 12),
            Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 14,
                color: Color(0xFF62748E))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _load,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
              child: const Text('Réessayer',
                style: TextStyle(color: Colors.white,
                    fontFamily: 'Public Sans')),
            ),
          ],
        ),
      );
    }
    if (_types.isEmpty) {
      return const Center(
        child: Text('Aucun service disponible pour cette catégorie.',
          style: TextStyle(
            fontFamily: 'Public Sans', fontSize: 14,
            color: Color(0xFF62748E))),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      itemCount: _types.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final type    = _types[i];
        final checked = _selected?.id == type.id;
        return GestureDetector(
          onTap: () => setState(() => _selected = checked ? null : type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: checked
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : Colors.white,
              border: Border.all(
                color: checked ? AppColors.primary : const Color(0xFFE5E7EB),
                width: checked ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: checked
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : const Color(0x0A000000),
                  blurRadius: checked ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(children: [
              Expanded(
                child: Text(type.name,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                    color: checked
                        ? AppColors.primary
                        : const Color(0xFF314158),
                  )),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: checked ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: checked
                        ? AppColors.primary : const Color(0xFFD1D5DC),
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: checked
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 13)
                    : null,
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, -4)),
        ],
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
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Précédent',
                style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                  fontSize: 15, color: AppColors.primary)),
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
                disabledBackgroundColor: const Color(0xFFD1D5DC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continuer',
                style: TextStyle(
                  fontFamily: 'Poppins', fontWeight: FontWeight.w600,
                  fontSize: 15, color: Colors.white)),
            ),
          ),
        ),
      ]),
    );
  }
}
