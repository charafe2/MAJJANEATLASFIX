import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/widgets/atlas_logo.dart';
import '../../../core/auth_state.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/repositories/artisan_job_repository.dart';
import '../../../data/repositories/profile_repository.dart';
import 'artisan_home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanProfileScreen extends StatefulWidget {
  const ArtisanProfileScreen({super.key});
  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  final _repo        = ArtisanJobRepository();
  final _profileRepo = ProfileRepository();

  bool              _loading   = true;
  String?           _error;
  ArtisanMyProfile? _profile;
  bool              _uploadingAvatar = false;

  String  _name      = '';
  String  _specialty = '';
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadFromStorage();
    _load();
  }

  Future<void> _loadFromStorage() async {
    final user = await SecureStorage.getUser();
    if (user != null && mounted) {
      setState(() {
        _name      = user['name']            as String?
                  ?? user['full_name']       as String? ?? '';
        _specialty = user['business_name']   as String?
                  ?? user['service_category'] as String?
                  ?? user['specialty']       as String? ?? '';
        _avatarUrl = user['avatar']          as String?
                  ?? user['avatar_url']      as String?;
      });
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await _repo.getMyProfile();
      if (mounted) {
        setState(() {
          _profile   = p;
          _name      = p.name.isNotEmpty ? p.name : _name;
          _specialty = p.specialty.isNotEmpty ? p.specialty : _specialty;
          _avatarUrl = p.avatarUrl ?? _avatarUrl;
          _loading   = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ArtisanJobRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  void _openReferralSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReferralSheet(referralCode: _profile?.referralCode),
    );
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
      final updated = await _profileRepo.updateAvatarBytes(bytes, filename);
      debugPrint('[AVATAR] new avatarUrl = ${updated.avatarUrl}');
      imageCache.clear();
      imageCache.clearLiveImages();
      if (mounted) {
        setState(() {
          _avatarUrl = updated.avatarUrl;
          _uploadingAvatar = false;
        });
      }
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
      backgroundColor: const Color(0xFFF6F6F6),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _error != null
                    ? _buildError()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                        child: Column(
                          children: [
                            // Space for avatar overlap
                            const SizedBox(height: 56),

                            // ── Name ────────────────────────────────────
                            Text(
                              _name.isNotEmpty ? _name : 'Mon profil',
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Color(0xFF191C24),
                              )),
                            const SizedBox(height: 20),

                            // ── 2×2 Stats grid ───────────────────────────
                            _loading
                                ? const SizedBox(
                                    height: 110,
                                    child: Center(child: CircularProgressIndicator(
                                      color: AppColors.primary, strokeWidth: 2)))
                                : Column(children: [
                                    Row(children: [
                                      Expanded(child: _StatCard(
                                        icon: Icons.work_outline_rounded,
                                        iconBg: const Color(0xFFFF6B35),
                                        value: '${_profile?.completedServices ?? 0}',
                                        label: 'Travaux complétés',
                                      )),
                                      const SizedBox(width: 12),
                                      Expanded(child: _StatCard(
                                        icon: Icons.star_rounded,
                                        iconBg: const Color(0xFFFFB800),
                                        value: _profile != null && _profile!.rating > 0
                                            ? '${_profile!.rating.toStringAsFixed(1)}/5'
                                            : '0.0/5',
                                        label: 'Note moyenne',
                                      )),
                                    ]),
                                    const SizedBox(height: 12),
                                    Row(children: [
                                      Expanded(child: _StatCard(
                                        icon: Icons.reviews_outlined,
                                        iconBg: const Color(0xFF22C55E),
                                        value: '${_profile?.totalReviews ?? 0}',
                                        label: 'Avis clients',
                                      )),
                                      const SizedBox(width: 12),
                                      Expanded(child: _StatCard(
                                        icon: Icons.phone_outlined,
                                        iconBg: const Color(0xFF3B82F6),
                                        value: '${(_profile?.activeOffers ?? 0) + (_profile?.pendingOffers ?? 0)}',
                                        label: 'Offres en cours',
                                      )),
                                    ]),
                                  ]),
                            const SizedBox(height: 16),

                            // ── Programme de Parrainage ──────────────────
                            _ReferralBanner(onTap: _openReferralSheet),
                            const SizedBox(height: 20),

                            // ── Menu items ───────────────────────────────
                            _ProfileMenuItem(
                              icon:  Icons.manage_accounts_outlined,
                              label: 'Mes Informations',
                              onTap: () => context.push('/artisan/info'),
                            ),
                            const SizedBox(height: 12),
                            _ProfileMenuItem(
                              icon:  Icons.build_circle_outlined,
                              label: 'Mes services',
                              onTap: () => context.push('/artisan/my-services'),
                            ),
                            const SizedBox(height: 12),
                            _ProfileMenuItem(
                              icon:  Icons.account_balance_wallet_outlined,
                              label: 'Mes paiements',
                              onTap: () {},
                            ),
                            const SizedBox(height: 32),

                            // ── Logout ───────────────────────────────────
                            _LogoutBtn(),
                          ],
                        ),
                      ),
              ),
            ],
          ),

          // ── Floating avatar ──────────────────────────────────────────
          Positioned(
            top: 152, left: 0, right: 0,
            child: Center(child: _Avatar(
              avatarUrl: _avatarUrl,
              uploading: _uploadingAvatar,
              onTap: _pickAndUploadAvatar,
            )),
          ),

          // ── Bottom nav ───────────────────────────────────────────────
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 4)),
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
        child: SizedBox(
          height: 205,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 70),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AtlasLogo(),
                Row(children: [
                  GestureDetector(
                    onTap: () => context.push('/artisan/agenda'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFF393C40), size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
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
          ),
        ),
      ),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(_error!, textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Public Sans',
            fontSize: 14, color: Color(0xFF62748E))),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ]),
    ),
  );
}

// ── Floating avatar ───────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String? avatarUrl;
  final bool uploading;
  final VoidCallback? onTap;
  const _Avatar({this.avatarUrl, this.uploading = false, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: uploading ? null : onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFE0D3),
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000),
                blurRadius: 14, offset: Offset(0, 6)),
            ],
          ),
          child: ClipOval(
            child: uploading
                ? const Center(child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2.5))
                : avatarUrl != null && avatarUrl!.isNotEmpty
                    ? Image.network(avatarUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, size: 50, color: AppColors.primary))
                    : const Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
        ),
        // Edit badge
        Positioned(
          bottom: 0, right: 0,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.edit_outlined, size: 13, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color    iconBg;
  final String   value;
  final String   label;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF191C24),
                )),
              Text(label,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                )),
            ],
          ),
        ),
      ]),
    );
  }
}

// ── Referral banner ───────────────────────────────────────────────────────────
class _ReferralBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ReferralBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(children: [
        const Icon(Icons.card_giftcard_rounded,
          color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('Programme de Parrainage',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Color(0xFF191C24),
            )),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text('Générer',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.white,
              )),
          ),
        ),
      ]),
    );
  }
}

// ── Profile menu item ─────────────────────────────────────────────────────────
class _ProfileMenuItem extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              )),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
            color: Colors.white, size: 14),
        ]),
      ),
    );
  }
}

// ── Logout button ─────────────────────────────────────────────────────────────
class _LogoutBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity, height: 50,
    child: ElevatedButton.icon(
      onPressed: () async => AuthState.instance.logout(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
      label: const Text('Se déconnecter',
        style: TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.white,
        )),
    ),
  );
}

// ── Referral bottom sheet ─────────────────────────────────────────────────────
class _ReferralSheet extends StatefulWidget {
  const _ReferralSheet({this.referralCode});
  final String? referralCode;

  @override
  State<_ReferralSheet> createState() => _ReferralSheetState();
}

class _ReferralSheetState extends State<_ReferralSheet> {
  bool _copied = false;

  String get _referralLink {
    final code = widget.referralCode ?? '';
    if (code.isEmpty) return '';
    return '${ApiConstants.webBaseUrl}/register/artisan?ref=$code';
  }

  Future<void> _copyLink() async {
    final link = _referralLink;
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lien de parrainage non disponible.'),
        backgroundColor: Colors.orange,
      ));
      return;
    }
    await Clipboard.setData(ClipboardData(text: link));
    setState(() => _copied = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Lien copié dans le presse-papier !'),
        backgroundColor: Color(0xFF22C55E),
        duration: Duration(seconds: 2),
      ));
    }
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasCode = (widget.referralCode ?? '').isNotEmpty;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text('Programme de Parrainage',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Color(0xFF191C24),
                  )),
              ),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_giftcard_rounded,
                  color: AppColors.primary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Partagez AtlasFix avec vos amis et gagnez un boost gratuit pour chaque inscription !',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: Color(0xFF62748E),
              height: 1.55,
            )),
          if (hasCode) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _referralLink,
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 12,
                  color: Color(0xFF555555),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton.icon(
              onPressed: _copyLink,
              icon: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 18,
              ),
              label: Text(
                _copied ? 'Lien copié !' : 'Générer mon lien de parrainage',
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                )),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copied
                    ? const Color(0xFF22C55E)
                    : AppColors.primary,
                elevation: 0,
                shape: const StadiumBorder(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCE8),
              border: Border.all(color: const Color(0xFFFFF085)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFFD08700), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gagnez 1 boost gratuit',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF733E0A),
                        )),
                      SizedBox(height: 3),
                      Text(
                        "(7 jours) pour chaque ami qui crée un compte artisan via votre lien !",
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 13,
                          color: Color(0xFF733E0A),
                          height: 1.4,
                        )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
