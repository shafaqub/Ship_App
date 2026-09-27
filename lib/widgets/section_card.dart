import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.purple.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.purple.withOpacity(0.10),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }
}
