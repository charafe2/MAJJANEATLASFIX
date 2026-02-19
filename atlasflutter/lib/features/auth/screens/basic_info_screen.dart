import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../core/widgets/auth_widgets.dart';
import '../../../core/phone_helper.dart';
/// STEP 1 – Basic personal information
/// Collects: full_name, birth_date, email, phone
/// Forwards everything in `data` map to next screen.
class BasicInfoScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const BasicInfoScreen({super.key, required this.data});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _fullName  = TextEditingController();
  final _birthDate = TextEditingController();
  final _email     = TextEditingController();
  final _phone     = TextEditingController();
  final _errors    = <String, String>{};

  @override
  void initState() {
    super.initState();
    // Pre-fill if navigating back
    _fullName.text  = widget.data['full_name']  ?? '';
    _birthDate.text = widget.data['birth_date'] ?? '';
    _email.text     = widget.data['email']      ?? '';
    _phone.text     = widget.data['phone']      ?? '';
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context:     context,
      initialDate: DateTime(2000),
      firstDate:   DateTime(1940),
      lastDate:    DateTime.now().subtract(const Duration(days: 365 * 18)),
      helpText:    'Date de naissance (18+ ans requis)',
    );
    if (d != null) {
      setState(() {
        _birthDate.text =
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      });
    }
  }

  bool _validate() {
    _errors.clear();
    if (_fullName.text.trim().isEmpty)  _errors['full_name']  = 'Requis';
    if (_birthDate.text.isEmpty)        _errors['birth_date'] = 'Requis';
    if (_email.text.trim().isEmpty)     _errors['email']      = 'Requis';
    else if (!_email.text.contains('@')) _errors['email']     = 'Email invalide';
    if (_phone.text.trim().isEmpty)     _errors['phone']      = 'Requis';
    setState(() {});
    return _errors.isEmpty;
  }

  void _next() {
    if (!_validate()) return;
    final next = {
      ...widget.data,
      'full_name':  _fullName.text.trim(),
      'birth_date': _birthDate.text,
      'email':      _email.text.trim(),
    'phone':      format212(_phone.text),
    };
    context.push('/register/choose-verif', extra: next);
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
              const AuthTitle(title: 'Créer votre compte'),
              const SizedBox(height: 28),

              PillInput(
                label:      'Nom complet',
                controller: _fullName,
                icon:       Icons.person_outline,
                error:      _errors['full_name'],
              ),
              const SizedBox(height: 14),

              PillInput(
                label:    'Date de naissance',
                controller: _birthDate,
                icon:     Icons.calendar_today_outlined,
                readOnly: true,
                onTap:    _pickDate,
                error:    _errors['birth_date'],
                trailing: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 14),

              PillInput(
                label:       'Adresse email',
                controller:  _email,
                icon:        Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                error:       _errors['email'],
              ),
              const SizedBox(height: 14),

              PillInput(
                label:       'Téléphone',
                controller:  _phone,
                icon:        Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                error:       _errors['phone'],
              ),
              const SizedBox(height: 32),

              OrangeBtn(label: 'Suivant', onPressed: _next),
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
  void dispose() {
    _fullName.dispose(); _birthDate.dispose();
    _email.dispose();    _phone.dispose();
    super.dispose();
  }
}