import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:js_util' as js_util;
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'dart:ui_web' as ui_web;
import '../providers/agent_provider.dart';
import '../models/agent_data.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selectedAgentId;
  final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  bool _mapLoaded = false;
  static const String _viewType = 'map-host';

  @override
  void initState() {
    super.initState();
    // Register the view factory
    if (kIsWeb) {
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        final mapContainer = html.DivElement()
          ..id = 'map-container'
          ..style.width = '100%'
          ..style.height = '100%';
        return mapContainer;
      });
    }
    _loadGoogleMapsScript();
  }

  void _loadGoogleMapsScript() {
    if (!kIsWeb) return;

    // Check if script is already loaded
    if (html.document.querySelector('script[src*="maps.googleapis.com"]') !=
        null) {
      _initializeMap();
      return;
    }

    // Define the initMap function
    js_util.setProperty(html.window, 'initMap', js_util.allowInterop(() {
      _initializeMap();
    }));

    // Create and add the script element
    final script = html.ScriptElement()
      ..src =
          'https://maps.googleapis.com/maps/api/js?key=$_apiKey&callback=initMap'
      ..async = true
      ..defer = true;
    html.document.head?.append(script);
  }

  void _initializeMap() {
    if (!kIsWeb) return;

    try {
      final mapElement = html.document.getElementById('map-container');
      if (mapElement == null) return;

      final mapOptions = js_util.jsify({
        'center': {'lat': 10.762622, 'lng': 106.660172}, // Ho Chi Minh City
        'zoom': 14,
      });

      // Wait for Google Maps to be fully loaded
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          final google = js_util.getProperty(html.window, 'google');
          if (google == null) return;

          final maps = js_util.getProperty(google, 'maps');
          if (maps == null) return;

          final mapConstructor = js_util.getProperty(maps, 'Map');
          if (mapConstructor == null) return;

          final map =
              js_util.callConstructor(mapConstructor, [mapElement, mapOptions]);
          js_util.setProperty(html.window, 'mapObject', map);

          setState(() {
            _mapLoaded = true;
          });
        } catch (e) {
          print('Error in delayed map initialization: $e');
        }
      });
    } catch (e) {
      print('Error initializing map: $e');
    }
  }

  void _addAgentMarkers(List<AgentData> agents) {
    if (!_mapLoaded || !kIsWeb) return;

    try {
      final map = js_util.getProperty(html.window, 'mapObject');
      if (map == null) return;

      final google = js_util.getProperty(html.window, 'google');
      if (google == null) return;

      final maps = js_util.getProperty(google, 'maps');
      if (maps == null) return;

      final markerConstructor = js_util.getProperty(maps, 'Marker');
      if (markerConstructor == null) return;

      for (final agent in agents) {
        if (agent.latitude == null || agent.longitude == null) continue;

        final markerOptions = js_util.jsify({
          'position': {'lat': agent.latitude, 'lng': agent.longitude},
          'map': map,
          'title': 'Agent ${agent.agentId}',
        });

        final marker =
            js_util.callConstructor(markerConstructor, [markerOptions]);

        js_util.callMethod(marker, 'addListener', [
          'click',
          js_util.allowInterop((_) {
            setState(() {
              _selectedAgentId = agent.agentId;
            });
          })
        ]);
      }
    } catch (e) {
      print('Error adding markers: $e');
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      html.document.getElementById('map-container')?.remove();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentProvider = Provider.of<AgentProvider>(context);

    if (_mapLoaded && agentProvider.agents.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _addAgentMarkers(agentProvider.agents.values.toList());
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Control Map'),
      ),
      body: Stack(
        children: [
          // Google Maps container
          Container(
            width: double.infinity,
            height: double.infinity,
            child: kIsWeb
                ? const HtmlElementView(viewType: _viewType)
                : const Center(child: Text('Maps are only supported on web')),
          ),
          // Agent details panel
          if (_selectedAgentId != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Consumer<AgentProvider>(
                  builder: (context, provider, child) {
                    final agent = provider.agents[_selectedAgentId];
                    if (agent == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Agent: ${agent.agentId}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _selectedAgentId = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Status: ${agent.status}'),
                          Text(
                              'Latest Reward: ${agent.latestReward.toStringAsFixed(2)}'),
                          Text(
                              'Queue Length: ${agent.latestQueueLength.toStringAsFixed(2)}'),
                          Text(
                              'Waiting Time: ${agent.latestWaitingTime.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
