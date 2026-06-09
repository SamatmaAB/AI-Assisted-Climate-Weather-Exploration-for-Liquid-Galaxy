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
  final SSH ssh = SSH();

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const blue950 = Color(0xFF172554);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);
    const cyanWhite = Color(0xFFE0F7FA);
    const warningOrange = Color(0xFFF59E0B);
    const criticalRed = Color(0xFFEF4444);
    const purpleAccent = Color(0xFF9C27B0);
    const refreshCyan = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: slate950,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [slate950, blue950],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: _buildGlow(electricBlue.withOpacity(0.1), 400),
            ),
            SafeArea(
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
                          onPressed: () => ssh.shutdownLG(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTaskButton(
                          label: 'Reboot',
                          icon: CupertinoIcons.refresh_bold,
                          color: warningOrange,
                          onPressed: () => ssh.rebootLG(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTaskButton(
                          label: 'Clear KML',
                          icon: CupertinoIcons.trash,
                          color: electricBlue,
                          onPressed: () => ssh.clearKML(),
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
                          onPressed: () => ssh.sendLogo(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTaskButton(
                          label: 'Orbit',
                          icon: CupertinoIcons.eye,
                          color: purpleAccent,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTaskButton(
                          label: 'Refresh',
                          icon: CupertinoIcons.arrow_2_circlepath,
                          color: refreshCyan,
                          onPressed: () => ssh.executeCommand('sudo systemctl restart lg'),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  _buildAvailabilityCard(criticalRed),
                  
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlow(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(),
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
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20),
      borderRadius: 20,
      borderColor: Colors.white.withOpacity(0.05),
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(Color offlineRed) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: offlineRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(CupertinoIcons.wifi_slash, color: offlineRed, size: 20),
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
                  color: offlineRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'OFFLINE',
                  style: GoogleFonts.outfit(
                    color: offlineRed,
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
              widthFactor: 0.1,
              child: Container(
                decoration: BoxDecoration(
                  color: offlineRed.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Node Connection', 'Not Configured'),
          const SizedBox(height: 12),
          _buildInfoRow('Cluster Size', '3 Rigs'),
        ],
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
