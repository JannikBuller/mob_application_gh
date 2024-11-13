import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    //Aktuelles Datum für die Statistik
    final DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: ListView.builder(
        itemCount: 30,
        itemBuilder: (context, index) {

          //Datum für jeden Eintrag berechnen
          DateTime currentDate = today.subtract(Duration(days: index));
          String formattedDate = '${currentDate.day}.${currentDate.month}.${currentDate.year}';

          //Zeigt jeden Tag mit einem Beispielwert an
          return ListTile(
            leading: const Icon(Icons.directions_walk, color: Colors.deepPurple),
            title: Text(formattedDate), //Datum
            subtitle: const Text('Schritte: 0'), //Platzhalter Schritte
          );
        },
      ),
    );
  }
}
