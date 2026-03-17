import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/agenda_repository.dart';

class ClientAgendaScreen extends StatefulWidget {
  const ClientAgendaScreen({super.key});
  @override
  State<ClientAgendaScreen> createState() => _ClientAgendaScreenState();
}

class _ClientAgendaScreenState extends State<ClientAgendaScreen> {
  final _repo = AgendaRepository();

  List<Appointment> _all     = [];
  List<Appointment> _shown   = [];
  bool              _loading = true;
  String?           _error;
  String?           _activeFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getAppointments();
      if (mounted) {
        setState(() {
          _all     = data;
          _shown   = _applyFilter(data, _activeFilter);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = AgendaRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  List<Appointment> _applyFilter(List<Appointment> list, String? status) {
    if (status == null) return list;
    return list.where((a) => a.status == status).toList();
  }

  void _setFilter(String? status) {
    setState(() {
      _activeFilter = status;
      _shown = _applyFilter(_all, status);
    });
  }

  Future<void> _cancelAppointment(Appointment a) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler le rendez-vous ?',
            style: TextStyle(fontFamily: 'Public Sans', fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: const Text('Cette action est irréversible.',
            style: TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non', style: TextStyle(color: Color(0xFF62748E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Oui, annuler',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _repo.cancelAppointment(a.id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Rendez-vous annulé.',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AgendaRepository.errorMessage(e),
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.6238],
                  colors: [Color(0x4DFF8C5B), Color(0x00FF8C5B)],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary, strokeWidth: 2))
                    : _error != null
                        ? _buildError()
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: _load,
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
                              children: [
                                _buildAgendaHeader(),
                                const SizedBox(height: 16),
                                _buildFilterButton(),
                                const SizedBox(height: 20),
                                if (_shown.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 60),
                                    child: Center(
                                      child: Text('Aucun rendez-vous trouvé.',
                                        style: TextStyle(
                                          fontFamily: 'Public Sans',
                                          fontSize: 14,
                                          color: Color(0xFF9CA3AF),
                                        )),
                                    ),
                                  )
                                else
                                  ..._shown.map((a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _AgendaCard(
                                      appointment: a,
                                      onCancel: a.status == 'scheduled'
                                          ? () => _cancelAppointment(a)
                                          : null,
                                      onProfile: a.contactId != null
                                          ? () => context.push(
                                              '/artisans/profile/${a.contactId}',
                                              extra: {
                                                'name': a.contactName ?? 'Artisan',
                                                'role': a.title,
                                              })
                                          : null,
                                    ),
                                  )),
                              ],
                            ),
                          ),
              ),
            ],
          ),

          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: -1)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFC5A15),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_today_outlined,
                            color: Color(0xFF393C40), size: 20),
                      ),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () => context.push('/client/notifications'),
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: Color(0xFF393C40), shape: BoxShape.circle),
                        child: const Icon(Icons.notifications_none_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                height: 48,
                padding: const EdgeInsets.fromLTRB(16, 0, 6, 0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('Quel service recherchez-vous ?',
                        style: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                            fontWeight: FontWeight.w400, color: Color(0xFF494949))),
                    ),
                    Container(
                      width: 36, height: 36,
                      decoration: const BoxDecoration(
                          color: Color(0xFF393C40), shape: BoxShape.circle),
                      child: const Icon(Icons.manage_search,
                          color: Colors.white, size: 18),
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

  Widget _buildAgendaHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_month_outlined,
                color: Color(0xFF191C24), size: 24),
            SizedBox(width: 8),
            Text('Agenda',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF191C24),
              )),
          ],
        ),
        SizedBox(height: 6),
        Text(
          'Gorem ipsum dolor sit amet, consectetur adipiscing elit.',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 13,
            color: Color(0xFF62748E),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: _showFilterSheet,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded,
                color: _activeFilter != null ? AppColors.primary : const Color(0xFF62748E),
                size: 18),
            const SizedBox(width: 8),
            Text(
              _activeFilter == null
                  ? 'Filtrer'
                  : _activeFilter == 'scheduled' ? 'En attente' : 'Terminé',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _activeFilter != null ? AppColors.primary : const Color(0xFF62748E),
              ),
            ),
            if (_activeFilter != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _setFilter(null),
                child: const Icon(Icons.close, size: 14, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DC),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text('Filtrer par statut',
              style: TextStyle(fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700, fontSize: 16,
                  color: Color(0xFF314158))),
            const SizedBox(height: 16),
            _FilterOption(
              label: 'Tous',
              selected: _activeFilter == null,
              onTap: () { Navigator.pop(context); _setFilter(null); },
            ),
            _FilterOption(
              label: 'En attente',
              selected: _activeFilter == 'scheduled',
              onTap: () { Navigator.pop(context); _setFilter('scheduled'); },
            ),
            _FilterOption(
              label: 'Terminé',
              selected: _activeFilter == 'completed',
              onTap: () { Navigator.pop(context); _setFilter('completed'); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter option ─────────────────────────────────────────────────────────────
class _FilterOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterOption({required this.label, required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primary : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label,
            style: TextStyle(
              fontFamily: 'Public Sans', fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.primary : const Color(0xFF314158),
            ))),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ],
      ),
    ),
  );
}

// ── Agenda appointment card ──────────────────────────────────────────────────
class _AgendaCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onProfile;
  const _AgendaCard({required this.appointment, this.onCancel, this.onProfile});

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "Aujourd'hui";
    }
    const months = [
      '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    return 'Le ${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String? _avatarUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return '${ApiConstants.storageBaseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final avatarUrl = _avatarUrl(a.contactAvatar);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Top: avatar + info + date badge ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(avatarUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _avatarPlaceholder())
                        : _avatarPlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + service + rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.contactName ?? 'Artisan',
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF191C24),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 12,
                          color: Color(0xFF62748E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Color(0xFFFF8904)),
                          const SizedBox(width: 4),
                          Text(
                            '${(a.rating ?? 0).toStringAsFixed(1)}  ',
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF191C24),
                            ),
                          ),
                          Text(
                            '${a.reviewsCount} avis',
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Date badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(a.scheduledAt),
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          // ── Price + duration row ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prix à partir de',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 10,
                        color: Color(0xFF9CA3AF),
                      )),
                    const SizedBox(height: 2),
                    Text(
                      a.price != null ? '${a.price!.toStringAsFixed(0)}DH' : '--',
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Color(0xFF191C24),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Text(
                          a.durationLabel,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 13,
                            color: Color(0xFF62748E),
                          ),
                        ),
                      ],
                    ),
                    if (a.city != null && a.city!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            a.city!,
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 12,
                              color: Color(0xFF62748E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Action buttons ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Annuler la demande',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: AppColors.primary,
                        )),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: onProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Voir le profil',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          color: Colors.white,
                        )),
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

  Widget _avatarPlaceholder() => Container(
    color: const Color(0xFFE5E7EB),
    child: const Center(
      child: Icon(Icons.person, size: 28, color: Color(0xFFD1D5DC)),
    ),
  );
}
