import 'package:flutter/material.dart';
import '../widgets/allocate_mode_selection_dialog.dart';
import 'allocate_filter_screen.dart';

class AllocateLeadsScreen extends StatelessWidget {
  const AllocateLeadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show mode selection dialog immediately
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final mode = await showDialog<String>(
        context: context,
        builder: (context) => const AllocateModeSelectionDialog(),
      );

      if (mode != null && context.mounted) {
        // Navigate to filter screen with selected mode
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AllocateFilterScreen(mode: mode),
          ),
        );
      } else if (context.mounted) {
        // User cancelled, go back
        Navigator.pop(context);
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
