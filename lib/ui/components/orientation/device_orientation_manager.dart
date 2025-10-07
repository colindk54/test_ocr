import 'package:flutter/material.dart';
import 'package:test_ocr/ui/components/orientation/device_orientation_builder.dart';

class DeviceOrientationManager extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const DeviceOrientationManager({
    super.key,
    required this.children,
    this.spacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return DeviceOrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        if (orientation == Orientation.landscape) {
          return Row(spacing: spacing, children: children);
        }
        return Column(spacing: spacing, children: children);
      },
    );
  }
}
