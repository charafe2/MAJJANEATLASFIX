import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../core/widgets/auth_widgets.dart';

/// ARTISAN STEP 5 – Portfolio & description (bio + photos + terms)
class ArtisanPortfolioScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ArtisanPortfolioScreen({super.key, required this.data});

  @override
  State<ArtisanPortfolioScreen> createState() => _ArtisanPortfolioScreenState();
}

class _ArtisanPortfolioScreenState extends State<ArtisanPortfolioScreen> {
  final _picker = ImagePicker();
  final _bio    = TextEditingController();
  final _photos = <File>[];
  bool  _terms  = false;
  final _errors = <String, String>{};

  @override
  void initState() {
    super.initState();
    _bio.text = widget.data['bio'] ?? '';
  }

  Future<void> _pickPhotos() async {
    final files = await _picker.pickMultiImage();
    setState(() => _photos.addAll(files.map((x) => File(x.path))));
  }

  bool _validate() {
    _errors.clear();
    if (_bio.text.trim().length < 20) _errors['bio']    = 'Min 20 caractères';
    if (_photos.length < 3)           _errors['photos'] = 'Min 3 photos requises';
    if (!_terms)                      _errors['terms']  = 'Acceptez les conditions';
    setState(() {});
    return _errors.isEmpty;
  }

  void _next() {
    if (!_validate()) return;
    // Carry photo paths as strings (File can't be serialised in the map directly)
    context.push('/register/password', extra: {
      ...widget.data,
      'bio':         _bio.text.trim(),
      'photo_paths': _photos.map((f) => f.path).toList(),
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
                subtitle: 'Portfolio et description',
              ),
              const SizedBox(height: 24),

              // ── Bio ───────────────────────────────────────────────
              PillInput(
                label:      'Décrivez votre expérience...',
                controller: _bio,
                maxLines:   5,
                error:      _errors['bio'],
                onChanged:  (_) => setState(() {}),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text('${_bio.text.length} caractères',
                    style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Photo upload zone ─────────────────────────────────
              GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  width:  double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color:        const Color(0xFFF5F8F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _errors['photos'] != null
                          ? AppColors.error : AppColors.lightGrey),
                  ),
                  child: _photos.isEmpty
                    ? const Column(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload_outlined,
                              size: 40, color: AppColors.grey),
                          SizedBox(height: 8),
                          Text('Cliquez pour télécharger vos images',
                            style: TextStyle(
                              fontFamily: 'Public Sans',
                              fontSize:   13,
                              color:      AppColors.grey,
                            )),
                        ])
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 6, mainAxisSpacing: 6),
                        itemCount: _photos.length,
                        itemBuilder: (_, i) => Stack(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_photos[i],
                              fit:    BoxFit.cover,
                              width:  double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(top: 2, right: 2,
                            child: GestureDetector(
                              onTap: () => setState(() => _photos.removeAt(i)),
                              child: const CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.black54,
                                child: Icon(Icons.close,
                                    color: Colors.white, size: 10)),
                            )),
                        ]),
                      ),
                ),
              ),
              if (_errors['photos'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(_errors['photos']!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 11)),
                ),
              const SizedBox(height: 14),

              // ── Terms checkbox ────────────────────────────────────
              Row(children: [
                Checkbox(
                  value:       _terms,
                  onChanged:   (v) => setState(() => _terms = v ?? false),
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _terms = !_terms),
                    child: const Text(
                      'J\'accepte les conditions générales d\'utilisation et la politique de confidentialité',
                      style: TextStyle(
                        fontFamily: 'Public Sans',
                        fontSize:   11,
                        color:      AppColors.grey,
                      )),
                  ),
                ),
              ]),
              if (_errors['terms'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 12),
                  child: Text(_errors['terms']!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 11)),
                ),

              const SizedBox(height: 28),
              NavRow(
                showPrev: true,
                onPrev:   () => context.pop(),
                onNext:   _next,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _bio.dispose(); super.dispose(); }
}