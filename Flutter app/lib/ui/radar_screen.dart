import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../database/database.dart';
import '../services/auth_service.dart';

class RadarScreen extends StatefulWidget {
  const RadarScreen({Key? key}) : super(key: key);

  @override
  _RadarScreenState createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
  List<Attraction> _attractions = [];
  double _gpsAccuracyThreshold = 30.0;
  bool _isLoading = true;

  final TransformationController _transformationController = TransformationController();
  bool _hasAutoCentered = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _autoScaleRadar(Size screenSize) {
    if (_attractions.isEmpty || _currentPosition == null) return;
    double maxDist = 300.0;
    final metersPerLonLocal = 111320.0 * math.cos(_currentPosition!.latitude * math.pi / 180.0);
    final metersPerLat = 111320.0;
    
    for (var attr in _attractions) {
      double dx = (attr.longitude - _currentPosition!.longitude) * metersPerLonLocal;
      double dy = (_currentPosition!.latitude - attr.latitude) * metersPerLat;
      double dist = math.sqrt(dx * dx + dy * dy) + attr.radius;
      if (dist > maxDist) maxDist = dist;
    }
    
    double smallestDimension = math.min(screenSize.width, screenSize.height);
    // smallestDimension / 2 to promień ekranu. maxDist to nasz największy wymagany promień. 
    double desiredScale = (smallestDimension / 2) / (maxDist * 1.1); // 10% marginesu
    desiredScale = desiredScale.clamp(0.01, 5.0); // limity
    
    final cx = screenSize.width / 2;
    final cy = screenSize.height / 2;
    
    _transformationController.value = Matrix4.identity()
      ..translate(cx, cy)
      ..scale(desiredScale)
      ..translate(-cx, -cy);
  }

  Future<void> _initData() async {
    // Pobranie atrakcji i ustawień z lokalnej bazy
    final db = Provider.of<AppDatabase>(context, listen: false);
    _attractions = await db.select(db.attractions).get();
    
    final settingsList = await db.select(db.globalSettings).get();
    if (settingsList.isNotEmpty) {
      _gpsAccuracyThreshold = settingsList.first.gpsAccuracyThreshold.toDouble();
    }

    // Inicjalizacja nasłuchiwania pozycji GPS
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    // Próba natychmiastowego pobrania ostatniej znanej pozycji, żeby nie czekać
    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null && mounted) {
        setState(() {
          _currentPosition = lastPos;
          _isLoading = false;
        });
      } else {
        // Jeśli nie ma w pamięci, próbujemy pobrać aktualną (z limitem czasu 3s, żeby nie zablokować interfejsu)
        final currentPos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high, 
            timeLimit: const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _currentPosition = currentPos;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Ignorujemy błędy (np. timeout), bo zaraz odpalamy strumień
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Odświeżaj co 1 metr
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _currentPosition != null && !_hasAutoCentered) {
      _hasAutoCentered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           _autoScaleRadar(MediaQuery.of(context).size);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black, // Radar ma ciemne tło
      appBar: AppBar(
        title: const Text('Radar Geofence (Offline)'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.greenAccent,
      ),
      body: _isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.greenAccent),
                SizedBox(height: 16),
                Text('Ustalanie pozycji satelitarnej...', style: TextStyle(color: Colors.greenAccent))
              ],
            )
          )
        : _currentPosition == null
            ? const Center(child: Text('Brak dostępu do GPS', style: TextStyle(color: Colors.red)))
            : InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.01,
                maxScale: 10.0,
                boundaryMargin: const EdgeInsets.all(50000), // Pozwala przesuwać mapę na boki
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _RadarPainter(
                    myPosition: _currentPosition!,
                    attractions: _attractions,
                    transformationController: _transformationController,
                    gpsAccuracyThreshold: _gpsAccuracyThreshold,
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        tooltip: 'Centruj na mnie',
        child: const Icon(Icons.my_location),
        onPressed: () {
          // Resetujemy pozycję i odświeżamy zoom, by idealnie wpasować wszystko
          _autoScaleRadar(MediaQuery.of(context).size);
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Position myPosition;
  final List<Attraction> attractions;
  final TransformationController transformationController;
  final double gpsAccuracyThreshold;

  _RadarPainter({
    required this.myPosition, 
    required this.attractions,
    required this.transformationController,
    required this.gpsAccuracyThreshold,
  }) : super(repaint: transformationController);

  final double _metersPerLat = 111320.0;
  
  double _metersPerLon(double lat) {
    return 111320.0 * math.cos(lat * math.pi / 180.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Odczytanie aktualnej skali z kontrolera, aby odpowiednio zmniejszać grubość pędzli i tekst
    double currentScale = transformationController.value.getMaxScaleOnAxis();
    if (currentScale == 0) currentScale = 1.0;

    // Ustawiamy środek ekranu na punkcie początkowym (0,0) naszego radaru
    canvas.translate(size.width / 2, size.height / 2);

    final metersPerLonLocal = _metersPerLon(myPosition.latitude);
    
    // Obliczamy maksymalny zasięg do narysowania siatki
    double maxDistance = 300.0;
    for (var attr in attractions) {
      double dx = (attr.longitude - myPosition.longitude) * metersPerLonLocal;
      double dy = (myPosition.latitude - attr.latitude) * _metersPerLat;
      double dist = math.sqrt(dx * dx + dy * dy) + attr.radius;
      if (dist > maxDistance) maxDistance = dist;
    }

    // 1. Rysowanie linii pomocniczych - siatka zasięgu radaru
    final gridPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / currentScale; // Zachowaj grubość na ekranie 1px
      
    // Dostosowanie gęstości siatki na podstawie wielkości (żeby nie rysować 100 kółek dla 5km)
    double step = maxDistance > 2000 ? 500.0 : (maxDistance > 1000 ? 250.0 : 50.0);
    
    for (double i = step; i <= maxDistance + step; i += step) {
      canvas.drawCircle(Offset.zero, i, gridPaint);
      
      // Podpisy dystansu (opcjonalne, ale pomocne)
      final textSpan = TextSpan(
        text: '${i.toInt()}m',
        style: TextStyle(color: Colors.greenAccent.withOpacity(0.3), fontSize: 10 / currentScale),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(2.0 / currentScale, -i - (12 / currentScale)));
    }

    // 2. Rysowanie atrakcji
    for (var attr in attractions) {
      // Obliczamy odległość w metrach względem środka
      double dx = (attr.longitude - myPosition.longitude) * metersPerLonLocal;
      double dy = (myPosition.latitude - attr.latitude) * _metersPerLat; // Północ w górę ekranu (czyli ujemne Y)

      final offset = Offset(dx, dy);

      // Koło promienia strefy
      final zonePaint = Paint()
        ..color = attr.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(offset, attr.radius, zonePaint);

      // Krawędź strefy
      final borderPaint = Paint()
        ..color = attr.isActive ? Colors.green : Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / currentScale; // Stała grubość linii obramowania 2px
        
      canvas.drawCircle(offset, attr.radius, borderPaint);

      // Krawędź bufora (zasięg telefonu) jako przerywana pomarańczowa linia wokół strefy
      final double triggerRadius = attr.radius + gpsAccuracyThreshold;
      final Paint dashPaint = Paint()
        ..color = Colors.orangeAccent.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / currentScale;

      const int dashCount = 36;
      final double dashSweepAngle = (2 * math.pi) / (dashCount * 2);
      for (int i = 0; i < dashCount * 2; i += 2) {
        final startAngle = i * dashSweepAngle;
        canvas.drawArc(
          Rect.fromCircle(center: offset, radius: triggerRadius),
          startAngle,
          dashSweepAngle,
          false,
          dashPaint,
        );
      }

      // Punkt w samym środku atrakcji
      canvas.drawCircle(offset, 2.0 / currentScale, Paint()..color = Colors.white);

      // Etykieta (Nazwa)
      final textSpan = TextSpan(
        text: attr.name,
        // Zmniejszamy czcionkę gdy użytkownik zoomuje, by rozmiar wizualny był stały
        style: TextStyle(color: Colors.white, fontSize: 12 / currentScale, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(dx - textPainter.width / 2, dy - attr.radius - (16 / currentScale)));
    }

    // 3. Rysowanie Ciebie (użytkownika) w centrum
    final userPaint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.fill;
    // Niebieska kropka (stała wizualnie)
    canvas.drawCircle(Offset.zero, 4.0 / currentScale, userPaint);

    // Pulsujący promień radaru (minimalistyczny)
    final pulsePaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / currentScale;
    canvas.drawCircle(Offset.zero, 8.0 / currentScale, pulsePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    // Repaint wyzwalany automatycznie gdy zmieni się zoom (dzięki super(repaint: controller))
    // plus manualnie gdy zmienią się dane.
    return myPosition.latitude != oldDelegate.myPosition.latitude ||
           myPosition.longitude != oldDelegate.myPosition.longitude;
  }
}
