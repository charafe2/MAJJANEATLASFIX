import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../data/repositories/conversation_repository.dart';

class ClientChatScreen extends StatefulWidget {
  final int     conversationId;
  final String  otherName;
  final String  otherRole;
  final String? otherAvatar;
  final int?    otherProfileId;

  const ClientChatScreen({
    super.key,
    required this.conversationId,
    required this.otherName,
    required this.otherRole,
    this.otherAvatar,
    this.otherProfileId,
  });

  @override
  State<ClientChatScreen> createState() => _ClientChatScreenState();
}

class _ClientChatScreenState extends State<ClientChatScreen> {
  final _repo       = ConversationRepository();
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker     = ImagePicker();

  List<Message> _messages = [];
  bool          _loading  = true;
  bool          _sending  = false;
  String?       _error;
  int?          _currentUserId;
  XFile?        _pendingImage;
  String?       _previewUrl;
  Timer?        _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await SecureStorage.getUser();
    if (mounted) setState(() => _currentUserId = user?['id'] as int?);
  }

  Future<void> _loadMessages({bool silent = false}) async {
    if (!silent) setState(() { _loading = true; _error = null; });
    try {
      final msgs = await _repo.getMessages(widget.conversationId);
      await _repo.markRead(widget.conversationId);
      if (mounted) {
        setState(() { _messages = msgs; _loading = false; });
        _scrollToBottom();
        _startPolling();
      }
    } catch (e) {
      if (mounted) setState(() {
        _error   = ConversationRepository.errorMessage(e);
        _loading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!mounted) return;
      try {
        final fresh = await _repo.getMessages(widget.conversationId);
        if (!mounted) return;
        if (fresh.length != _messages.length ||
            fresh.any((fm) {
              final ex = _messages.where((m) => m.id == fm.id).firstOrNull;
              return ex != null && fm.isRead != ex.isRead;
            })) {
          await _repo.markRead(widget.conversationId);
          setState(() => _messages = fresh);
          _scrollToBottom();
        }
      } catch (_) {}
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text  = _msgCtrl.text.trim();
    final image = _pendingImage;
    if ((!text.isNotEmpty && image == null) || _sending) return;

    setState(() => _sending = true);
    try {
      Message sent;
      if (image != null) {
        sent = await _repo.sendImage(
          widget.conversationId, image, caption: text.isNotEmpty ? text : null);
      } else {
        sent = await _repo.sendText(widget.conversationId, text);
      }
      _msgCtrl.clear();
      setState(() {
        _pendingImage = null;
        _previewUrl   = null;
        _messages     = [..._messages, sent];
      });
      _scrollToBottom();
    } catch (e) {
      _showSnack(ConversationRepository.errorMessage(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      _pendingImage = file;
      _previewUrl   = file.path;
    });
  }

  void _clearImage() => setState(() { _pendingImage = null; _previewUrl = null; });

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Public Sans')),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  void _showSnackSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Public Sans')),
      backgroundColor: const Color(0xFF16A34A),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ));
  }

  void _showReportSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _ReportSheet(
        onReport: (reason) async {
          try {
            await _repo.report(widget.conversationId, reason);
            if (mounted) _showSnackSuccess('Signalement envoyé. Merci !');
          } catch (e) {
            if (mounted) _showSnack(ConversationRepository.errorMessage(e));
          }
        },
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  // ── Orange header ──────────────────────────────────────────────────────────
  // CSS: 393x243, bg #FC5A15, border-radius 0 0 20 20
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFC5A15),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: AtlasLogo + 2 circle icon buttons (CSS top:69 → ~17px from SafeArea)
              const SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    _ChatCircleBtn(
                      icon: Icons.calendar_today_outlined,
                      onTap: () => context.push('/client/agenda'),
                    ),
                    const SizedBox(width: 15),
                    const _ChatCircleBtn(icon: Icons.notifications_none_rounded),
                  ]),
                ],
              ),

              // Back button (CSS: ArrowCircleLeft, 40x40, left:25, top:119 → ~10px gap)
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFFFC5A15), size: 16,
                  ),
                ),
              ),

              // User info row (CSS: left:28, top:176 → ~17px gap after back btn)
              const SizedBox(height: 17),
              Row(
                children: [
                  // Avatar 48x48 + green online dot
                  Stack(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.3),
                          image: widget.otherAvatar != null &&
                                  widget.otherAvatar!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.otherAvatar!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (widget.otherAvatar == null ||
                                widget.otherAvatar!.isEmpty)
                            ? Center(
                                child: Text(
                                  _initials(widget.otherName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      // Green online dot (CSS: 13.71x13.71, #00C950, border 1.71px white)
                      Positioned(
                        right: 0, bottom: 0,
                        child: Container(
                          width: 13.71, height: 13.71,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C950),
                            border: Border.all(color: Colors.white, width: 1.71),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 13),
                  // Name + Online
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CSS: Public Sans 700 16px white letter-spacing -0.02em
                        Text(
                          widget.otherName,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: -0.32,
                            color: Colors.white,
                          ),
                        ),
                        // CSS: Public Sans 400 14px white letter-spacing -0.02em
                        const Text(
                          'Online',
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            letterSpacing: -0.28,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons — phone, video, 3-dots
                  const Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 14),
                  const Icon(Icons.videocam_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: _showReportSheet,
                    child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body (white rounded panel + messages + input) ──────────────────────────
  Widget _buildBody(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Stack(
      children: [
        // White rounded panel (CSS: Rectangle 4 border-radius 32.35 32.35 0 0)
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(32.35),
              topRight: Radius.circular(32.35),
            ),
          ),
          child: Column(
            children: [
              Expanded(child: _buildMessagesList()),
              // Image preview (compact strip above input)
              if (_previewUrl != null) _buildImagePreview(),
              _buildInput(bottomPad),
            ],
          ),
        ),
        // Bottom fade (CSS: Rectangle 7036 gradient transparent→white, 88px)
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: IgnorePointer(
            child: Container(
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Messages list ──────────────────────────────────────────────────────────
  Widget _buildMessagesList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary, strokeWidth: 2));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(
              fontFamily: 'Public Sans', color: Color(0xFF62748E))),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadMessages,
              child: const Text('Réessayer',
                style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Commencez la conversation en envoyant un message.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      // CSS: Frame 27 left:20.71, top:25.65 → padding 25 top, 20 sides
      padding: const EdgeInsets.fromLTRB(20.71, 25.65, 20.71, 20),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg  = _messages[i];
        final mine = msg.senderId == _currentUserId;
        return _MessageBubble(
          message:  msg,
          isMine:   mine,
          showRead: mine && i == _messages.length - 1 && msg.isRead,
        );
      },
    );
  }

  // ── Image preview ──────────────────────────────────────────────────────────
  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _previewUrl!,
              width: 60, height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60, height: 60,
                color: const Color(0xFFE5E7EB),
                child: const Icon(Icons.image_outlined,
                  color: Color(0xFF9CA3AF), size: 24),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _clearImage,
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF314158), shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded,
                color: Colors.white, size: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input bar ──────────────────────────────────────────────────────────────
  // CSS: Frame 1597881130 — 349.59x66.79, borderRadius 171.14px
  // Border: 1.04px solid #E5E6E9
  // Left btn: 34.44x34.44, #393C40 circle at left:14.61 — attachment/add
  // Right btn: 34.44x34.44, #FC5A15 circle at left:300.54 — microphone/send
  // Divider: 1px #E5E6E9 at left:285.93
  Widget _buildInput(double bottomPad) {
    final hasContent = _msgCtrl.text.trim().isNotEmpty || _pendingImage != null;
    return Padding(
      // CSS: centered with margin ~21.7px each side
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPad + 16),
      child: Container(
        height: 66.79,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(171.14),
          border: Border.all(color: const Color(0xFFE5E6E9), width: 1.04),
        ),
        child: Row(
          children: [
            // CSS: left:14.61
            const SizedBox(width: 14.61),
            // Left dark circle button (attach)
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 34.44, height: 34.44,
                decoration: BoxDecoration(
                  color: _pendingImage != null
                      ? AppColors.primary
                      : const Color(0xFF393C40),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _pendingImage != null ? Icons.check_rounded : Icons.add_rounded,
                  color: Colors.white, size: 18,
                ),
              ),
            ),
            // gap: 61.57 - 14.61 - 34.44 = 12.52
            const SizedBox(width: 12.52),
            // Text field
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                maxLines: 1,
                // CSS: Public Sans 400 14.61px
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14.61,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: 'Écrivez votre message...',
                  hintStyle: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14.61,
                    color: Color(0xFFAAAAAA),
                  ),
                  border:        InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense:       true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            // Vertical divider (CSS: Line 26 at left:285.93)
            Container(
              width: 1, height: 34,
              color: const Color(0xFFE5E6E9),
            ),
            const SizedBox(width: 7),
            // Right orange circle (mic/send)
            GestureDetector(
              onTap: hasContent ? _send : null,
              child: Container(
                width: 34.44, height: 34.44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFC5A15),
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : Icon(
                        hasContent
                            ? Icons.send_rounded
                            : Icons.mic_rounded,
                        color: Colors.white, size: 18,
                      ),
              ),
            ),
            // CSS: right edge ~ 8px from container edge
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────
// CSS: received bg rgba(208,208,208,0.25), sent bg #FFECDD, borderRadius 15.65px
// Text: Public Sans 400 15.65px line-height 18px color #000000
// Timestamp: Public Sans 400 12.52px color #8A91A8, below bubble gap 6.26px

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool    isMine;
  final bool    showRead;
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showRead,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // CSS: gap between message frames 5.22px (used in Frame 27)
      padding: const EdgeInsets.only(bottom: 10.44),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Bubble
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding: message.isImage
                    ? const EdgeInsets.all(5)
                    // CSS: padding 10.4354px 20.8708px
                    : const EdgeInsets.symmetric(
                        horizontal: 20.87, vertical: 10.44),
                decoration: BoxDecoration(
                  // Received: rgba(208,208,208,0.25) = 0x40D0D0D0
                  // Sent:     #FFECDD
                  color: isMine
                      ? const Color(0xFFFFECDD)
                      : const Color(0x40D0D0D0),
                  borderRadius: BorderRadius.circular(15.65),
                ),
                child: _buildBubbleContent(),
              ),
              // Timestamp (CSS: gap 6.26px, Public Sans 400 12.52px #8A91A8)
              const SizedBox(height: 6.26),
              Text(
                _formatTime(message.createdAt),
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12.52,
                  height: 1,
                  letterSpacing: -0.25,
                  color: Color(0xFF8A91A8),
                ),
              ),
              if (showRead)
                const Text('Vu',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 10,
                    color: Color(0xFF8A91A8),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent() {
    if (message.isImage && message.imageUrl != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              message.imageUrl!,
              width: 220,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      width: 220, height: 160,
                      color: const Color(0xFFE5E7EB),
                      child: const Center(child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2)),
                    ),
            ),
          ),
          if (message.content != null && message.content!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(message.content!,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 15.65,
                height: 18 / 15.65,
                letterSpacing: -0.31,
                color: Colors.black,
              )),
          ],
        ],
      );
    }
    return Text(
      message.content ?? '',
      // CSS: Public Sans 400 15.6531px line-height 18px letter-spacing -0.02em #000000
      style: const TextStyle(
        fontFamily: 'Public Sans',
        fontSize: 15.65,
        height: 18 / 15.65,
        letterSpacing: -0.31,
        color: Colors.black,
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h   = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12    = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$min $period';
  }
}

// ── Chat circle button (header) ───────────────────────────────────────────────
// CSS: Frame 1597881071 — 40x40, bg #FFFFFF, border-radius 125px

class _ChatCircleBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback? onTap;
  const _ChatCircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF393C40), size: 20),
    ),
  );
}

// ── Report sheet ──────────────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  final Future<void> Function(String reason) onReport;
  const _ReportSheet({required this.onReport});
  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _selected;
  bool    _submitting = false;

  static const _options = [
    'Comportement inapproprié',
    'Spam ou publicité',
    'Informations incorrectes',
    'Contenu offensant',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 12, 20,
        MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DC),
                borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Row(children: [
            Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 10),
            Text('Signaler cette conversation',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF314158),
              )),
          ]),
          const SizedBox(height: 16),
          ..._options.map((opt) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selected = opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _selected == opt
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : const Color(0xFFF9FAFB),
                  border: Border.all(
                    color: _selected == opt
                        ? AppColors.primary : const Color(0xFFE5E7EB),
                    width: _selected == opt ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(opt,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 13,
                        fontWeight: _selected == opt
                            ? FontWeight.w600 : FontWeight.w400,
                        color: _selected == opt
                            ? AppColors.primary : const Color(0xFF314158),
                      )),
                  ),
                  if (_selected == opt)
                    const Icon(Icons.check_circle_rounded,
                      color: AppColors.primary, size: 18),
                ]),
              ),
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: (_selected == null || _submitting) ? null : () async {
                setState(() => _submitting = true);
                await widget.onReport(_selected!);
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                disabledBackgroundColor: const Color(0xFFD1D5DC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                  : const Text('Envoyer le signalement',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}
