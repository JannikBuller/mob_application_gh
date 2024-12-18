import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Map<String, dynamic>> _stepsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStepsFromFirestore();
  }

Future<void> _loadStepsFromFirestore() async {
  try {
    if(FirebaseAuth.instance.currentUser != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance 
        .collection('users')
        .doc(userId)
        .get();

      if (userDoc.exists) {
        List<dynamic> stepsData = userDoc['steps'] ?? [];

        setState(() {
          _stepsList = stepsData.map((entry) {
            String dateString = entry['date'];
            DateTime date = DateTime.parse(dateString);
            return {
              'date' : date,
              'stepCount' : entry['stepCount'],
            };
          }).toList();
          _stepsList.sort((a, b) => b['date'].compareTo(a['date']));
        });
       }
      }
    } catch (e) {
      print('Fehler beim laden der Schritte: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _stepsList.isEmpty
          ? const Center(child: Text('Keine Daten abrufbar.'))
          : ListView.builder(
              itemCount: _stepsList.length,
              itemBuilder: (context, index) {
                var entry = _stepsList[index];
                String formattedDate = 
                  '${entry['date'].day}.${entry['date'].month}.${entry['date'].year}';
                int steps = entry['stepCount'];

                return ListTile(
                  leading: const Icon(Icons.directions_walk, color: Colors.deepPurple),
                  title: Text('Datum: $formattedDate'),
                  subtitle: Text('Schritte: $steps'),
                );
              },
          ),
    );
  } 
}
