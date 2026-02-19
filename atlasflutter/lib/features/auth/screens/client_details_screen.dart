import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/auth_widgets.dart';

/// CLIENT STEP 4 – Location details
/// Collects city + address then goes to PasswordScreen.
class ClientDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ClientDetailsScreen({super.key, required this.data});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final _city    = TextEditingController();
  final _address = TextEditingController();
  final _errors  = <String, String>{};

  @override
  void initState() {
    super.initState();
    _city.text    = widget.data['city']    ?? '';
    _address.text = widget.data['address'] ?? '';
  }

  bool _validate() {
    _errors.clear();
    if (_city.text.trim().isEmpty)    _errors['city']    = 'Requis';
    if (_address.text.trim().isEmpty) _errors['address'] = 'Requis';
    setState(() {});
    return _errors.isEmpty;
  }

  void _next() {
    if (!_validate()) return;
    context.push('/register/password', extra: {
      ...widget.data,
      'account_type': 'client',
      'city':    _city.text.trim(),
      'address': _address.text.trim(),
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
                subtitle: 'Informations de localisation',
              ),
              const SizedBox(height: 28),

              PillInput(
                label:      'Ville',
                controller: _city,
                icon:       Icons.location_city_outlined,
                error:      _errors['city'],
              ),
              const SizedBox(height: 14),

              PillInput(
                label:      'Adresse complète',
                controller: _address,
                icon:       Icons.home_outlined,
                error:      _errors['address'],
              ),
              const SizedBox(height: 32),

              NavRow(showPrev: true, onPrev: () => context.pop(), onNext: _next),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() { _city.dispose(); _address.dispose(); super.dispose(); }
}