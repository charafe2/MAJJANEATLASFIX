import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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
    // Silent refresh — no loading spinner
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
          // Warm gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5],
                  colors: [Color(0x33FC5A15), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(),
              _buildTitleRow(),
              _buildSearchInput(),
              Expanded(child: _buildBody()),
            ],
          ),

          // Bottom nav
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: _BottomNavBar(activeIndex: 3)),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WhiteLogo(),
              const Row(children: [
                _HeaderIconBtn(Icons.notifications_none_rounded),
                SizedBox(width: 10),
                _HeaderIconBtn(Icons.person_outline_rounded),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Messages',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                fontSize: 20, color: Color(0xFF314158))),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit_outlined,
              color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
              color: Color(0xFF314158)),
          decoration: const InputDecoration(
            hintText: 'Rechercher une conversation…',
            hintStyle: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF62748E), size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
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
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 110),
        itemCount: filtered.length,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: AppColors.primary, width: 3))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              // Avatar with online dot + unread badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildAvatar(),
                  // Online dot
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C950),
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Unread badge
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
                            style: const TextStyle(color: Colors.white,
                                fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(conv.otherName,
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontWeight: conv.unread > 0
                                ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 15,
                            color: const Color(0xFF314158),
                          )),
                        Text(_formatTime(conv.lastAt),
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 11,
                            color: conv.unread > 0
                                ? AppColors.primary
                                : const Color(0xFF62748E),
                          )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(conv.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 13,
                        fontWeight: conv.unread > 0
                            ? FontWeight.w600 : FontWeight.w400,
                        color: conv.unread > 0
                            ? const Color(0xFF314158)
                            : const Color(0xFF62748E),
                      )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (conv.otherAvatar != null && conv.otherAvatar!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          conv.otherAvatar!,
          width: 54, height: 54,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsAvatar(),
        ),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() => Container(
    width: 54, height: 54,
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
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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

class _WhiteLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Atlas',
        style: TextStyle(fontFamily: 'Poppins', fontSize: 20,
            fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white),
        ),
        child: const Text('Fix',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14,
              fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    ],
  );
}

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

// ── Bottom nav ────────────────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int activeIndex;
  const _BottomNavBar({required this.activeIndex});

  void _onTap(BuildContext context, int index) {
    if (index == activeIndex) return;
    switch (index) {
      case 0: context.go('/client/dashboard');            break;
      case 1: context.go('/client/mes-demandes');         break;
      case 2: context.push('/client/service-categories'); break;
      case 3: context.go('/client/messages');             break;
      case 4: context.go('/client/profile');              break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_outlined,
      Icons.list_alt_outlined,
      Icons.add,
      Icons.chat_bubble_outline_rounded,
      Icons.person_outline_rounded,
    ];

    return Container(
      width: 342, height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(icons.length, (i) {
          final active = i == activeIndex;
          if (i == 2) {
            return GestureDetector(
              onTap: () => _onTap(context, i),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            );
          }
          return GestureDetector(
            onTap: () => _onTap(context, i),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icons[i],
                color: active ? AppColors.primary : Colors.white, size: 22),
            ),
          );
        }),
      ),
    );
  }
}
