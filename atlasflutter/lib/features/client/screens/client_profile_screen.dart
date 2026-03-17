import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/auth_state.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../core/widgets/client_bottom_nav_bar.dart';
import '../../../../data/repositories/profile_repository.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  final _repo = ProfileRepository();

  bool         _loading = true;
  String?      _error;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _uploadingAvatar = false;

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await _repo.getProfile();
      if (mounted) setState(() { _profile = p; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ProfileRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final bytes = await picked.readAsBytes();
      final filename = picked.name;
      final updated = await _repo.updateAvatarBytes(bytes, filename);
      debugPrint('[AVATAR] new avatarUrl = ${updated.avatarUrl}');
      imageCache.clear();
      imageCache.clearLiveImages();
      if (mounted) setState(() { _profile = updated; _uploadingAvatar = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ProfileRepository.errorMessage(e),
            style: const TextStyle(fontFamily: 'Public Sans')),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
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
          // ── Warm gradient background ────────────────────────────
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

          // ── Main column ─────────────────────────────────────────
          Column(
            children: [
              _Header(),

              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.primary))
                    : _error != null
                        ? _buildError()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(40, 0, 40, 120),
                            child: Column(
                              children: [
                                const SizedBox(height: 76),

                                // Name
                                Text(
                                  _profile!.name.isNotEmpty
                                      ? _profile!.name
                                      : 'Mon profil',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.5,
                                    letterSpacing: 0.06,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Stats row
                                _StatsRow(
                                  demandes:  _profile!.demandesCount,
                                  completed: _profile!.completedCount,
                                ),
                                const SizedBox(height: 30),

                                // Menu: Mes Informations
                                _MenuBtn(
                                  icon:  Icons.person_outline_rounded,
                                  label: 'Mes Informations',
                                  onTap: () => context.push('/client/info'),
                                ),
                                const SizedBox(height: 18),

                                // Menu: Mes paiements
                                _MenuBtn(
                                  icon:  Icons.account_balance_wallet_outlined,
                                  label: 'Mes paiements',
                                  onTap: () => context.push('/client/payments'),
                                ),
                                const SizedBox(height: 120),

                                // Logout button
                                _LogoutBtn(),
                              ],
                            ),
                          ),
              ),
            ],
          ),

          // ── Floating avatar ──────────────────────────────────────
          Positioned(
            top: 150, left: 0, right: 0,
            child: _Avatar(
              avatarUrl: _profile?.avatarUrl,
              uploading: _uploadingAvatar,
              onTap: _pickAndUploadAvatar,
            ),
          ),

          // ── Bottom navigation bar ────────────────────────────────
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ClientBottomNavBar(activeIndex: 4)),
          ),
        ],
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
}

// ── Orange header ─────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AtlasLogo(),
              Row(
                children: [
                  const _HeaderIconBtn(Icons.calendar_today_outlined),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => context.push('/client/notifications'),
                    child: const _HeaderIconBtn(Icons.notifications_none_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


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

// ── Avatar ─────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback? onTap;
  const _Avatar({this.avatarUrl, this.uploading = false, this.onTap});

  @override
  Widget build(BuildContext context) => Center(
    child: GestureDetector(
      onTap: uploading ? null : onTap,
      child: SizedBox(
        width: 128, height: 128,
        child: Stack(
          children: [
            Container(
              width: 128, height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10)),
                  BoxShadow(color: Color(0x0A000000), blurRadius: 6,  offset: Offset(0, 4)),
                ],
              ),
              child: ClipOval(
                child: uploading
                    ? const Center(child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2.5))
                    : avatarUrl != null && avatarUrl!.isNotEmpty
                        ? Image.network(
                            avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person, size: 64, color: AppColors.primary),
                          )
                        : const Icon(Icons.person, size: 64, color: AppColors.primary),
              ),
            ),
            Positioned(
              bottom: 0, right: 44,
              child: Container(
                width: 31, height: 31,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 14, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Stats row ──────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int demandes;
  final int completed;
  const _StatsRow({required this.demandes, required this.completed});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 9),
      ],
    ),
    child: Row(
      children: [
        Expanded(child: _StatCard(
          icon:  Icons.assignment_outlined,
          count: '$demandes',
          label: 'Demandes',
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          icon:  Icons.check_circle_outline_rounded,
          count: '$completed',
          label: 'Projets terminés',
        )),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   count;
  final String   label;
  const _StatCard({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(6)),
    child: Row(
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(5.4),
          ),
          child: Icon(icon, color: Colors.white, size: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$count $label',
            style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14,
              color: Colors.black, letterSpacing: -0.12,
            )),
        ),
      ],
    ),
  );
}

// ── Menu button ───────────────────────────────────────────────────────────────

class _MenuBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  const _MenuBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 12.5),
      decoration: BoxDecoration(
        color: const Color(0xFF393C40),
        borderRadius: BorderRadius.circular(125),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 27, height: 27,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
              style: const TextStyle(
                fontFamily: 'Inter', fontSize: 14.2,
                color: Colors.white, letterSpacing: -0.15,
              )),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
        ],
      ),
    ),
  );
}

// ── Logout button ─────────────────────────────────────────────────────────────

class _LogoutBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 270, height: 56,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(67.7),
      border: Border.all(color: const Color(0xFFFFC9C9), width: 0.9),
    ),
    child: ElevatedButton.icon(
      onPressed: () async {
        await AuthState.instance.logout();
        // GoRouter's refreshListenable picks up the change and redirects to /login
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE7000B),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.1)),
      ),
      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
      label: const Text(
        'Se déconnecter',
        style: TextStyle(
          fontFamily: 'Open Sans', fontWeight: FontWeight.w700,
          fontSize: 12, color: Colors.white,
        ),
      ),
    ),
  );
}

