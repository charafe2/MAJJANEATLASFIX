import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/netwrok/api_client.dart';


class ArtisanServiceDetailScreen extends StatefulWidget {
  final int serviceCategoryId;
  final String serviceName;

  const ArtisanServiceDetailScreen({
    super.key,
    required this.serviceCategoryId,
    this.serviceName = 'Service',
  });

  @override
  State<ArtisanServiceDetailScreen> createState() =>
      _ArtisanServiceDetailScreenState();
}

class _ArtisanServiceDetailScreenState
    extends State<ArtisanServiceDetailScreen> {
  bool _loading = true;

  // Data
  String _bio = '';
  int _experienceYears = 0;
  String _serviceType = '';
  List<String> _serviceTypes = [];
  List<_CertItem> _certifications = [];
  List<_PhotoItem> _photos = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/me');
      final data = (res.data is Map<String, dynamic>)
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};

      _bio = data['bio'] as String? ?? '';
      _experienceYears = data['experience_years'] as int? ?? 0;

      // Find matching service for this category
      final services = data['services'] as List<dynamic>? ?? [];
      for (final s in services) {
        final m = s as Map<String, dynamic>;
        if (m['service_category_id'] == widget.serviceCategoryId) {
          _serviceType = m['type'] as String? ?? '';
          break;
        }
      }

      // Parse service types (comma-separated or single)
      if (_serviceType.isNotEmpty) {
        _serviceTypes = _serviceType
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }

      // Certifications
      final certs = data['certifications'] as List<dynamic>? ?? [];
      _certifications = certs.map((c) {
        final m = c as Map<String, dynamic>;
        return _CertItem(
          title: m['title'] as String? ?? '',
          year: m['created_at'] as String? ?? '',
        );
      }).toList();

      // Portfolio photos filtered by service_category_id
      final portfolio = data['portfolio'] as List<dynamic>? ?? [];
      _photos = portfolio
          .map((p) => p as Map<String, dynamic>)
          .where((p) =>
              p['service_category_id'] == widget.serviceCategoryId ||
              p['service_category_id'] == null)
          .map((p) {
        final rawUrl = p['url'] as String? ?? '';
        final url = rawUrl.startsWith('http')
            ? rawUrl
            : '${ApiConstants.storageBaseUrl}$rawUrl';
        return _PhotoItem(url: url, caption: p['caption'] as String? ?? '');
      }).toList();

      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    child: Column(
                      children: [
                        _buildAdvancedInfo(),
                        const SizedBox(height: 20),
                        _buildCertifications(),
                        const SizedBox(height: 20),
                        _buildPhotos(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
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
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const Spacer(),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.calendar_today_outlined,
                    color: Color(0xFF393C40), size: 18),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.notifications_none_rounded,
                    color: Color(0xFF393C40), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Informations avancées ───────────────────────────────────────────────────
  Widget _buildAdvancedInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(Icons.build_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Informations avancées',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF191C24),
                    )),
              ),
              _editButton(),
            ],
          ),
          const SizedBox(height: 20),

          // À propos
          const Text('À propos',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary,
              )),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              _bio.isNotEmpty
                  ? _bio
                  : 'Aucune description ajoutée.',
              style: const TextStyle(
                fontFamily: 'Public Sans',
                fontSize: 13,
                color: Color(0xFF45556C),
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Types de service
          const Text('Types de service',
              style: TextStyle(
                fontFamily: 'Public Sans',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primary,
              )),
          const SizedBox(height: 10),
          if (_serviceTypes.isEmpty)
            const Text('Aucun type de service défini.',
                style: TextStyle(
                  fontFamily: 'Public Sans',
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _serviceTypes
                  .map((t) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(t,
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            )),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 20),

          // Expérience + Tarif minimum
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.work_outline_rounded,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expérience',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              )),
                          Text(
                            '$_experienceYears ans',
                            style: const TextStyle(
                              fontFamily: 'Public Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF191C24),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_outlined,
                            color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tarif minimum',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontSize: 11,
                                color: Color(0xFF9CA3AF),
                              )),
                          Text('200 DH',
                              style: TextStyle(
                                fontFamily: 'Public Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF191C24),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Certifications ──────────────────────────────────────────────────────────
  Widget _buildCertifications() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Certifications',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF191C24),
                    )),
              ),
              _editButton(),
            ],
          ),
          const SizedBox(height: 16),
          if (_certifications.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Aucune certification ajoutée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  )),
            )
          else
            ...List.generate(_certifications.length, (i) {
              final cert = _certifications[i];
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < _certifications.length - 1 ? 10 : 0),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.workspace_premium_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cert.title,
                                style: const TextStyle(
                                  fontFamily: 'Public Sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Color(0xFF191C24),
                                )),
                            if (cert.year.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text('Delivrée en ${cert.year}',
                                  style: const TextStyle(
                                    fontFamily: 'Public Sans',
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  )),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Photos de mes travaux ───────────────────────────────────────────────────
  Widget _buildPhotos() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Photos de mes travaux',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF191C24),
                    )),
              ),
              _editButton(),
            ],
          ),
          const SizedBox(height: 16),
          if (_photos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Aucune photo ajoutée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  )),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: _photos.length,
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _photos[i].url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE5E7EB),
                    child: const Icon(Icons.image_outlined,
                        size: 32, color: Color(0xFFD1D5DC)),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Ajouter une image button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_outlined,
                  color: Colors.white, size: 20),
              label: const Text('Ajouter une image',
                  style: TextStyle(
                    fontFamily: 'Public Sans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editButton() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child:
          const Icon(Icons.edit_outlined, color: Colors.white, size: 16),
    );
  }
}

// ── Data models ───────────────────────────────────────────────────────────────
class _CertItem {
  final String title;
  final String year;
  const _CertItem({required this.title, required this.year});
}

class _PhotoItem {
  final String url;
  final String caption;
  const _PhotoItem({required this.url, required this.caption});
}
