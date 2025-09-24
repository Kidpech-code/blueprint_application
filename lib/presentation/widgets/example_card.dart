import 'package:flutter/material.dart';

class ExampleCard extends StatelessWidget {
  final String name;
  const ExampleCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(name, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
