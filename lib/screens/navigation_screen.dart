import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import '../services/directions_service.dart';

/// Tela de navegação: busca a rota até o destino recebido da tela
/// anterior e vai lendo as instruções em voz alta, uma de cada vez.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final FlutterTts _tts = FlutterTts();

  List<PassoRota> _passos = [];
  int _passoAtual = 0;
  bool _carregando = true;
  String? _erro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lemos o destino passado pela SearchScreen (Navigator arguments)
    // e só então iniciamos a busca da rota — por isso está aqui e não
    // no initState (que roda antes dos argumentos estarem disponíveis).
    if (_carregando && _passos.isEmpty && _erro == null) {
      final destino = ModalRoute.of(context)!.settings.arguments as String;
      _carregarRota(destino);
    }
  }

  Future<void> _carregarRota(String destino) async {
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.5);

    try {
      // 1. Descobre a posição atual do usuário via GPS.
      final posicao = await _obterLocalizacaoAtual();

      // 2. Chama a API de rotas com origem = posição atual, destino = texto buscado.
      final passos = await DirectionsService.buscarRota(
        origemLat: posicao.latitude,
        origemLng: posicao.longitude,
        destino: destino,
      );

      setState(() {
        _passos = passos;
        _carregando = false;
      });

      if (passos.isNotEmpty) {
        _falarPassoAtual();
      } else {
        await _tts.speak('Nenhuma rota encontrada para este destino.');
      }
    } catch (e) {
      setState(() {
        _erro = 'Não foi possível calcular a rota. Verifique o destino e sua conexão.';
        _carregando = false;
      });
      await _tts.speak(_erro!);
    }
  }

  Future<Position> _obterLocalizacaoAtual() async {
    bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      throw Exception('Serviço de localização desativado.');
    }

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _falarPassoAtual() async {
    if (_passoAtual < _passos.length) {
      final passo = _passos[_passoAtual];
      await _tts.speak('${passo.instrucao}. Em ${passo.distancia}.');
    } else {
      await _tts.speak('Você chegou ao seu destino.');
    }
  }

  void _proximaInstrucao() {
    if (_passoAtual < _passos.length - 1) {
      setState(() => _passoAtual++);
      _falarPassoAtual();
    } else {
      _tts.speak('Esta é a última instrução da rota.');
    }
  }

  void _repetirInstrucao() {
    _falarPassoAtual();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navegando')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _carregando
            ? const Center(child: CircularProgressIndicator())
            : _erro != null
                ? Center(
                    child: Text(_erro!, style: const TextStyle(fontSize: 20)),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _passos.length,
                          itemBuilder: (context, index) {
                            final passo = _passos[index];
                            final atual = index == _passoAtual;
                            return Card(
                              color: atual ? Colors.indigo.shade50 : null,
                              child: ListTile(
                                leading: Icon(
                                  atual ? Icons.volume_up : Icons.circle_outlined,
                                ),
                                title: Text(passo.instrucao, style: const TextStyle(fontSize: 18)),
                                subtitle: Text(passo.distancia),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _repetirInstrucao,
                              icon: const Icon(Icons.replay),
                              label: const Text('Repetir'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _proximaInstrucao,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Próxima'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
