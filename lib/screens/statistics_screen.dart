import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: ListView.builder(
        itemCount: 30,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.directions_walk, color: Colors.deepPurple),
            title: Text('Tag ${index +1}'),
            subtitle: const Text('Schritte: 0'), //Platzhalter Wert
          );
        },
      )
    );
  }
}