import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

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

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
      ),
      body: ListView.builder(
        itemCount: 30, // Anzahl der Listenelemente, z. B. für 30 Tage
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.directions_walk, color: Colors.deepPurple),
            title: Text('Tag ${index + 1}'),
            subtitle: Text('Schritte: ${index * 1000 + 500}'), // Beispielwert
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

