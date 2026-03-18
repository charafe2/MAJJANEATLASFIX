import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/netwrok/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/repositories/conversation_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ArtisanClientProfileScreen extends StatefulWidget {
  final int?    clientId;
  final String  clientName;
  final String? clientAvatar;
  final String? clientCity;

  const ArtisanClientProfileScreen({
    super.key,
    this.clientId,
    this.clientName  = 'Client',
    this.clientAvatar,
    this.clientCity,
  });

  @override
  State<ArtisanClientProfileScreen> createState() =>
      _ArtisanClientProfileScreenState();
}

class _ArtisanClientProfileScreenState
    extends State<ArtisanClientProfileScreen> {

  final _convRepo = ConversationRepository();
  bool            _loading = true;
  _ClientProfile? _profile;
  bool            _busy    = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      if (widget.clientId != null) {
        final res = await ApiClient.instance.get(
          '/artisan/clients/${widget.clientId}',
        );
        final body = res.data is Map<String, dynamic>
            ? res.data as Map<String, dynamic>
            : <String, dynamic>{};
        // Handle both { data: { ... } } and { user: ..., stats: ..., history: ... }
        final parsed = body.containsKey('data')
            ? body['data'] as Map<String, dynamic>
            : body;
        if (mounted) {
          setState(() {
            _profile = _ClientProfile.fromJson(parsed);
            _loading = false;
          });
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openMessage() async {
    if (widget.clientId == null) return;
    setState(() => _busy = true);
    try {
      final conv = await _convRepo.getOrCreate(clientId: widget.clientId);
      if (mounted) {
        context.push('/artisan/chat/${conv.id}', extra: {
          'name':      _name,
          'avatar':    _avatar,
          'profileId': conv.otherProfileId,
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Impossible d\'ouvrir la conversation.',
              style: TextStyle(fontFamily: 'Public Sans', fontSize: 14)),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  String  get _name      => _profile?.name      ?? widget.clientName;
  String? get _avatar    => _profile?.avatarUrl  ?? widget.clientAvatar;
  String  get _city      => _profile?.city       ?? widget.clientCity ?? '';
  String  get _since     => _profile?.memberSince ?? '';
  bool    get _verified  => _profile?.isVerified  ?? false;
  int     get _active    => _profile?.activeRequests    ?? 0;
  int     get _completed => _profile?.completedRequests ?? 0;
  double  get _rating    => _profile?.averageRating     ?? 0;
  double  get _spent     => _profile?.totalSpent        ?? 0;
  double  get _trust     => _profile?.trustScore        ?? 0;
  List<_HistoryItem> get _history => _profile?.history ?? [];

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else ...[
            SliverToBoxAdapter(child: _buildStatsRow()),
            SliverToBoxAdapter(child: _buildActionButtons()),
            SliverToBoxAdapter(child: _buildTrustCard()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: const Text('Historique des demandes',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: Color(0xFF191C24),
                  )),
              ),
            ),
            if (_history.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyHistory())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, 0, 20, i == _history.length - 1 ? 32 : 12),
                    child: _HistoryCard(item: _history[i]),
                  ),
                  childCount: _history.length,
                ),
              ),
          ],
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
          bottomLeft:  Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              // Back + 3-dot row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 38, height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Avatar + Name row (side by side)
              Row(
                children: [
                  // Avatar with green border + online dot
                  Stack(
                    children: [
                      Container(
                        width: 82, height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF22C55E), width: 3),
                        ),
                        child: ClipOval(child: _avatarWidget()),
                      ),
                      Positioned(
                        bottom: 4, right: 4,
                        child: Container(
                          width: 16, height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Name + member since
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: Colors.white,
                          )),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              _since.isNotEmpty
                                  ? 'Membre depuis $_since'
                                  : 'Membre',
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 12,
                                color: Colors.white70,
                              )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Info pills row: email + location
              Row(
                children: [
                  if (_verified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.email_outlined,
                              color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text('E-mail vérifié',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 12,
                              color: Colors.white,
                            )),
                        ],
                      ),
                    ),
                  if (_verified && _city.isNotEmpty)
                    const SizedBox(width: 8),
                  if (_city.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(_city,
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 12,
                              color: Colors.white,
                            )),
                        ],
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

  Widget _avatarWidget() {
    final url = _avatar;
    if (url != null && url.isNotEmpty) {
      final fullUrl = url.startsWith('http')
          ? url
          : '${ApiConstants.storageBaseUrl}$url';
      return Image.network(fullUrl, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarPlaceholder());
    }
    return _avatarPlaceholder();
  }

  Widget _avatarPlaceholder() => Container(
    color: const Color(0xFFFFE5D9),
    child: Center(
      child: Text(
        _name.isNotEmpty ? _name[0].toUpperCase() : 'C',
        style: const TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w700,
          fontSize: 32,
          color: AppColors.primary,
        ),
      ),
    ),
  );

  // ── Stats Row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        _StatCard(
          value: '$_active',
          label: 'Demandes\nactives',
          borderColor: const Color(0xFF3B82F6),
          valueColor: const Color(0xFF1D4ED8),
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: '$_completed',
          label: 'Demandes\ncomplétées',
          borderColor: const Color(0xFF22C55E),
          valueColor: const Color(0xFF16A34A),
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: _rating > 0
              ? _rating.toStringAsFixed(1)
              : '—',
          label: 'Note\nmoyenne',
          borderColor: const Color(0xFFEAB308),
          valueColor: const Color(0xFFCA8A04),
          suffix: _rating > 0
              ? const Icon(Icons.star_rounded,
                  color: Color(0xFFCA8A04), size: 14)
              : null,
        ),
        const SizedBox(width: 10),
        _StatCard(
          value: _spent > 0
              ? _formatAmount(_spent)
              : '—',
          label: 'Total\ndépensé',
          borderColor: AppColors.primary,
          valueColor: AppColors.primary,
          valueFontSize: _spent >= 10000 ? 13 : 16,
          subLabel: _spent > 0 ? 'DH' : null,
        ),
      ]),
    );
  }

  static String _formatAmount(double v) {
    if (v >= 1000) {
      final k = v / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return v.toInt().toString();
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _busy ? null : _openMessage,
            icon: const Icon(Icons.chat_bubble_outline_rounded,
              color: AppColors.primary, size: 18),
            label: const Text('Message',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary,
              )),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.phone_outlined,
              color: Colors.white, size: 18),
            label: const Text('Appel',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.white,
              )),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Trust Card ─────────────────────────────────────────────────────────────
  Widget _buildTrustCard() {
    final score    = _trust > 0 ? _trust : 93.0;
    final label    = score >= 90
        ? 'Excellent'
        : score >= 70
            ? 'Bien'
            : 'À améliorer';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          border: Border.all(color: const Color(0xFFBBF7D0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Client fiable',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF166534),
                    )),
                  Text('Score de fiabilité',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 12,
                      color: Color(0xFF4ADE80),
                    )),
                ],
              ),
            ]),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${score.toInt()}%  ',
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14,
                      color: Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFDCFCE7),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF22C55E)),
              ),
            ),
            const SizedBox(height: 14),
            const _TrustItem(text: 'Paiements à temps'),
            const SizedBox(height: 6),
            const _TrustItem(text: 'Bonne communication'),
            const SizedBox(height: 6),
            const _TrustItem(text: 'Avis positifs'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Column(
          children: [
            Icon(Icons.history_rounded, size: 40, color: Color(0xFFD1D5DC)),
            SizedBox(height: 10),
            Text('Aucun historique disponible',
              style: TextStyle(fontFamily: 'Public Sans',
                fontSize: 14, color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}

// ── Trust item ─────────────────────────────────────────────────────────────────
class _TrustItem extends StatelessWidget {
  final String text;
  const _TrustItem({required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
    const Icon(Icons.check_circle_outline_rounded,
      color: Color(0xFF22C55E), size: 16),
    const SizedBox(width: 8),
    Text(text,
      style: const TextStyle(
        fontFamily: 'Public Sans',
        fontSize: 13,
        color: Color(0xFF166534),
      )),
  ]);
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String  value;
  final String  label;
  final Color   borderColor;
  final Color   valueColor;
  final double  valueFontSize;
  final Widget? suffix;
  final String? subLabel;

  const _StatCard({
    required this.value,
    required this.label,
    required this.borderColor,
    required this.valueColor,
    this.valueFontSize = 18,
    this.suffix,
    this.subLabel,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: valueFontSize,
                  color: valueColor,
                )),
              if (suffix != null) ...[
                const SizedBox(width: 2),
                suffix!,
              ],
            ],
          ),
          if (subLabel != null) ...[
            Text(subLabel!,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 11,
                color: valueColor,
              )),
          ],
          const SizedBox(height: 2),
          Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 10,
              color: Color(0xFF62748E),
            )),
        ],
      ),
    ),
  );
}

// ── History Card ──────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final _HistoryItem item;
  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.status == 'completed';
    final isOngoing   = item.status == 'in_progress' || item.status == 'open';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000),
            blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDate(item.date),
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: Color(0xFF62748E),
                )),
              _StatusBadge(isCompleted: isCompleted, isOngoing: isOngoing),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(item.title,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF191C24),
            )),
          const SizedBox(height: 6),

          // Category + service type
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(item.category,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                )),
            ),
            if (item.serviceType.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward_rounded,
                  size: 12, color: Color(0xFF9CA3AF)),
              ),
              Text(item.serviceType,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: Color(0xFF62748E),
                )),
            ],
          ]),
          const SizedBox(height: 8),

          // Artisan + stars (if completed)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Text('Artisan: ',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Color(0xFF62748E),
                  )),
                Text(item.artisanName,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF191C24),
                  )),
              ]),
              if (isCompleted && item.rating > 0)
                _StarRating(rating: item.rating),
            ],
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
}

// ── Status Badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final bool isCompleted;
  final bool isOngoing;
  const _StatusBadge({required this.isCompleted, required this.isOngoing});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          border: Border.all(color: const Color(0xFF86EFAC)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF22C55E), size: 12),
          SizedBox(width: 4),
          Text('Complétée',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16A34A),
            )),
        ]),
      );
    }
    if (isOngoing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          border: Border.all(color: const Color(0xFFFDBA74)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.schedule_rounded,
            color: Color(0xFFEA580C), size: 12),
          SizedBox(width: 4),
          Text('En cours',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEA580C),
            )),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('Annulée',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        )),
    );
  }
}

// ── Star Rating ───────────────────────────────────────────────────────────────
class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half   = !filled && (i < rating);
        return Icon(
          half ? Icons.star_half_rounded
               : filled ? Icons.star_rounded
                        : Icons.star_border_rounded,
          color: const Color(0xFFEAB308),
          size: 16,
        );
      }),
    );
  }
}

// ── Data Models ───────────────────────────────────────────────────────────────

class _ClientProfile {
  final String  name;
  final String? avatarUrl;
  final String  city;
  final String  memberSince;
  final bool    isVerified;
  final int     activeRequests;
  final int     completedRequests;
  final double  averageRating;
  final double  totalSpent;
  final double  trustScore;
  final List<_HistoryItem> history;

  const _ClientProfile({
    required this.name,
    this.avatarUrl,
    required this.city,
    required this.memberSince,
    required this.isVerified,
    required this.activeRequests,
    required this.completedRequests,
    required this.averageRating,
    required this.totalSpent,
    required this.trustScore,
    required this.history,
  });

  factory _ClientProfile.fromJson(Map<String, dynamic> j) {
    final user     = j['user']    as Map<String, dynamic>? ?? j;
    final stats    = j['stats']   as Map<String, dynamic>? ?? {};
    final histRaw  = j['history'] as List<dynamic>?        ?? [];

    final rawAvatar = user['avatar_url'] as String?;
    final fullAvatar = rawAvatar != null && rawAvatar.isNotEmpty
        ? (rawAvatar.startsWith('http')
            ? rawAvatar
            : '${ApiConstants.storageBaseUrl}$rawAvatar')
        : null;

    return _ClientProfile(
      name:              user['full_name'] as String?  ?? 'Client',
      avatarUrl:         fullAvatar,
      city:              user['city']      as String?  ?? '',
      memberSince:       _parseSince(user['created_at']),
      isVerified:        user['is_verified'] as bool?  ?? false,
      activeRequests:    stats['active_requests']    as int?    ?? 0,
      completedRequests: stats['completed_requests'] as int?    ?? 0,
      averageRating:     (stats['average_rating']    as num?    ?? 0).toDouble(),
      totalSpent:        (stats['total_spent']       as num?    ?? 0).toDouble(),
      trustScore:        (stats['trust_score']       as num?    ?? 0).toDouble(),
      history: histRaw
          .map((e) => _HistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String _parseSince(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return '';
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

class _HistoryItem {
  final int    id;
  final String title;
  final String category;
  final String serviceType;
  final String artisanName;
  final String status;
  final double rating;
  final DateTime date;

  const _HistoryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.serviceType,
    required this.artisanName,
    required this.status,
    required this.rating,
    required this.date,
  });

  factory _HistoryItem.fromJson(Map<String, dynamic> j) {
    final cat    = j['category']     as Map<String, dynamic>?;
    final st     = j['service_type'] as Map<String, dynamic>?;
    final artisan = j['artisan']     as Map<String, dynamic>?;
    final aUser   = artisan?['user'] as Map<String, dynamic>?;

    return _HistoryItem(
      id:           j['id']          as int?    ?? 0,
      title:        j['description'] as String? ?? 'Demande',
      category:     cat?['name']     as String? ?? '',
      serviceType:  st?['name']      as String? ?? '',
      artisanName:  aUser?['full_name'] as String? ?? artisan?['name'] as String? ?? '—',
      status:       j['status']      as String? ?? '',
      rating:       (j['rating']     as num?    ?? 0).toDouble(),
      date:         DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
