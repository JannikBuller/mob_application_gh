import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //Variablen
  String _weight = '';
  String _height = '';

  //Textcontroller für die Eingabefelder
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  //Lädt Benutzerinformationen aus SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weight = prefs.getString('weight') ?? 'Nicht gesetzt';
      _height = prefs.getString('height') ?? 'Nicht gesetzt';
    });
  }

  //Speichert Benutzerinformationen in SharedPreferences
  Future<void> _saveProfilData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('height', _heightController.text);
    await _loadProfileData();
  }

  //Öffnet Dialog, wo Benutzer Größe & Gewicht eingibt
  void _showEditDialog() {
    _weightController.text = _weight == 'Nicht gesetzt' ? '' : _weight;
    _heightController.text = _height == 'Nicht gesetzt' ? '' : _height;

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text('Profil bearbeiten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              //Eingabefeld - Gewicht
              TextField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Gewicht  (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

                //Eingabefeld - Größe
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Größe  (cm)',
                    border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [

            //Abbrechen Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')
            ),

            //Speichern Button
            TextButton(
              onPressed: () async {
                await _saveProfilData();
                Navigator.pop(context);
              },
              child: const Text('Speichern')
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    //Benutzeroberfläche Bildschirm
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Wilkommen auf deinem Profil!',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            Text(
              'Gewicht: $_weight kg',
              style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            
            Text(
              'Größe: $_height cm',
              style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            
            //Button - Profil bearbeiten
            ElevatedButton(
              onPressed: _showEditDialog, 
              child: const Text('Profil bearbeiten'),
            ),
          ],
        ),
      )
    );
  }
}