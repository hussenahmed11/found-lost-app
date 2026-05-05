import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// Utility class for network connectivity checks and error handling.
class NetworkHelper {
  /// Check if the device has internet connectivity.
  /// Performs a DNS lookup to verify actual internet access.
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Convert a raw error into a user-friendly message.
  static String getFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    // Network / connectivity errors
    if (errorStr.contains('socketexception') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('network_error') ||
        errorStr.contains('networkexception') ||
        errorStr.contains('no address associated') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('connection timed out') ||
        errorStr.contains('connection reset') ||
        errorStr.contains('handshake') ||
        errorStr.contains('errno = 7') ||
        errorStr.contains('errno = 101') ||
        errorStr.contains('unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Timeout errors
    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return 'Connection timed out. Please check your internet and try again.';
    }

    // Firebase Auth errors
    if (errorStr.contains('user-not-found') ||
        errorStr.contains('no user record')) {
      return 'No account found with this email. Please sign up first.';
    }
    if (errorStr.contains('wrong-password') ||
        errorStr.contains('invalid-credential')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (errorStr.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    }
    if (errorStr.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (errorStr.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (errorStr.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    }
    if (errorStr.contains('user-disabled')) {
      return 'This account has been disabled. Contact support.';
    }
    if (errorStr.contains('operation-not-allowed')) {
      return 'This sign-in method is not enabled.';
    }
    if (errorStr.contains('requires-recent-login')) {
      return 'Please log in again to perform this action.';
    }

    // Firestore permission errors
    if (errorStr.contains('permission-denied') ||
        errorStr.contains('permission_denied')) {
      return 'You don\'t have permission to perform this action.';
    }

    // Generic Firebase errors
    if (errorStr.contains('unavailable')) {
      return 'Service temporarily unavailable. Please try again.';
    }
    if (errorStr.contains('cancelled')) {
      return 'Operation was cancelled.';
    }

    // Strip "[firebase_auth/...]" wrapper for cleaner display
    final firebaseMatch = RegExp(r'\[firebase_auth/[^\]]+\]\s*(.+)')
        .firstMatch(error.toString());
    if (firebaseMatch != null) {
      return firebaseMatch.group(1)!;
    }

    // If nothing matched, return a generic message
    return 'Something went wrong. Please try again.';
  }

  /// Show a user-friendly error snackbar.
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final message = getFriendlyErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFFF3B30),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show a no-internet dialog with retry option.
  static Future<bool> showNoInternetDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Color(0xFFFF9500), size: 28),
            SizedBox(width: 12),
            Text('No Internet'),
          ],
        ),
        content: const Text(
          'You appear to be offline. Please check your internet connection and try again.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
