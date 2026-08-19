import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

class WorkScreen extends StatefulWidget {
  final Attraction attraction;

  const WorkScreen({Key? key, required this.attraction}) : super(key: key);

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  DateTime? _startTime;
  Timer? _timer;
  int _elapsedSeconds = 0;
  String? _currentMeasurementId;

  void _startWork() async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final auth = Provider.of<AuthService>(context, listen: false);
    
    final id = Uuid().v4();
    final now = DateTime.now().toUtc();

    await db.into(db.measurements).insert(
      MeasurementsCompanion.insert(
        id: id,
        operatorId: auth.userId!,
        attractionId: widget.attraction.id,
        startTime: now,
      )
    );

    setState(() {
      _startTime = now;
      _currentMeasurementId = id;
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopWork() async {
    _timer?.cancel();
    if (_currentMeasurementId == null) return;

    final db = Provider.of<AppDatabase>(context, listen: false);
    final now = DateTime.now().toUtc();

    await (db.update(db.measurements)..where((t) => t.id.equals(_currentMeasurementId!)))
        .write(MeasurementsCompanion(
      stopTime: drift.Value(now),
      totalDurationSeconds: drift.Value(_elapsedSeconds),
    ));

    setState(() {
      _startTime = null;
      _currentMeasurementId = null;
    });

    // Po zakończeniu automatycznie spróbuj zsynchronizować z serwerem
    Provider.of<SyncService>(context, listen: false).syncMeasurements();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pomiar zapisany lokalnie i zakolejkowany do wysyłki!')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isWorking = _startTime != null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.attraction.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWorking ? 'Czas pracy:' : 'Gotowy do pracy',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            if (isWorking)
              Text(
                _formatDuration(_elapsedSeconds),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isWorking ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              ),
              onPressed: isWorking ? _stopWork : _startWork,
              child: Text(
                isWorking ? 'Zakończ Pomiar' : 'Start',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
