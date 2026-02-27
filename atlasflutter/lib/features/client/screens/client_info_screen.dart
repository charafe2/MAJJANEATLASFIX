import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/profile_repository.dart';

class ClientInfoScreen extends StatefulWidget {
  const ClientInfoScreen({super.key});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen>
    with SingleTickerProviderStateMixin {
  final _repo = ProfileRepository();
  late final TabController _tabs;

  // ── Loading / error state ──────────────────────────────────────
  bool    _loading = true;
  bool    _saving  = false;
  String? _error;

  // ── Informations personnelles controllers ──────────────────────
  final _nom        = TextEditingController();
  final _email      = TextEditingController();
  final _phone      = TextEditingController();
  final _birthdate  = TextEditingController();
  final _ville      = TextEditingController();
  final _adresse    = TextEditingController();
  final _codePostal = TextEditingController();
  bool _editing = false;

  // ── Préférences state ──────────────────────────────────────────
  bool   _emailNotif = true;
  bool   _smsNotif   = false;
  String _lang       = 'Français';

  // ── Sécurité state ────────────────────────────────────────────
  bool _twoFa = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nom.dispose(); _email.dispose(); _phone.dispose();
    _birthdate.dispose(); _ville.dispose(); _adresse.dispose();
    _codePostal.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await _repo.getProfile();
      if (mounted) {
        setState(() {
          _nom.text        = p.name;
          _email.text      = p.email;
          _phone.text      = p.phone;
          _birthdate.text  = p.birthdate ?? '';
          _ville.text      = p.city      ?? '';
          _adresse.text    = p.address   ?? '';
          _codePostal.text = p.postalCode ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ProfileRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      await _repo.updateProfile(
        name:       _nom.text.trim(),
        phone:      _phone.text.trim(),
        birthdate:  _birthdate.text.trim().isEmpty ? null : _birthdate.text.trim(),
        city:       _ville.text.trim().isEmpty     ? null : _ville.text.trim(),
        address:    _adresse.text.trim().isEmpty   ? null : _adresse.text.trim(),
        postalCode: _codePostal.text.trim().isEmpty ? null : _codePostal.text.trim(),
      );
      if (mounted) {
        setState(() { _editing = false; _saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Informations mises à jour.',
              style: TextStyle(fontFamily: 'Public Sans')),
          backgroundColor: Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
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
          // Gradient background
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
              // Tiny orange header strip
              Container(
                height: MediaQuery.of(context).padding.top + 24,
                color: AppColors.primary,
              ),

              // White card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft:  Radius.circular(32.35),
                      topRight: Radius.circular(32.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.primary))
                      : _error != null
                          ? _buildError()
                          : Column(
                              children: [
                                _TabBar(controller: _tabs),
                                Expanded(
                                  child: TabBarView(
                                    controller: _tabs,
                                    children: [
                                      _InfoTab(
                                        nom: _nom, email: _email, phone: _phone,
                                        birthdate: _birthdate, ville: _ville,
                                        adresse: _adresse, codePostal: _codePostal,
                                        editing: _editing,
                                        saving:  _saving,
                                        onToggleEdit: () {
                                          if (_editing) {
                                            _saveProfile();
                                          } else {
                                            setState(() => _editing = true);
                                          }
                                        },
                                      ),
                                      _PrefsTab(
                                        emailNotif: _emailNotif,
                                        smsNotif:   _smsNotif,
                                        lang:       _lang,
                                        onEmailChanged: (v) => setState(() => _emailNotif = v),
                                        onSmsChanged:   (v) => setState(() => _smsNotif   = v),
                                        onLangChanged:  (v) => setState(() => _lang       = v!),
                                      ),
                                      _SecTab(
                                        twoFa: _twoFa,
                                        onTwoFaChanged: (v) => setState(() => _twoFa = v),
                                        onDeleteAccount: () => _confirmDelete(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ],
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 4,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => context.pop(),
            ),
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
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                    color: Color(0xFF62748E))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProfile,
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text('Cette action est irréversible. Confirmez-vous ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () { Navigator.pop(context); context.go('/login'); },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Custom tab bar ────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    height: 39,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.8)),
      borderRadius: BorderRadius.only(
        topLeft:  Radius.circular(32.35),
        topRight: Radius.circular(32.35),
      ),
    ),
    child: TabBar(
      controller: controller,
      labelColor:           AppColors.primary,
      unselectedLabelColor: const Color(0xFF62748E),
      indicatorColor:       AppColors.primary,
      indicatorWeight:      1.6,
      indicatorSize:        TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(
        fontFamily: 'Open Sans', fontSize: 12, fontWeight: FontWeight.w400,
        letterSpacing: -0.25),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Open Sans', fontSize: 12, fontWeight: FontWeight.w400,
        letterSpacing: -0.25),
      tabs: const [
        Tab(text: 'Informations personnelles'),
        Tab(text: 'Préférences'),
        Tab(text: 'Sécurité'),
      ],
    ),
  );
}

// ── Informations personnelles tab ─────────────────────────────────────────────

class _InfoTab extends StatelessWidget {
  final TextEditingController nom, email, phone, birthdate, ville, adresse, codePostal;
  final bool         editing;
  final bool         saving;
  final VoidCallback onToggleEdit;

  const _InfoTab({
    required this.nom,       required this.email,    required this.phone,
    required this.birthdate, required this.ville,    required this.adresse,
    required this.codePostal,
    required this.editing,   required this.saving,   required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(39, 24, 39, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Modifier / Enregistrer button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Informations personnelles',
              style: TextStyle(
                fontFamily: 'Open Sans', fontWeight: FontWeight.w700,
                fontSize: 16, letterSpacing: -0.31, color: Color(0xFF191C24),
              )),
            GestureDetector(
              onTap: saving ? null : onToggleEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                decoration: BoxDecoration(
                  color: saving
                      ? const Color(0xFFD1D5DC)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(28.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (saving)
                      const SizedBox(
                        width: 13, height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Colors.white),
                      )
                    else
                      Icon(
                        editing ? Icons.check_outlined : Icons.edit_outlined,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      saving ? 'Enregistrement…'
                          : editing ? 'Enregistrer' : 'Modifier',
                      style: const TextStyle(
                        fontFamily: 'Open Sans', fontSize: 12,
                        color: Colors.white, letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Form fields
        _LabeledInput(label: 'Nom complet',       ctrl: nom,        icon: Icons.person_outline_rounded,      readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Adresse email',     ctrl: email,      icon: Icons.mail_outline_rounded,        readOnly: true,    keyboard: TextInputType.emailAddress),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Téléphone',         ctrl: phone,      icon: Icons.phone_outlined,              readOnly: !editing, keyboard: TextInputType.phone),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Date de naissance', ctrl: birthdate,  icon: Icons.calendar_month_outlined,     readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Ville',             ctrl: ville,      icon: Icons.location_on_outlined,        readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Adresse',           ctrl: adresse,    icon: Icons.home_outlined,               readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Code postal',       ctrl: codePostal, icon: Icons.markunread_mailbox_outlined, readOnly: !editing, keyboard: TextInputType.number),
      ],
    ),
  );
}

// ── Labeled input field ───────────────────────────────────────────────────────

class _LabeledInput extends StatelessWidget {
  final String                label;
  final TextEditingController ctrl;
  final IconData              icon;
  final bool                  readOnly;
  final TextInputType         keyboard;

  const _LabeledInput({
    required this.label,
    required this.ctrl,
    required this.icon,
    this.readOnly = true,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: readOnly
              ? const Color(0x1AF5F8F9)
              : const Color(0x1AFC5A15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller:   ctrl,
                readOnly:     readOnly,
                keyboardType: keyboard,
                style: const TextStyle(
                  fontFamily: 'Open Sans', fontSize: 14,
                  color: Colors.black, letterSpacing: -0.36,
                ),
                decoration: const InputDecoration(
                  border:         InputBorder.none,
                  isDense:        true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating label tag
      Positioned(
        top: -8, left: 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: readOnly ? Colors.black : AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Open Sans', fontSize: 10,
              color: Colors.white, height: 1.4,
            ),
          ),
        ),
      ),
    ],
  );
}

// ── Préférences tab ──────────────────────────────────────────────────────────

class _PrefsTab extends StatelessWidget {
  final bool   emailNotif;
  final bool   smsNotif;
  final String lang;
  final void Function(bool)    onEmailChanged;
  final void Function(bool)    onSmsChanged;
  final void Function(String?) onLangChanged;

  const _PrefsTab({
    required this.emailNotif, required this.smsNotif, required this.lang,
    required this.onEmailChanged, required this.onSmsChanged, required this.onLangChanged,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(39, 24, 39, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Préférences',
          style: TextStyle(
            fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
            fontSize: 16, letterSpacing: -0.31, color: Color(0xFF191C24),
          )),
        const SizedBox(height: 24),

        _PrefToggleRow(
          icon: Icons.mail_outline_rounded,
          label: 'Notifications par email',
          desc: 'Recevoir des notifications sur les nouvelles demandes',
          value: emailNotif,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 26),

        _PrefToggleRow(
          icon: Icons.phone_outlined,
          label: 'Notifications par SMS',
          desc: 'Recevoir des SMS pour les mises à jour importantes',
          value: smsNotif,
          onChanged: onSmsChanged,
        ),
        const SizedBox(height: 26),

        const Text('Langue',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: Color(0xFF62748E))),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0x1AF5F8F9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.primary),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: lang,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: Colors.black),
              items: const [
                DropdownMenuItem(value: 'Français', child: Text('Français')),
                DropdownMenuItem(value: 'English',  child: Text('English')),
                DropdownMenuItem(value: 'العربية',  child: Text('العربية')),
              ],
              onChanged: onLangChanged,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PrefToggleRow extends StatelessWidget {
  final IconData            icon;
  final String              label;
  final String              desc;
  final bool                value;
  final void Function(bool) onChanged;

  const _PrefToggleRow({
    required this.icon,  required this.label, required this.desc,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withValues(alpha: 0.1)
              : const Color(0x1AF5F8F9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14, color: Colors.black)),
            ),
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                color: value ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: value ? AppColors.primary : const Color(0xFFFFC3A9)),
                borderRadius: BorderRadius.circular(5),
              ),
              child: value
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(desc,
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            color: Color(0xFF62748E), letterSpacing: -0.15,
          )),
      ),
    ],
  );
}

// ── Sécurité tab ──────────────────────────────────────────────────────────────

class _SecTab extends StatelessWidget {
  final bool   twoFa;
  final void Function(bool) onTwoFaChanged;
  final VoidCallback        onDeleteAccount;

  const _SecTab({
    required this.twoFa,
    required this.onTwoFaChanged,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(39, 24, 39, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sécurité',
          style: TextStyle(
            fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
            fontSize: 16, letterSpacing: -0.31, color: Color(0xFF191C24),
          )),
        const SizedBox(height: 24),

        _SecRow(
          icon: Icons.lock_outline_rounded,
          label: 'Modifier le mot de passe',
          desc: 'Changez votre mot de passe régulièrement',
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(24.5)),
            child: const Text('Modifier',
              style: TextStyle(fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 26),

        _SecRow(
          icon: Icons.security_outlined,
          label: 'Authentification à deux facteurs',
          desc: 'Sécurisez votre compte avec la 2FA',
          action: Switch(
            value:              twoFa,
            onChanged:          onTwoFaChanged,
            activeThumbColor:   AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DC),
          ),
        ),
        const SizedBox(height: 26),

        _SecRow(
          icon: Icons.credit_card_outlined,
          label: 'Moyens de paiement',
          desc: 'Gérez vos cartes bancaires',
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(24.5)),
            child: const Text('Gérer',
              style: TextStyle(fontFamily: 'Public Sans',
                  fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 32),

        // Delete account — danger zone
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Supprimer mon compte',
                      style: TextStyle(
                        fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                        fontSize: 14, color: Color(0xFFDC2626),
                      )),
                    SizedBox(height: 2),
                    Text('Cette action est irréversible',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                          color: Color(0xFFEF4444))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDeleteAccount,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Supprimer',
                    style: TextStyle(fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SecRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   desc;
  final Widget   action;

  const _SecRow({
    required this.icon,   required this.label,
    required this.desc,   required this.action,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0x1AF5F8F9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                style: const TextStyle(
                  fontFamily: 'Public Sans', fontSize: 14,
                  color: Colors.black, letterSpacing: -0.36,
                )),
            ),
            action,
          ],
        ),
      ),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(desc,
          style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            color: Color(0xFF62748E), letterSpacing: -0.15,
          )),
      ),
    ],
  );
}
