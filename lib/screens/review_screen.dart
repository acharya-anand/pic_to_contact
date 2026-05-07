import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/extracted_contact.dart';
import '../services/contacts_service.dart';
import '../utils/permission_utils.dart';
import '../widgets/contact_field_tile.dart';

class ReviewScreen extends StatefulWidget {
  final ExtractedContact contact;

  const ReviewScreen({super.key, required this.contact});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _address;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.contact.name);
    _phone = TextEditingController(text: widget.contact.phone);
    _email = TextEditingController(text: widget.contact.email ?? '');
    _address = TextEditingController(text: widget.contact.address ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  ExtractedContact get _currentContact => ExtractedContact(
        name: _name.text.trim(),
        phone: _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      );

  bool get _canSave =>
      _name.text.trim().isNotEmpty && _phone.text.trim().isNotEmpty;

  Future<void> _save() async {
    final granted = await requestContactsPermission(context);
    if (!granted || !mounted) return;

    setState(() => _saving = true);

    try {
      final contact = _currentContact;
      final isDuplicate = await ContactsService.checkDuplicate(contact);

      if (!mounted) return;

      if (isDuplicate) {
        final proceed = await _showDuplicateDialog(contact.name);
        if (!mounted || proceed != true) {
          setState(() => _saving = false);
          return;
        }
      }

      await ContactsService.save(contact);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact saved!')),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save contact: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool?> _showDuplicateDialog(String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Duplicate Contact'),
        content: Text(
            'A contact named "$name" or with the same phone number already exists. Save anyway?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Save Anyway'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review Contact'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retake'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([_name, _phone]),
                builder: (context, _) {
                  return Column(
                    children: [
                      ContactFieldTile(
                        label: 'Name',
                        controller: _name,
                      ),
                      ContactFieldTile(
                        label: 'Phone',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  );
                },
              ),
              ContactFieldTile(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              ContactFieldTile(
                label: 'Address',
                controller: _address,
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              ListenableBuilder(
                listenable: Listenable.merge([_name, _phone]),
                builder: (context, _) => FilledButton.icon(
                  onPressed: (_saving || !_canSave) ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add_outlined),
                  label: const Text('Save to Contacts'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                ),
              ),
              if (!_canSave)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Name and phone are required to save.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
