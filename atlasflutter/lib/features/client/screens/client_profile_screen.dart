import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Warm gradient background ────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6238],
                  colors: [Color(0x4DFF8C5B), Colors.white],
                ),
              ),
            ),
          ),

          // ── Main column ─────────────────────────────────────────
          Column(
            children: [
              // Orange header banner
              _Header(),

              // Scrollable body (avatar overlap handled in Stack below)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 120),
                  child: Column(
                    children: [
                      // Space for avatar that hangs below header
                      const SizedBox(height: 76),

                      // Name
                      const Text(
                        'Marie Dupont',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 20.5,
                          letterSpacing: 0.06,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Stats row (12 Demandes / 8 Projets terminés)
                      _StatsRow(),
                      const SizedBox(height: 30),

                      // Menu: Mes Informations
                      _MenuBtn(
                        icon: Icons.person_outline_rounded,
                        label: 'Mes Informations',
                        onTap: () => context.push('/client/info'),
                      ),
                      const SizedBox(height: 18),

                      // Menu: Mes paiements
                      _MenuBtn(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Mes paiements',
                        onTap: () {},
                      ),
                      const SizedBox(height: 120),

                      // Logout button
                      _LogoutBtn(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Floating avatar (overlaps header / body boundary) ───
          const Positioned(
            top: 150,
            left: 0,
            right: 0,
            child: _Avatar(),
          ),

          // ── Bottom navigation bar ───────────────────────────────
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(child: _BottomNavBar(activeIndex: 4)),
          ),
        ],
      ),
    );
  }
}

// ── Orange header ──────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 215,
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // AtlasFix logo in white
              _WhiteLogo(),
              Row(
                children: [
                  _HeaderIconBtn(Icons.calendar_today_outlined),
                  const SizedBox(width: 15),
                  _HeaderIconBtn(Icons.notifications_none_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// White version of AtlasFix logo for the orange header
class _WhiteLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const Text('Atlas',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        )),
      const SizedBox(width: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: const Text('Fix',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          )),
      ),
    ],
  );
}

// White circle icon button for header
class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  const _HeaderIconBtn(this.icon);
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: const Color(0xFF393C40), size: 20),
  );
}

// ── Avatar with edit pencil ───────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar();
  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 128,
      height: 128,
      child: Stack(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 15,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Icon(Icons.person, size: 64, color: AppColors.primary),
            ),
          ),
          // Edit pencil
          Positioned(
            bottom: 0,
            right: 44,
            child: Container(
              width: 31,
              height: 31,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Stats row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 9,
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(child: _StatCard(icon: Icons.assignment_outlined, count: '12', label: 'Demandes')),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(icon: Icons.check_circle_outline_rounded, count: '8', label: 'Projets terminés')),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String   count;
  final String   label;
  const _StatCard({required this.icon, required this.count, required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(5.4),
          ),
          child: Icon(icon, color: Colors.white, size: 13),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$count $label',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black,
              letterSpacing: -0.12,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Dark pill menu button ─────────────────────────────────────────────────────
class _MenuBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final VoidCallback onTap;
  const _MenuBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 51,
      padding: const EdgeInsets.symmetric(horizontal: 12.5),
      decoration: BoxDecoration(
        color: const Color(0xFF393C40),
        borderRadius: BorderRadius.circular(125),
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.2,
                color: Colors.white,
                letterSpacing: -0.15,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
        ],
      ),
    ),
  );
}

// ── Logout button ─────────────────────────────────────────────────────────────
class _LogoutBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 270,
    height: 56,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(67.7),
      border: Border.all(color: const Color(0xFFFFC9C9), width: 0.9),
    ),
    child: ElevatedButton.icon(
      onPressed: () => context.go('/login'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE7000B),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27.1)),
      ),
      icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
      label: const Text(
        'Se déconnecter',
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    ),
  );
}

// ── Bottom navigation bar ─────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int activeIndex;
  const _BottomNavBar({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.home_outlined,
      Icons.list_alt_outlined,
      Icons.add,
      Icons.chat_bubble_outline_rounded,
      Icons.person_outline_rounded,
    ];

    return Container(
      width: 342,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final active = i == activeIndex;
          if (i == 2) {
            // Center "+" button
            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(Icons.add, color: Colors.white, size: 22),
            );
          }
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              items[i],
              color: active ? AppColors.primary : Colors.white,
              size: 22,
            ),
          );
        }),
      ),
    );
  }
}
