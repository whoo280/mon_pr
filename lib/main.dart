import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Importer le package
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Report App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EmergencyReportPage(),
    );
  }
}

class EmergencyReportPage extends StatefulWidget {
  @override
  _EmergencyReportPageState createState() => _EmergencyReportPageState();
}

class _EmergencyReportPageState extends State<EmergencyReportPage> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  String _emergencyType = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _selectedWilaya = '';
  bool _isVolunteerInvolved = false; // Indique si un bénévole est impliqué

  // Dictionnaire des numéros de protection civile par wilaya
  final Map<String, String> _emergencyNumbers = {
    'Alger': '021 71 10 14',
    'Oran': '041 52 16 71',
    'Constantine': '031 32 16 16',
    'Annaba': '038 88 27 14',
    'Blida': '025 93 14 10',
    'Tizi Ouzou': '026 72 07 22',
    'Setif': '036 94 45 01',
    'Batna': '033 94 13 59',
    'Béjaïa': '034 21 13 00',
  };

  Future<void> _sendEmergencyReport() async {
    final response = await http.post(
      Uri.parse(
          'https://api.secoursprofessionnels.com/report'), // Remplacez par votre API
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'description': _description,
        'emergency_type': _emergencyType,
        'location': {
          'latitude': _latitude,
          'longitude': _longitude,
        },
        'volunteer_involved':
            _isVolunteerInvolved, // Ajout de l'implication du bénévole
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande envoyée avec succès!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi de la demande.')),
      );
    }
  }

  Future<void> _getLocation() async {
    Location location = new Location();

    // Vérifier le statut de la permission
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Obtenir la localisation
    LocationData _locationData = await location.getLocation();
    setState(() {
      _latitude = _locationData.latitude!;
      _longitude = _locationData.longitude!;
    });
  }

  Future<void> _callEmergencyServices() async {
    final String emergencyNumber = _emergencyNumbers[_selectedWilaya] ?? '1021';
    final Uri launchUri = Uri(scheme: 'tel', path: emergencyNumber);
    await launchUrl(launchUri);
  }

  Future<void> _callFreeEmergencyNumber() async {
    final Uri launchUri = Uri(scheme: 'tel', path: '1021');
    await launchUrl(launchUri);
  }

  Future<void> _shareLocation() async {
    // Vérifier la connectivité
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      String message =
          'Je suis ici : https://maps.google.com/?q=$_latitude,$_longitude';
      await Share.share(message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pas de connexion Internet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signaler une Urgence'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Wilaya'),
                items: _emergencyNumbers.keys.map((String wilaya) {
                  return DropdownMenuItem<String>(
                    value: wilaya,
                    child: Text(wilaya),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedWilaya = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Sélectionnez une wilaya' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Type d\'urgence'),
                items: <String>[
                  'Blessure',
                  'Désorientation',
                  'Conditions climatiques'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _emergencyType = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Sélectionnez un type d\'urgence' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (value) {
                  _description = value;
                },
                validator: (value) =>
                    value!.isEmpty ? 'Entrez une description' : null,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isVolunteerInvolved,
                    onChanged: (value) {
                      setState(() {
                        _isVolunteerInvolved = value!;
                      });
                    },
                  ),
                  Text('Géré par un bénévole'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _getLocation().then((_) {
                      _sendEmergencyReport();
                    });
                  }
                },
                child: Text('Envoyer'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _callEmergencyServices,
                child: Text('Appeler la Protection Civile'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _callFreeEmergencyNumber,
                child: Text('Appeler le numéro gratuit 1021'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _shareLocation,
                child: Text('Partager ma Localisation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
