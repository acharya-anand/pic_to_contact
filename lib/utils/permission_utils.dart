import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraPermission(BuildContext context) async {
  final status = await Permission.camera.request();
  if (status.isGranted) return true;
  if (context.mounted) await _showDeniedDialog(context, 'camera');
  return false;
}

Future<bool> requestContactsPermission(BuildContext context) async {
  final status = await Permission.contacts.request();
  if (status.isGranted) return true;
  if (context.mounted) await _showDeniedDialog(context, 'contacts');
  return false;
}

Future<void> _showDeniedDialog(BuildContext context, String permission) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('${_capitalize(permission)} permission required'),
      content: Text(
          'Please grant $permission access so the app can work correctly.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
