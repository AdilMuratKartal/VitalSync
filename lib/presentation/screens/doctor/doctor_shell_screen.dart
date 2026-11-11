import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';

class DoctorShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DoctorShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: AppColors.doctorSurface,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.doctorSurface.withValues(alpha: 0.94),
          border: const Border(
            top: BorderSide(
              color: AppColors.doctorSurfaceContainerHigh,
              width: 1,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F0B1C30),
              blurRadius: 24,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _DoctorNavItem(
                  icon: Symbols.calendar_today,
                  label: 'Ajanda',
                  isSelected: currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _DoctorNavItem(
                  icon: Symbols.prescriptions,
                  label: 'Reçete Yaz',
                  isSelected: currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _DoctorNavItem(
                  icon: Symbols.folder_shared,
                  label: 'Geçmiş',
                  isSelected: currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
                _DoctorNavItem(
                  icon: Symbols.tune,
                  label: 'Program',
                  isSelected: currentIndex == 3,
                  onTap: () => _onTap(3),
                ),
                _DoctorNavItem(
                  icon: Symbols.chat_bubble,
                  label: 'Mesajlar',
                  isSelected: currentIndex == 4,
                  badgeCount: '2',
                  onTap: () => _onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badgeCount;
  final VoidCallback onTap;

  const _DoctorNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryFixedDoctor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    fill: isSelected ? 1 : 0,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                if (badgeCount != null)
                  Positioned(
                    top: -2,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.doctorSurface,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        badgeCount!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

