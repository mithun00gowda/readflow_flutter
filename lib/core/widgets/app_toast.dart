import 'package:flutter/material.dart';
import 'package:readflow/core/theme/app_theme.dart';
import 'package:readflow/main.dart';

enum ToastType { success, error, info }

class AppToast {
  static void show(String message, {ToastType type = ToastType.success}) {
    final messenger = scafflodMessageKey.currentState;
    if (messenger == null) return;

    final color = switch (type) {
      ToastType.success => AppColors.primary,
      ToastType.error => AppColors.error,
      ToastType.info => AppColors.primary,
    };
    final icon = switch (type) {
      ToastType.success => Icons.check_circle_outline,
      ToastType.error => Icons.error_outline,
      ToastType.info => Icons.info_outline,
    };

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        elevation: 4,
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(14),
        ),
        duration: Duration(seconds: 2),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
