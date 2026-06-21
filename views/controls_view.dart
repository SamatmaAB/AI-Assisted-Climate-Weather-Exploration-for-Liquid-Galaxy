import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../state/app_state.dart';
import '../widgets/glass_card.dart';
import '../services/ssh_service.dart';

class ControlsView extends StatelessWidget {
  const ControlsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sshService = context.read<SSHService>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liquid Galaxy',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Services',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          _ControlSection(
            title: 'System Tasks',
            items: [
              _ControlTile(
                icon: LucideIcons.power, 
                label: 'Shutdown', 
                color: Colors.redAccent,
                onTap: () => _confirmAction(context, 'Shutdown Rig?', () => sshService.shutdownRigs()),
              ),
              _ControlTile(
                icon: LucideIcons.refreshCw, 
                label: 'Reboot', 
                color: Colors.orangeAccent,
                onTap: () => _confirmAction(context, 'Reboot Rig?', () => sshService.rebootRigs()),
              ),
              _ControlTile(
                icon: LucideIcons.trash2, 
                label: 'Clear KML', 
                color: Colors.blueAccent,
                onTap: () => sshService.clearKmls(),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 16),
          
          _ControlSection(
            title: 'Visual Controls',
            items: [
              _ControlTile(
                icon: LucideIcons.image, 
                label: 'Show Logo', 
                color: Colors.greenAccent,
                onTap: () => sshService.sendLogo(),
              ),
              _ControlTile(
                icon: LucideIcons.eye, 
                label: 'Orbit', 
                color: Colors.purpleAccent,
                onTap: () => sshService.execute('echo "playtour=Orbit" > /tmp/query.txt'),
              ),
              _ControlTile(
                icon: LucideIcons.globe, 
                label: 'Refresh', 
                color: Colors.cyanAccent,
                onTap: () => sshService.refreshKml(),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 16),
          
          GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (appState.isConnected ? Colors.greenAccent : Colors.redAccent).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        appState.isConnected ? LucideIcons.zap : LucideIcons.zapOff, 
                        color: appState.isConnected ? Colors.greenAccent : Colors.redAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Rig Availability', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: appState.isConnected ? Colors.greenAccent.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appState.isConnected ? 'ROBUST SESSION' : 'OFFLINE', 
                        style: TextStyle(
                          color: appState.isConnected ? Colors.greenAccent : Colors.redAccent, 
                          fontWeight: FontWeight.w900, 
                          fontSize: 10,
                          letterSpacing: 0.5,
                        )
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: appState.isConnected ? 1.0 : 0.0,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(appState.isConnected ? Colors.greenAccent : Colors.redAccent),
                      minHeight: 10,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                    if (appState.isProcessing)
                      const Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Node Connection', style: TextStyle(color: appState.textSecondaryColor, fontSize: 12)),
                    Text(
                      appState.lgIp.isEmpty ? 'Not Configured' : '${appState.lgIp}:${appState.lgPort}', 
                      style: TextStyle(color: appState.textColor, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cluster Size', style: TextStyle(color: appState.textSecondaryColor, fontSize: 12)),
                    Text('${appState.lgRigs} Rigs', style: TextStyle(color: appState.textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).scale(),
        ],
      ),
    );
  }

  void _confirmAction(BuildContext context, String title, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: const Text('This will affect all nodes in the Liquid Galaxy cluster.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            }, 
            child: const Text('CONFIRM', style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }
}

class _ControlSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _ControlSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
          ),
        ),
        Row(
          children: items.map((item) => Expanded(child: item)).toList(),
        ),
      ],
    );
  }
}

class _ControlTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ControlTile({
    required this.icon, 
    required this.label, 
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
