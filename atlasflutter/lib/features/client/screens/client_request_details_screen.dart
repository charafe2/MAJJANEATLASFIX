import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/atlas_logo.dart';
import '../../../../data/repositories/service_request_repository.dart';

class ClientRequestDetailsScreen extends StatefulWidget {
  final int    categoryId;
  final String categoryName;
  final int    serviceTypeId;
  final String serviceTypeName;

  const ClientRequestDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.serviceTypeId,
    required this.serviceTypeName,
  });

  @override
  State<ClientRequestDetailsScreen> createState() =>
      _ClientRequestDetailsScreenState();
}

class _ClientRequestDetailsScreenState
    extends State<ClientRequestDetailsScreen> {
  final _repo      = ServiceRequestRepository();
  final _picker    = ImagePicker();
  final _descCtrl  = TextEditingController();
  final _villeCtrl = TextEditingController();
  final _addrCtrl  = TextEditingController();
  final _infoCtrl  = TextEditingController();
  final List<XFile> _photos = [];
  bool _submitting = false;

  // Dropdown selections
  String? _selectedServiceMode; // e.g. 'À domicile', 'En atelier'
  String? _selectedVille;

  static const _serviceModes = ['À domicile', 'En atelier', 'Sur site'];
  static const _villes = [
    'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger',
    'Agadir', 'Meknès', 'Oujda', 'Kenitra', 'Tétouan',
  ];

  @override
  void initState() {
    super.initState();
    _descCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _villeCtrl.dispose();
    _addrCtrl.dispose();
    _infoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) setState(() => _photos.add(file));
  }

  Future<void> _onPublish() async {
    final desc = _descCtrl.text.trim();
    final city = _selectedVille ?? '';
    if (desc.isEmpty || city.isEmpty) return;
    if (_submitting) return;

    setState(() => _submitting = true);
    try {
      await _repo.createRequest(
        categoryId:     widget.categoryId,
        serviceTypeId:  widget.serviceTypeId,
        description:    desc,
        city:           city,
        address:        _addrCtrl.text.trim(),
        additionalInfo: _infoCtrl.text.trim().isEmpty ? null : _infoCtrl.text.trim(),
        photos:         _photos.isEmpty ? null : _photos,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Demande publiée avec succès !',
            style: TextStyle(fontFamily: 'Public Sans')),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
      context.go('/client/mes-demandes');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ServiceRequestRepository.errorMessage(e),
            style: const TextStyle(fontFamily: 'Public Sans')),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle orange-to-white gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.62],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              const _StepProgressBar(currentStep: 3, totalSteps: 3),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(29, 0, 29, 160),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 22),

                      // Title + subtitle
                      const Text(
                        'Détails de votre demande',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF191C24),
                          letterSpacing: -0.31,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Fournissez les informations nécessaires pour que les artisans puissent vous faire une offre précise',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF494949),
                          letterSpacing: -0.01,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── À domicile pill dropdown ──
                      _PillDropdown(
                        icon: Icons.home_outlined,
                        label: _selectedServiceMode ?? 'À domicile',
                        onTap: () async {
                          final picked = await _showPickerSheet(
                            context,
                            title: 'Mode d\'intervention',
                            options: _serviceModes,
                            selected: _selectedServiceMode,
                          );
                          if (picked != null) {
                            setState(() => _selectedServiceMode = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Description du travail ──
                      _FloatingLabelBox(
                        icon: Icons.description_outlined,
                        label: 'Description du travail',
                        child: TextField(
                          controller: _descCtrl,
                          minLines: 4,
                          maxLines: null,
                          maxLength: 250,
                          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            fontSize: 14,
                            color: Color(0xFF000000),
                            backgroundColor: Colors.transparent, // explicitly transparent

                          ),
                          decoration: InputDecoration(
                            hintText: 'Décrivez en détail le travail à réaliser...',
                            hintStyle: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                          ),
                        ),
                        trailing: Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 8),
                          child: Text(
                            '${_descCtrl.text.length}/250 caractères',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 11,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Ville pill dropdown ──
                      _PillDropdown(
                        icon: Icons.location_on_outlined,
                        label: _selectedVille ?? 'Ville',
                        onTap: () async {
                          final picked = await _showPickerSheet(
                            context,
                            title: 'Sélectionnez une ville',
                            options: _villes,
                            selected: _selectedVille,
                          );
                          if (picked != null) {
                            setState(() => _selectedVille = picked);
                          }
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Adresse pill with GPS button ──
                      _PillDropdownWithAction(
                        icon: Icons.home_outlined,
                        label: 'Adresse',
                        controller: _addrCtrl,
                      ),
                      const SizedBox(height: 28),

                      // ── Informations complémentaires ──
                      _FloatingLabelBox(
                        icon: Icons.info_outline,
                        label: 'Informations complémentaires',
                        child: TextField(
                          controller: _infoCtrl,
                          minLines: 3,
                          maxLines: null,
                          style: const TextStyle(
                            fontFamily: 'Public Sans',
                            backgroundColor: Colors.transparent, // explicitly transparent

                            fontSize: 14,
                            color: Color(0xFF000000),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Ajoutez des informations (accès, contraintes, horaires préférés...)',
                            hintStyle: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 14,
                              color: Colors.black.withValues(alpha: 0.6),
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.fromLTRB(16, 6, 16, 6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Photos (optionnel) ──
                      _FloatingLabelBox(
                        icon: Icons.camera_alt_outlined,
                        label: 'Photos (optionnel)',
                        minHeight: 174,
                        child: _photos.isEmpty
                            ? GestureDetector(
                                onTap: _pickImage,
                                child: SizedBox(
                                  height: 130,
                                  
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          
                                      children: [
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEDED0)
                                                .withValues(alpha: 0.6),
                                            shape: BoxShape.circle,
                                            
                                          ),
                                          child: const Icon(
                                            Icons.upload_outlined,
                                            color: AppColors.primary,
                                            // explicitly transparent
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Ajouter des photos',
                                          style: TextStyle(
                                            fontFamily: 'Public Sans',
                                            fontSize: 14,
                                            color: Colors.black
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 8, 16, 16),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    ...List.generate(
                                      _photos.length,
                                      (i) => _PhotoThumb(
                                        path: _photos[i].path,
                                        onRemove: () => setState(
                                            () => _photos.removeAt(i)),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          border: Border.all(
                                              color: const Color(0xFFE5E7EB)),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          color: AppColors.primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(context),
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
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Top row: logo + icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AtlasLogo(),
                  Row(children: [
                    _HeaderIconButton(
                        icon: Icons.calendar_today_outlined, onTap: () {}),
                    const SizedBox(width: 15),
                    _HeaderIconButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () => context.push('/client/notifications')),
                  ]),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.white],
        ),
      ),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(29, 16, 29, 36),
        child: Row(
          children: [
            // Précédent
            SizedBox(
              width: 127,
              height: 44,
              child: OutlinedButton(
                onPressed: _submitting ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Précédent',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Publier la demande
            SizedBox(
              width: 194,
              height: 44,
              child: ElevatedButton(
                onPressed: (_descCtrl.text.trim().isNotEmpty &&
                        (_selectedVille?.isNotEmpty ?? false) &&
                        !_submitting)
                    ? _onPublish
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFD1D5DC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding: EdgeInsets.zero,
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text(
                        'Publier la demande',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showPickerSheet(
    BuildContext context, {
    required String title,
    required List<String> options,
    String? selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF191C24),
                  )),
            ),
            const SizedBox(height: 8),
            ...options.map((o) => ListTile(
                  title: Text(o,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 15,
                        color: Color(0xFF314158),
                      )),
                  trailing: selected == o
                      ? const Icon(Icons.check_rounded,
                          color: Color(0xFFFC5A15))
                      : null,
                  onTap: () => Navigator.of(context).pop(o),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Orange rounded-pill "dropdown" row (À domicile / Ville)
class _PillDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _PillDropdown({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFC5A15)),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFC5A15), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.6),
                letterSpacing: -0.36,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFFC5A15), size: 20),
        ],
      ),
    ),
    );
  }
}

/// Adresse pill with a GPS orange action button on the right
class _PillDropdownWithAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  const _PillDropdownWithAction(
      {required this.icon, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFC5A15)),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.only(left: 16, right: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFC5A15), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 14,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          // GPS button
          Container(
            width: 78,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFC5A15),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(Icons.gps_fixed_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

/// Floating-label bordered box (Description / Infos / Photos)
class _FloatingLabelBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  final Widget? trailing;
  final double minHeight;

  const _FloatingLabelBox({
    required this.icon,
    required this.label,
    required this.child,
    this.trailing,
    this.minHeight = 107,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The bordered box
        Container(
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFFC5A15)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 14),
              child,
              if (trailing != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: trailing,
                ),
              if (trailing == null) const SizedBox(height: 8),
            ],
          ),
        ),

        // Floating label pinned to top-left border
        Positioned(
          top: -20,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: const Color(0xFFFC5A15), size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF393C40),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Header circular icon button
class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF393C40), size: 22),
      ),
    );
  }
}

class _StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  const _StepProgressBar({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final isActive = i < currentStep;
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _PhotoThumb({required this.path, required this.onRemove});

  @override
  Widget build(BuildContext context) => Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              path,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image_outlined,
                    color: AppColors.primary, size: 32),
              ),
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: Color(0xFFDC2626), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      );
}