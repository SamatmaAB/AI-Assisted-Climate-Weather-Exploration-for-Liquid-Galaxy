import 'package:flutter/material.dart';
import 'package:lg_connection/core/common_widgets/status_badge.dart';
import 'package:lg_connection/features/city_explorer/city_explorer_viewmodel.dart';
import 'package:lg_connection/services/tts/widgets/tts_playback_bar.dart';

class CityExplorerScreen extends StatefulWidget {
  const CityExplorerScreen({super.key});

  @override
  State<CityExplorerScreen> createState() => _CityExplorerScreenState();
}

class _CityExplorerScreenState extends State<CityExplorerScreen> {
  late final CityExplorerViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const List<String> _popularCities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Kolkata', 'Chennai', 'Hyderabad', 'Ahmedabad', 'Pune',
    'London', 'Paris', 'New York', 'Tokyo', 'Sydney', 'Cairo', 'Rio de Janeiro',
    'Beijing', 'Berlin', 'Rome', 'Dubai', 'Singapore', 'Toronto', 'Los Angeles',
    'Buenos Aires', 'Cape Town', 'Bangkok', 'Seoul', 'Istanbul', 'Moscow',
    'Mexico City', 'Sao Paulo', 'Madrid', 'Amsterdam', 'Vienna', 'Chicago',
    'San Francisco', 'Miami', 'Washington D.C.', 'Boston', 'Seattle', 'Melbourne',
    'Auckland', 'Dublin', 'Lisbon', 'Munich', 'Milan', 'Zurich', 'Oslo', 'Stockholm',
    'Copenhagen', 'Helsinki', 'Athens', 'Jakarta', 'Manila', 'Hong Kong', 'Shanghai',
    'Vancouver', 'Montreal', 'Kyoto',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = CityExplorerViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    _focusNode.unfocus();
    _viewModel.exploreCity(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'City',
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'Explorer',
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: _viewModel.isConnected,
                        builder: (_, connected, __) =>
                            StatusBadge(isConnected: connected),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Search a city to fly to its landmark and explore the local weather.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildSearchBar(context),

                const SizedBox(height: 24),

                Expanded(child: _buildBody(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.trim().isEmpty) {
                  return const Iterable<String>.empty();
                }
                final query = textEditingValue.text.toLowerCase();
                return _popularCities.where((city) => city.toLowerCase().contains(query));
              },
              onSelected: (String selection) {
                _searchController.text = selection;
                _onSearch();
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                if (_searchController.text != controller.text && _searchController.text.isNotEmpty) {
                  controller.text = _searchController.text;
                }
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    _searchController.text = value;
                    onFieldSubmitted();
                    _onSearch();
                  },
                  enabled: _viewModel.status != CityExplorerStatus.loading,
                  decoration: InputDecoration(
                    hintText: 'e.g. Mumbai, Paris, Tokyo…',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    suffixIcon: controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.clear();
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    _searchController.text = val;
                    setState(() {});
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerHigh,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 108,
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (_, __) => Divider(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            leading: Icon(Icons.location_on_outlined, size: 18, color: colorScheme.primary),
                            title: Text(option, style: Theme.of(context).textTheme.bodyMedium),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _viewModel.status == CityExplorerStatus.loading ? null : _onSearch,
            style: FilledButton.styleFrom(
              minimumSize: const Size(56, 56),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _viewModel.status == CityExplorerStatus.loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.travel_explore),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_viewModel.status) {
      case CityExplorerStatus.idle:
        return _buildIdleState(context);
      case CityExplorerStatus.loading:
        return _buildLoadingState(context);
      case CityExplorerStatus.error:
        return _buildErrorState(context);
      case CityExplorerStatus.success:
        return _buildSuccessState(context);
    }
  }

  Widget _buildIdleState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.travel_explore,
            size: 72,
            color: colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Enter a city to begin exploration',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Liquid Galaxy will fly to an iconic landmark\nand show live weather around it.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.38),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Resolving landmark…',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Flying to the landmark and fetching live weather',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              _viewModel.errorMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _onSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final landmark = _viewModel.landmark;
    final weather = _viewModel.weather;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.place, color: colorScheme.onPrimaryContainer),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        landmark?.landmark ?? '—',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        landmark?.city ?? '—',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (landmark?.climateContext.isNotEmpty ?? false)
                        Chip(
                          label: Text(landmark!.climateContext),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        if (weather != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weather',
                    style: textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°C',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        weather.condition,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _weatherDetail(context, Icons.water_drop_outlined, '${weather.humidity}%'),
                      _weatherDetail(context, Icons.air, '${weather.windSpeed.toStringAsFixed(0)} km/h'),
                      _weatherDetail(context, Icons.grain, '${weather.precipitation.toStringAsFixed(1)} mm'),
                    ],
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        if (_viewModel.narration.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Climate Insight',
                        style: textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      TtsPlaybackBar(
                        text: _viewModel.narration,
                        compact: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _viewModel.narration,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 12),

        FilledButton.icon(
          onPressed: () async {
            await _viewModel.toggleOrbit();
          },
          icon: Icon(_viewModel.isOrbiting
              ? Icons.stop_circle_outlined
              : Icons.rotate_90_degrees_ccw_outlined),
          label: Text(_viewModel.isOrbiting ? 'Stop Orbit' : 'Orbit View'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            backgroundColor: _viewModel.isOrbiting
                ? colorScheme.errorContainer
                : colorScheme.primary,
            foregroundColor: _viewModel.isOrbiting
                ? colorScheme.onErrorContainer
                : colorScheme.onPrimary,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _weatherDetail(BuildContext context, IconData icon, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        Text(
          value,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
