import 'package:flutter/material.dart';
import 'package:lg_connection/services/tts/tts_service.dart';

class TtsSettingsCard extends StatelessWidget {
  const TtsSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: TtsService.instance,
      builder: (context, _) {
        final tts = TtsService.instance;
        final voices = tts.availableVoices;
        final selectedVoice = tts.selectedVoice;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Auto-narrate Summaries & Chat',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Automatically read aloud new chatbot responses and climate summaries',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  value: tts.autoNarrate,
                  onChanged: (val) => tts.setAutoNarrate(val),
                ),
                const Divider(height: 24),

                Text(
                  'Voice Selection',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),

                if (voices.isEmpty)
                  Text(
                    'Default system voice active',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    initialValue: selectedVoice != null ? selectedVoice['name'] : null,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Select Voice',
                    ),
                    items: voices.map((v) {
                      final name = v['name']!;
                      final locale = v['locale'] ?? '';
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(
                          '$name ($locale)',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                    onChanged: (selectedName) {
                      if (selectedName != null) {
                        final found = voices.firstWhere(
                          (v) => v['name'] == selectedName,
                          orElse: () => {'name': selectedName, 'locale': 'en-US'},
                        );
                        tts.setVoice(found);
                      }
                    },
                  ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      tts.speak(
                          'Hello! This is a test of your selected voice settings.');
                    },
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text('Test Voice'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
