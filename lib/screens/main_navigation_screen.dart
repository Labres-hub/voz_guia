import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'diary_screen.dart';

/// Tela "casca" que segura a barra de navegação inferior e alterna
/// entre as 3 abas do app: Mapa (esquerda), Início/Falar (meio) e
/// Diário (direita).
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceSelecionado = 1; // começa na aba do meio (Início/Falar)

  // IndexedStack mantém as 3 telas "vivas" na memória e só troca qual
  // é exibida — assim o TTS/estado de cada aba não é perdido ao trocar.
  final List<Widget> _telas = const [
    MapScreen(),
    HomeScreen(),
    DiaryScreen(),
  ];

  final List<String> _titulos = const ['Mapa', 'VozGuia', 'Diário'];

  void _aoTocarAba(int index) {
    setState(() => _indiceSelecionado = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indiceSelecionado])),
      body: IndexedStack(
        index: _indiceSelecionado,
        children: _telas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSelecionado,
        onTap: _aoTocarAba,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diário',
          ),
        ],
      ),
    );
  }
}