import 'package:flutter/material.dart';

/// Card containing AI Assistant Gemini API key settings and action buttons.
class AiSettingsCard extends StatelessWidget {
  final TextEditingController apiKeyController;
  final bool isObscured;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSave;
  final VoidCallback onRemove;

  const AiSettingsCard({
    super.key,
    required this.apiKeyController,
    required this.isObscured,
    required this.onToggleVisibility,
    required this.onSave,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Google Gemini API Key',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apiKeyController,
              obscureText: isObscured,
              decoration: InputDecoration(
                labelText: 'Google Gemini API Key',
                prefixIcon: const Icon(Icons.key_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: onToggleVisibility,
                  tooltip: isObscured ? 'Show API Key' : 'Hide API Key',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRemove,
                    child: const Text('Remove API Key'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: onSave,
                    child: const Text('Save API Key'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
