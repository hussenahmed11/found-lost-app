import 'package:flutter/material.dart';
import '../constants/theme.dart';

enum AppButtonType { primary, secondary, danger, outline }

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPress;
  final AppButtonType type;
  final bool loading;
  final bool disabled;

  const AppButton({
    super.key,
    required this.title,
    this.onPress,
    this.type = AppButtonType.primary,
    this.loading = false,
    this.disabled = false,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case AppButtonType.secondary:
        return AppColors.secondary;
      case AppButtonType.danger:
        return AppColors.danger;
      case AppButtonType.outline:
        return Colors.transparent;
      case AppButtonType.primary:
        return AppColors.primary;
    }
  }

  Color _getTextColor() {
    if (type == AppButtonType.outline) return AppColors.primary;
    return AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: Material(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppRadius.m),
          child: InkWell(
            onTap: isDisabled ? null : onPress,
            borderRadius: BorderRadius.circular(AppRadius.m),
            child: Container(
              decoration: type == AppButtonType.outline
                  ? BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    )
                  : null,
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.l),
              child: loading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          type == AppButtonType.outline
                              ? AppColors.primary
                              : AppColors.surface,
                        ),
                      ),
                    )
                  : Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _getTextColor(),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
