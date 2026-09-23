import 'dart:convert';
import 'package:http/http.dart' as http;

/// Representa uma única instrução de navegação (um "passo" da rota).
class PassoRota {
  final String instrucao;
  final String distancia;

  PassoRota({required this.instrucao, required this.distancia});
}

/// Serviço responsável por conversar com a Google Routes API e
/// transformar a resposta numa lista simples de PassoRota.
class DirectionsService {
  static const String _apiKey = 'SUA_CHAVE_AQUI';

  static const String _endpoint =
      'https://routes.googleapis.com/directions/v2:computeRoutes';

  static Future<List<PassoRota>> buscarRota({
    required double origemLat,
    required double origemLng,
    required String destino,
  }) async {
    final url = Uri.parse(_endpoint);

    final corpo = {
      'origin': {
        'location': {
          'latLng': {'latitude': origemLat, 'longitude': origemLng}
        }
      },
      'destination': {
        'address': destino,
      },
      'travelMode': 'WALK',
      'languageCode': 'pt-BR',
      'units': 'METRIC',
    };

    final resposta = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask':
        'routes.legs.steps.navigationInstruction,routes.legs.steps.localizedValues.distance,routes.legs.steps.distanceMeters',
      },
      body: json.encode(corpo),
    );

    if (resposta.statusCode != 200) {
      throw Exception('Erro ao consultar a API de rotas (${resposta.statusCode}): ${resposta.body}');
    }

    final dados = json.decode(resposta.body);

    final List<dynamic>? rotas = dados['routes'];
    if (rotas == null || rotas.isEmpty) {
      throw Exception('Nenhuma rota encontrada.');
    }

    final List<dynamic> passosBrutos = rotas[0]['legs'][0]['steps'];

    return passosBrutos.map((passo) {
      final instrucao = passo['navigationInstruction']?['instructions'] as String? ??
          'Continue em frente';

      final distanciaTexto = passo['localizedValues']?['distance']?['text'] as String?;
      final distanciaMetros = passo['distanceMeters'] as int?;
      final distancia = distanciaTexto ?? (distanciaMetros != null ? '$distanciaMetros m' : '');

      return PassoRota(instrucao: instrucao, distancia: distancia);
    }).toList();
  }
}