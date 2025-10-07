import 'package:flutter/material.dart';

class DeviceOrientationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation) builder;
  const DeviceOrientationBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return builder(context, orientation);
  }
}
