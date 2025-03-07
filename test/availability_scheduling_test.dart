import 'package:flutter_test/flutter_test.dart';
import 'package:availability_scheduling/availability_scheduling.dart';
import 'package:availability_scheduling/availability_scheduling_platform_interface.dart';
import 'package:availability_scheduling/availability_scheduling_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAvailabilitySchedulingPlatform
    with MockPlatformInterfaceMixin
    implements AvailabilitySchedulingPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AvailabilitySchedulingPlatform initialPlatform =
      AvailabilitySchedulingPlatform.instance;

  test('$MethodChannelAvailabilityScheduling is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelAvailabilityScheduling>());
  });

  test('getPlatformVersion', () async {
    AvailabilityScheduling availabilitySchedulingPlugin =
        AvailabilityScheduling();
    MockAvailabilitySchedulingPlatform fakePlatform =
        MockAvailabilitySchedulingPlatform();
    AvailabilitySchedulingPlatform.instance = fakePlatform;

    expect(await availabilitySchedulingPlugin.getPlatformVersion(), '42');
  });
}
