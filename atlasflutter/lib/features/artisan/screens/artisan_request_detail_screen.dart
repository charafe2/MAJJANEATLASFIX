import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/atlas_logo.dart';
import '../../../data/repositories/artisan_job_repository.dart';
import 'artisan_home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanRequestDetailScreen extends StatefulWidget {
  final int requestId;
  final AvailableRequest? initialData;

  const ArtisanRequestDetailScreen({
    super.key,
    required this.requestId,
    this.initialData,
  });

  @override
  State<ArtisanRequestDetailScreen> createState() =>
      _ArtisanRequestDetailScreenState();
}

class _ArtisanRequestDetailScreenState
    extends State<ArtisanRequestDetailScreen> {
  final _repo = ArtisanJobRepository();

  AvailableRequest? _request;
  bool    _loading = true;
  String? _error;
  bool    _submitted = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _request = widget.initialData;
      _loading = false;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _repo.getRequest(widget.requestId);
      if (mounted) setState(() { _request = data; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = ArtisanJobRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  void _openOfferSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProposeOfferSheet(
        requestId:  widget.requestId,
        clientName: _request?.clientName ?? 'le client',
        repo:       _repo,
        onSuccess: () => setState(() => _submitted = true),
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0,
          leading: BackButton(color: const Color(0xFF314158),
            onPressed: () => context.pop()),
        ),
        body: Center(
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              ),
            ]),
          ),
        ),
      );
    }

    final req = _request!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page title ──────────────────────────────────────
                      const Text('Détail de la demande',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Color(0xFF191C24),
                        )),
                      const SizedBox(height: 4),
                      Text(
                        req.serviceType.isNotEmpty
                            ? req.serviceType
                            : req.description,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Public Sans', fontSize: 13,
                          color: Color(0xFF62748E)),
                      ),
                      const SizedBox(height: 18),

                      // ── Client card ─────────────────────────────────────
                      _ClientCard(request: req),
                      const SizedBox(height: 18),

                      // ── Lieu d'intervention ──────────────────────────────
                      _LabeledField(
                        label: "Lieu d'intervention",
                        child: Row(children: [
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0E8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.home_outlined,
                              color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text('À domicile',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Color(0xFF191C24),
                              )),
                          ),
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 16),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 18),

                      // ── Map ─────────────────────────────────────────────
                      _CityMap(city: req.city),
                      const SizedBox(height: 18),

                      // ── Photos ───────────────────────────────────────────
                      if (req.photos.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(
                                  width: 30, height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE5D9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.photo_camera_outlined,
                                    color: AppColors.primary, size: 16),
                                ),
                                const SizedBox(width: 10),
                                const Text('Photos de fuite',
                                  style: TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF191C24),
                                  )),
                              ]),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  for (int i = 0; i < req.photos.take(2).length; i++) ...[
                                    if (i > 0) const SizedBox(width: 10),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          req.photos[i],
                                          height: 120, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 120,
                                            color: const Color(0xFFE5E7EB),
                                            child: const Icon(Icons.image_outlined,
                                              size: 32, color: Color(0xFFD1D5DC)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // ── Informations complémentaires ─────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 28, height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF0E8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.info_outline_rounded,
                                  color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 10),
                              const Text('Informations complémentaires',
                                style: TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF191C24),
                                )),
                            ]),
                            const SizedBox(height: 10),
                            Text(req.description,
                              style: const TextStyle(
                                fontFamily: 'Public Sans', fontSize: 13,
                                color: Color(0xFF62748E), height: 1.6,
                              )),
                          ],
                        ),
                      ),

                      if (_submitted) ...[
                        const SizedBox(height: 18),
                        _SubmittedBanner(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Bottom action buttons ────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x15000000),
                    blurRadius: 12, offset: Offset(0, -4)),
                ],
              ),
              child: Row(children: [
                // Retour
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Retour',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primary,
                      )),
                  ),
                ),
                const SizedBox(width: 12),
                // Proposer une offre
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _submitted ? null : _openOfferSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: const Color(0xFFD1D5DC),
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Proposer une offre',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.white,
                      )),
                  ),
                ),
              ]),
            ),
          ),

          // ── Bottom nav ───────────────────────────────────────────────────
          const Positioned(
            bottom: 28, left: 0, right: 0,
            child: Center(child: ArtisanBottomNavBar(activeIndex: 2)),
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
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
                const SizedBox(width: 15),
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
    );
  }
}

// ── Client info card ──────────────────────────────────────────────────────────
class _ClientCard extends StatelessWidget {
  final AvailableRequest request;
  const _ClientCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: const Color(0xFFFFE5D9),
                backgroundImage: (request.clientAvatar != null &&
                        request.clientAvatar!.isNotEmpty)
                    ? NetworkImage(request.clientAvatar!)
                    : null,
                child: (request.clientAvatar == null ||
                        request.clientAvatar!.isEmpty)
                    ? Text(
                        request.clientName?.isNotEmpty == true
                            ? request.clientName![0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.serviceType.isNotEmpty
                          ? request.serviceType
                          : request.category,
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF191C24),
                      )),
                    const SizedBox(height: 2),
                    Text(
                      request.clientName ?? 'Client',
                      style: const TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize: 13,
                        color: Color(0xFF62748E),
                      )),
                  ],
                ),
              ),
              // Date
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_outlined,
                    size: 13, color: Color(0xFF62748E)),
                  const SizedBox(width: 4),
                  Text(_formatDate(request.createdAt),
                    style: const TextStyle(
                      fontFamily: 'Public Sans', fontSize: 12,
                      color: Color(0xFF62748E),
                    )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(request.description,
            style: const TextStyle(
              fontFamily: 'Public Sans', fontSize: 13,
              color: Color(0xFF45556C), height: 1.6,
            )),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.location_on_outlined,
              size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(request.city,
              style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 13,
                color: Color(0xFF62748E),
              )),
          ]),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// ── Labeled bordered field ────────────────────────────────────────────────────
class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5EF),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
        Positioned(
          top: -10, left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.white,
              )),
          ),
        ),
      ],
    );
  }
}

// ── Dynamic city map (OpenStreetMap via flutter_map + Nominatim geocoding) ────
class _CityMap extends StatefulWidget {
  final String city;
  const _CityMap({required this.city});

  @override
  State<_CityMap> createState() => _CityMapState();
}

class _CityMapState extends State<_CityMap> {
  // Default: Casablanca, Morocco
  LatLng _center = const LatLng(33.5731, -7.5898);
  bool   _loading = true;

  @override
  void initState() {
    super.initState();
    _geocode(widget.city);
  }

  Future<void> _geocode(String city) async {
    try {
      final res = await dio.Dio().get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q':              '$city, Morocco',
          'format':         'json',
          'limit':          '1',
          'accept-language':'fr',
        },
        options: dio.Options(headers: {
          'User-Agent': 'AtlasFixApp/1.0',
        }),
      );
      final results = res.data ?? [];
      if (results.isNotEmpty) {
        final lat = double.tryParse(results[0]['lat'].toString());
        final lon = double.tryParse(results[0]['lon'].toString());
        if (lat != null && lon != null && mounted) {
          setState(() { _center = LatLng(lat, lon); });
        }
      }
    } catch (_) {
      // Keep default center on failure
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom:   13,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.atlasfix.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _center,
                      width: 44, height: 52,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 10, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: const Icon(Icons.location_on_rounded,
                              color: Colors.white, size: 22),
                          ),
                          Container(width: 3, height: 8, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // City label chip
            Positioned(
              bottom: 10, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x25000000),
                        blurRadius: 6, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined,
                        size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(widget.city,
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF191C24),
                        )),
                    ],
                  ),
                ),
              ),
            ),
            // Loading spinner while geocoding
            if (_loading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33FFFFFF),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Submitted banner ──────────────────────────────────────────────────────────
class _SubmittedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FDF4),
      border: Border.all(color: const Color(0xFF86EFAC)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(children: [
      Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
      SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Offre envoyée !',
            style: TextStyle(fontFamily: 'Public Sans',
              fontWeight: FontWeight.w700, fontSize: 14,
              color: Color(0xFF166534))),
          SizedBox(height: 2),
          Text('Le client examinera votre offre et vous contactera.',
            style: TextStyle(fontFamily: 'Public Sans',
              fontSize: 12, color: Color(0xFF166534), height: 1.4)),
        ],
      )),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet: "Proposer vos services"
// ─────────────────────────────────────────────────────────────────────────────
class _ProposeOfferSheet extends StatefulWidget {
  final int requestId;
  final String clientName;
  final ArtisanJobRepository repo;
  final VoidCallback onSuccess;

  const _ProposeOfferSheet({
    required this.requestId,
    required this.clientName,
    required this.repo,
    required this.onSuccess,
  });

  @override
  State<_ProposeOfferSheet> createState() => _ProposeOfferSheetState();
}

class _ProposeOfferSheetState extends State<_ProposeOfferSheet> {
  final _priceCtrl    = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _noteCtrl     = TextEditingController();
  bool  _submitting   = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final priceText = _priceCtrl.text.trim();
    if (priceText.isEmpty) {
      _showError('Veuillez saisir un prix.');
      return;
    }
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      _showError('Prix invalide.');
      return;
    }

    // Parse duration text → minutes
    int durationMins = 60;
    final durText = _durationCtrl.text.trim();
    if (durText.isNotEmpty) {
      final parsed = int.tryParse(durText.replaceAll(RegExp(r'[^0-9]'), ''));
      if (parsed != null && parsed > 0) durationMins = parsed;
    }

    setState(() => _submitting = true);
    try {
      await widget.repo.submitOffer(
        widget.requestId,
        price:             price,
        estimatedDuration: durationMins,
        note:              _noteCtrl.text.trim().isNotEmpty
                           ? _noteCtrl.text.trim() : null,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Offre envoyée avec succès !',
            style: TextStyle(fontFamily: 'Public Sans')),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showError(ArtisanJobRepository.errorMessage(e));
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Public Sans')),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text('Proposer vos services',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF191C24),
                  )),
              ),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Public Sans', fontSize: 14,
                color: Color(0xFF62748E)),
              children: [
                const TextSpan(text: 'Envoyez votre proposition à '),
                TextSpan(
                  text: widget.clientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191C24),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Prix ──────────────────────────────────────────────────────
          _OrangeInputField(
            label: 'Votre prix',
            controller: _priceCtrl,
            hint: 'Ex: 650',
            prefix: const Icon(Icons.attach_money_rounded,
              color: AppColors.primary, size: 20),
            suffix: const Text('DH',
              style: TextStyle(
                fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                fontSize: 14, color: Color(0xFF62748E))),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
          ),
          const SizedBox(height: 20),

          // ── Durée ─────────────────────────────────────────────────────
          _OrangeInputField(
            label: 'Durée estimée',
            controller: _durationCtrl,
            hint: 'Ex: 2-3 heures',
            prefix: const Icon(Icons.schedule_rounded,
              color: AppColors.primary, size: 20),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 20),

          // ── Message ───────────────────────────────────────────────────
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Public Sans', fontWeight: FontWeight.w600,
                fontSize: 14, color: AppColors.primary),
              children: [
                TextSpan(text: 'Message pour le client '),
                TextSpan(
                  text: '(optionnel)',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _noteCtrl,
              maxLines: 5,
              style: const TextStyle(fontFamily: 'Public Sans',
                fontSize: 13, color: Color(0xFF314158)),
              decoration: const InputDecoration(
                hintText: 'Lorem ipsum...',
                hintStyle: TextStyle(fontFamily: 'Public Sans',
                  fontSize: 13, color: Color(0xFFD1D5DC)),
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Buttons ───────────────────────────────────────────────────
          Row(children: [
            // Retour
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Retour',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primary,
                  )),
              ),
            ),
            const SizedBox(width: 12),
            // Envoyer
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFD1D5DC),
                  elevation: 0,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _submitting
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Text('Envoyer ma proposition',
                        style: TextStyle(
                          fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.white,
                        )),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Orange floating-label input field ─────────────────────────────────────────
class _OrangeInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _OrangeInputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.prefix,
    this.suffix,
    required this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (prefix != null) ...[
                const SizedBox(width: 14),
                prefix!,
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
                    fontFamily: 'Public Sans', fontSize: 14,
                    color: Color(0xFF191C24)),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 14, color: Color(0xFFBDBDBD)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (suffix != null) ...[
                suffix!,
                const SizedBox(width: 14),
              ],
            ],
          ),
        ),
        Positioned(
          top: -10, left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: Colors.white,
              )),
          ),
        ),
      ],
    );
  }
}
