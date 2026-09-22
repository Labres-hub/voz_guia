import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Tela de busca de destino.
/// O usuário pode digitar OU falar o destino — pensado para não
/// depender de digitação em teclado (difícil sem enxergar a tela).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _destinoController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _ouvindo = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('pt-BR');
    _tts.speak('Diga ou digite para onde você quer ir, e toque em buscar rota.');
  }

  Future<void> _iniciarEscuta() async {
    bool disponivel = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _ouvindo = false);
        }
      },
      onError: (error) => setState(() => _ouvindo = false),
    );

    if (disponivel) {
      setState(() => _ouvindo = true);
      _speech.listen(
        localeId: 'pt_BR',
        onResult: (result) {
          setState(() {
            _destinoController.text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _pararEscuta() {
    _speech.stop();
    setState(() => _ouvindo = false);
  }

  void _buscarRota() {
    final destino = _destinoController.text.trim();
    if (destino.isEmpty) {
      _tts.speak('Por favor, informe um destino antes de buscar a rota.');
      return;
    }
    // Passa o destino digitado/falado para a tela de navegação via
    // argumentos de rota do Flutter.
    Navigator.pushNamed(context, '/navigation', arguments: destino);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _destinoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Para onde você vai?')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _destinoController,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                labelText: 'Digite o destino',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Botão de microfone: alterna entre "começar a ouvir" e
            // "parar de ouvir".
            ElevatedButton.icon(
              onPressed: _ouvindo ? _pararEscuta : _iniciarEscuta,
              icon: Icon(_ouvindo ? Icons.mic : Icons.mic_none),
              label: Text(_ouvindo ? 'Ouvindo... toque para parar' : 'Falar destino'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _buscarRota,
              icon: const Icon(Icons.search),
              label: const Text('Buscar rota'),
            ),
          ],
        ),
      ),
    );
  }
}
