import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schrittzähler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Schrittzähler'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _dailyGoal = 50;
  int _selectedIndex = 0; // Hält den aktuellen Tab-Index

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;


  void onStepCount(StepCount event) {
    setState(() {
      _counter = event.steps;
    });
  }

  void onStepCountError(error){
    print('Step Count Error: $error');
  }

  Future<void> initPlatformState() async {
    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream.listen(onPedestrianStatusChanged).onError(onPedestrianStatusError);
  }

  @override 
  void initState() {
    super.initState();
    initPlatformState();
  }

  double getProgress(){
    return _counter / _dailyGoal;
  }
  void onPedestrianStatusChanged(PedestrianStatus event){
    print('Pedestrian Status: ${event.status}');
  }

  void onPedestrianStatusError(error){
    print('Pedestrain Status Error: $error');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // Funktion zum Aktualisieren des Tab-Index
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SecondScreen()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StatisticsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Deine Schrittzahl heute: '),
            const SizedBox(height:20),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height:200,
                  width: 200,
                  child: CircularProgressIndicator(
                    value: getProgress(),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    strokeWidth: 15,
                  ),  
                ),
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
            Text(
              '${(_counter / _dailyGoal * 100).toStringAsFixed(1)} % des Ziels erreicht!',
              style: TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),/* Hier eine Lineare Progressbar
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: getProgess(),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),*//*
            const SizedBox(height: 20),

            // Text mit dem Fortschritt
            Text(
              '${(_counter / _dailyGoal * 100).toStringAsFixed(1)}% des Ziels erreicht!',
              style: TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),     */     
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, 
          tooltip: 'Increment',
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
         
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Statistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
        onTap: _onTabTapped,
      ),
      drawer: const Drawer(),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String _weight = '';
  String _height = '';


  @override
  void initState() {
    super.initState();
    _loadProfilData();
  }

  Future<void> _loadProfilData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weight = prefs.getString('weight') ?? 'Nicht gesetzt';
      _height = prefs.getString('height') ?? 'Nicht gesetzt';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dein Profil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Willkommen auf deinem Profil!',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Gewicht: $_weight kg',
              style: TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
            const SizedBox(height: 10),
            Text(
              'Größe: $_height cm',
              style: TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilSettingsScreen(),
                  ),
                ).then((_) => _loadProfilData());
              },
              child: const Text('Profil bearbeiten'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Zurück zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

//Screen für Statistik mit ListView
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: ListView.builder(
        itemCount: 30, // Anzahl der Listenelemente, z. B. für 30 Tage
        itemBuilder: (context, index) {
          DateTime currentDate = today.subtract(Duration(days: index));
          String formattedDate = DateFormat('dd.MM.yyyy').format(currentDate);

          return ListTile(
            leading: const Icon(Icons.directions_walk, color: Colors.deepPurple),
            title: Text(formattedDate),
            subtitle: Text('Schritte: '), // Beispielwert
          );
        },
      ),
    );
  }
}


//Screen für Statistik mit Gridview
/*class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
     body: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Anzahl der Spalten im Raster
        childAspectRatio: 2.5, // Verhältnis für die Größe der Zellen
        ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8),
          child: Center(
          child: Text(
            'Tag ${index + 1}\nSchritte: ${index * 1000 + 500}',
            textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}  */

// Neuer Screen für Einstellungen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Willkommen in den Einstellungen!',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Zurück zur Startseite'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilSettingsScreen extends StatefulWidget {
  const ProfilSettingsScreen({super.key});

  @override
  _ProfilSettingsScreenState createState() => _ProfilSettingsScreenState();
}

class _ProfilSettingsScreenState extends State<ProfilSettingsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();


  @override
   void initState(){
    super.initState();
    _loadProfilData();
   }

  Future<void> _loadProfilData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weightController.text = prefs.getString('weight') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
    });
  }

  Future <void> _saveProfilData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('height', _heightController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  //Mögliche Bildauswahl ?
                },
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/default_profile.jpg'),
                  child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Gewicht (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Größe (cm)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveProfilData();
                Navigator.pop(context);
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}

