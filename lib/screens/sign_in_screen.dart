import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;
  String _errorMessage = '';

  Future<void> _saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<void> _signInWithEmailPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim()
        );

        final user = userCredential.user;
        final displayName = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim() : user?.email?.split('@') [0] ?? 'Gast';

        await _saveUserName(displayName);

        print ('Erfolgreich angemeldet: ${userCredential.user?.email}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

    } catch (e) {
      print('Fehler bei Anmeldung: $e');
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text('Fehler'),
          content: Text('Fehler bei der Anmeldung: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ok'),
            ),
          ],
        ),
        );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _registerWithEmailPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        );

        final user = userCredential.user;
        final displayName = user?.email?.split('@') [0] ?? 'Gast';

        await _saveUserName(displayName);

        print('Erfolgreich registriert: ${userCredential.user?.email}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
    
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler bei der Registrierung: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Anmelden oder Registrieren"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        },
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),

            const SizedBox(height: 20),

            if(_errorMessage.isNotEmpty)
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
            ),

            if(_isLoading)
              const CircularProgressIndicator()
            else...[
            ElevatedButton(
              onPressed: _isRegistering
                ? _registerWithEmailPassword
                : _signInWithEmailPassword,
              child: Text(_isRegistering ? 'Registrierung' : 'Anmelden'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                });
              },
              child: Text(
                _isRegistering
                  ? 'Bereits registriert ? Hier anmelden'
                  : 'Noch keinen Account ? Hier registrieren',
              ),
            ),
          ],
        ],
      ),
    ),
  );
  }
}
