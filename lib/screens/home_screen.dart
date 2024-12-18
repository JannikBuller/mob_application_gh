// ignore_for_file: library_private_types_in_public_api, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //Variablen
  int _counter = 0;
  int _dailyGoal = 10000;
  bool _isUserLoggedIn = false;
  int _sensorSteps = 0;

  @override initState() {
    super.initState();
    _loadStepsFromFirestore();
    _initStepCounter();
    _checkUserStatus();
  }

void _loadStepsFromFirestore() async {
  if(FirebaseAuth.instance.currentUser != null) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month}-${now.day}';

    try {
      DocumentSnapshot docSnapshot = await userDoc.get();
      List<dynamic> stepsList = docSnapshot.exists ? (docSnapshot['steps'] ?? []) : [];
      bool isNewDay = true;

      for (var stepEntry in stepsList) {
        if (stepEntry['date'] == today) {
          setState(() {
            _counter = stepEntry['stepCount'];
          });
          isNewDay = false;
          break;
        }
      }
    if (isNewDay) {
      setState(() {
        _counter = 0;
        _sensorSteps = 0;
      });
      _saveStepsToFirestore();
    }
    } catch(e) {
      print('Fehler beim Laden der Schritte: $e');
    }
  }
}

void _saveStepsToFirestore() async {
  if (FirebaseAuth.instance.currentUser != null) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    
    DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    DateTime now = DateTime.now();
    String today = '${now.year}-${now.month}-${now.day}'; 

    try {
      
      DocumentSnapshot docSnapshot = await userDoc.get();
      List<dynamic> stepsList = docSnapshot.exists ? (docSnapshot['steps'] ?? []) : [];

      bool found = false;

      
      for (var stepEntry in stepsList) {
        if (stepEntry['date'] == today) {
          stepEntry['stepCount'] = (_counter + _sensorSteps);
          found = true;
          break;
        }
      }

      if (!found) {
        stepsList.add({
          'date': today,
          'stepCount': _counter + _sensorSteps,
        });
      }

      
      await userDoc.set({'steps': stepsList}, SetOptions(merge: true));
    } catch (e) {
      print('Fehler beim Speichern der Schritte: $e');
    }
  }
}
  
  //Stream für Schrittzähler
  late Stream<StepCount> _stepCountStream;

  void _initStepCounter() {
    _stepCountStream = Pedometer.stepCountStream;
    
    _stepCountStream.listen(
    (StepCount event) {
      setState(() {
        _sensorSteps = event.steps;
        _saveStepsToFirestore();
      });
    },
  );
  }

  //Erhöhen der Schritte (manuell)
  void _incrementCounter() {
    setState(() {
      _counter++;
      _saveStepsToFirestore();
    });
  }

  //Schritte-Fortschritt in Prozent
  double getProgess() {
    return (_counter + _sensorSteps) / _dailyGoal;
  }

  void _checkUserStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isUserLoggedIn = user != null;
    });
  }

  Future<bool> _logoutConfirmation(BuildContext context) async {
    return await showDialog(context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: const Text("Abmelden"),
              content: const Text("Möchten Sie sich wirklich Abmelden?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text("Abbrechen"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Abmelden"),
                ),
              ],
            );
          },
    ) ??
    false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkUserStatus();
  }

  @override
  Widget build(BuildContext context) {

    //Benutzeroberfläche Home Screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schrittzähler'),
        actions: [
          if(_isUserLoggedIn)
            Tooltip(
              message: 'Abmelden',
              child: IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async{
                  final confirmLogout = await _logoutConfirmation(context);
                  if (confirmLogout) {
                  await FirebaseAuth.instance.signOut();
                  _checkUserStatus();
                  }
              },
              ),
            ),
          if(!_isUserLoggedIn)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                ).then((_) {
                  _checkUserStatus();
                });
              },
            ),
        ],
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
                  '${_counter + (_sensorSteps)} Schritte',
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
              '${((_counter + _sensorSteps )/ _dailyGoal * 100).toStringAsFixed(1)} % des Ziels erreicht.',
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
          if(_isUserLoggedIn) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }
        } else {
          showDialog(
            context: context,
            builder:(BuildContext context) {
              return AlertDialog(
                title: const Text("Bitte Anmelden"),
                content: const Text("Um auf diese Funktion zuzugreifen, bitte anmelden"),
                actions: <Widget>[
                  TextButton (
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Ok"),
                  ),
                ],
              );
            },
          );
        }
      },
    ),
  );
}
}