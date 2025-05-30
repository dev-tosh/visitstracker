import 'package:flutter/material.dart';
import 'package:visitstracker/core/theme/text_styles.dart';

class AlertService {
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title, style: title3(context: dialogContext)),
        content: Text(message, style: body(context: dialogContext)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
