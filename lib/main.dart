import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Report App',
      theme: ThemeData(primarySwatch: Colors.blue),
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
  bool _isVolunteerInvolved = false;

  final Map<String, Map<String, List<String>>> _emergencyNumbers = {
    '01': {'Adrar': ['049364842']},
    '02': {'Chlef': ['027 84 55 60', '027 84 59 75']},
    '03': {'Laghouat': ['029 93 16 40', '029 93 15 35']},
    '04': {'Oum El Bouaghi': ['032 41 78 78']},
    '05': {'Batna': ['033 86 51 51']},
    '06': {'Béjaïa': ['034 21 35 35']},
    '07': {'Biskra': ['033 71 25 25']},
    '08': {'Béchar': ['049 10 00 00']},
    '09': {'Blida': ['043 00 00 00']},
    '10': {'Bouira': ['026 75 00 00']},
    '11': {'Tamanrasset': ['029 72 42 42']},
    '12': {'Tébessa': ['037 90 00 00']},
    '13': {'Tlemcen': ['043 20 30 30']},
    '14': {'Tiaret': ['038 88 11 11']},
    '15': {'Tizi Ouzou': ['026 12 56 56']},
    '16': {'Alger': ['021 69 57 57']},
    '17': {'Djelfa': ['036 74 00 00']},
    '18': {'Djijel': ['039 00 00 00']},
    '19': {'Sétif': ['036 74 00 00']},
    '20': {'Saïda': ['048 74 00 00']},
    '21': {'Skikda': ['038 80 00 00']},
    '22': {'Sidi Bel Abbès': ['048 80 00 00']},
    '23': {'Annaba': ['038 80 00 00']},
    '24': {'Guelma': ['032 12 34 34']},
    '25': {'Constantine': ['031 00 00 00']},
    '26': {'Médéa': ['025 00 00 00']},
    '27': {'Mostaganem': ['045 24 00 00']},
    '28': {'Msila': ['037 00 00 00']},
    '29': {'Mascara': ['046 24 00 00']},
    '30': {'Ouargla': ['029 75 00 00']},
    '31': {'Oran': ['041 50 40 40']},
    '32': {'El Bayadh': ['038 00 00 00']},
    '33': {'Illizi': ['029 80 00 00']},
    '34': {'Bordj Bou Arréridj': ['036 73 32 32']},
    '35': {'Boumerdès': ['024 80 00 00']},
    '36': {'El Tarf': ['038 34 00 00']},
    '37': {'Tindouf': ['029 80 00 00']},
    '38': {'Tissemsilt': ['035 00 00 00']},
    '39': {'El Oued': ['032 12 34 34']},
    '40': {'Khenchela': ['032 80 00 00']},
    '41': {'Souk Ahras': ['037 80 00 00']},
    '42': {'Tipaza': ['024 80 00 00']},
    '43': {'Mila': ['033 45 67 67']},
    '44': {'Aïn Defla': ['025 00 00 00']},
    '45': {'Naâma': ['048 74 00 00']},
    '46': {'Aïn Témouchent': ['043 20 30 30']},
    '47': {'Ghardaïa': ['029 75 00 00']},
    '48': {'Relizane': ['046 24 00 00']},
  };

  Future<void> _sendEmergencyReport() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/report'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'description': _description,
          'emergency_type': _emergencyType,
          'location': {'latitude': _latitude, 'longitude': _longitude},
          'volunteer_involved': _isVolunteerInvolved,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demande envoyée avec succès!')),
        );
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi de la demande: $e')),
      );
    }
  }

  Future<void> _getLocation() async {
    Location location = new Location();

    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    LocationData _locationData = await location.getLocation();
    setState(() {
      _latitude = _locationData.latitude!;
      _longitude = _locationData.longitude!;
      _autoFillForm();
    });
  }

  void _autoFillForm() {
    // Exemple de logique améliorée pour déterminer la wilaya en fonction de la latitude et de la longitude.
    if (_latitude >= 0 && _latitude < 10 && _longitude >= 0 && _longitude < 10) {
      _selectedWilaya = '01'; // Adrar
    } else if (_latitude >= 36.0 && _latitude < 37.0 && _longitude >= 2.0 && _longitude < 3.0) {
      _selectedWilaya = '31'; // Oran
    } else if (_latitude >= 35.0 && _latitude < 36.0 && _longitude >= 0.0 && _longitude < 1.5) {
      _selectedWilaya = '02'; // Chlef
    } else if (_latitude >= 34.0 && _latitude < 35.0 && _longitude >= 2.0 && _longitude < 3.0) {
      _selectedWilaya = '03'; // Laghouat
    } else if (_latitude >= 33.0 && _latitude < 34.0 && _longitude >= 4.0 && _longitude < 5.0) {
      _selectedWilaya = '04'; // Oum El Bouaghi
    } else if (_latitude >= 35.0 && _latitude < 36.0 && _longitude >= 5.0 && _longitude < 6.0) {
      _selectedWilaya = '05'; // Batna
    } else if (_latitude >= 36.0 && _latitude < 37.0 && _longitude >= 1.5 && _longitude < 2.5) {
      _selectedWilaya = '06'; // Béjaïa
    } else {
      _selectedWilaya = '31'; // Oran par défaut
    }

    // Remplissage de la description avec la localisation.
    _description = 'Localisation: $_latitude, $_longitude';
    _emergencyType = 'Blessure'; // Type d'urgence par défaut.
  }

  Future<void> _callEmergencyServices() async {
    final List<String> emergencyNumbers = _emergencyNumbers[_selectedWilaya]?.values.expand((x) => x).toList() ?? ['1021'];
    final Uri launchUri = Uri(scheme: 'tel', path: emergencyNumbers[0]);
    await launchUrl(launchUri);
  }

  Future<void> _shareLocation() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      String message = 'Je suis ici : https://maps.google.com/?q=$_latitude,$_longitude';
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
      appBar: AppBar(title: Text('Signalement d\'Urgence')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Signalement d\'Urgence',
                style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Wilaya'),
                      value: _selectedWilaya.isNotEmpty ? _selectedWilaya : null,
                      items: _emergencyNumbers.keys.map((String key) {
                        String wilayaName = _emergencyNumbers[key]!.keys.first;
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text('$key - $wilayaName'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWilaya = value!;
                        });
                      },
                      validator: (value) => value == null ? 'Sélectionnez une wilaya' : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Type d\'urgence'),
                      items: <String>[
                        'Blessure',
                        'Désorientation',
                        'Conditions climatiques',
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
                      validator: (value) => value == null ? 'Sélectionnez un type d\'urgence' : null,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      initialValue: _description,
                      onChanged: (value) {
                        _description = value;
                      },
                      validator: (value) => value!.isEmpty ? 'Entrez une description' : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _sendEmergencyReport();
                        }
                      },
                      child: Text('Envoyer'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _getLocation,
                      child: Text('Obtenir ma Localisation'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _callEmergencyServices,
                      child: Text('Appeler les Services d\'Urgence'),
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
          ),
        ],
      ),
    );
  }
}

