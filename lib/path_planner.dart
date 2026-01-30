import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class PathPlanner {
  /// Generates a zigzag path that covers the given polygon.
  /// [polygonPoints] is the list of vertices of the polygon.
  /// [laneSpacing] is the distance between parallel lines in meters.
  static List<LatLng> generateZigzagPath(
      List<LatLng> polygonPoints, double laneSpacing) {
    if (polygonPoints.length < 3) return [];

    // 1. Find bounding box
    double minLat = polygonPoints[0].latitude;
    double maxLat = polygonPoints[0].latitude;
    double minLng = polygonPoints[0].longitude;
    double maxLng = polygonPoints[0].longitude;

    for (var p in polygonPoints) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    // 2. Convert lane spacing from meters to degrees latitude (approximate)
    // 1 degree lat approx 111,320 meters
    final double latStep = laneSpacing / 111320.0;

    List<List<LatLng>> lines = [];

    // 3. Generate horizontal sweeps
    for (double lat = minLat + latStep / 2; lat <= maxLat; lat += latStep) {
      List<double> intersections = [];

      // Find intersections of line Y = lat with polygon edges
      for (int i = 0; i < polygonPoints.length; i++) {
        final p1 = polygonPoints[i];
        final p2 = polygonPoints[(i + 1) % polygonPoints.length];

        if ((p1.latitude < lat && p2.latitude >= lat) ||
            (p2.latitude < lat && p1.latitude >= lat)) {
          final lng = p1.longitude +
              (lat - p1.latitude) *
                  (p2.longitude - p1.longitude) /
                  (p2.latitude - p1.latitude);
          intersections.add(lng);
        }
      }

      intersections.sort();

      if (intersections.isNotEmpty) {
        List<LatLng> linePoints = [];
        // Group intersections into segments (inside the polygon)
        for (int i = 0; i < intersections.length - 1; i += 2) {
          linePoints.add(LatLng(lat, intersections[i]));
          linePoints.add(LatLng(lat, intersections[i + 1]));
        }
        if (linePoints.isNotEmpty) {
          lines.add(linePoints);
        }
      }
    }

    // 4. Connect lines in zigzag
    List<LatLng> fullPath = [];
    bool reverse = false;
    for (var line in lines) {
      if (reverse) {
        fullPath.addAll(line.reversed);
      } else {
        fullPath.addAll(line);
      }
      reverse = !reverse;
    }

    return fullPath;
  }

  /// Generates release points along the path every [interval] meters.
  static List<LatLng> generateReleasePoints(List<LatLng> path, double interval) {
    if (path.isEmpty) return [];

    List<LatLng> result = [];
    // The first point of the path is the first release point
    result.add(path[0]);

    double distanceToNextPoint = interval;

    for (int i = 0; i < path.length - 1; i++) {
      final p1 = mp.LatLng(path[i].latitude, path[i].longitude);
      final p2 = mp.LatLng(path[i + 1].latitude, path[i + 1].longitude);
      double segmentDist =
          mp.SphericalUtil.computeDistanceBetween(p1, p2).toDouble();

      double currentPosInSegment = 0;

      // Place as many points as fit in the current segment
      while (currentPosInSegment + distanceToNextPoint <= segmentDist) {
        currentPosInSegment += distanceToNextPoint;
        final interpolated = mp.SphericalUtil.interpolate(
            p1, p2, currentPosInSegment / segmentDist);
        result.add(LatLng(interpolated.latitude, interpolated.longitude));
        distanceToNextPoint = interval;
      }

      // Carry over the remaining distance to the next segment
      distanceToNextPoint -= (segmentDist - currentPosInSegment);
    }

    return result;
  }
}
