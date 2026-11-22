import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_offline_gps/core/routing/offline_road_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('OfflineRoadRouter calculates valid road route across Central India', () async {
    final router = OfflineRoadRouter();
    await router.loadRoadNetwork();

    // Route from Bhopal Center to Indore Center
    const start = LatLng(23.2599, 77.4126);
    const end = LatLng(22.7196, 75.8577);

    final result = await router.calculateRoute(start, end);

    expect(result['distanceKm'], isA<double>());
    expect(result['distanceKm'], greaterThan(150.0));
    expect(result['distanceKm'], lessThan(250.0));

    expect(result['durationMins'], isA<int>());
    expect(result['durationMins'], greaterThan(100));

    final waypoints = result['waypoints'] as List<LatLng>;
    expect(waypoints.length, greaterThan(20)); // Dense curve coordinates

    // Route within Bhopal (MP Nagar to Airport)
    const mpNagar = LatLng(23.2332, 77.4343);
    const airport = LatLng(23.2875, 77.3378);

    final cityResult = await router.calculateRoute(mpNagar, airport);
    expect(cityResult['distanceKm'], greaterThan(10.0));
    expect(cityResult['distanceKm'], lessThan(30.0));
    final cityWaypoints = cityResult['waypoints'] as List<LatLng>;
    expect(cityWaypoints.length, greaterThan(10));
  });
}
