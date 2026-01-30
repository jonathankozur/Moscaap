import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app/path_planner.dart';

void main() {
  group('PathPlanner Tests', () {
    test('generateZigzagPath should return a path within the bounding box', () {
      final polygon = [
        const LatLng(0.0, 0.0),
        const LatLng(0.0, 0.001),
        const LatLng(0.001, 0.001),
        const LatLng(0.001, 0.0),
      ];

      final path = PathPlanner.generateZigzagPath(polygon, 20.0);

      expect(path, isNotEmpty);
      for (var point in path) {
        // Allow a small margin for bounding box due to latStep/2 offset
        expect(point.latitude, greaterThanOrEqualTo(-0.0001));
        expect(point.latitude, lessThanOrEqualTo(0.0011));
        expect(point.longitude, greaterThanOrEqualTo(-0.0001));
        expect(point.longitude, lessThanOrEqualTo(0.0011));
      }
    });

    test('generateReleasePoints should generate points at roughly the correct intervals', () {
      // 0.001 degrees latitude is ~111.32 meters
      final path = [
        const LatLng(0.0, 0.0),
        const LatLng(0.001, 0.0),
      ];

      final points = PathPlanner.generateReleasePoints(path, 50.0);

      // Should have points at 0m, 50m, 100m. (111m total)
      expect(points.length, equals(3));

      // Check first point
      expect(points[0].latitude, closeTo(0.0, 0.000001));

      // Check last point (at 100m)
      // 100m / 111320m/deg = 0.000898 deg
      expect(points[2].latitude, closeTo(0.000898, 0.00001));
    });
  });
}
