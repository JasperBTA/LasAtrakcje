import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/geofence_service.dart';
import '../services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart' as package_shorebird;
import 'attractions_screen.dart';
import 'surveyor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isPinLogin = true;
  String _version = "1.0.0";

  @override
  void initState() {
    super.initState();
    _initVersionInfo();
    UpdateService().checkForUpdates(context);
  }

  Future<void> _initVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    String baseVersion = info.version;
    String patchDisplay = "";
    
    try {
      final shorebird = package_shorebird.ShorebirdUpdater();
      final patch = await shorebird.readCurrentPatch();
      if (patch != null) {
        patchDisplay = " SP `${patch.number}";
      }
    } catch (e) {}

    setState(() {
      _version = "$baseVersion$patchDisplay";
    });
  }

  void _login() async {
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    String? errorMessage;
    if (_isPinLogin) {
      if (_pinController.text.trim().isEmpty) {
        errorMessage = "Wprowadź kod PIN";
      } else {
        errorMessage = await authService.loginWithPin(_pinController.text.trim());
      }
    } else {
      if (_usernameController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        errorMessage = "Wprowadź nazwę użytkownika i hasło";
      } else {
        errorMessage = await authService.login(
          _usernameController.text.trim(), 
          _passwordController.text.trim()
        );
      }
    }

    setState(() => _isLoading = false);

    if (errorMessage == null && mounted) {
      if (authService.isSurveyor) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SurveyorScreen()),
        );
      } else {
        final geofenceService = Provider.of<GeofenceService>(context, listen: false);
        geofenceService.startGeofencing();
        
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (_) => const AttractionsScreen())
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? 'Nieznany błąd logowania')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jeśli jeszcze nie dodano pliku
                    return const Icon(Icons.park, size: 120, color: Color(0xFF2E8B57));
                  },
                ),
                const SizedBox(height: 48),
                const SizedBox(height: 16),
                
                // Przełącznik logowania (Checkbox)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isPinLogin,
                      onChanged: (bool? value) {
                        setState(() {
                          _isPinLogin = value ?? true;
                        });
                      },
                      activeColor: const Color(0xFF2E8B57),
                    ),
                    const Text(
                      'Logowanie wyłącznie PIN-em',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                if (_isPinLogin) ...[
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    onChanged: (val) {
                      if (val.length == 4) {
                        FocusScope.of(context).unfocus(); // Chowa klawiaturę
                        _login();
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Twój kod PIN',
                      prefixIcon: Icon(Icons.dialpad, color: Color(0xFF2E8B57)),
                      counterText: '', // Ukrywa licznik znaków pod spodem
                    ),
                    obscureText: true,
                  ),
                ] else ...[
                  TextField(
                    key: const Key('username_field'),
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nazwa użytkownika',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF2E8B57)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    key: const Key('password_field'),
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Hasło',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF2E8B57)),
                    ),
                    obscureText: true,
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text('Zaloguj się', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Wersja $_version | Developed by KO',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
