import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/netwrok/api_client.dart';
import '../../../data/repositories/profile_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanInfoScreen extends StatefulWidget {
  const ArtisanInfoScreen({super.key});
  @override
  State<ArtisanInfoScreen> createState() => _ArtisanInfoScreenState();
}

class _ArtisanInfoScreenState extends State<ArtisanInfoScreen>
    with SingleTickerProviderStateMixin {
  final _repo = ProfileRepository();
  final _dio  = ApiClient.instance;
  late final TabController _tabs;

  bool    _loading  = true;
  bool    _saving   = false;
  String? _error;
  bool    _editing  = false;

  // ── Controllers ───────────────────────────────────────────────────────────
  final _nom    = TextEditingController();
  final _email  = TextEditingController();
  final _phone  = TextEditingController();
  final _ville  = TextEditingController();

  // ── Professional services ─────────────────────────────────────────────────
  List<_ServiceItem> _services = [];

  // ── Preferences ───────────────────────────────────────────────────────────
  bool   _emailNotif = true;
  bool   _smsNotif   = false;
  String _lang       = 'Français';

  // ── Security ──────────────────────────────────────────────────────────────
  bool _twoFa = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nom.dispose(); _email.dispose(); _phone.dispose(); _ville.dispose();
    super.dispose();
  }

  // ── Load data ─────────────────────────────────────────────────────────────
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      // Personal info
      final p = await _repo.getProfile();
      _nom.text   = p.name;
      _email.text = p.email;
      _phone.text = p.phone;
      _ville.text = p.city ?? '';

      // Artisan services
      await _loadServices();

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ProfileRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadServices() async {
    try {
      final res = await _dio.get('/me');
      final data = (res.data is Map<String, dynamic>)
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      final raw = data['services'] as List<dynamic>? ?? [];
      _services = raw.map((s) {
        final m = s as Map<String, dynamic>;
        return _ServiceItem(
          id:                m['id'] as int? ?? 0,
          serviceCategoryId: m['service_category_id'] as int? ?? 0,
          name:     m['category']  as String?
                 ?? m['name']      as String? ?? 'Service',
          type:     m['type']      as String? ?? '',
          iconCode: _iconForService(
              m['category'] as String? ?? m['name'] as String? ?? ''),
        );
      }).toList();
    } catch (_) {
      _services = [];
    }
  }

  // ── Save personal info ────────────────────────────────────────────────────
  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _repo.updateProfile(
        name:  _nom.text.trim(),
        phone: _phone.text.trim(),
        city:  _ville.text.trim(),
      );
      if (mounted) {
        setState(() { _editing = false; _saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profil mis à jour avec succès !'),
          backgroundColor: Color(0xFF22C55E),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ProfileRepository.errorMessage(e)),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  // ── Icon helper ───────────────────────────────────────────────────────────
  static int _iconForService(String name) {
    final n = name.toLowerCase();
    if (n.contains('plomb'))    return Icons.water_drop_outlined.codePoint;
    if (n.contains('electr'))   return Icons.bolt_outlined.codePoint;
    if (n.contains('peintur'))  return Icons.format_paint_outlined.codePoint;
    if (n.contains('maçon') || n.contains('macon')) return Icons.home_repair_service_outlined.codePoint;
    if (n.contains('jardín') || n.contains('jardin')) return Icons.eco_outlined.codePoint;
    if (n.contains('menuiser')) return Icons.carpenter_outlined.codePoint;
    return Icons.build_outlined.codePoint;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? _buildError()
                    : TabBarView(
                        controller: _tabs,
                        children: [
                          _buildPersonalTab(),
                          _buildPrefsTab(),
                          _buildSecurityTab(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // ── Orange header ─────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mes informations',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.white,
                      )),
                    const SizedBox(height: 4),
                    Text(
                      'Gérez vos informations personnelles et professionnelles',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.manage_accounts_outlined,
                    color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabs,
        labelStyle: const TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Public Sans',
          fontWeight: FontWeight.w400,
          fontSize: 13,
        ),
        labelColor: AppColors.primary,
        unselectedLabelColor: const Color(0xFF9CA3AF),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        tabs: const [
          Tab(text: 'Informations personnelles'),
          Tab(text: 'Préférences'),
          Tab(text: 'Sécurité'),
        ],
      ),
    );
  }

  // ── Tab 1: Personal ───────────────────────────────────────────────────────
  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section heading + Modifier button ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Informations personnelles',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF191C24),
                )),
              GestureDetector(
                onTap: _editing ? _save : () => setState(() => _editing = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _editing
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (_saving)
                      const SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                      )
                    else
                      Icon(
                        _editing ? Icons.check_rounded : Icons.edit_outlined,
                        color: Colors.white, size: 14,
                      ),
                    const SizedBox(width: 5),
                    Text(
                      _editing ? 'Enregistrer' : 'Modifier',
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white,
                      )),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Fields ──────────────────────────────────────────────────────
          _LabeledField(
            label: 'Nom complet',
            controller: _nom,
            enabled: _editing,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'Adresse email',
            controller: _email,
            enabled: false,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'Téléphone',
            controller: _phone,
            enabled: _editing,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: 'Ville',
            controller: _ville,
            enabled: _editing,
            icon: Icons.location_on_outlined,
          ),

          const SizedBox(height: 28),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 20),

          // ── Professional section ─────────────────────────────────────────
          const Text('Informations professionnelles',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF191C24),
            )),
          const SizedBox(height: 16),

          if (_services.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Text(
                'Aucun service configuré.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                )),
            )
          else
            ...List.generate(_services.length, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => context.push(
                  '/artisan/service-detail/${_services[i].serviceCategoryId}',
                  extra: {'serviceName': _services[i].name},
                ),
                child: _ServiceRow(item: _services[i]),
              ),
            )),
        ],
      ),
    );
  }

  // ── Tab 2: Preferences ───────────────────────────────────────────────────
  Widget _buildPrefsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notifications',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF191C24),
            )),
          const SizedBox(height: 16),
          _ToggleRow(
            label: 'Notifications par email',
            value: _emailNotif,
            onChanged: (v) => setState(() => _emailNotif = v),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            label: 'Notifications par SMS',
            value: _smsNotif,
            onChanged: (v) => setState(() => _smsNotif = v),
          ),
          const SizedBox(height: 28),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          const SizedBox(height: 20),
          const Text('Langue',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF191C24),
            )),
          const SizedBox(height: 16),
          _LangRow(
            current: _lang,
            options: const ['Français', 'العربية', 'English'],
            onSelect: (v) => setState(() => _lang = v),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Security ───────────────────────────────────────────────────────
  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sécurité du compte',
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF191C24),
            )),
          const SizedBox(height: 16),
          _ToggleRow(
            label: 'Authentification à deux facteurs',
            value: _twoFa,
            onChanged: (v) => setState(() => _twoFa = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock_outline_rounded, size: 16),
              label: const Text('Changer le mot de passe'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    ),
  );
}

// ── Labeled field ─────────────────────────────────────────────────────────────
class _LabeledField extends StatelessWidget {
  final String             label;
  final TextEditingController controller;
  final bool               enabled;
  final IconData           icon;
  final TextInputType      keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: const TextStyle(
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: AppColors.primary,
            letterSpacing: 0.3,
          )),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: enabled
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon,
                size: 16,
                color: enabled ? AppColors.primary : const Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 14,
                    color: Color(0xFF191C24),
                  ),
                  decoration: const InputDecoration(
                    border:         InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    isDense:        true,
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Service row ───────────────────────────────────────────────────────────────
class _ServiceItem {
  final int    id;
  final int    serviceCategoryId;
  final String name;
  final String type;
  final int    iconCode;
  const _ServiceItem({
    required this.id,
    required this.serviceCategoryId,
    required this.name,
    required this.type,
    required this.iconCode,
  });
}

class _ServiceRow extends StatelessWidget {
  final _ServiceItem item;
  const _ServiceRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              IconData(item.iconCode, fontFamily: 'MaterialIcons'),
              color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF191C24),
                  )),
                if (item.type.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(item.type,
                    style: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    )),
                ],
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              color: Color(0xFF9CA3AF), size: 14),
        ],
      ),
    );
  }
}

// ── Toggle row ────────────────────────────────────────────────────────────────
class _ToggleRow extends StatelessWidget {
  final String  label;
  final bool    value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: const TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF191C24),
            )),
          Switch(
            value:            value,
            onChanged:        onChanged,
            activeThumbColor: AppColors.primary,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// ── Language picker ───────────────────────────────────────────────────────────
class _LangRow extends StatelessWidget {
  final String         current;
  final List<String>   options;
  final ValueChanged<String> onSelect;
  const _LangRow({
    required this.current,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: options.map((o) {
        final active = o == current;
        return GestureDetector(
          onTap: () => onSelect(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: active ? AppColors.primary : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(o,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: active ? Colors.white : const Color(0xFF62748E),
              )),
          ),
        );
      }).toList(),
    );
  }
}
