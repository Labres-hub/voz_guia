import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Tela inicial do app (aba do meio da navegação).
/// Ao abrir, o app já anuncia por voz o que o usuário pode fazer —
/// pensado para que a pessoa não precise nem olhar pra tela pra saber
/// o que fazer em seguida.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _falarBoasVindas();
  }

  Future<void> _falarBoasVindas() async {
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.5);
    await _tts.speak(
      'Bem-vindo ao VozGuia. Toque em qualquer lugar da tela para buscar um destino.',
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ATENÇÃO: esta tela NÃO tem mais seu próprio Scaffold/AppBar.
    // Ela agora vive "dentro" do MainNavigationScreen, que fornece um
    // único Scaffold compartilhado pelas 3 abas (Mapa, Início, Diário).
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/search'),
      child: Semantics(
        label: 'Toque em qualquer lugar da tela para buscar um destino',
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.navigation, size: 96),
              const SizedBox(height: 24),
              Text(
                'Toque em qualquer lugar\npara buscar um destino',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}