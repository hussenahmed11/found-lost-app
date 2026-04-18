import 'package:flutter/material.dart';
import '../constants/theme.dart';

class AppInput extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final String? error;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final double? height;

  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    this.error,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppSpacing.xs, left: AppSpacing.xs),
              child: Text(
                label!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          Container(
            height: height ?? (maxLines > 1 ? null : 52),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.m),
              border: Border.all(
                color: error != null ? AppColors.danger : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.m,
                  vertical: AppSpacing.s,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, left: AppSpacing.xs),
              child: Text(
                error!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
