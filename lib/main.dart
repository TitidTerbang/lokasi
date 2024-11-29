import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Location App'),
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
  Position? _currentPosition;
  String _locationMessage = "Mencari Lat dan Long...";
  bool _loading = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    setState(() {
      _loading = true;
    });
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw Exception('Location service not enabled');
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied forever');
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentPosition = position;
        _locationMessage =
        "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _locationMessage = 'Gagal mendapatkan lokasi: ${e.toString()}';
      });
    }
  }

  void _openGoogleMaps() async {
    if (_currentPosition != null) {
      final url = Uri.parse(
          'https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Titik Koordinat',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(_locationMessage),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Cari Lokasi'),
            ),
            const SizedBox(height: 20),
            if (_currentPosition != null)
              ElevatedButton(
                onPressed: _openGoogleMaps,
                child: const Text('Buka Google Maps'),
              ),
          ],
        ),
      ),
    );
  }
}