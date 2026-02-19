import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../core/widgets/auth_widgets.dart';

class ArtisanProScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ArtisanProScreen({super.key, required this.data});

  @override
  State<ArtisanProScreen> createState() => _ArtisanProScreenState();
}

class _ArtisanProScreenState extends State<ArtisanProScreen> {
  final _picker      = ImagePicker();
  final _serviceType = TextEditingController();  // ← now a real editable field
  final _address     = TextEditingController();
  final _errors      = <String, String>{};

  String? _service;
  String? _city;
  File?   _diploma;

  final List<String> _services = [
    'Plomberie','Électricité','Menuiserie','Peinture',
    'Maçonnerie','Climatisation','Carrelage','Jardinage',
    'Serrurerie','Piscine','Toiture','Déménagement',
  ];
  final List<String> _cities = [
    'Casablanca','Rabat','Marrakech','Fès','Tanger',
    'Agadir','Meknès','Oujda','Kenitra','Tétouan','Salé','Temara',
  ];

  @override
  void initState() {
    super.initState();
    _service         = widget.data['service'] as String?;
    _serviceType.text = widget.data['service_type'] ?? '';
    _city            = widget.data['city'] as String?;
    _address.text    = widget.data['address'] ?? '';
  }

  Future<void> _pickDiploma() async {
    final f = await _picker.pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => _diploma = File(f.path));
  }

  bool _validate() {
    _errors.clear();
    if (_service == null)              _errors['service']      = 'Requis';
    if (_serviceType.text.trim().isEmpty) _errors['service_type'] = 'Requis';
    if (_city == null)                 _errors['city']         = 'Requis';
    if (_address.text.trim().isEmpty)  _errors['address']      = 'Requis';
    if (_diploma == null)              _errors['diploma']      = 'Requis';
    setState(() {});
    return _errors.isEmpty;
  }

  void _next() {
    if (!_validate()) return;
    context.push('/register/artisan-portfolio', extra: {
      ...widget.data,
      'account_type':  'artisan',
      'service':       _service,
      'service_type':  _serviceType.text.trim(),
      'city':          _city,
      'address':       _address.text.trim(),
      'diploma_path':  _diploma!.path,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthTitle(
                title:    'Créer votre compte',
                subtitle: 'Informations professionnelles',
              ),
              const SizedBox(height: 24),

              // ── Service principal dropdown ─────────────────────────
              PillDropdown(
                hint:      'Service principal',
                items:     _services,
                value:     _service,
                icon:      Icons.build_outlined,
                error:     _errors['service'],
                onChanged: (v) => setState(() => _service = v),
              ),
              const SizedBox(height: 14),

              // ── Type de service  (FIXED — real text input) ────────
              PillInput(
                label:      'Type de service',
                controller: _serviceType,
                icon:       Icons.design_services_outlined,
                error:      _errors['service_type'],
                onChanged:  (_) => setState(() {}),
              ),

              // Tags row (shows entered service type as a chip)
              if (_serviceType.text.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _Tag(_serviceType.text.trim()),
                  ]),
                ),
              ],
              const SizedBox(height: 14),

              // ── Ville ─────────────────────────────────────────────
              PillDropdown(
                hint:      'Ville',
                items:     _cities,
                value:     _city,
                icon:      Icons.location_city_outlined,
                error:     _errors['city'],
                onChanged: (v) => setState(() => _city = v),
              ),
              const SizedBox(height: 14),

              // ── Adresse with GPS pin button ───────────────────────
              PillInput(
                label:      'Adresse',
                controller: _address,
                icon:       Icons.home_outlined,
                error:      _errors['address'],
                trailing: GestureDetector(
                  onTap: () {/* geolocation — implement later */},
                  child: Container(
                    margin:  const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: Colors.white, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Diploma scanner ───────────────────────────────────
              ScanRow(
                hint:     'Scanner le diplôme',
                icon:     Icons.badge_outlined,
                fileName: _diploma?.path.split('/').last,
                error:    _errors['diploma'],
                btnLabel: 'Scanner',
                onTap:    _pickDiploma,
              ),

              if (_errors['general'] != null) ...[
                const SizedBox(height: 12),
                ErrBanner(_errors['general']!),
              ],
              const SizedBox(height: 28),

              NavRow(
                showPrev: true,
                onPrev:   () => context.pop(),
                onNext:   _next,
              ),
              const SizedBox(height: 20),

              FooterLink(
                prefix: 'J\'ai un compte ?  ',
                link:   'Connexion',
                onTap:  () => context.go('/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _serviceType.dispose(); _address.dispose(); super.dispose(); }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color:        AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border:       Border.all(color: AppColors.primary.withOpacity(0.4)),
    ),
    child: Text(label,
      style: const TextStyle(
        fontFamily: 'Public Sans', fontSize: 12, color: AppColors.primary)),
  );
}