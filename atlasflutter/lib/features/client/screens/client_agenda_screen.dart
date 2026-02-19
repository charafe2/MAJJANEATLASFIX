import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

enum _Status { terminee, enAttente }

class _Rdv {
  final DateTime date;
  final String time;
  final String duration;
  final String title;
  final String client;
  final String phone;
  final String city;
  final _Status status;
  const _Rdv({
    required this.date,
    required this.time,
    required this.duration,
    required this.title,
    required this.client,
    required this.phone,
    required this.city,
    required this.status,
  });
}

final _kRdvs = [
  _Rdv(
    date: DateTime(2025, 12, 23),
    time: '17:00',
    duration: '1h',
    title: 'Réparation Fuite',
    client: 'Mohammad Alami',
    phone: '+212 07 00 00 00 00',
    city: 'Rabat',
    status: _Status.terminee,
  ),
  _Rdv(
    date: DateTime(2025, 12, 23),
    time: '17:00',
    duration: '1h',
    title: 'Réparation Fuite',
    client: 'Mohammad Alami',
    phone: '+212 07 00 00 00 00',
    city: 'Rabat',
    status: _Status.enAttente,
  ),
];

// ── Screen ───────────────────────────────────────────────────────────────────

class ClientAgendaScreen extends StatefulWidget {
  const ClientAgendaScreen({super.key});

  @override
  State<ClientAgendaScreen> createState() => _ClientAgendaScreenState();
}

class _ClientAgendaScreenState extends State<ClientAgendaScreen> {
  final DateTime _today = DateTime.now();
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final todayKey = _dayKey(_today);
    final apptDays = _kRdvs.map((r) => _dayKey(r.date)).toSet();
    if (apptDays.contains(todayKey)) {
      _selectedDay = _today;
      _focusedMonth = DateTime(_today.year, _today.month);
    } else if (_kRdvs.isNotEmpty) {
      _selectedDay = _kRdvs.first.date;
      _focusedMonth = DateTime(_selectedDay.year, _selectedDay.month);
    } else {
      _selectedDay = _today;
      _focusedMonth = DateTime(_today.year, _today.month);
    }
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  List<_Rdv> get _selectedRdvs =>
      _kRdvs.where((r) => _dayKey(r.date) == _dayKey(_selectedDay)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  // ── Top bar ────────────────────────────────────────────────────────────────

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
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Color(0xFF62748E),
                    )),
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
                          fontFamily: 'Inter',
                          fontSize: 26,
                          color: Color(0xFF314158),
                        )),
                    SizedBox(height: 2),
                    Text('Gérez tous vos rendez-vous en un seul endroit',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFF62748E),
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  shadowColor: Colors.black26,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add, color: Colors.white, size: 16),
                label: const Text('Nouveau\nrendez-vous',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white,
                      height: 1.3,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Calendar ───────────────────────────────────────────────────────────────

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: Color(0x2E000000), blurRadius: 8.2, offset: Offset(0, 1)),
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
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
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
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  color: Colors.white,
                ),
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
              _selectedDay = _today;
              _focusedMonth = DateTime(_today.year, _today.month);
            }),
            child: Container(
              width: double.infinity,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Aujourd'hui",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
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
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF62748E),
                      )),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDayGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    // weekday: 1=Mon…7=Sun → convert to Sun=0 offset
    final startOffset = firstDay.weekday % 7;
    final rows = ((startOffset + daysInMonth) / 7).ceil();

    // Build sets for days with appointments and their accent colour
    final apptColorMap = <String, Color>{};
    for (final rdv in _kRdvs) {
      final key = _dayKey(rdv.date);
      // Prefer green (Terminée) colour; otherwise primary
      apptColorMap[key] ??=
          rdv.status == _Status.terminee ? const Color(0xFF02BB05) : AppColors.primary;
    }

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final idx = row * 7 + col;
            final dayNum = idx - startOffset + 1;

            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 80));
            }

            final date =
                DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
            final key = _dayKey(date);
            final isSelected = _dayKey(_selectedDay) == key;
            final isToday = _dayKey(_today) == key;
            final apptColor = apptColorMap[key];
            final hasAppt = apptColor != null;

            Color borderColor = Colors.transparent;
            Color numColor = const Color(0xFF314158);
            Color bgColor = const Color(0xFFF9FAFB);

            if (isSelected && hasAppt) {
              borderColor = apptColor;
              numColor = apptColor;
              bgColor = apptColor == const Color(0xFF02BB05)
                  ? const Color(0xFFF0FFF4)
                  : const Color(0xFFFFF7ED);
            } else if (isToday) {
              borderColor = AppColors.primary;
              numColor = AppColors.primary;
              bgColor = const Color(0xFFFFF7ED);
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = date),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: 80,
                  decoration: BoxDecoration(
                    color: bgColor,
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
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: numColor,
                            )),
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
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              color: Color(0xFF314158),
            )),
        const SizedBox(height: 16),
        if (_selectedRdvs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text('Aucun rendez-vous ce jour',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.grey,
                  )),
            ),
          )
        else
          ..._selectedRdvs.map((rdv) => _AppointmentCard(rdv: rdv)),
      ],
    );
  }
}

// ── Calendar navigation button ────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      );
}

// ── Appointment card ──────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final _Rdv rdv;
  const _AppointmentCard({required this.rdv});

  @override
  Widget build(BuildContext context) {
    final isTerminee = rdv.status == _Status.terminee;
    final accentColor =
        isTerminee ? const Color(0xFF00A63E) : AppColors.primary;

    const monthNames = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFC),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Color(0x29000000), blurRadius: 5.8, offset: Offset(0, 1)),
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
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text('${rdv.date.day} ${monthNames[rdv.date.month]}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF62748E),
                    )),
                const SizedBox(width: 14),
                Icon(Icons.access_time_rounded, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(rdv.time,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Color(0xFF62748E),
                    )),
                const SizedBox(width: 6),
                Text('(${rdv.duration})',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: accentColor,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(rdv.title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  color: accentColor,
                )),
            const SizedBox(height: 10),
            // Client details
            _InfoRow(
                icon: Icons.person_outline_rounded, text: rdv.client),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.phone_outlined, text: rdv.phone),
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.location_on_outlined, text: rdv.city),
            const SizedBox(height: 14),
            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.04),
                border: Border.all(color: accentColor, width: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isTerminee ? 'Terminée' : 'En attente',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: accentColor,
                ),
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
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF62748E)),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF62748E),
              )),
        ],
      );
}
