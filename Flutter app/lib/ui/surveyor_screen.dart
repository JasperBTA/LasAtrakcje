import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../services/auth_service.dart';
import '../api/api_client.dart';
import 'login_screen.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SurveyorScreen extends StatefulWidget {
  const SurveyorScreen({Key? key}) : super(key: key);

  @override
  _SurveyorScreenState createState() => _SurveyorScreenState();
}

class _SurveyorScreenState extends State<SurveyorScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  
  int _rating = 5;
  String _strengths = '';
  String _improvements = '';
  int _recommendRating = 10;
  String _source = 'Od znajomych';
  String _sourceOther = '';
  String _notes = '';

  final List<String> _sourceOptions = [
    'Od znajomych',
    'Media Społecznościowe',
    'Google',
    'Inne'
  ];

  bool _isSyncing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final db = Provider.of<AppDatabase>(context, listen: false);
      final auth = Provider.of<AuthService>(context, listen: false);
      
      if (auth.userId == null) return;

      final survey = SurveysCompanion.insert(
        id: const Uuid().v4(),
        operatorId: auth.userId!,
        createdAt: DateTime.now().toUtc(),
        rating: _rating,
        strengths: _strengths,
        improvements: _improvements,
        recommendRating: _recommendRating,
        source: _source,
        sourceOther: drift.Value(_sourceOther.isEmpty ? null : _sourceOther),
        notes: drift.Value(_notes.isEmpty ? null : _notes),
        syncStatus: const drift.Value('PENDING'),
      );

      await db.into(db.surveys).insert(survey);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zapisano ankietę!'), backgroundColor: Colors.green),
      );
      
      _formKey.currentState!.reset();
      setState(() {
        _rating = 5;
        _recommendRating = 10;
        _source = 'Od znajomych';
        _sourceOther = '';
      });
      
      // Przewiń na samą górę dla kolejnego respondenta
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _syncSurveys() async {
    setState(() => _isSyncing = true);
    try {
      final db = Provider.of<AppDatabase>(context, listen: false);
      final auth = Provider.of<AuthService>(context, listen: false);
      final apiClient = ApiClient();
      
      // Jeśli jesteśmy na wirtualnym tokenie offline, spróbujmy się zalogować w tle
      if (await auth.checkLoginStatus()) {
        final currentToken = await const FlutterSecureStorage().read(key: 'jwt_token');
        if (currentToken != null && currentToken.startsWith('offline_token_')) {
          await auth.autoLoginWithSavedCredentials();
        }
      }
      
      final pendingSurveys = await (db.select(db.surveys)
        ..where((t) => t.syncStatus.equals('PENDING'))).get();

      if (pendingSurveys.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Brak ankiet do synchronizacji.')));
        setState(() => _isSyncing = false);
        return;
      }

      final List<Map<String, dynamic>> surveysData = pendingSurveys.map((s) => {
        'id': s.id,
        'operatorId': s.operatorId,
        'createdAt': s.createdAt.toUtc().toIso8601String(),
        'rating': s.rating,
        'strengths': s.strengths,
        'improvements': s.improvements,
        'recommendRating': s.recommendRating,
        'source': s.source,
        'sourceOther': s.sourceOther,
        'notes': s.notes,
      }).toList();

      final response = await apiClient.post('/surveys/sync', {'surveys': surveysData});
      
      if (response.statusCode == 200) {
        for (var s in pendingSurveys) {
          await (db.update(db.surveys)..where((t) => t.id.equals(s.id)))
            .write(const SurveysCompanion(syncStatus: drift.Value('SYNCED')));
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pomyślnie zsynchronizowano ${pendingSurveys.length} ankiet.'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('Błąd serwera');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Błąd synchronizacji. Sprawdź internet.'), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Ankietera'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: _isSyncing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.cloud_upload),
            onPressed: _isSyncing ? null : _syncSurveys,
            tooltip: 'Synchronizuj ankiety',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Jak ocenia Pan/Pani ogólne wrażenia? (1-5)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              DropdownButtonFormField<int>(
                value: _rating,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [1, 2, 3, 4, 5].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _rating = val!),
                onSaved: (val) => _rating = val!,
              ),
              const SizedBox(height: 16),
              
              const Text('2. Co było najmocniejszą stroną wizyty i co pozytywnie Was zaskoczyło?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextFormField(
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Wpisz odpowiedź...'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'To pole jest wymagane' : null,
                onSaved: (val) => _strengths = val!,
              ),
              const SizedBox(height: 16),

              const Text('3. Co moglibyśmy zrobić lepiej. Czego zabrakło lub co się nie podobało?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextFormField(
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Wpisz odpowiedź...'),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'To pole jest wymagane' : null,
                onSaved: (val) => _improvements = val!,
              ),
              const SizedBox(height: 16),

              const Text('4. W skali od 1 do 10, jak bardzo prawdopodobne jest że polecą państwo Las Odkrywców znajomym?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              DropdownButtonFormField<int>(
                value: _recommendRating,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: List.generate(10, (i) => i + 1).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _recommendRating = val!),
                onSaved: (val) => _recommendRating = val!,
              ),
              const SizedBox(height: 16),

              const Text('5. Gdzie po raz pierwszy Państwo o nas usłyszeli?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              DropdownButtonFormField<String>(
                value: _source,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _sourceOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _source = val!),
                onSaved: (val) => _source = val!,
              ),
              
              if (_source == 'Inne') ...[
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Proszę wpisać (Inne)'),
                  validator: (val) {
                    if (_source == 'Inne' && (val == null || val.trim().isEmpty)) {
                      return 'Proszę określić inne źródło';
                    }
                    return null;
                  },
                  onSaved: (val) => _sourceOther = val ?? '',
                ),
              ],
              const SizedBox(height: 16),

              const Text('6. Uwagi (opcjonalne)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextFormField(
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Dodatkowe uwagi...'),
                maxLines: 2,
                onSaved: (val) => _notes = val ?? '',
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitForm,
                  child: const Text('WYŚLIJ ANKIETĘ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 48), // Duży padding od dołu zapobiegający nakładaniu się z przyciskami Androida
            ],
          ),
        ),
      ),
    );
  }
}
