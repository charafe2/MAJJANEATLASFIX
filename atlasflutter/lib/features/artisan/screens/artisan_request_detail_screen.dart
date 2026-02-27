import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/artisan_job_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
class ArtisanRequestDetailScreen extends StatefulWidget {
  final int requestId;
  final AvailableRequest? initialData; // pre-loaded from list

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
  bool  _loading  = true;
  String? _error;

  // offer form
  final _priceCtrl    = TextEditingController();
  final _noteCtrl     = TextEditingController();
  int   _durationMins = 60;
  bool  _submitting   = false;
  bool  _submitted    = false;

  static const _durations = [30, 60, 90, 120, 180, 240, 300, 480];

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

  @override
  void dispose() {
    _priceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
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

  Future<void> _submitOffer() async {
    final priceText = _priceCtrl.text.trim();
    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez saisir un prix.',
          style: TextStyle(fontFamily: 'Public Sans')),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Prix invalide.',
          style: TextStyle(fontFamily: 'Public Sans')),
        backgroundColor: Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _submitting = true);
    try {
      await _repo.submitOffer(
        widget.requestId,
        price:             price,
        estimatedDuration: _durationMins,
        note:              _noteCtrl.text.trim().isNotEmpty
                           ? _noteCtrl.text.trim() : null,
      );
      if (mounted) {
        setState(() { _submitted = true; _submitting = false; });
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ArtisanJobRepository.errorMessage(e),
            style: const TextStyle(fontFamily: 'Public Sans')),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

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
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
          leading: BackButton(color: const Color(0xFF314158),
            onPressed: () => context.pop())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final req = _request!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──────────────────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            pinned: true,
            title: Text(
              req.serviceType.isNotEmpty ? req.serviceType : req.category,
              style: const TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
            ),
            centerTitle: true,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 16),
              ),
            ),
          ),

          // ── Request details ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + city
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(req.category,
                        style: const TextStyle(fontFamily: 'Public Sans',
                          fontWeight: FontWeight.w600, fontSize: 12,
                          color: AppColors.primary)),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_outlined,
                      size: 14, color: Color(0xFF62748E)),
                    const SizedBox(width: 3),
                    Text(req.city,
                      style: const TextStyle(fontFamily: 'Public Sans',
                        fontSize: 13, color: Color(0xFF62748E))),
                    const Spacer(),
                    Text(_timeAgo(req.createdAt),
                      style: const TextStyle(fontFamily: 'Public Sans',
                        fontSize: 11, color: Color(0xFF9CA3AF))),
                  ]),

                  const SizedBox(height: 16),

                  // Description
                  const Text('Description',
                    style: TextStyle(fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700, fontSize: 15,
                      color: Color(0xFF314158))),
                  const SizedBox(height: 8),
                  Text(req.description,
                    style: const TextStyle(fontFamily: 'Public Sans',
                      fontSize: 13.5, color: Color(0xFF45556C), height: 1.6)),

                  // Photos
                  if (req.photos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Photos',
                      style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700, fontSize: 15,
                        color: Color(0xFF314158))),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: req.photos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            req.photos[i],
                            width: 110, height: 110, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 110, height: 110,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.image_outlined,
                                size: 32, color: Color(0xFFD1D5DC)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Offers count
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      const Icon(Icons.groups_outlined,
                        size: 18, color: Color(0xFF62748E)),
                      const SizedBox(width: 8),
                      Text('${req.offersCount} offre(s) déjà soumise(s)',
                        style: const TextStyle(fontFamily: 'Public Sans',
                          fontSize: 13, color: Color(0xFF62748E))),
                    ]),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 20),

                  // ── Offer form ─────────────────────────────────────────
                  if (_submitted)
                    _buildSubmittedBanner()
                  else ...[
                    const Text('Soumettre une offre',
                      style: TextStyle(fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700, fontSize: 16,
                        color: Color(0xFF314158))),
                    const SizedBox(height: 16),

                    // Price
                    _buildLabel('Prix proposé (MAD)'),
                    const SizedBox(height: 8),
                    _PriceField(controller: _priceCtrl),
                    const SizedBox(height: 16),

                    // Duration
                    _buildLabel('Durée estimée'),
                    const SizedBox(height: 8),
                    _DurationPicker(
                      value: _durationMins,
                      options: _durations,
                      onChanged: (v) => setState(() => _durationMins = v),
                    ),
                    const SizedBox(height: 16),

                    // Note
                    _buildLabel('Note (optionnel)'),
                    const SizedBox(height: 8),
                    _NoteField(controller: _noteCtrl),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submitOffer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: const Color(0xFFD1D5DC),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _submitting
                            ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                            : const Text('Envoyer mon offre',
                                style: TextStyle(fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600, fontSize: 15,
                                  color: Colors.white)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
    style: const TextStyle(fontFamily: 'Public Sans',
      fontWeight: FontWeight.w600, fontSize: 13,
      color: Color(0xFF314158)));

  Widget _buildSubmittedBanner() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FDF4),
      border: Border.all(color: const Color(0xFF86EFAC)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Row(children: [
      Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offre envoyée !',
              style: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w700, fontSize: 14,
                color: Color(0xFF166534))),
            SizedBox(height: 2),
            Text('Le client examinera votre offre et vous contactera.',
              style: TextStyle(fontFamily: 'Public Sans',
                fontSize: 12, color: Color(0xFF166534), height: 1.4)),
          ],
        ),
      ),
    ]),
  );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60)  return 'il y a ${diff.inMinutes}min';
    if (diff.inHours   < 24)  return 'il y a ${diff.inHours}h';
    return 'il y a ${diff.inDays}j';
  }
}

// ── Price field ───────────────────────────────────────────────────────────────
class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  const _PriceField({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(children: [
      const SizedBox(width: 14),
      const Text('MAD',
        style: TextStyle(fontFamily: 'Public Sans',
          fontWeight: FontWeight.w600, fontSize: 14,
          color: Color(0xFF62748E))),
      const SizedBox(width: 8),
      Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
      Expanded(
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          style: const TextStyle(fontFamily: 'Public Sans',
            fontSize: 15, color: Color(0xFF314158)),
          decoration: const InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(color: Color(0xFFD1D5DC)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ),
    ]),
  );
}

// ── Duration picker ───────────────────────────────────────────────────────────
class _DurationPicker extends StatelessWidget {
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;
  const _DurationPicker({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  String _label(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}min';
    return m > 0 ? '${h}h${m.toString().padLeft(2, '0')}' : '${h}h';
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8, runSpacing: 8,
    children: options.map((mins) {
      final selected = mins == value;
      return GestureDetector(
        onTap: () => onChanged(mins),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : const Color(0xFFF9FAFB),
            border: Border.all(
              color: selected ? AppColors.primary : const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_label(mins),
            style: TextStyle(
              fontFamily: 'Public Sans',
              fontWeight: FontWeight.w600, fontSize: 13,
              color: selected ? Colors.white : const Color(0xFF314158),
            )),
        ),
      );
    }).toList(),
  );
}

// ── Note field ────────────────────────────────────────────────────────────────
class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      maxLines: 4,
      style: const TextStyle(fontFamily: 'Public Sans',
        fontSize: 13.5, color: Color(0xFF314158)),
      decoration: const InputDecoration(
        hintText: 'Ex : Je peux intervenir rapidement et proposer des pièces de qualité…',
        hintStyle: TextStyle(fontFamily: 'Public Sans',
          fontSize: 13, color: Color(0xFFD1D5DC)),
        contentPadding: EdgeInsets.all(14),
      ),
    ),
  );
}
