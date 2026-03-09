import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/conversation_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────

class ClientMessagesScreen extends StatefulWidget {
  const ClientMessagesScreen({super.key});
  @override
  State<ClientMessagesScreen> createState() => _ClientMessagesScreenState();
}

class _ClientMessagesScreenState extends State<ClientMessagesScreen>
    with WidgetsBindingObserver {
  final _repo        = ConversationRepository();
  final _searchCtrl  = TextEditingController();

  String _query = '';
  int?   _selectedId;

  bool   _isLoading = true;
  String? _error;
  List<Conversation> _conversations = [];

  Timer? _pollTimer;

  // ── lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _reload(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _searchCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ── data ────────────────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _repo.getConversations();
      if (mounted) setState(() { _conversations = data; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ConversationRepository.errorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _reload() async {
    try {
      final data = await _repo.getConversations();
      if (mounted) setState(() => _conversations = data);
    } catch (_) {}
  }

  List<Conversation> get _filtered {
    if (_query.isEmpty) return _conversations;
    final q = _query.toLowerCase();
    return _conversations
        .where((c) =>
            c.otherName.toLowerCase().contains(q) ||
            c.lastMessage.toLowerCase().contains(q))
        .toList();
  }

  // ── build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Warm gradient background (orange tint at top fading to white)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.3776],
                  colors: [Color(0x4CFF8C5B), Color(0x00FF8C5B)],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(),
              _buildTitleRow(),
              _buildDescription(),
              Expanded(child: _buildBody()),
            ],
          ),

          // Bottom nav
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: 3)),
          ),
        ],
      ),
    );
  }

  // ── Header (orange + logo + search bar inside) ──────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(29, 12, 29, 20),
          child: Column(
            children: [
              // Logo row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  const Row(children: [
                    _HeaderIconBtn(Icons.calendar_today_outlined),
                    SizedBox(width: 10),
                    _HeaderIconBtn(Icons.notifications_none_rounded),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
              // Search bar inside orange header
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
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            color: Color(0xFF494949)),
                        decoration: const InputDecoration(
                          hintText: 'Quelle Artisan recherchez-vous ?',
                          hintStyle: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              color: Color(0xFF494949)),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    // Dark circular search-launch button
                    Container(
                      width: 36, height: 36,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF393C40),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
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

  // ── Title row ───────────────────────────────────────────────────────────────
  Widget _buildTitleRow() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(29, 16, 29, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.306545,
              color: Color(0xFF191C24),
            ),
          ),
          Icon(Icons.chat_bubble_outline_rounded,
              color: AppColors.primary, size: 24),
        ],
      ),
    );
  }

  // ── Description text ────────────────────────────────────────────────────────
  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(29, 6, 29, 8),
      child: Text(
        'Gorem ipsum dolor sit amet, consectetur adipiscing elit.',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.5,
          letterSpacing: -0.01 * 14,
          color: Color(0xFF494949),
        ),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
            Icon(Icons.chat_bubble_outline_rounded,
              size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty
                  ? 'Aucune conversation pour le moment'
                  : 'Aucun résultat pour "$_query"',
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                  color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(29, 8, 29, 110),
        itemCount: filtered.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFFFC7B0),
        ),
        itemBuilder: (_, i) {
          final conv = filtered[i];
          return _ConvItem(
            conv:       conv,
            isSelected: _selectedId == conv.id,
            onTap: () {
              setState(() => _selectedId = conv.id);
              context.push('/client/chat/${conv.id}', extra: {
                'name':      conv.otherName,
                'role':      conv.otherRole,
                'avatar':    conv.otherAvatar,
                'profileId': conv.otherProfileId,
              });
            },
          );
        },
      ),
    );
  }
}

// ── Conversation item ─────────────────────────────────────────────────────────

class _ConvItem extends StatelessWidget {
  final Conversation conv;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConvItem({
    required this.conv,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            // Avatar with online dot + unread badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAvatar(),
                // Online dot (bottom-right)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 16, height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C950),
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Unread badge (top-right)
                if (conv.unread > 0)
                  Positioned(
                    top: -4, right: -4,
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          conv.unread > 9 ? '9+' : '${conv.unread}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400)),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(conv.otherName,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.02 * 15,
                          color: Color(0xFF000000),
                        )),
                      Text(_formatTime(conv.lastAt),
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          letterSpacing: -0.02 * 12,
                          color: Color(0xFF8A91A8),
                        )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.02 * 14,
                            color: Color(0xFF8A91A8),
                          )),
                      ),
                      // Double-check read indicator
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all_rounded,
                          size: 16, color: Color(0xFF8A91A8)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (conv.otherAvatar != null && conv.otherAvatar!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          conv.otherAvatar!,
          width: 56, height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() => Container(
    width: 56, height: 56,
    decoration: BoxDecoration(
      color: _avatarColor(conv.otherName), shape: BoxShape.circle),
    child: Center(
      child: Text(_initials(conv.otherName),
        style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.w600, fontSize: 18)),
    ),
  );

  Color _avatarColor(String name) {
    const palette = [
      Color(0xFFFC5A15), Color(0xFF3B82F6), Color(0xFF8B5CF6),
      Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444),
      Color(0xFF06B6D4), Color(0xFF84CC16),
    ];
    if (name.isEmpty) return palette[0];
    int h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) % palette.length;
    }
    return palette[h];
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now  = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) {
      final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ampm';
    } else if (diff == 1) {
      return 'Hier';
    } else if (diff < 7) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[dt.weekday - 1];
    } else {
      const months = ['jan', 'fév', 'mar', 'avr', 'mai', 'jun',
                      'jul', 'aoû', 'sep', 'oct', 'nov', 'déc'];
      return '${dt.day} ${months[dt.month - 1]}';
    }
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────


class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const _HeaderIconBtn(this.icon);
  @override
  Widget build(BuildContext context) => Container(
    width: 40, height: 40,
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: Icon(icon, color: const Color(0xFF393C40), size: 20),
  );
}

