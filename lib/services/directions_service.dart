import 'dart:convert';
import 'package:http/http.dart' as http;

/// Representa uma única instrução de navegação (um "passo" da rota).
class PassoRota {
  final String instrucao; // ex: "Vire à direita na Rua X"
  final String distancia; // ex: "50 m"

  PassoRota({required this.instrucao, required this.distancia});
}

/// Serviço responsável por conversar com a Google Routes API (substituta
/// oficial da antiga Directions API, hoje em status "legado") e
/// transformar a resposta numa lista simples de PassoRota.
class DirectionsService {
/// Não consegui ativar pelo route, deu problema no pré-pagamento, vou tentar outras e o openstreetmap
static const String _apiKey = '';

static const String _endpoint =
'https://routes.googleapis.com/directions/v2:computeRoutes';

/// Busca a rota entre [origemLat]/[origemLng] (localização atual do
/// usuário, vinda do GPS) e [destino] (texto livre, ex: "Praça
/// Central, Venâncio Aires"). Devolve a lista de passos em português.
static Future<List<PassoRota>> buscarRota({
required double origemLat,
required double origemLng,
required String destino,
}) async {
final url = Uri.parse(_endpoint);

// A Routes API usa POST com corpo JSON, diferente da antiga
// Directions API (que usava GET com parâmetros na URL).
final corpo = {
'origin': {
'location': {
'latLng': {'latitude': origemLat, 'longitude': origemLng}
}
},
'destination': {
'address': destino,
},
'travelMode': 'WALK', // navegação a pé, adequado ao nosso caso de uso
'languageCode': 'pt-BR',
'units': 'METRIC',
};

final resposta = await http.post(
url,
headers: {
'Content-Type': 'application/json',
'X-Goog-Api-Key': _apiKey,
// A Routes API exige que você diga explicitamente quais campos
// quer de volta na resposta (evita respostas gigantes por padrão).
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
if (rotas == null ||