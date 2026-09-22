import 'package:flutter/material.dart';

/// Placeholder da aba de Mapa. A funcionalidade real de navegação por
/// mapa ainda não foi implementada nesta Sprint — esta tela existe só
/// para reservar o espaço na navegação e comunicar a ideia visualmente.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 96, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'Mapa em desenvolvimento',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta funcionalidade será implementada em uma próxima Sprint.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}