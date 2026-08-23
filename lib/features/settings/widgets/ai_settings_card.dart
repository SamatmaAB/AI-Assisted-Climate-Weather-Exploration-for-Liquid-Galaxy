import 'package:flutter/material.dart';

class AiSettingsCard extends StatelessWidget {
  final TextEditingController apiKeyController;
  final bool isObscured;
  final bool isBuildConfigured;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSave;
  final VoidCallback onRemove;

  const AiSettingsCard({
    super.key,
    required this.apiKeyController,
    required this.isObscured,
    required this.isBuildConfigured,
    required this.onToggleVisibility,
    required this.onSave,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Google Gemini API Key',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isBuildConfigured) ...[
                  const SizedBox(width: 8),
                  _BuildConfiguredBadge(),
                ],
              ],
            ),

            if (isBuildConfigured) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.35),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 15, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'API key injected from dart_defines.json at build time. '
                        'You can override it manually below.',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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

class _BuildConfiguredBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_outlined, size: 11, color: Colors.green.shade600),
          const SizedBox(width: 4),
          Text(
            'Pre-configured',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.green.shade700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
