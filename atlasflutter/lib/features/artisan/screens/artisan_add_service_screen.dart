import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/netwrok/api_client.dart';
import '../../../core/widgets/atlas_logo.dart';
import '../../../data/repositories/service_request_repository.dart';

class ArtisanAddServiceScreen extends StatefulWidget {
  const ArtisanAddServiceScreen({super.key});
  @override
  State<ArtisanAddServiceScreen> createState() => _ArtisanAddServiceScreenState();
}

class _ArtisanAddServiceScreenState extends State<ArtisanAddServiceScreen> {
  final _repo = ServiceRequestRepository();
  int _step = 0; // 0 = choose service, 1 = portfolio & description

  // Step 1 state
  List<ServiceCategory> _categories = [];
  List<ServiceType> _serviceTypes = [];
  bool _loadingCategories = true;
  ServiceCategory? _selectedCategory;
  ServiceType? _selectedType;
  final _cityController = TextEditingController();
  XFile? _diploma;

  // Step 2 state
  final _descController = TextEditingController();
  List<XFile> _photos = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repo.getCategories();
      if (mounted) setState(() { _categories = cats; _loadingCategories = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  Future<void> _loadServiceTypes(int categoryId) async {
    setState(() => _serviceTypes = []);
    try {
      final types = await _repo.getServiceTypes(categoryId);
      if (mounted) setState(() => _serviceTypes = types);
    } catch (_) {}
  }

  Future<void> _pickDiploma() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null && mounted) setState(() => _diploma = picked);
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(maxWidth: 1200, imageQuality: 85);
    if (picked.isNotEmpty && mounted) {
      setState(() {
        _photos.addAll(picked);
        if (_photos.length > 5) _photos = _photos.sublist(0, 5);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  bool get _canProceed {
    if (_step == 0) {
      return _selectedCategory != null && _selectedType != null;
    }
    return _descController.text.trim().isNotEmpty;
  }

  void _next() {
    if (_step == 0 && _canProceed) {
      setState(() => _step = 1);
    } else if (_step == 1 && _canProceed) {
      _submit();
    }
  }

  void _back() {
    if (_step == 1) {
      setState(() => _step = 0);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final formData = FormData.fromMap({
        'service_category': _selectedCategory!.name,
        'type_service': _selectedType!.name,
        'description': _descController.text.trim(),
      });

      if (_diploma != null) {
        final bytes = await _diploma!.readAsBytes();
        formData.files.add(MapEntry(
          'diplome',
          MultipartFile.fromBytes(bytes, filename: _diploma!.name),
        ));
      }

      for (var i = 0; i < _photos.length; i++) {
        final bytes = await _photos[i].readAsBytes();
        formData.files.add(MapEntry(
          'photos[]',
          MultipartFile.fromBytes(bytes, filename: 'photo_$i.jpg'),
        ));
      }

      await ApiClient.instance.post(
        '/artisan/service',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Service ajouté avec succès !'),
          backgroundColor: Color(0xFF16A34A),
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Une erreur est survenue.';
        if (e is DioException) {
          final b = e.response?.data;
          if (b is Map) {
            msg = b['message'] as String? ?? msg;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: const Color(0xFFEF4444),
        ));
      }
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
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: _step == 0 ? _buildStep1() : _buildStep2(),
                ),
              ),
            ],
          ),
          if (_submitting)
            const Positioned.fill(child: ColoredBox(
              color: Color(0x44000000),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )),
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
            children: [
              Row(children: [
                const AtlasLogo(),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/artisan/notifications'),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_none_rounded,
                        color: Color(0xFF393C40), size: 20),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 16),
                    Icon(Icons.search_rounded, color: Color(0xFF393C40), size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Quelle service recherchez-vous ?',
                      style: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                          color: Color(0xFF494949)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 1: Choose service ─────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choisissez un service',
          style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
              fontSize: 20, color: Color(0xFF191C24))),
        const SizedBox(height: 6),
        const Text(
          'Sélectionnez le type de service que voulez-vous ajouter',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
              color: Color(0xFF62748E), height: 1.4)),
        const SizedBox(height: 24),

        // Category dropdown
        _buildDropdown(
          icon: Icons.build_outlined,
          hint: 'Service principal',
          value: _selectedCategory?.name,
          onTap: _showCategoryPicker,
        ),
        const SizedBox(height: 14),

        // Service type dropdown with inline Ajouter button
        _buildDropdown(
          icon: Icons.miscellaneous_services_outlined,
          hint: 'Type de service',
          value: _selectedType?.name,
          onTap: _selectedCategory != null ? _showTypePicker : null,
          actionLabel: 'Ajouter',
          onAction: _selectedCategory != null ? _showTypePicker : null,
        ),

        // Selected type chips
        if (_selectedType != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _buildChip(_selectedType!.name),
            ],
          ),
        ],

        const SizedBox(height: 14),

        // City field
        _buildDropdown(
          icon: Icons.location_on_outlined,
          hint: 'Ville',
          value: _cityController.text.isNotEmpty ? _cityController.text : null,
          onTap: _showCityPicker,
        ),
        const SizedBox(height: 14),

        // Diploma scanner with inline Scanner button
        _buildDropdown(
          icon: Icons.school_outlined,
          hint: 'Scannez le diplôme',
          value: _diploma != null ? 'Diplôme sélectionné' : null,
          onTap: _pickDiploma,
          actionLabel: 'Scanner',
        ),

        const SizedBox(height: 32),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _back,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Précédent', style: TextStyle(
                    fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                    fontSize: 14, color: AppColors.primary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _canProceed ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFFFCAB0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Suivant', style: TextStyle(
                    fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                    fontSize: 14, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Portfolio & description ────────────────────────────────────────
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Portfolio et description',
          style: TextStyle(fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
              fontSize: 20, color: Color(0xFF191C24))),
        const SizedBox(height: 6),
        const Text(
          'Sélectionnez le type de service dont vous avez besoin',
          style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
              color: Color(0xFF62748E), height: 1.4)),
        const SizedBox(height: 24),

        // Description field
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _descController,
            maxLines: 5,
            maxLength: 2000,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                color: Color(0xFF314158)),
            decoration: const InputDecoration(
              hintText: 'Décrivez votre expérience...',
              hintStyle: TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                  color: Color(0xFF9CA3AF)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Photo upload area
        GestureDetector(
          onTap: _pickPhotos,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              border: Border.all(color: const Color(0xFFFFD4B8), width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cloud_upload_outlined,
                      color: AppColors.primary, size: 26),
                ),
                const SizedBox(height: 12),
                const Text('Cliquez pour télécharger ou glissez\nvos images',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                      color: Color(0xFF62748E), height: 1.4)),
              ],
            ),
          ),
        ),

        // Photo previews
        if (_photos.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<List<int>>(
                      future: _photos[i].readAsBytes(),
                      builder: (ctx, snap) {
                        if (!snap.hasData) {
                          return Container(width: 80, height: 80,
                            color: const Color(0xFFE5E7EB));
                        }
                        return Image.memory(snap.data! as dynamic,
                          width: 80, height: 80, fit: BoxFit.cover);
                      },
                    ),
                  ),
                  Positioned(
                    top: -6, right: -6,
                    child: GestureDetector(
                      onTap: () => _removePhoto(i),
                      child: Container(
                        width: 22, height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444), shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Terms checkbox placeholder
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                "J'accepte les conditions générales d'utilisation et la politique de confidentialité",
                style: TextStyle(fontFamily: 'Public Sans', fontSize: 11,
                    color: Color(0xFF62748E), height: 1.4)),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _submitting ? null : _back,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Précédent', style: TextStyle(
                    fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                    fontSize: 14, color: AppColors.primary)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _canProceed && !_submitting ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFFFCAB0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: _submitting
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirmer', style: TextStyle(
                        fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                        fontSize: 14, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────
  Widget _buildDropdown({
    required IconData icon,
    required String hint,
    String? value,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: EdgeInsets.fromLTRB(14, 0, actionLabel != null ? 5 : 14, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontFamily: 'Public Sans', fontSize: 14,
                  color: value != null ? const Color(0xFF314158) : const Color(0xFF9CA3AF),
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
            if (actionLabel != null)
              GestureDetector(
                onTap: onAction ?? onTap,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(actionLabel, style: const TextStyle(
                      fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                      fontSize: 13, color: Colors.white)),
                  ),
                ),
              )
            else
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF9CA3AF), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(
        fontFamily: 'Public Sans', fontSize: 12, color: AppColors.primary)),
    );
  }

  // ── Pickers ───────────────────────────────────────────────────────────────
  void _showCategoryPicker() {
    if (_loadingCategories) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'Choisissez votre service',
        items: _categories.map((c) => _PickerItem(c.id, c.name)).toList(),
        selectedId: _selectedCategory?.id,
        onSelect: (item) {
          final cat = _categories.firstWhere((c) => c.id == item.id);
          setState(() {
            _selectedCategory = cat;
            _selectedType = null;
            _serviceTypes = [];
          });
          _loadServiceTypes(cat.id);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTypePicker() {
    if (_serviceTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Chargement des types de service...'),
        duration: Duration(seconds: 1),
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'Choisissez votre Type de service',
        items: _serviceTypes.map((t) => _PickerItem(t.id, t.name)).toList(),
        selectedId: _selectedType?.id,
        onSelect: (item) {
          final type = _serviceTypes.firstWhere((t) => t.id == item.id);
          setState(() => _selectedType = type);
          Navigator.pop(context);
        },
      ),
    );
  }

  static const _cities = [
    'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger',
    'Agadir', 'Meknès', 'Oujda', 'Kenitra', 'Tétouan', 'Salé', 'Temara',
  ];

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: 'Choisissez votre ville',
        items: _cities.asMap().entries.map((e) => _PickerItem(e.key, e.value)).toList(),
        selectedId: _cities.indexOf(_cityController.text),
        onSelect: (item) {
          setState(() => _cityController.text = item.name);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Bottom sheet picker ──────────────────────────────────────────────────────

class _PickerItem {
  final int id;
  final String name;
  const _PickerItem(this.id, this.name);
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<_PickerItem> items;
  final int? selectedId;
  final ValueChanged<_PickerItem> onSelect;

  const _PickerSheet({
    required this.title,
    required this.items,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
              fontFamily: 'Public Sans', fontWeight: FontWeight.w700,
              fontSize: 18, color: Color(0xFF191C24))),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final item = items[i];
                  final selected = item.id == selectedId;
                  return GestureDetector(
                    onTap: () => onSelect(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFFFF3EE) : Colors.white,
                        border: Border.all(
                          color: selected ? AppColors.primary : const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(item.name, style: TextStyle(
                        fontFamily: 'Public Sans', fontSize: 14,
                        color: selected ? AppColors.primary : const Color(0xFF314158),
                      )),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('valider', style: TextStyle(
                  fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                  fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
