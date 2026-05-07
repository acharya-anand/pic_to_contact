import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/extracted_contact.dart';
import '../services/api_key_service.dart';
import '../services/claude_service.dart';
import '../utils/permission_utils.dart';
import '../widgets/loading_overlay.dart';
import 'review_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  Future<void> _checkApiKey() async {
    final key = await ApiKeyService.read();
    if (mounted) setState(() => _hasApiKey = key != null && key.isNotEmpty);
  }

  Future<void> _scanCard() async {
    final granted = await requestCameraPermission(context);
    if (!granted || !mounted) return;

    final apiKey = await ApiKeyService.read();
    if (apiKey == null || apiKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your Claude API key in Settings first.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: _openSettings,
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
    if (file == null || !mounted) return;

    setState(() => _loading = true);

    try {
      final bytes = await file.readAsBytes();
      final contact = await ClaudeService.extractContact(bytes, apiKey);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReviewScreen(contact: contact),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openSettings() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    if (saved == true) _checkApiKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_hasApiKey)
                    _ApiKeyBanner(onTap: _openSettings),
                  const SizedBox(height: 24),
                  const Icon(Icons.badge_outlined, size: 96,
                      color: Colors.blueGrey),
                  const SizedBox(height: 24),
                  const Text(
                    'Scan a business card',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Point your camera at any business card, contact card, or advertisement to extract contact information.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 36),
                  FilledButton.icon(
                    onPressed: _loading ? null : _scanCard,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Scan Card'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(200, 52),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading) const LoadingOverlay(),
        ],
      ),
    );
  }
}

class _ApiKeyBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ApiKeyBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.amber.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.key_outlined, color: Colors.amber.shade800),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Add your Claude API key to get started.',
                  style: TextStyle(color: Colors.amber.shade900),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.amber.shade800),
            ],
          ),
        ),
      ),
    );
  }
}
