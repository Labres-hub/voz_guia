# VozGuia — Sprint 1

Código inicial do Módulo 1 (Navegação por voz): telas principais + integração
com a Google Directions API.

## Como usar este código

1. Crie o projeto Flutter (se ainda não criou):
   ```
   flutter create voz_guia
   ```

2. Substitua a pasta `lib/` do projeto gerado pelos arquivos deste pacote
   (mantendo a mesma estrutura de pastas: `lib/screens/`, `lib/services/`).

3. Substitua o `pubspec.yaml` do projeto gerado pelo arquivo `pubspec.yaml`
   deste pacote.

4. Rode no terminal, dentro da pasta do projeto:
   ```
   flutter pub get
   ```

5. Insira sua chave da Google Directions API em
   `lib/services/directions_service.dart`, na linha:
   ```dart
   static const String _apiKey = 'SUA_CHAVE_AQUI';
   ```
   (veja o passo a passo de como conseguir a chave nas instruções que te
   passei sobre o Google Cloud Console)

## Permissões necessárias

### Android (`android/app/src/main/AndroidManifest.xml`)
Adicione estas linhas dentro da tag `<manifest>`, antes de `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### iOS (`ios/Runner/Info.plist`)
Adicione estas chaves dentro da tag `<dict>`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para calcular a rota até o destino.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Precisamos do microfone para você buscar o destino por voz.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Precisamos reconhecer sua fala para buscar o destino.</string>
```

## Fluxo do app (o que já está pronto nesta Sprint 1)

1. **HomeScreen** — tela inicial, já fala em voz alta uma saudação e instrução
   de uso ao abrir. Toque em qualquer lugar leva para a busca.
2. **SearchScreen** — o usuário digita OU fala o destino (botão de microfone
   usando `speech_to_text`). Ao confirmar, navega para a tela de navegação.
3. **NavigationScreen** — pega a localização atual do usuário (GPS), chama a
   `DirectionsService` (que consulta a Google Directions API), e lê a
   primeira instrução em voz alta automaticamente. Botões "Repetir" e
   "Próxima" controlam a leitura passo a passo.
4. **DirectionsService** — isola toda a lógica de comunicação com a API de
   mapas, devolvendo uma lista simples de `PassoRota` (instrução + distância)
   já sem tags HTML, pronta para ser lida pelo TTS.

## O que falta para a Sprint 2 (não está neste pacote)

- Tratamento de erros mais refinado (ex: sem sinal de GPS, destino ambíguo)
- Atualização automática da instrução conforme o usuário se desloca de
  verdade (aqui o avanço é manual, pelo botão "Próxima")
- Testes reais de acessibilidade com TalkBack/VoiceOver ativados
- Ajustes de UI com base em feedback da associação

## Observação de segurança

Nunca suba sua chave de API (`_apiKey`) para um repositório público no
GitHub. Para o projeto de semestre, uma alternativa simples é usar variáveis
de ambiente do Flutter (`--dart-define`) ou um arquivo `.env` no `.gitignore`
— posso te ajudar a configurar isso se quiser deixar mais seguro.
