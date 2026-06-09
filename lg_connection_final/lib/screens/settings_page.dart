import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _isColorblindMode = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? 'lg';
      _ipController.text = prefs.getString('ipAddress') ?? '';
      _portController.text = prefs.getString('sshPort') ?? '22';
      _passwordController.text = prefs.getString('password') ?? 'lg';
      _rigsController.text = prefs.getString('numberOfRigs') ?? '3';
    });
  }

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const blue950 = Color(0xFF172554);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);

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
                    'App Settings',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  _buildSubHeader('LIQUID GALAXY CONNECTION'),
                  const SizedBox(height: 16),
                  _buildConnectionCard(neonGreen, electricBlue),
                  
                  const SizedBox(height: 32),
                  _buildSubHeader('APPEARANCE'),
                  const SizedBox(height: 16),
                  _buildAppearanceCard(neonGreen),
                  
                  const SizedBox(height: 32),
                  _buildSubHeader('ABOUT'),
                  const SizedBox(height: 16),
                  _buildAboutCard(),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Earth Science Visualization App',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Liquid Galaxy Project 2026',
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
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
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildConnectionCard(Color saveGreen, Color connectBlue) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          _buildSettingsInput('IP Address', _ipController, CupertinoIcons.flowchart),
          const SizedBox(height: 24),
          _buildSettingsInput('SSH Port', _portController, CupertinoIcons.number),
          const SizedBox(height: 24),
          _buildSettingsInput('Username', _usernameController, CupertinoIcons.person),
          const SizedBox(height: 24),
          _buildSettingsInput('Password', _passwordController, CupertinoIcons.lock, isPassword: true),
          const SizedBox(height: 24),
          _buildSettingsInput('Number of Rigs', _rigsController, CupertinoIcons.layers),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSmallButton(
                  'Save Credentials',
                  saveGreen.withOpacity(0.15),
                  saveGreen,
                  () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallButton(
                  'Connect',
                  connectBlue.withOpacity(0.15),
                  connectBlue,
                  () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsInput(String label, TextEditingController controller, IconData icon, {bool isPassword = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 24),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              TextField(
                controller: controller,
                obscureText: isPassword,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(Color activeColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          _buildSwitchRow('Dark Mode', CupertinoIcons.moon, _isDarkMode, (v) => setState(() => _isDarkMode = v), activeColor),
          _buildDivider(),
          _buildSwitchRow('Color Blind Mode', CupertinoIcons.eye, _isColorblindMode, (v) => setState(() => _isColorblindMode = v), activeColor),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          _buildAboutRow('User Guide', CupertinoIcons.book),
          _buildDivider(),
          _buildAboutRow('Version 1.0.0 (Beta)', CupertinoIcons.info),
          _buildDivider(),
          _buildAboutRow('Open Source Code', CupertinoIcons.link),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, IconData icon, bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(CupertinoIcons.arrow_up_right, color: Colors.white.withOpacity(0.3), size: 18),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.05), height: 1, indent: 64);
  }
}
