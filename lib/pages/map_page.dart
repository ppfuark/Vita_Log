import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  LatLng? _initialCenter;
  bool _loading = true;
  String? _error;

  bool _isTracking = false;
  DateTime? _startTime;
  LatLng? _lastPosition;
  double _distanceWalked = 0.0;
  int _gpsUpdateCount = 0;

  final List<String> _debugLogs = [];
  bool _showDebug = false;

  final List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'A localização do aparelho está desligada.';
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Permissão de localização negada.';
          _loading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _initialCenter = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao obter localização: $e';
        _loading = false;
      });
    }
  }

  Future<void> _startTracking() async {
    await _positionSubscription?.cancel();
    _timer?.cancel();

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    setState(() {
      _isTracking = true;
      _startTime = DateTime.now();
      _lastPosition = null;
      _distanceWalked = 0.0;
      _gpsUpdateCount = 0;
      _routePoints.clear();
      _debugLogs.clear(); // limpa logs ao iniciar
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _isTracking) setState(() {});
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            if (!_isTracking || !mounted) return;

            if (position.speed < 0.3) return;

            final newPosition = LatLng(position.latitude, position.longitude);
            double delta = 0;

            if (_lastPosition != null) {
              delta = Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                newPosition.latitude,
                newPosition.longitude,
              );

              if (delta > 1.5 && position.accuracy < 20.0) {
                _distanceWalked += delta;
                _routePoints.add(newPosition);
              }
            } else {
              _routePoints.add(newPosition);
            }

            setState(() {
              _lastPosition = newPosition;
              _gpsUpdateCount++;
              mapController.move(newPosition, 16);

              final log =
                  '#$_gpsUpdateCount | Δ${delta.toStringAsFixed(1)}m | '
                  'prec:${position.accuracy.toStringAsFixed(0)}m | '
                  'vel:${position.speed.toStringAsFixed(1)}';

              _debugLogs.insert(0, log);
              if (_debugLogs.length > 20) _debugLogs.removeLast();
            });
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _debugLogs.insert(0, '❌ ERRO: $error');
              });
            }
          },
        );
  }

  void _stopTracking() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    setState(() => _isTracking = false);
  }

  String _formatDuration(Duration duration) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(duration.inHours)}:${two(duration.inMinutes.remainder(60))}:${two(duration.inSeconds.remainder(60))}';
  }

  String _formatDistance(double distance) {
    if (distance >= 1000) return '${(distance / 1000).toStringAsFixed(2)} km';
    return '${distance.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    final elapsed = _isTracking
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _initialCenter!,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                urlTemplate:
                    'https://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.ppfuark.vite_log',
              ),
              if (_routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blue,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              const CurrentLocationLayer(),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_isTracking ? 'Rastreando...' : 'Parado'),
                    Text('Distância: ${_formatDistance(_distanceWalked)}'),
                    Text('Tempo: ${_formatDuration(elapsed)}'),
                    ElevatedButton(
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                      child: Text(_isTracking ? 'Parar' : 'Iniciar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showDebug = !_showDebug),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black,
                    child: Text(
                      'Debug ($_gpsUpdateCount)',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                if (_showDebug)
                  Container(
                    height: 200,
                    color: Colors.black87,
                    child: ListView.builder(
                      itemCount: _debugLogs.length,
                      itemBuilder: (_, i) => Text(
                        _debugLogs[i],
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
