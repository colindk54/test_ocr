import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  const LoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 25,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Text(message ?? 'Chargement en cours')
        ],
      ),
    );
  }
}
