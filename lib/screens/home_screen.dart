import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lg_connection/components/glass_card.dart';
import 'package:lg_connection/connections/ssh.dart';
import 'package:lg_connection/screens/category_detail_screen.dart';
import 'package:lg_connection/services/gemini_service.dart';
import 'package:lg_connection/services/climate_cache_service.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  final SSH ssh = SSH();

  GoogleMapController? _mapController;
  LatLng _lastTarget = const LatLng(20.5937, 78.9629);
  double _lastZoom = 4;
  double _lastTilt = 0;
  double _lastBearing = 0;
  Timer? _debounce;
  bool _isVisualisingMonsoon = false;
  bool _isVisualisingKuroshio = false;
  bool _isVisualisingGulfStream = false;

  static const _slate950 = Color(0xFF020617);
  static const _electricBlue = Color(0xFF3B82F6);
  static const _neonGreen = Color(0xFF22C55E);
  static const _cyanWhite = Color(0xFFE0F7FA);
  static const _goldAccent = Color(0xFFFFC107);
  static const _criticalRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    ssh.connectToLG();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _showFeedback(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? _electricBlue : _criticalRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 110, left: 20, right: 20),
      ),
    );
  }
  void _showAiLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: _slate950,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const CupertinoActivityIndicator(
                color: _electricBlue,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  'Generating climate explanation...',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<String> _getClimateInfo(
      String phenomenon,
      ) async {
    final cached =
    await ClimateCacheService.get(
      phenomenon,
    );

    if (cached != null) {
      return cached;
    }
    try{
    _showAiLoading();
    final text =
    await GeminiService().ask(
      '''
You are an Earth Systems Observatory assistant.

Explain the following phenomenon:

$phenomenon

Include:
• What it is
• How it works
• Why it is important
• Its impact on weather and climate.

Keep the explanation under 200 words and easy to understand.
''',
    );

    if (mounted) {
      Navigator.of(context).pop();
    }

    await ClimateCacheService.save(
      phenomenon,
      text,
    );

    return text;
  }
    catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }

      rethrow;
    }}

  Future<void> _showClimatePopup(
      String title,
      String text,
      ) async {
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      backgroundColor: _slate950,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          maxChildSize: 0.85,
          builder: (context, controller) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
            Expanded(
            child: GlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: 22,
            borderColor:
            Colors.white.withOpacity(0.08),
            backgroundColor:
            Colors.white.withOpacity(0.03),
            child: SingleChildScrollView(
                      controller: controller,
                      child: Text(
                        text,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.7,
                        ),
                      ),),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _visualiseIndianMonsoon() async {
    if (_isVisualisingMonsoon) return;

    setState(() => _isVisualisingMonsoon = true);

    try {
      await ssh.visualizeIndianMonsoon();

      _showFeedback(
        'Indian Monsoon sent to Liquid Galaxy',
        true,
      );

      final text =
      await _getClimateInfo(
        'Indian Monsoon',
      );

      await _showClimatePopup(
        'Indian Monsoon',
        text,
      );
    } catch (e) {
      _showFeedback(
        'Could not send Indian Monsoon KML',
        false,
      );
    } finally {
      if (mounted) {
        setState(
              () => _isVisualisingMonsoon = false,
        );
      }
    }
  }
  Future<void> _visualiseKuroshioCurrent() async {
    if (_isVisualisingKuroshio) return;

    setState(() => _isVisualisingKuroshio = true);

    try {
      await ssh.visualizeKuroshioCurrent();

      _showFeedback(
        'Kuroshio Current sent to Liquid Galaxy',
        true,
      );

      final text =
      await _getClimateInfo(
        'Kuroshio Current',
      );

      await _showClimatePopup(
        'Kuroshio Current',
        text,
      );
    } catch (e) {
      _showFeedback(
        'Could not send Kuroshio KML',
        false,
      );
    } finally {
      if (mounted) {
        setState(
              () => _isVisualisingKuroshio = false,
        );
      }
    }
  }

  Future<void> _visualiseGulfStream() async {
    if (_isVisualisingGulfStream) return;

    setState(() => _isVisualisingGulfStream = true);

    try {
      await ssh.visualizeGulfStream();

      _showFeedback(
        'Gulf Stream sent to Liquid Galaxy',
        true,
      );

      final text =
      await _getClimateInfo(
        'Gulf Stream',
      );

      await _showClimatePopup(
        'Gulf Stream',
        text,
      );
    } catch (e) {
      _showFeedback(
        'Could not send Gulf Stream KML',
        false,
      );
    } finally {
      if (mounted) {
        setState(
              () => _isVisualisingGulfStream = false,
        );
      }
    }
  }

  void _syncToLG() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      ssh.flyToCoordinates(
        _lastTarget.latitude,
        _lastTarget.longitude,
        _lastZoom,
        _lastTilt,
        _lastBearing,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate950,
      body: Container(
        color: _slate950,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 28),
              ValueListenableBuilder<bool>(
                valueListenable: ssh.isConnected,
                builder: (context, connected, child) {
                  return _buildLiveStatus(
                    connected ? _neonGreen : _criticalRed,
                    connected,
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Liquid Galaxy',
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              Text(
                'Climate View',
                style: GoogleFonts.outfit(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: _electricBlue,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Choose a visualization and project it directly to the rig.',
                style: GoogleFonts.outfit(
                  color: Colors.white.withOpacity(0.62),
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 28),
              _buildVisualizationAction(
                title: 'Visualise Indian Monsoon',
                description:
                    'Loads the pre-generated KML and overwrites master.kml on Liquid Galaxy.',
                icon: CupertinoIcons.cloud_rain,
                color: _electricBlue,
                isLoading: _isVisualisingMonsoon,
                onTap: _visualiseIndianMonsoon,
              ),
              const SizedBox(height: 16),
              _buildVisualizationAction(
                title: 'Visualise Kuroshio Current',
                description:
                    'Loads the pre-generated Kuroshio KML and overwrites master.kml on Liquid Galaxy.',
                icon: CupertinoIcons.waveform,
                color: _goldAccent,
                isLoading: _isVisualisingKuroshio,
                onTap: _visualiseKuroshioCurrent,
              ),
              const SizedBox(height: 16),
              _buildVisualizationAction(
                title: 'Visualise Gulf Stream',
                description:
                'Loads the pre-generated Gulf Stream KML and overwrites master.kml on Liquid Galaxy.',
                icon: CupertinoIcons.arrow_2_circlepath,
                color: Colors.orange,
                isLoading: _isVisualisingGulfStream,
                onTap: _visualiseGulfStream,
              ),
              const SizedBox(height: 16),
              _buildQuickAction(
                label: 'Clear',
                icon: CupertinoIcons.trash,
                color: _criticalRed,
                onTap: () async {
                  await ssh.clearKML();
                  _showFeedback('KML cleared from Liquid Galaxy', true);
                },
              ),
              const SizedBox(height: 30),
              _buildSectionHeader('Map Sync', CupertinoIcons.map),
              const SizedBox(height: 14),
              _buildMapPreview(),
              const SizedBox(height: 16),
              _buildOrbitButton(),
              const SizedBox(height: 30),
              _buildSectionHeader('More Patterns', CupertinoIcons.square_grid_2x2),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildExploreCard(
                      'Winds',
                      CupertinoIcons.wind,
                      _electricBlue,
                      'Global Wind Systems',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExploreCard(
                      'Currents',
                      CupertinoIcons.waveform,
                      _goldAccent,
                      'Ocean Currents',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatus(Color statusColor, bool connected) {
    return Row(
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.4, end: 1.0).animate(_pulseController),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          connected ? 'RIG CONNECTED' : 'CONNECT IN SETTINGS',
          style: GoogleFonts.outfit(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildVisualizationAction({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required FutureOr<void> Function() onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.22),
            blurRadius: 28,
            spreadRadius: -8,
          ),
        ],
      ),
      child: GlassCard(
        onTap: isLoading
            ? null
            : () {
                onTap();
              },
        padding: const EdgeInsets.all(22),
        borderRadius: 24,
        borderColor: color.withOpacity(0.28),
        backgroundColor: Colors.white.withOpacity(0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withOpacity(0.25)),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const Spacer(),
                isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CupertinoActivityIndicator(color: Colors.white),
                      )
                    : const Icon(
                        CupertinoIcons.arrow_right_circle_fill,
                        color: Colors.white,
                        size: 28,
                      ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.outfit(
                color: Colors.white.withOpacity(0.58),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required Color color,
    required FutureOr<void> Function() onTap,
    bool isLoading = false,
  }) {
    return GlassCard(
      onTap: isLoading
          ? null
          : () {
              onTap();
            },
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      borderRadius: 18,
      borderColor: color.withOpacity(0.22),
      backgroundColor: Colors.white.withOpacity(0.035),
      child: Row(
        children: [
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CupertinoActivityIndicator(color: Colors.white),
                )
              : Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.62),
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview() {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 22,
      borderColor: _cyanWhite.withOpacity(0.1),
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _lastTarget,
                  zoom: _lastZoom,
                ),
                onMapCreated: (controller) => _mapController = controller,
                onCameraMove: (position) {
                  _lastTarget = position.target;
                  _lastZoom = position.zoom;
                  _lastTilt = position.tilt;
                  _lastBearing = position.bearing;
                  _syncToLG();
                },
                mapType: MapType.satellite,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.62),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: _neonGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Drag to fly',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_electricBlue, _neonGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _electricBlue.withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 15),
        onPressed: () async {
          await ssh.buildOrbit();
          _showFeedback('Orbit command sent', true);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              'Orbit Current View',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreCard(
    String title,
    IconData icon,
    Color color,
    String categoryName,
  ) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryName: categoryName,
            ),
          ),
        );
      },
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      borderColor: color.withOpacity(0.22),
      backgroundColor: Colors.white.withOpacity(0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 18),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Open',
            style: GoogleFonts.outfit(
              color: color.withOpacity(0.72),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
