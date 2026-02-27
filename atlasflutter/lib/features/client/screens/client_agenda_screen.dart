import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/repositories/agenda_repository.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class ClientAgendaScreen extends StatefulWidget {
  const ClientAgendaScreen({super.key});

  @override
  State<ClientAgendaScreen> createState() => _ClientAgendaScreenState();
}

class _ClientAgendaScreenState extends State<ClientAgendaScreen> {
  final _repo       = AgendaRepository();
  final DateTime _today = DateTime.now();

  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  bool                _loading = true;
  String?             _error;
  List<Appointment>   _appointments = [];

  @override
  void initState() {
    super.initState();
    _selectedDay   = _today;
    _focusedMonth  = DateTime(_today.year, _today.month);
    _load();
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  List<Appointment> get _selectedAppts => _appointments
      .where((a) => _dayKey(a.scheduledAt) == _dayKey(_selectedDay))
      .toList();

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final appts = await _repo.getAppointments();
      if (mounted) {
        setState(() {
          _appointments = appts;
          _loading      = false;
          // If today has no appointment but some exist, jump to first one
          if (appts.isNotEmpty &&
              !appts.any((a) => _dayKey(a.scheduledAt) == _dayKey(_today))) {
            _selectedDay  = appts.first.scheduledAt;
            _focusedMonth = DateTime(
                appts.first.scheduledAt.year, appts.first.scheduledAt.month);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = AgendaRepository.errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
                  : _error != null
                      ? _buildError()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCalendar(),
                              const SizedBox(height: 24),
                              _buildAppointmentsSection(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ─────────────────────────────────────────────────────────────────

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14, color: Color(0xFF62748E)),
                SizedBox(width: 6),
                Text('Retour',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 15,
                        color: Color(0xFF62748E))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mon agenda',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 26,
                            color: Color(0xFF314158))),
                    SizedBox(height: 2),
                    Text('Gérez tous vos rendez-vous en un seul endroit',
                        style: TextStyle(
                            fontFamily: 'Inter', fontSize: 12,
                            color: Color(0xFF62748E))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showCreateSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  shadowColor: Colors.black26,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: const Text('Nouveau\nrendez-vous',
                    style: TextStyle(
                        fontFamily: 'Inter', fontSize: 11,
                        color: Colors.white, height: 1.3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Error state ──────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14,
                    color: Color(0xFF62748E))),
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
    );
  }

  // ── Calendar ─────────────────────────────────────────────────────────────────

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x2E000000), blurRadius: 8.2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Column(
              children: [
                _buildWeekdayRow(),
                const SizedBox(height: 4),
                _buildDayGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    const monthNames = [
      '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFC5A15), Color(0xFFFF7A47)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBtn(
                icon: Icons.chevron_left_rounded,
                onTap: () => setState(() => _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
              ),
              Text(
                '${monthNames[_focusedMonth.month]} ${_focusedMonth.year}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 20,
                    color: Colors.white),
              ),
              _NavBtn(
                icon: Icons.chevron_right_rounded,
                onTap: () => setState(() => _focusedMonth =
                    DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() {
              _selectedDay  = _today;
              _focusedMonth = DateTime(_today.year, _today.month);
            }),
            child: Container(
              width: double.infinity, height: 38,
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: const Text("Aujourd'hui",
                style: TextStyle(fontFamily: 'Inter', fontSize: 15,
                    color: AppColors.primary)),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Center(
                  child: Text(d,
                      style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 12,
                          color: Color(0xFF62748E))),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDayGrid() {
    final firstDay    = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday % 7; // Sun=0
    final rows        = ((startOffset + daysInMonth) / 7).ceil();

    // Build colour map from real appointments
    final apptColorMap = <String, Color>{};
    for (final appt in _appointments) {
      final key = _dayKey(appt.scheduledAt);
      apptColorMap[key] ??=
          appt.isCompleted ? const Color(0xFF02BB05) : AppColors.primary;
    }

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final idx    = row * 7 + col;
            final dayNum = idx - startOffset + 1;

            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 80));
            }

            final date       = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
            final key        = _dayKey(date);
            final isSelected = _dayKey(_selectedDay) == key;
            final isToday    = _dayKey(_today)        == key;
            final apptColor  = apptColorMap[key];
            final hasAppt    = apptColor != null;

            Color borderColor = Colors.transparent;
            Color numColor    = const Color(0xFF314158);
            Color bgColor     = const Color(0xFFF9FAFB);

            if (isSelected && hasAppt) {
              borderColor = apptColor;
              numColor    = apptColor;
              bgColor     = apptColor == const Color(0xFF02BB05)
                  ? const Color(0xFFF0FFF4)
                  : const Color(0xFFFFF7ED);
            } else if (isToday) {
              borderColor = AppColors.primary;
              numColor    = AppColors.primary;
              bgColor     = const Color(0xFFFFF7ED);
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: 80,
                  decoration: BoxDecoration(
                    color:  bgColor,
                    border: Border.all(
                      color: borderColor,
                      width: borderColor == Colors.transparent ? 0 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                        child: Text('$dayNum',
                            style: TextStyle(
                                fontFamily: 'Inter', fontSize: 12,
                                color: numColor)),
                      ),
                      const Spacer(),
                      if (hasAppt)
                        Container(
                          height: 4,
                          margin: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                          decoration: BoxDecoration(
                            color: apptColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        )
                      else
                        const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  // ── Appointments section ───────────────────────────────────────────────────

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Détails des rendez-vous',
            style: TextStyle(fontFamily: 'Inter', fontSize: 20,
                color: Color(0xFF314158))),
        const SizedBox(height: 16),
        if (_selectedAppts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Aucun rendez-vous ce jour',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14,
                      color: AppColors.grey)),
            ),
          )
        else
          ..._selectedAppts.map((appt) => _AppointmentCard(appt: appt)),
      ],
    );
  }

  // ── Create appointment bottom sheet ────────────────────────────────────────

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CreateAppointmentSheet(
        onCreated: (appt) {
          setState(() {
            _appointments.add(appt);
            _selectedDay  = appt.scheduledAt;
            _focusedMonth = DateTime(
                appt.scheduledAt.year, appt.scheduledAt.month);
          });
        },
      ),
    );
  }
}

// ── Calendar navigation button ────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}

// ── Appointment card ───────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Appointment appt;
  const _AppointmentCard({required this.appt});

  @override
  Widget build(BuildContext context) {
    final accentColor = appt.isCompleted
        ? const Color(0xFF00A63E)
        : AppColors.primary;

    const monthNames = [
      '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];

    final timeStr = '${appt.scheduledAt.hour.toString().padLeft(2, '0')}:'
        '${appt.scheduledAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFC),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Color(0x29000000), blurRadius: 5.8, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date + time row
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  '${appt.scheduledAt.day} ${monthNames[appt.scheduledAt.month]}',
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                      color: Color(0xFF62748E))),
                const SizedBox(width: 14),
                Icon(Icons.access_time_rounded, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(timeStr,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14,
                      color: Color(0xFF62748E))),
                if (appt.durationLabel.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text('(${appt.durationLabel})',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12,
                        color: accentColor)),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Title
            Text(appt.title,
              style: TextStyle(fontFamily: 'Inter', fontSize: 15, color: accentColor)),
            const SizedBox(height: 10),

            // Contact details
            if (appt.contactName?.isNotEmpty == true)
              _InfoRow(icon: Icons.person_outline_rounded, text: appt.contactName!),
            if (appt.contactPhone?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.phone_outlined, text: appt.contactPhone!),
            ],
            if (appt.city?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.location_on_outlined, text: appt.city!),
            ],
            const SizedBox(height: 14),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.04),
                border: Border.all(color: accentColor, width: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                appt.isCompleted ? 'Terminée' : 'En attente',
                style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String   text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 13, color: const Color(0xFF62748E)),
      const SizedBox(width: 8),
      Text(text,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 13,
              color: Color(0xFF62748E))),
    ],
  );
}

// ── Create appointment bottom sheet ───────────────────────────────────────────

class _CreateAppointmentSheet extends StatefulWidget {
  final void Function(Appointment) onCreated;
  const _CreateAppointmentSheet({required this.onCreated});

  @override
  State<_CreateAppointmentSheet> createState() => _CreateAppointmentSheetState();
}

class _CreateAppointmentSheetState extends State<_CreateAppointmentSheet> {
  final _repo        = AgendaRepository();
  final _titleCtrl   = TextEditingController();
  final _clientCtrl  = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _notesCtrl   = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;
  String    _duration = '1h';
  bool      _saving   = false;
  String?   _error;

  static const _durations = ['30min', '1h', '2h', '3h'];

  @override
  void dispose() {
    _titleCtrl.dispose(); _clientCtrl.dispose(); _phoneCtrl.dispose();
    _cityCtrl.dispose();  _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _date == null || _time == null) {
      setState(() => _error = 'Titre, date et heure sont obligatoires.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final dateStr = '${_date!.year}-'
          '${_date!.month.toString().padLeft(2, '0')}-'
          '${_date!.day.toString().padLeft(2, '0')}';
      final timeStr = '${_time!.hour.toString().padLeft(2, '0')}:'
          '${_time!.minute.toString().padLeft(2, '0')}';

      final appt = await _repo.createAppointment(
        title:       _titleCtrl.text.trim(),
        date:        dateStr,
        time:        timeStr,
        clientName:  _clientCtrl.text.trim().isEmpty ? null : _clientCtrl.text.trim(),
        clientPhone: _phoneCtrl.text.trim().isEmpty  ? null : _phoneCtrl.text.trim(),
        duration:    _duration,
        city:        _cityCtrl.text.trim().isEmpty   ? null : _cityCtrl.text.trim(),
        notes:       _notesCtrl.text.trim().isEmpty  ? null : _notesCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated(appt);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error  = AgendaRepository.errorMessage(e);
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DC),
                  borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Nouveau rendez-vous',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700,
                  fontSize: 18, color: Color(0xFF314158))),
            const SizedBox(height: 20),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5))),
                child: Text(_error!,
                  style: const TextStyle(fontFamily: 'Public Sans', fontSize: 13,
                      color: Color(0xFFDC2626))),
              ),
              const SizedBox(height: 12),
            ],

            // Title (required)
            _SheetField(
              ctrl:  _titleCtrl,
              label: 'Titre du rendez-vous *',
              icon:  Icons.title_rounded,
            ),
            const SizedBox(height: 14),

            // Date + Time row
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: _SheetDisplay(
                      label: _date == null
                          ? 'Date *'
                          : '${_date!.day.toString().padLeft(2, '0')}/'
                            '${_date!.month.toString().padLeft(2, '0')}/'
                            '${_date!.year}',
                      icon:      Icons.calendar_today_outlined,
                      highlight: _date != null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: _SheetDisplay(
                      label: _time == null
                          ? 'Heure *'
                          : '${_time!.hour.toString().padLeft(2, '0')}:'
                            '${_time!.minute.toString().padLeft(2, '0')}',
                      icon:      Icons.access_time_rounded,
                      highlight: _time != null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Duration
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _duration,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary),
                  style: const TextStyle(
                      fontFamily: 'Public Sans', fontSize: 14, color: Colors.black),
                  items: _durations
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setState(() => _duration = v!),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Client + phone
            _SheetField(ctrl: _clientCtrl, label: 'Nom du client',   icon: Icons.person_outline_rounded),
            const SizedBox(height: 14),
            _SheetField(ctrl: _phoneCtrl, label: 'Téléphone',        icon: Icons.phone_outlined,       keyboard: TextInputType.phone),
            const SizedBox(height: 14),
            _SheetField(ctrl: _cityCtrl,  label: 'Ville',            icon: Icons.location_on_outlined),
            const SizedBox(height: 14),
            _SheetField(ctrl: _notesCtrl, label: 'Notes',            icon: Icons.notes_rounded,        maxLines: 3),
            const SizedBox(height: 20),

            // Submit
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: const Color(0xFFD1D5DC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Créer le rendez-vous',
                        style: TextStyle(fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600, fontSize: 15,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sheet helpers ─────────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String                label;
  final IconData              icon;
  final TextInputType         keyboard;
  final int                   maxLines;

  const _SheetField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller:   ctrl,
    keyboardType: keyboard,
    maxLines:     maxLines,
    style: const TextStyle(fontFamily: 'Public Sans', fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      labelStyle: const TextStyle(
          fontFamily: 'Public Sans', fontSize: 13, color: Color(0xFF62748E)),
      filled:       true,
      fillColor:    const Color(0xFFF9FAFB),
      border:       OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: maxLines > 1
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : null,
    ),
  );
}

class _SheetDisplay extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool   highlight;
  const _SheetDisplay({
    required this.label, required this.icon, this.highlight = false});

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: highlight
          ? AppColors.primary.withValues(alpha: 0.06)
          : const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: highlight ? AppColors.primary : const Color(0xFFE5E7EB),
        width: highlight ? 1.5 : 1,
      ),
    ),
    child: Row(
      children: [
        Icon(icon,
          color: highlight ? AppColors.primary : const Color(0xFF9CA3AF),
          size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
            style: TextStyle(
              fontFamily: 'Public Sans', fontSize: 13,
              color: highlight ? AppColors.primary : const Color(0xFF9CA3AF),
            )),
        ),
      ],
    ),
  );
}
