import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ClientInfoScreen extends StatefulWidget {
  const ClientInfoScreen({super.key});

  @override
  State<ClientInfoScreen> createState() => _ClientInfoScreenState();
}

class _ClientInfoScreenState extends State<ClientInfoScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  // ── Informations personnelles controllers ──────────────────────
  final _nom        = TextEditingController(text: 'Fullname');
  final _email      = TextEditingController(text: 'email@gmail.com');
  final _phone      = TextEditingController(text: '06 xx xx xx xx');
  final _birthdate  = TextEditingController(text: 'JJ/MM/AAAA');
  final _ville      = TextEditingController(text: 'Rabat');
  final _adresse    = TextEditingController(text: 'Lorem ipsum dolor sit amet, consectetur');
  final _codePostal = TextEditingController(text: '12000');
  bool _editing = false;

  // ── Préférences state ──────────────────────────────────────────
  bool _emailNotif = true;
  bool _smsNotif   = false;
  String _lang     = 'Français';

  // ── Sécurité state ────────────────────────────────────────────
  bool _twoFa = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nom.dispose(); _email.dispose(); _phone.dispose();
    _birthdate.dispose(); _ville.dispose(); _adresse.dispose();
    _codePostal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient background (same as profile screen)
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

          // ── White panel sliding up ──────────────────────────────
          Column(
            children: [
              // Tiny orange header strip (visible behind the white card)
              Container(
                height: MediaQuery.of(context).padding.top + 24,
                color: AppColors.primary,
              ),

              // White card with rounded top corners
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
                  child: Column(
                    children: [
                      // ── Tab bar ─────────────────────────────────
                      _TabBar(controller: _tabs),

                      // ── Tab views ───────────────────────────────
                      Expanded(
                        child: TabBarView(
                          controller: _tabs,
                          children: [
                            _InfoTab(
                              nom: _nom, email: _email, phone: _phone,
                              birthdate: _birthdate, ville: _ville,
                              adresse: _adresse, codePostal: _codePostal,
                              editing: _editing,
                              onToggleEdit: () => setState(() => _editing = !_editing),
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

          // ── Back button ─────────────────────────────────────────
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text('Cette action est irréversible. Confirmez-vous ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () { Navigator.pop(context); context.go('/login'); },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Custom tab bar matching Figma design ──────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    height: 39,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 0.8)),
      borderRadius: const BorderRadius.only(
        topLeft:  Radius.circular(32.35),
        topRight: Radius.circular(32.35),
      ),
    ),
    child: TabBar(
      controller: controller,
      labelColor:      AppColors.primary,
      unselectedLabelColor: const Color(0xFF62748E),
      indicatorColor:  AppColors.primary,
      indicatorWeight: 1.6,
      indicatorSize:   TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(
        fontFamily: 'Open Sans',
        fontSize:   12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: 'Open Sans',
        fontSize:   12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
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
  final VoidCallback onToggleEdit;

  const _InfoTab({
    required this.nom,       required this.email,    required this.phone,
    required this.birthdate, required this.ville,    required this.adresse,
    required this.codePostal,
    required this.editing,   required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(39, 24, 39, 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Modifier button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Informations personnelles',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.31,
                color: Color(0xFF191C24),
              )),
            GestureDetector(
              onTap: onToggleEdit,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(28.4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_outlined, color: Colors.white, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      editing ? 'Enregistrer' : 'Modifier',
                      style: const TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 12,
                        color: Colors.white,
                        letterSpacing: -0.2,
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
        _LabeledInput(label: 'Nom complet',        ctrl: nom,        icon: Icons.person_outline_rounded, readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Adresse email',      ctrl: email,      icon: Icons.mail_outline_rounded,   readOnly: !editing, keyboard: TextInputType.emailAddress),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Téléphone',          ctrl: phone,      icon: Icons.phone_outlined,          readOnly: !editing, keyboard: TextInputType.phone),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Date de naissance',  ctrl: birthdate,  icon: Icons.calendar_month_outlined, readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Ville',              ctrl: ville,      icon: Icons.location_on_outlined,    readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Adresse',            ctrl: adresse,    icon: Icons.home_outlined,           readOnly: !editing),
        const SizedBox(height: 26),
        _LabeledInput(label: 'Code postal',        ctrl: codePostal, icon: Icons.markunread_mailbox_outlined, readOnly: !editing, keyboard: TextInputType.number),
      ],
    ),
  );
}

// ── Labeled input field (Figma style with floating orange label tag) ──────────
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
      // Input container
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color:        readOnly
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
                  fontFamily: 'Open Sans',
                  fontSize:   14,
                  color:      Colors.black,
                  letterSpacing: -0.36,
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
      // Floating orange label tag
      Positioned(
        top: -8,
        left: 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFF1F1431).withOpacity(0) : AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: readOnly ? Colors.black : AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Open Sans',
                fontSize:   10,
                color:      Colors.white,
                height:     1.4,
              ),
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
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.31,
            color: Color(0xFF191C24),
          )),
        const SizedBox(height: 24),

        // Email notifications toggle
        _PrefToggleRow(
          icon:    Icons.mail_outline_rounded,
          label:   'Notifications par email',
          desc:    'Recevoir des notifications sur les nouvelles demandes',
          value:   emailNotif,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 26),

        // SMS notifications toggle
        _PrefToggleRow(
          icon:    Icons.phone_outlined,
          label:   'Notifications par SMS',
          desc:    'Recevoir des SMS pour les mises à jour importantes',
          value:   smsNotif,
          onChanged: onSmsChanged,
        ),
        const SizedBox(height: 26),

        // Language dropdown
        const Text('Langue',
          style: TextStyle(
            fontFamily: 'Public Sans',
            fontSize: 14,
            color: Color(0xFF62748E),
          )),
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
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Colors.black,
              ),
              items: const [
                DropdownMenuItem(value: 'Français',  child: Text('Français')),
                DropdownMenuItem(value: 'English',   child: Text('English')),
                DropdownMenuItem(value: 'العربية',   child: Text('العربية')),
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
  final IconData           icon;
  final String             label;
  final String             desc;
  final bool               value;
  final void Function(bool) onChanged;

  const _PrefToggleRow({
    required this.icon,  required this.label, required this.desc,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Input row with toggle as trailing
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: value
              ? AppColors.primary.withOpacity(0.1)
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
                style: const TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Colors.black,
                )),
            ),
            // Tick / check mark indicator
            Container(
              width: 20,
              height: 20,
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
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF62748E),
            letterSpacing: -0.15,
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
            fontFamily: 'Public Sans',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.31,
            color: Color(0xFF191C24),
          )),
        const SizedBox(height: 24),

        // Change password
        _SecRow(
          icon:  Icons.lock_outline_rounded,
          label: 'Modifier le mot de passe',
          desc:  'Changez votre mot de passe régulièrement',
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24.5),
            ),
            child: const Text('Modifier',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Colors.white,
              )),
          ),
        ),
        const SizedBox(height: 26),

        // 2FA toggle
        _SecRow(
          icon:  Icons.security_outlined,
          label: 'Authentification à deux facteurs',
          desc:  'Sécurisez votre compte avec la 2FA',
          action: Switch(
            value:          twoFa,
            onChanged:      onTwoFaChanged,
            activeColor:    AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DC),
          ),
        ),
        const SizedBox(height: 26),

        // Payment methods
        _SecRow(
          icon:  Icons.credit_card_outlined,
          label: 'Moyens de paiement',
          desc:  'Gérez vos cartes bancaires',
          action: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24.5),
            ),
            child: const Text('Gérer',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Colors.white,
              )),
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
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFFDC2626),
                      )),
                    SizedBox(height: 2),
                    Text('Cette action est irréversible',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                      )),
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
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white,
                    )),
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
    required this.icon,  required this.label,
    required this.desc,  required this.action,
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
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Colors.black,
                  letterSpacing: -0.36,
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
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF62748E),
            letterSpacing: -0.15,
          )),
      ),
    ],
  );
}
