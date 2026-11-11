import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';

class PatientShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const PatientShellScreen({
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
      backgroundColor: AppColors.surface,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.94),
          border: const Border(
            top: BorderSide(
              color: AppColors.surfaceContainerHigh,
              width: 1,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F131B2E),
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
                _NavItem(
                  icon: Symbols.home,
                  label: 'Ana Sayfa',
                  isSelected: currentIndex == 0,
                  onTap: () => _onTap(0),
                ),
                _NavItem(
                  icon: Symbols.calendar_month,
                  label: 'Randevularım',
                  isSelected: currentIndex == 1,
                  onTap: () => _onTap(1),
                ),
                _NavItem(
                  icon: Symbols.lab_profile,
                  label: 'Sonuçlarım',
                  isSelected: currentIndex == 2,
                  onTap: () => _onTap(2),
                ),
                _NavItem(
                  icon: Symbols.monitoring,
                  label: 'Verilerim',
                  isSelected: currentIndex == 3,
                  onTap: () => _onTap(3),
                ),
                _NavItem(
                  icon: Symbols.chat_bubble,
                  label: 'Mesajlaşma',
                  isSelected: currentIndex == 4,
                  showDot: true,
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool showDot;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.showDot = false,
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
                        ? AppColors.secondaryContainer.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
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
                if (showDot && !isSelected)
                  Positioned(
                    top: 2,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 1.5,
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

