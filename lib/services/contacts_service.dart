import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/extracted_contact.dart';

class ContactsService {
  /// Returns true if a contact with the same name or phone already exists.
  static Future<bool> checkDuplicate(ExtractedContact contact) async {
    final existing =
        await FlutterContacts.getContacts(withProperties: true);

    final targetPhone = _normalizePhone(contact.phone);
    final targetName = contact.name.trim().toLowerCase();

    for (final c in existing) {
      final existingName =
          '${c.name.first} ${c.name.last}'.trim().toLowerCase();
      if (existingName == targetName) return true;

      for (final p in c.phones) {
        if (_normalizePhone(p.number) == targetPhone) return true;
      }
    }
    return false;
  }

  /// Inserts the contact without performing any duplicate check.
  static Future<void> save(ExtractedContact contact) async {
    final parts = contact.name.trim().split(RegExp(r'\s+'));
    final first = parts.first;
    final last = parts.length > 1 ? parts.skip(1).join(' ') : '';

    final newContact = Contact(
      name: Name(first: first, last: last),
      phones: contact.phone.isNotEmpty
          ? [Phone(contact.phone)]
          : [],
      emails: contact.email != null
          ? [Email(contact.email!)]
          : [],
      addresses: contact.address != null
          ? [Address(contact.address!)]
          : [],
    );

    await newContact.insert();
  }

  /// Strips all non-digit characters and returns the last 10 digits for comparison.
  static String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
  }
}
