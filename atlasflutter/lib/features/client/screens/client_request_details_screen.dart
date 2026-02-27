import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
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
  final _repo       = ServiceRequestRepository();
  final _picker     = ImagePicker();
  final _descCtrl   = TextEditingController();
  final _villeCtrl  = TextEditingController();
  final _addrCtrl   = TextEditingController();
  final _infoCtrl   = TextEditingController();
  final List<XFile> _photos = [];
  bool              _submitting = false;

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
    final city = _villeCtrl.text.trim();
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
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service type chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                              color:
                                  AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.handyman_outlined,
                                color: AppColors.primary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              '${widget.categoryName}  ›  ${widget.serviceTypeName}',
                              style: const TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const _SectionLabel(label: 'Description du travail *'),
                      const SizedBox(height: 8),
                      _TextArea(
                        controller: _descCtrl,
                        hint: 'Décrivez le travail à réaliser en détail…',
                        minLines: 4,
                      ),
                      const SizedBox(height: 20),

                      // Ville
                      const _SectionLabel(label: 'Ville *'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _villeCtrl,
                        hint: 'Ex: Casablanca',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Adresse
                      const _SectionLabel(label: 'Adresse'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _addrCtrl,
                        hint: 'Ex: 12 Rue Mohammed V, Maarif',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Infos complémentaires
                      const _SectionLabel(
                          label: 'Informations complémentaires'),
                      const SizedBox(height: 8),
                      _TextArea(
                        controller: _infoCtrl,
                        hint: 'Précisions supplémentaires (optionnel)…',
                        minLines: 3,
                      ),
                      const SizedBox(height: 20),

                      // Photos
                      const _SectionLabel(label: 'Photos (optionnel)'),
                      const SizedBox(height: 8),
                      _PhotoPicker(
                        photos: _photos,
                        onAdd: _pickImage,
                        onRemove: (i) =>
                            setState(() => _photos.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new_rounded,
                        size: 14, color: Colors.white70),
                    SizedBox(width: 6),
                    Text('Retour',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Colors.white70,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Détails de votre demande',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.white,
                  )),
              const SizedBox(height: 4),
              const Text(
                  'Les artisans vous feront leurs meilleures offres',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    color: Colors.white70,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 12,
              offset: Offset(0, -4)),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: _submitting ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Précédent',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.primary,
                  )),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52,
            child: ValueListenableBuilder(
              valueListenable: _descCtrl,
              builder: (_, __, ___) => ValueListenableBuilder(
                valueListenable: _villeCtrl,
                builder: (_, __, ___) {
                  final canSubmit = _descCtrl.text.trim().isNotEmpty &&
                      _villeCtrl.text.trim().isNotEmpty &&
                      !_submitting;
                  return ElevatedButton(
                    onPressed: canSubmit ? _onPublish : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: const Color(0xFFD1D5DC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                        : const Text('Publier la demande',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            )),
                  );
                },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Color(0xFF314158),
      ));
}

class _TextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;
  const _TextArea(
      {required this.controller, required this.hint, this.minLines = 3});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        minLines: minLines,
        maxLines: null,
        style: const TextStyle(
            fontFamily: 'Public Sans', fontSize: 14, color: Color(0xFF314158)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: Color(0xFF9CA3AF)),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        style: const TextStyle(
            fontFamily: 'Public Sans', fontSize: 14, color: Color(0xFF314158)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
              fontFamily: 'Public Sans',
              fontSize: 14,
              color: Color(0xFF9CA3AF)),
          prefixIcon:
              Icon(prefixIcon, color: const Color(0xFF9CA3AF), size: 20),
          suffixIcon: suffixIcon != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child:
                      Icon(suffixIcon, color: AppColors.primary, size: 20))
              : null,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

class _PhotoPicker extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  const _PhotoPicker(
      {required this.photos, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ...List.generate(
              photos.length,
              (i) => _PhotoThumb(
                  path: photos[i].path, onRemove: () => onRemove(i))),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: AppColors.primary, size: 28),
                  SizedBox(height: 4),
                  Text('Ajouter',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 11,
                        color: AppColors.primary,
                      )),
                ],
              ),
            ),
          ),
        ],
      );
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
                child:
                    const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      );
}
