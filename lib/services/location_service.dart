import 'package:location/location.dart';
import 'dart:math';

class LocationService {
  // Map des coordonnées approximatives pour chaque wilaya (points centraux)
  static final Map<String, Map<String, double>> wilayaCoordinates = {
    '01': {'lat': 27.8742, 'lng': -0.2993},  // Adrar
    '02': {'lat': 36.1691, 'lng': 1.3387},   // Chlef
    '03': {'lat': 33.8000, 'lng': 2.8800},   // Laghouat
    '04': {'lat': 35.8700, 'lng': 7.1100},   // Oum El Bouaghi
    '05': {'lat': 35.5500, 'lng': 6.1700},   // Batna
    '06': {'lat': 36.7500, 'lng': 5.0800},   // Béjaïa
    '07': {'lat': 34.8500, 'lng': 5.7300},   // Biskra
    '08': {'lat': 31.6200, 'lng': -2.2200},  // Béchar
    '09': {'lat': 36.4700, 'lng': 2.8300},   // Blida
    '10': {'lat': 36.3800, 'lng': 3.9000},   // Bouira
    '11': {'lat': 22.7900, 'lng': 5.5300},   // Tamanrasset
    '12': {'lat': 35.4000, 'lng': 8.1200},   // Tébessa
    '13': {'lat': 34.8800, 'lng': -1.3200},  // Tlemcen
    '14': {'lat': 35.3700, 'lng': 1.3200},   // Tiaret
    '15': {'lat': 36.7100, 'lng': 4.0500},   // Tizi Ouzou
    '16': {'lat': 36.7630, 'lng': 3.0586},   // Alger
    '17': {'lat': 34.6700, 'lng': 3.2500},   // Djelfa
    '18': {'lat': 36.8200, 'lng': 5.7600},   // Jijel
    '19': {'lat': 36.1900, 'lng': 5.4100},   // Sétif
    '20': {'lat': 34.8300, 'lng': 0.1500},   // Saïda
    '21': {'lat': 36.8800, 'lng': 6.9000},   // Skikda
    '22': {'lat': 35.2000, 'lng': -0.6300},  // Sidi Bel Abbès
    '23': {'lat': 36.9000, 'lng': 7.7700},   // Annaba
    '24': {'lat': 36.4600, 'lng': 7.4300},   // Guelma
    '25': {'lat': 36.3600, 'lng': 6.6100},   // Constantine
    '26': {'lat': 36.2700, 'lng': 2.7700},   // Médéa
    '27': {'lat': 35.9300, 'lng': 0.0900},   // Mostaganem
    '28': {'lat': 35.7000, 'lng': 4.5400},   // M'Sila
    '29': {'lat': 35.4000, 'lng': 0.1400},   // Mascara
    '30': {'lat': 31.9500, 'lng': 5.3300},   // Ouargla
    '31': {'lat': 35.6900, 'lng': -0.6400},  // Oran
    '32': {'lat': 33.6800, 'lng': 1.0200},   // El Bayadh
    '33': {'lat': 26.5000, 'lng': 8.4800},   // Illizi
    '34': {'lat': 36.0700, 'lng': 4.7600},   // Bordj Bou Arréridj
    '35': {'lat': 36.7600, 'lng': 3.4800},   // Boumerdès
    '36': {'lat': 36.7700, 'lng': 8.3100},   // El Tarf
    '37': {'lat': 27.6700, 'lng': -8.1400},  // Tindouf
    '38': {'lat': 35.6100, 'lng': 1.8100},   // Tissemsilt
    '39': {'lat': 33.3700, 'lng': 6.8600},   // El Oued
    '40': {'lat': 35.4300, 'lng': 7.1400},   // Khenchela
    '41': {'lat': 36.2900, 'lng': 7.9500},   // Souk Ahras
    '42': {'lat': 36.5900, 'lng': 2.4200},   // Tipaza
    '43': {'lat': 36.4500, 'lng': 6.2600},   // Mila
    '44': {'lat': 36.2500, 'lng': 1.9700},   // Aïn Defla
    '45': {'lat': 33.2700, 'lng': -0.3100},  // Naâma
    '46': {'lat': 35.3000, 'lng': -1.1400},  // Aïn Témouchent
    '47': {'lat': 32.4900, 'lng': 3.6700},   // Ghardaïa
    '48': {'lat': 35.7400, 'lng': 0.5600},   // Relizane
    '49': {'lat': 27.1900, 'lng': 2.4800},   // In Salah
    '50': {'lat': 33.9500, 'lng': 5.9200},   // El M'Ghair
    '51': {'lat': 21.6800, 'lng': 0.9500},   // Bordj Badji Mokhtar
    '52': {'lat': 19.5700, 'lng': 5.7700},   // In Guezzam
    '53': {'lat': 30.1300, 'lng': -2.1700},  // Béni Abbès
    '54': {'lat': 34.4200, 'lng': 5.0600},   // Ouled Djellal
    '55': {'lat': 29.2600, 'lng': 0.2300},   // Timimoun
    '56': {'lat': 24.5500, 'lng': 9.4800},   // Djanet
    '57': {'lat': 33.1000, 'lng': 6.0600},   // Touggourt
    '58': {'lat': 30.5800, 'lng': 2.8800}    // El Menia
  };

  // Fonction pour calculer la distance entre deux coordonnées (formule de Haversine)
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Rayon de la terre en km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    final double a = 
      sin(dLat/2) * sin(dLat/2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * 
      sin(dLon/2) * sin(dLon/2);
    final double c = 2 * atan2(sqrt(a), sqrt(1-a)); 
    final double distance = R * c; // Distance en km
    return distance;
  }

  // Convertir degrés en radians
  static double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  // Fonction pour trouver la wilaya la plus proche en fonction des coordonnées
  static String findClosestWilaya(double lat, double lng) {
    String closestWilaya = '';
    double minDistance = double.maxFinite;

    wilayaCoordinates.forEach((wilayaCode, coordinates) {
      final double distance = calculateDistance(
        lat, 
        lng, 
        coordinates['lat']!, 
        coordinates['lng']!
      );
      
      if (distance < minDistance) {
        minDistance = distance;
        closestWilaya = wilayaCode;
      }
    });

    return closestWilaya;
  }

  // Obtenir la localisation
  Future<LocationData> getLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Service de localisation désactivé');
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Permission de localisation non accordée');
      }
    }

    return await location.getLocation();
  }

  // Obtenir la localisation et déterminer la wilaya
  Future<Map<String, dynamic>> getLocationWithWilaya() async {
    LocationData locationData = await getLocation();
    
    // Trouver la wilaya la plus proche
    String wilayaCode = findClosestWilaya(
      locationData.latitude!, 
      locationData.longitude!
    );
    
    // Retourner à la fois la localisation et le code de la wilaya
    return {
      'location': locationData,
      'wilayaCode': wilayaCode
    };
  }
}