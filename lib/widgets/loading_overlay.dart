import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;

  const LoadingOverlay({super.key, this.message = 'Reading card...'});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.5)),
        Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(message, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
