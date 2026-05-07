import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactFieldTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;

  const ContactFieldTile({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  void _copy(BuildContext context) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction:
            maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.copy_outlined, size: 20),
            tooltip: 'Copy $label',
            onPressed: () => _copy(context),
          ),
        ),
      ),
    );
  }
}
