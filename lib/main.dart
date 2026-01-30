import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'path_planner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zonas de Liberación',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Asegúrate de configurar tus API Keys de Google Maps en Android, iOS y Web.'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  final List<LatLng> _polygonPoints = [];
  List<LatLng> _zigzagPath = [];
  List<LatLng> _releasePoints = [];

  // Parámetros configurables
  final double _laneSpacing = 20.0; // metros entre líneas de zigzag
  final double _releaseInterval = 10.0; // metros entre puntos de liberación

  void _onTap(LatLng point) {
    setState(() {
      // Si ya hay una ruta generada, limpiar para empezar de nuevo
      if (_zigzagPath.isNotEmpty) {
        _clear();
      }
      _polygonPoints.add(point);
    });
  }

  void _generateRoute() {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Define al menos 3 puntos para el polígono')),
      );
      return;
    }

    final path = PathPlanner.generateZigzagPath(_polygonPoints, _laneSpacing);
    final points = PathPlanner.generateReleasePoints(path, _releaseInterval);

    setState(() {
      _zigzagPath = path;
      _releasePoints = points;
    });
  }

  void _clear() {
    setState(() {
      _polygonPoints.clear();
      _zigzagPath.clear();
      _releasePoints.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificador de Ruta Zigzag'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _clear,
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Limpiar mapa',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-34.6037, -58.3816), // Buenos Aires
              zoom: 17,
            ),
            onTap: _onTap,
            polygons: {
              if (_polygonPoints.isNotEmpty)
                Polygon(
                  polygonId: const PolygonId('release_zone'),
                  points: _polygonPoints,
                  fillColor: Colors.blue.withOpacity(0.2),
                  strokeColor: Colors.blue,
                  strokeWidth: 2,
                ),
            },
            polylines: {
              if (_zigzagPath.isNotEmpty)
                Polyline(
                  polylineId: const PolylineId('zigzag_path'),
                  points: _zigzagPath,
                  color: Colors.orange,
                  width: 3,
                ),
            },
            markers: _releasePoints.asMap().entries.map((entry) {
              return Marker(
                markerId: MarkerId('point_${entry.key}'),
                position: entry.value,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  entry.key == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
                ),
                infoWindow: InfoWindow(title: 'Punto de liberación ${entry.key}'),
              );
            }).toSet(),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Vértices: ${_polygonPoints.length} | Puntos de liberación: ${_releasePoints.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _polygonPoints.length >= 3 ? _generateRoute : null,
                          icon: const Icon(Icons.route),
                          label: const Text('Generar Ruta'),
                        ),
                        OutlinedButton(
                          onPressed: _polygonPoints.isNotEmpty ? _clear : null,
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_polygonPoints.isEmpty)
            const Center(
              child: Card(
                color: Colors.black54,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Toca el mapa para dibujar el área',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
