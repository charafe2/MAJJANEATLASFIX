import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/notification_repository.dart';

class ClientNotificationsScreen extends StatefulWidget {
  const ClientNotificationsScreen({super.key});

  @override
  State<ClientNotificationsScreen> createState() =>
      _ClientNotificationsScreenState();
}

class _ClientNotificationsScreenState
    extends State<ClientNotificationsScreen> {
  final _repo = NotificationRepository();

  List<AppNotification> _notifications = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getNotifications();
      if (mounted) setState(() { _notifications = data; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = NotificationRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient bg
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6238],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody(context)),
            ],
          ),

          // Bottom fade gradient
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 88,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                ),
              ),
            ),
          ),

          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: -1)),
          ),
        ],
      ),
    );
  }

  // ── Orange header ──────────────────────────────────────────────────────────
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
              // Logo + icon row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    // Calendar — white circle
                    GestureDetector(
                      onTap: () => context.push('/client/agenda'),
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_today_outlined,
                            color: Color(0xFF393C40), size: 20),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Notification — dark circle (active page)
                    Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                          color: Color(0xFF393C40), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_none_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ]),
                ],
              ),
              const SizedBox(height: 16),

              // Back + search row
              Row(children: [
                // Back button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF393C40), size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                // Search bar
                Expanded(
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.only(left: 16, right: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(children: [
                      const Icon(Icons.search_rounded,
                          color: Color(0xFF393C40), size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Que recherchez-vous ?',
                          style: TextStyle(
                            fontFamily: 'Public Sans', fontSize: 14,
                            letterSpacing: -0.01 * 14,
                            color: Color(0xFF494949),
                          )),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF393C40),
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ]),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(29, 20, 29, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.306545,
                    color: Color(0xFF191C24),
                  )),
                const Icon(Icons.notifications_none_rounded,
                    color: AppColors.primary, size: 25),
              ],
            ),
            const SizedBox(height: 6),

            // Subtitle
            const Text(
              'Worem ipsum dolor sit amet, consectetur adipiscing elit.',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                height: 1.5,
                letterSpacing: -0.01 * 14,
                color: Color(0xFF494949),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            if (_loading)
              const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ))
            else if (_error != null)
              _buildError()
            else if (_notifications.isEmpty)
              _buildEmpty()
            else
              _buildList(),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFFFC7B0),
        ),
        itemBuilder: (_, i) => _NotificationItem(
          notification: _notifications[i],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Aucune notification pour le moment.',
              style: TextStyle(
                fontFamily: 'Public Sans', fontSize: 14,
                color: Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 14,
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

// ── Notification item ──────────────────────────────────────────────────────────

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  const _NotificationItem({required this.notification});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'à l\'instant';
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours  < 24)  return 'il y a ${diff.inHours}h';
    if (diff.inDays   < 7)   return 'il y a ${diff.inDays}j';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Container(
      color: isUnread
          ? const Color(0xFFFFF8F5)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: icon + name + time + arrow ──────────────────────────
            Row(
              children: [
                // Small orange circle icon
                Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),

                // Sender name
                Expanded(
                  child: Text(
                    notification.senderName,
                    style: const TextStyle(
                      fontFamily: 'Open Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFFC3430D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Time
                Text(
                  _timeAgo(notification.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF595959),
                  ),
                ),
                const SizedBox(width: 8),

                // Arrow
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary, size: 13),
              ],
            ),
            const SizedBox(height: 8),

            // ── Message ───────────────────────────────────────────────────────
            Text(
              notification.message.isNotEmpty
                  ? notification.message
                  : 'Lorem ipsum dolor sit amet, consectetur adipiscing',
              style: const TextStyle(
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                height: 1.67,
                color: Color(0xFF686868),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
