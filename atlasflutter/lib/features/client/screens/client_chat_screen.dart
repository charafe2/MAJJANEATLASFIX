import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/secure_storage.dart';
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

  // ── Send ────────────────────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildMessages()),
          _buildInput(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
              ),
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: Text(_initials(widget.otherName),
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C950),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.otherName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      )),
                    Text(widget.otherRole,
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      )),
                  ],
                ),
              ),
              // Actions
              _HeaderAction(
                icon: Icons.phone_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 4),
              _HeaderAction(
                icon: Icons.warning_amber_rounded,
                color: Colors.orange.shade200,
                onTap: () => _showReportSheet(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Messages area ───────────────────────────────────────────────────────────
  Widget _buildMessages() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
        color: AppColors.primary));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
              style: const TextStyle(color: Color(0xFF62748E))),
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
          )),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final msg  = _messages[i];
        final mine = msg.senderId == _currentUserId;
        return _MessageBubble(
          message:    msg,
          isMine:     mine,
          showRead:   mine && i == _messages.length - 1 && msg.isRead,
        );
      },
    );
  }

  // ── Input area ──────────────────────────────────────────────────────────────
  Widget _buildInput() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image preview strip
          if (_previewUrl != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _previewUrl!,
                      width: 72, height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 72, height: 72,
                        color: const Color(0xFFE5E7EB),
                        child: const Icon(Icons.image_outlined,
                          color: Color(0xFF9CA3AF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _clearImage,
                    child: Container(
                      width: 26, height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFF314158),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),

          // Input row
          Padding(
            padding: EdgeInsets.fromLTRB(
              12, 12, 12,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                // Image button
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _pendingImage != null
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.image_outlined,
                      color: _pendingImage != null
                          ? AppColors.primary : const Color(0xFF62748E),
                      size: 20),
                  ),
                ),
                const SizedBox(width: 8),

                // Text field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 14,
                        color: Color(0xFF314158),
                      ),
                      decoration: InputDecoration(
                        hintText: _pendingImage != null
                            ? 'Ajouter une légende…'
                            : 'Écrivez votre message…',
                        hintStyle: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Send button
                GestureDetector(
                  onTap: (_msgCtrl.text.trim().isNotEmpty || _pendingImage != null)
                      ? _send : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: (_msgCtrl.text.trim().isNotEmpty || _pendingImage != null)
                          ? AppColors.primary : const Color(0xFFD1D5DC),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Report sheet ────────────────────────────────────────────────────────────
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
            if (mounted) {
              _showSnackSuccess('Signalement envoyé. Merci !');
            }
          } catch (e) {
            if (mounted) _showSnack(ConversationRepository.errorMessage(e));
          }
        },
      ),
    );
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72),
                  padding: message.isImage
                      ? const EdgeInsets.all(5)
                      : const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  decoration: BoxDecoration(
                    color: isMine ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(16),
                      topRight:    const Radius.circular(16),
                      bottomLeft:  Radius.circular(isMine ? 16 : 4),
                      bottomRight: Radius.circular(isMine ? 4 : 16),
                    ),
                    border: isMine ? null : Border.all(
                      color: const Color(0xFFE5E7EB)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000),
                        blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (message.isImage && message.imageUrl != null)
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
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary, strokeWidth: 2)),
                                  ),
                          ),
                        ),
                      if (message.content != null &&
                          message.content!.isNotEmpty) ...[
                        if (message.isImage) const SizedBox(height: 4),
                        Text(message.content!,
                          style: TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            color: isMine ? Colors.white : const Color(0xFF314158),
                            height: 1.4,
                          )),
                      ],
                      const SizedBox(height: 4),
                      Text(_formatTime(message.createdAt),
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 10,
                          color: isMine
                              ? const Color(0xFFFFEDD4)
                              : const Color(0xFF62748E),
                        )),
                    ],
                  ),
                ),
                if (showRead)
                  const Padding(
                    padding: EdgeInsets.only(top: 2, right: 4),
                    child: Text('Vu',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 10,
                        color: Color(0xFF62748E),
                      )),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
           '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Header action button ──────────────────────────────────────────────────────

class _HeaderAction extends StatelessWidget {
  final IconData   icon;
  final Color?     color;
  final VoidCallback onTap;
  const _HeaderAction({required this.icon, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color ?? Colors.white, size: 19),
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
                fontFamily: 'Poppins',
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
                        fontFamily: 'Poppins',
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
