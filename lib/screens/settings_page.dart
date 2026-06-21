import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lg_connection/connections/ssh.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  bool _isColorblindMode = false;
  bool _isConnecting = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rigsController = TextEditingController();

  final SSH _ssh = SSH();

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
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _isColorblindMode = prefs.getBool('isColorblindMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('ipAddress', _ipController.text);
    await prefs.setString('sshPort', _portController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('numberOfRigs', _rigsController.text);
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isColorblindMode', _isColorblindMode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 110, left: 20, right: 20),
        ),
      );
    }
  }

  Future<void> _connectToLG() async {
    if (_ipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an IP Address'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 110, left: 20, right: 20),
        ),
      );
      return;
    }

    setState(() => _isConnecting = true);
    
    // Ensure settings are saved before connecting
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('ipAddress', _ipController.text);
    await prefs.setString('sshPort', _portController.text);
    await prefs.setString('password', _passwordController.text);
    await prefs.setString('numberOfRigs', _rigsController.text);

    try {
      bool connected = await _ssh.connectToLG();
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(connected 
              ? 'Successfully connected to Liquid Galaxy!' 
              : 'Connection failed. Verify IP and credentials.'),
            backgroundColor: connected ? const Color(0xFF3B82F6) : Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const slate950 = Color(0xFF020617);
    const electricBlue = Color(0xFF3B82F6);
    const neonGreen = Color(0xFF22C55E);

    return Material(
      color: slate950,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _ssh.isConnected,
                  builder: (context, connected, child) {
                    return _buildStatusBadge(connected ? 'ONLINE' : 'OFFLINE', connected ? neonGreen : Colors.redAccent);
                  },
                ),
              ],
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
            const SizedBox(height: 160), 
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 4, spreadRadius: 1),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
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
      borderColor: Colors.white.withOpacity(0.05),
      backgroundColor: Colors.white.withOpacity(0.02),
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
                  'Save',
                  saveGreen.withOpacity(0.08),
                  saveGreen,
                  _saveSettings,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallButton(
                  _isConnecting ? 'Connecting...' : 'Connect',
                  connectBlue.withOpacity(0.08),
                  connectBlue,
                  _isConnecting ? () {} : _connectToLG,
                  isLoading: _isConnecting,
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
        Icon(icon, color: Colors.white.withOpacity(0.4), size: 22),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.35), fontSize: 12)),
              TextField(
                controller: controller,
                obscureText: isPassword,
                style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.9), fontSize: 16),
                cursorColor: Colors.white.withOpacity(0.6),
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 4), border: InputBorder.none),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallButton(String label, Color bgColor, Color textColor, VoidCallback onTap, {bool isLoading = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withOpacity(0.1)),
        ),
        child: Center(
          child: isLoading 
            ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(textColor)))
            : Text(label, style: GoogleFonts.outfit(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(Color activeColor) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.04),
      backgroundColor: Colors.white.withOpacity(0.02),
      child: Column(
        children: [
          _buildSwitchRow('Dark Mode', CupertinoIcons.moon, _isDarkMode, (v) => setState(() { _isDarkMode = v; _saveSettings(); }), activeColor),
          _buildDivider(),
          _buildSwitchRow('Color Blind Mode', CupertinoIcons.eye, _isColorblindMode, (v) => setState(() { _isColorblindMode = v; _saveSettings(); }), activeColor),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      borderRadius: 28,
      borderColor: Colors.white.withOpacity(0.04),
      backgroundColor: Colors.white.withOpacity(0.02),
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
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
          const SizedBox(width: 20),
          Expanded(child: Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.85), fontSize: 16, fontWeight: FontWeight.w600))),
          Transform.scale(scale: 0.8, child: CupertinoSwitch(value: value, activeColor: activeColor.withOpacity(0.7), onChanged: onChanged)),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 22),
          const SizedBox(width: 20),
          Expanded(child: Text(label, style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.85), fontSize: 16, fontWeight: FontWeight.w600))),
          Icon(CupertinoIcons.arrow_up_right, color: Colors.white.withOpacity(0.2), size: 18),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.white.withOpacity(0.03), height: 1, indent: 64);
  }
}
