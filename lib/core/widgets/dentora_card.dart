import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Geliştirici 2 — Ortak Kart Tasarım Bileşeni
/// Klinik yüzey kartlarını ve vurgu kartlarını standart kenarlık ve gölgeyle sarmalar.
class DentoraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool isHighlighted;
  final Color? backgroundColor;

  const DentoraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.isHighlighted = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.surfaceContainerHigh,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A151D23),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: content,
    );
  }
}

