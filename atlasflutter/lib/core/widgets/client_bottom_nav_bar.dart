import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class ClientBottomNavBar extends StatelessWidget {
  final int activeIndex;
  const ClientBottomNavBar({super.key, required this.activeIndex});

  static const _imageAssets = [
    'assets/images/HomeIcone.png',
    'assets/images/ReservationIcone.png',
    null, // add button — uses Icon widget
    'assets/images/ChatIcone.png',
    'assets/images/profileicone.png',
  ];

  void _onTap(BuildContext context, int index) {
    if (index == activeIndex) return;
    switch (index) {
      case 0: context.go('/client/dashboard');            break;
      case 1: context.go('/client/mes-demandes');         break;
      case 2: context.push('/client/service-categories'); break;
      case 3: context.go('/client/messages');             break;
      case 4: context.go('/client/profile');              break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 342, height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(5, (i) {
          final active = i == activeIndex;

          if (i == 2) {
            return GestureDetector(
              onTap: () => _onTap(context, i),
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: active ? null : Border.all(color: Colors.white, width: 1),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            );
          }

          return GestureDetector(
            onTap: () => _onTap(context, i),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    active ? AppColors.primary : Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(_imageAssets[i]!, width: 22, height: 22),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
