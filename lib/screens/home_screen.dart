// ignore_for_file: library_private_types_in_public_api, prefer_final_fields

import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //Variablen
  int _counter = 0;
  int _dailyGoal = 10000;

  //Erhöhen der Schritte (manuell)
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  //Schritte-Fortschritt in Prozent
  double getProgess() {
    return _counter / _dailyGoal;
  }

  @override
  Widget build(BuildContext context) {

    //Benutzeroberfläche Home Screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schrittzähler')
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            const Text('Deine Schrittzahl heute:'),
            const SizedBox(height: 20),

            //Fortschrittsanzeige
            Stack(
              alignment: Alignment.center,
              children: [

                //Fortschrissbalken bzw. Kreis
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    value: getProgess(),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    strokeWidth: 15,
                  ),
                ),

                //Akutelle Schritte
                Text(
                  '$_counter Schritte',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            //Fortschrittsanzeige in Prozent
            Text(
              '${(_counter / _dailyGoal * 100).toStringAsFixed(1)} % des Ziels erreicht.',
              style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
          ],
        ),
      ),

      //Button zum Hinzufügen von Schritten
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),

      //Navigationsbar (Profil, Statistik, Einstellungen)
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Statistik'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }
        },
      ),
    );
  }
}