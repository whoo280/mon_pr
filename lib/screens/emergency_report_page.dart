import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../services/location_service.dart';

class EmergencyReportPage extends StatefulWidget {
  @override
  _EmergencyReportPageState createState() => _EmergencyReportPageState();
}

class _EmergencyReportPageState extends State<EmergencyReportPage> {
  final _formKey = GlobalKey<FormState>();
  final LocationService _locationService = LocationService();
  
  String _description = '';
  String _emergencyType = '';
  String _otherEmergencyType = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _selectedWilaya = '';
  String _selectedWilayaName = '';
  bool _isLoading = false;

  // Numéros d'urgence nationaux
  final Map<String, String> _nationalEmergencyNumbers = {
    'Numéro Vert': '1021',
    'Urgences': '14',
    'Gendarmerie Nationale': '1055',
  };

  // Map des numéros d'urgence pour chaque wilaya
  final Map<String, Map<String, List<String>>> _emergencyNumbers = {
    '01': {'Adrar': ['049364842']},
    '02': {'Chlef': ['027771051', '027779969']},
    '03': {'Laghouat': ['029102355', '029102360', '029102364']},
    '04': {'Oum El Bouaghi': ['032563161', '032417878']},
    '05': {'Batna': ['033222629', '033222593', '033865151']},
    '06': {'Béjaïa': ['034102497', '034102462', '034102340', '034213535']},
    '07': {'Biskra': ['033657447', '033657450', '033657451', '033657452', '033712525']},
    '08': {'Béchar': ['049216014', '049100000']},
    '09': {'Blida': ['025200425', '025200423', '043000000']},
    '10': {'Bouira': ['026744170', '026744192', '026744161', '026750000']},
    '11': {'Tamanrasset': ['029398954', '029398971', '029724242']},
    '12': {'Tébessa': ['037502323', '037502299', '037900000']},
    '13': {'Tlemcen': ['043418888', '043203030']},
    '14': {'Tiaret': ['046222586', '046222587', '038881111']},
    '15': {'Tizi Ouzou': ['026102607', '026102609', '026102612', '026125656']},
    '16': {'Alger': ['023909038', '023711414', '021695757']},
    '17': {'Djelfa': ['027908917', '027908918', '036740000']},
    '18': {'Jijel': ['034506200', '034506201', '034506202', '039000000']},
    '19': {'Sétif': ['036456076', '036456077', '036740000']},
    '20': {'Saïda': ['048433344', '048433333', '048740000']},
    '21': {'Skikda': ['038939665', '038800000']},
    '22': {'Sidi Bel Abbès': ['048706161', '048800000']},
    '23': {'Annaba': ['038485216', '038485158', '038800000']},
    '24': {'Guelma': ['037145357', '037145768', '032123434']},
    '25': {'Constantine': ['031958375', '031000000']},
    '26': {'Médéa': ['025784747', '025784953', '025784865', '025000000']},
    '27': {'Mostaganem': ['045439705', '045439026', '045240000']},
    '28': {'M\'Sila': ['035366000', '037000000']},
    '29': {'Mascara': ['045729701', '045729699', '046240000']},
    '30': {'Ouargla': ['029600035', '029600036', '029750000']},
    '31': {'Oran': ['041511544', '041511524', '041511584', '041504040']},
    '32': {'El Bayadh': ['049617426', '049617421', '038000000']},
    '33': {'Illizi': ['029404125', '029800000']},
    '34': {'Bordj Bou Arréridj': ['035874242', '035874343', '036733232']},
    '35': {'Boumerdès': ['024941024', '024941035', '024800000']},
    '36': {'El Tarf': ['038316222', '038316456', '038316473', '038340000']},
    '37': {'Tindouf': ['049375261', '029800000']},
    '38': {'Tissemsilt': ['046578309', '035000000']},
    '39': {'El Oued': ['032120005', '032120006', '032123434']},
    '40': {'Khenchela': ['032704203', '032704209', '032704210', '032740638', '032800000']},
    '41': {'Souk Ahras': ['037762154', '037762156', '037800000']},
    '42': {'Tipaza': ['024371150', '024371151', '024800000']},
    '43': {'Mila': ['031477012', '031501099', '033456767']},
    '44': {'Aïn Defla': ['027604634', '025000000']},
    '45': {'Naâma': ['049593350', '048740000']},
    '46': {'Aïn Témouchent': ['043798635', '043798655', '043203030']},
    '47': {'Ghardaïa': ['029259494', '029259409', '029750000']},
    '48': {'Relizane': ['046749393', '046749494', '046240000']},
    '49': {'In Salah': ['029386399']},
    '50': {'El M\'Ghair': ['032186423', '032186424']},
    '51': {'Bordj Badji Mokhtar': ['049329468']},
    '52': {'In Guezzam': ['029354555']},
    '53': {'Béni Abbès': ['049286050']},
    '54': {'Ouled Djellal': ['033661214']},
    '55': {'Timimoun': ['049304545']},
    '56': {'Djanet': ['029480093', '029480094']},
    '57': {'Touggourt': ['029663933']},
    '58': {'El Menia': ['029213393']},
  };

  // Types d'urgence disponibles
  final List<String> _emergencyTypes = [
    'Accident de la route',
    'Incendie',
    'Urgence médicale',
    'Catastrophe naturelle',
    'Autre'
  ];

  // Méthode pour obtenir la localisation et définir automatiquement la wilaya
  Future<void> _getLocationAndSetWilaya() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Afficher un indicateur de chargement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Récupération de votre position...'))
      );
      
      // Obtenir la localisation et la wilaya
      final locationData = await _locationService.getLocationWithWilaya();
      
      // Mettre à jour l'état avec les nouvelles données
      setState(() {
        _latitude = locationData['location'].latitude;
        _longitude = locationData['location'].longitude;
        _selectedWilaya = locationData['wilayaCode'];
        _selectedWilayaName = _emergencyNumbers[_selectedWilaya]!.keys.first;
        _isLoading = false;
      });
      
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Position obtenue. Wilaya détectée: $_selectedWilayaName'),
          backgroundColor: Colors.green,
        )
      );
    } catch (e) {
      // Gérer les erreurs
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // Méthode pour envoyer le rapport d'urgence
  void _sendEmergencyReport() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Déterminer le type d'urgence final (standard ou personnalisé)
    final finalEmergencyType = _emergencyType == 'Autre' ? _otherEmergencyType : _emergencyType;
    
    // Simuler l'envoi du rapport
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signalement envoyé avec succès'),
        backgroundColor: Colors.green,
      )
    );
    
    // Afficher les données dans la console pour vérification
    print('Wilaya: $_selectedWilaya - $_selectedWilayaName');
    print('Type d\'urgence: $finalEmergencyType');
    print('Description: $_description');
    print('Coordonnées: $_latitude, $_longitude');
    
    // Réinitialiser le formulaire
    _formKey.currentState!.reset();
    setState(() {
      _description = '';
      _emergencyType = '';
      _otherEmergencyType = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signalement d\'Urgence'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bouton pour obtenir la localisation
                ElevatedButton.icon(
                  icon: Icon(Icons.location_on),
                  label: Text(_isLoading 
                    ? 'Récupération en cours...' 
                    : 'Obtenir ma localisation'),
                  onPressed: _isLoading ? null : _getLocationAndSetWilaya,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Affichage de la wilaya détectée
                if (_selectedWilaya.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wilaya détectée:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('$_selectedWilaya - $_selectedWilayaName'),
                        SizedBox(height: 4),
                        Text(
                          'Coordonnées: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                
                // Sélection du type d'urgence
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Type d\'urgence',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warning),
                  ),
                  hint: Text('Sélectionnez le type d\'urgence'),
                  value: _emergencyType.isEmpty ? null : _emergencyType,
                  items: _emergencyTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _emergencyType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un type d\'urgence';
                    }
                    return null;
                  },
                ),
                
                // Champ pour saisir un autre type d'urgence (visible uniquement si "Autre" est sélectionné)
                if (_emergencyType == 'Autre')
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Précisez le type d\'urgence',
                        hintText: 'Ex: Glissement de terrain, Inondation...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _otherEmergencyType = value;
                        });
                      },
                      validator: (value) {
                        if (_emergencyType == 'Autre' && (value == null || value.isEmpty)) {
                          return 'Veuillez préciser le type d\'urgence';
                        }
                        return null;
                      },
                    ),
                  ),
                
                SizedBox(height: 20),
                
                // Champ de description
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description (optionnel)',
                    hintText: 'Donnez plus de détails sur la situation...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  onChanged: (value) {
                    _description = value;
                  },
                ),
                
                SizedBox(height: 30),
                
                // Bouton d'envoi
                ElevatedButton(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'ENVOYER LE SIGNALEMENT',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  onPressed: _selectedWilaya.isEmpty || _emergencyType.isEmpty || 
                            (_emergencyType == 'Autre' && _otherEmergencyType.isEmpty) || 
                            _isLoading 
                    ? null 
                    : _sendEmergencyReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Numéros d'urgence nationaux
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Numéros d\'urgence nationaux:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      ...(_nationalEmergencyNumbers.entries.map((entry) => 
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              ElevatedButton.icon(
                                icon: Icon(Icons.phone, size: 16),
                                label: Text(entry.value),
                                onPressed: () => _callNumber(entry.value),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )
                      ).toList()),
                    ],
                  ),
                ),
                
                // Boutons supplémentaires
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.phone),
                        label: Text('Appeler Wilaya'),
                        onPressed: _selectedWilaya.isEmpty ? null : _callEmergencyServices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.share),
                        label: Text('Partager'),
                        onPressed: _latitude == 0.0 ? null : _shareLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour appeler un numéro
  Future<void> _callNumber(String number) async {
    final url = 'tel:$number';
    
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'appeler ce numéro'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // Méthode pour appeler les services d'urgence de la wilaya
  Future<void> _callEmergencyServices() async {
    if (_selectedWilaya.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez d\'abord sélectionner une wilaya'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    final wilayaName = _emergencyNumbers[_selectedWilaya]!.keys.first;
    final numbers = _emergencyNumbers[_selectedWilaya]![wilayaName]!;

    if (numbers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aucun numéro disponible pour cette wilaya'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    // Afficher une boîte de dialogue avec les numéros disponibles
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Numéros d\'urgence - $wilayaName'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(numbers[index]),
                trailing: Icon(Icons.phone, color: Colors.green),
                onTap: () {
                  Navigator.of(context).pop();
                  _callNumber(numbers[index]);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
        ],
      ),
    );
  }

  // Méthode pour partager la localisation
  Future<void> _shareLocation() async {
    if (_latitude == 0.0 && _longitude == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez d\'abord obtenir votre position'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    final locationText = 'Je suis en situation d\'urgence. Voici ma position: https://www.google.com/maps?q=${_latitude},${_longitude}';

    try {
      await Share.share(
        locationText,
        subject: 'Position d\'urgence',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du partage: ${e.toString()}'),
          backgroundColor: Colors.red,
        )
      );
    }
  }
}