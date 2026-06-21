import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:lg_connection/connections/ssh.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({super.key});

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  final SSH _ssh = SSH();

  void _showFeedback(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? const Color(0xFF3B82F6) : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const warningOrange = Color(0xFFF59E0B);
    const criticalRed = Color(0xFFEF4444);
    const purpleAccent = Color(0xFF9C27B0);
    const refreshCyan = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: slate950,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 40),
              Text(
                'Liquid Galaxy\nServices',
                style: GoogleFonts.outfit(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSubHeader('SYSTEM TASKS'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTaskButton(
                      label: 'Shutdown',
                      icon: CupertinoIcons.power,
                      color: criticalRed,
                      onPressed: () async {
                        await _ssh.shutdownLG();
                        _showFeedback('Shutdown command sent to all rigs', true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskButton(
                      label: 'Reboot',
                      icon: CupertinoIcons.refresh_bold,
                      color: warningOrange,
                      onPressed: () async {
                        await _ssh.rebootLG();
                        _showFeedback('Reboot command sent to all rigs', true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskButton(
                      label: 'Clear KML',
                      icon: CupertinoIcons.trash,
                      color: electricBlue,
                      onPressed: () async {
                        await _ssh.clearKML();
                        _showFeedback('KMLs cleared successfully', true);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildSubHeader('VISUAL CONTROLS'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTaskButton(
                      label: 'Show Logo',
                      icon: CupertinoIcons.photo,
                      color: neonGreen,
                      onPressed: () async {
                        await _ssh.sendLogo();
                        _showFeedback('Logo sent to slave rig', true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskButton(
                      label: 'Orbit',
                      icon: CupertinoIcons.eye,
                      color: purpleAccent,
                      onPressed: () async {
                        await _ssh.buildOrbit();
                        _showFeedback('Orbiting started', true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTaskButton(
                      label: 'Refresh',
                      icon: CupertinoIcons.arrow_2_circlepath,
                      color: refreshCyan,
                      onPressed: () async {
                        await _ssh.executeCommand('sudo systemctl restart lg');
                        _showFeedback('System services refreshed', true);
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              ValueListenableBuilder<bool>(
                valueListenable: _ssh.isConnected,
                builder: (context, connected, child) {
                  return _buildAvailabilityCard(connected ? neonGreen : criticalRed, connected);
                },
              ),
              
              const SizedBox(height: 140),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white.withOpacity(0.4),
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTaskButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        borderRadius: 20,
        borderColor: color.withOpacity(0.2),
        backgroundColor: Colors.white.withOpacity(0.03),
        onTap: onPressed,
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(Color statusColor, bool isConnected) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: -10,
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 28,
        borderColor: Colors.white.withOpacity(0.05),
        backgroundColor: Colors.white.withOpacity(0.02),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isConnected ? CupertinoIcons.wifi : CupertinoIcons.wifi_slash, 
                    color: statusColor, 
                    size: 20
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Rig Availability',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isConnected ? 'ONLINE' : 'OFFLINE',
                    style: GoogleFonts.outfit(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: isConnected ? 1.0 : 0.1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Node Connection', isConnected ? 'Connected' : 'Not Configured'),
            const SizedBox(height: 12),
            _buildInfoRow('Cluster Size', '3 Rigs'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.4), fontSize: 14),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
