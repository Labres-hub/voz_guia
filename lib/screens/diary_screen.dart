import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Representa uma anotação salva no diário (ex: endereço de casa,
/// ponto de encontro combinado, lembrete pessoal).
class EntradaDiario {
  final String texto;
  final DateTime criadoEm;

  EntradaDiario({required this.texto, required this.criadoEm});
}

/// Tela de Diário/registro: permite tanto entrada por TEXTO (útil para
/// pessoas com visão que queiram digitar, ex: um familiar ajudando a
/// cadastrar um endereço) quanto por VOZ (para o usuário com deficiência
/// visual gravar a anotação falando).
///
/// OBS: por enquanto as anotações ficam só em memória (somem se o app
/// fechar). Guardar isso de forma permanente no celular é um ajuste
/// natural para a próxima Sprint.
class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _ouvindo = false;

  final List<EntradaDiario> _entradas = [];

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('pt-BR');
  }

  Future<void> _iniciarEscuta() async {
    bool disponivel = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') setState(() => _ouvindo = false);
      },
      onError: (error) => setState(() => _ouvindo = false),
    );

    if (disponivel) {
      setState(() => _ouvindo = true);
      _speech.listen(
        localeId: 'pt_BR',
        onResult: (result) {
          setState(() => _controller.text = result.recognizedWords);
        },
      );
    }
  }

  void _pararEscuta() {
    _speech.stop();
    setState(() => _ouvindo = false);
  }

  void _adicionarEntrada() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _entradas.insert(
        0, // adiciona no topo, mais recente primeiro
        EntradaDiario(texto: texto, criadoEm: DateTime.now()),
      );
      _controller.clear();
    });

    _tts.speak('Anotação salva.');
  }

  void _removerEntrada(int index) {
    setState(() => _entradas.removeAt(index));
  }

  Future<void> _lerEntradaEmVozAlta(String texto) async {
    await _tts.speak(texto);
  }

  String _formatarData(DateTime data) {
    final hora = data.hour.toString().padLeft(2, '0');
    final minuto = data.minute.toString().padLeft(2, '0');
    return '${data.day}/${data.month} às $hora:$minuto';
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 1,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(
              labelText: 'Digite uma anotação (ex: endereço, ponto de encontro)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _ouvindo ? _pararEscuta : _iniciarEscuta,
                  icon: Icon(_ouvindo ? Icons.mic : Icons.mic_none),
                  label: Text(_ouvindo ? 'Ouvindo...' : 'Falar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _adicionarEntrada,
                  icon: const Icon(Icons.add),
                  label: const Text('Salvar'),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: _entradas.isEmpty
                ? const Center(
              child: Text(
                'Nenhuma anotação ainda.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _entradas.length,
              itemBuilder: (context, index) {
                final entrada = _entradas[index];
                return Card(
                  child: ListTile(
                    title: Text(entrada.texto, style: const TextStyle(fontSize: 18)),
                    subtitle: Text(_formatarData(entrada.criadoEm)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          tooltip: 'Ouvir anotação',
                          onPressed: () => _lerEntradaEmVozAlta(entrada.texto),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Excluir anotação',
                          onPressed: () => _removerEntrada(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}