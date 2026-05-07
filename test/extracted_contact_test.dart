import 'package:flutter_test/flutter_test.dart';
import 'package:pic_to_contact/models/extracted_contact.dart';

void main() {
  group('ExtractedContact.fromJson', () {
    test('parses all fields', () {
      final c = ExtractedContact.fromJson({
        'name': 'Jane Smith',
        'phone': '+1 555-234-5678',
        'email': 'jane@example.com',
        'address': '123 Main St',
        'website': 'https://example.com',
      });
      expect(c.name, 'Jane Smith');
      expect(c.phone, '+1 555-234-5678');
      expect(c.email, 'jane@example.com');
      expect(c.address, '123 Main St');
      expect(c.website, 'https://example.com');
      expect(c.isValid, isTrue);
    });

    test('handles missing optional fields', () {
      final c = ExtractedContact.fromJson({
        'name': 'Bob',
        'phone': '555-0100',
      });
      expect(c.email, isNull);
      expect(c.address, isNull);
      expect(c.website, isNull);
      expect(c.isValid, isTrue);
    });

    test('empty string website becomes null', () {
      final c = ExtractedContact.fromJson({
        'name': 'Bob',
        'phone': '555-0100',
        'website': '  ',
      });
      expect(c.website, isNull);
    });

    test('trims whitespace', () {
      final c = ExtractedContact.fromJson({
        'name': '  Alice  ',
        'phone': ' 555-0101 ',
        'email': '  alice@example.com  ',
      });
      expect(c.name, 'Alice');
      expect(c.phone, '555-0101');
      expect(c.email, 'alice@example.com');
    });

    test('isValid false when name empty', () {
      final c = ExtractedContact.fromJson({'name': '', 'phone': '555-0100'});
      expect(c.isValid, isFalse);
    });

    test('isValid false when phone empty', () {
      final c = ExtractedContact.fromJson({'name': 'Bob', 'phone': ''});
      expect(c.isValid, isFalse);
    });

    test('empty string email becomes null', () {
      final c = ExtractedContact.fromJson({
        'name': 'Bob',
        'phone': '555-0100',
        'email': '   ',
      });
      expect(c.email, isNull);
    });
  });
}
