import 'package:flutter_test/flutter_test.dart';
import 'package:lg_connection/models/lookat_model.dart';

void main() {
  group('LookAt Model Tests', () {
    test('LookAt.fromXml parses valid LookAt XML string correctly', () {
      const xml = '<LookAt>'
          '<longitude>78.9629</longitude>'
          '<latitude>20.5937</latitude>'
          '<altitude>0</altitude>'
          '<heading>10.0</heading>'
          '<tilt>45.0</tilt>'
          '<range>5000000</range>'
          '<gx:altitudeMode>relativeToGround</gx:altitudeMode>'
          '</LookAt>';

      final lookAt = LookAt.fromXml(xml);

      expect(lookAt.latitude, closeTo(20.5937, 0.0001));
      expect(lookAt.longitude, closeTo(78.9629, 0.0001));
      expect(lookAt.tilt, closeTo(45.0, 0.0001));
      expect(lookAt.bearing, closeTo(10.0, 0.0001));
      // Range 5000000 should convert to a valid zoom level (~7.88 - 3.8 = 4.08)
      expect(lookAt.zoom, closeTo(4.08, 0.01));
    });

    test('LookAt.toXml generates correct LookAt XML structure', () {
      const lookAt = LookAt(
        latitude: 35.0,
        longitude: 135.0,
        zoom: 4.4, // Maps to 4.4 + 3.8 = 8.2 adjusted zoom
        tilt: 30.0,
        bearing: 0.0,
      );

      final xml = lookAt.toXml();

      expect(xml, contains('<latitude>35.0</latitude>'));
      expect(xml, contains('<longitude>135.0</longitude>'));
      expect(xml, contains('<tilt>30.0</tilt>'));
      expect(xml, contains('<heading>0.0</heading>'));
      expect(xml, contains('<range>4023967.2958295336</range>'));
    });
  });
}
