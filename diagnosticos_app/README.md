# Centro de Diagnosticos - App (Estudo de UI/UX)

App Android em Flutter que reproduz o padrao visual e de navegacao de um app de centro de diagnosticos medicos (inspirado no app do Hcor Centro de Diagnosticos). **Projeto exclusivamente para estudo de UI/UX** — todos os dados sao mock.

## Aviso legal

Este projeto NAO eh oficial nem afiliado ao Hcor (Hospital do Coracao). A marca "Hcor", logos e identidade visual oficial sao propriedade do Hospital do Coracao. Antes de qualquer uso publico, troque cores/nome/icones por identidade visual propria.

## Features

- **Telas**: Splash, Login, Home (bottom nav), Agendamentos, Resultados, Unidades, Perfil, Agendar exame, Preparos
- **Estado**: [Riverpod 2](https://riverpod.dev) (StateNotifier + FutureProvider)
- **Backend mock**: [json-server](https://github.com/typicode/json-server) com REST API
- **Autenticacao**: CPF + senha **OU** biometria (digital/face) via [local_auth](https://pub.dev/packages/local_auth)
- **Notificacoes**: lembrete local de exame 24h antes via [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Persistencia**: token e preferencias via [shared_preferences](https://pub.dev/packages/shared_preferences)

## Arquitetura

```
lib/
├── main.dart                       # ProviderScope + init notifications
├── theme/app_theme.dart            # Cores, fontes, ThemeData
├── models/models.dart              # Modelos de dominio
├── services/
│   ├── api_service.dart            # HTTP client (json-server)
│   ├── auth_service.dart           # Login + biometria
│   └── notification_service.dart   # Local notifications + scheduling
├── providers/providers.dart        # Riverpod providers (auth, user, exams, etc.)
├── widgets/                        # Componentes reutilizaveis
└── screens/                        # Telas (ConsumerWidget / ConsumerStatefulWidget)

mock_backend/
├── db.json                         # Dados mock
├── routes.json                     # Roteamento /api/*
├── package.json                    # json-server dependency
└── README.md
```

## Como rodar

### 1. Subir o backend mock

```bash
cd mock_backend
npm install
npm start
# Servidor sobe em http://localhost:3000
```

### 2. Gerar estrutura nativa do Flutter (primeira vez)

```bash
cd ..  # volta pra raiz do diagnosticos_app
flutter create --project-name diagnosticos_app .
flutter pub get
```

### 3. Configurar permissoes Android

Apos `flutter create`, edite `android/app/src/main/AndroidManifest.xml` e adicione **dentro de `<manifest>` antes de `<application>`**:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

Em `android/app/src/main/kotlin/.../MainActivity.kt`, troque por **FragmentActivity** (necessario para local_auth):

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity()
```

E em `android/app/build.gradle` confirme `minSdkVersion 21` ou superior.

Para o emulador Android acessar o json-server no host, use `10.0.2.2:3000` (ja configurado em `lib/services/api_service.dart`).

### 4. Rodar o app

```bash
flutter run
```

## Credenciais de teste

- **CPF**: `123.456.789-00`
- **Senha**: `123456`

## Fluxos para testar

1. **Login basico** → CPF + senha → home
2. **Habilitar biometria** → Perfil → toggle "Login por biometria" → autentica → relogin pela biometria
3. **Agendar exame** → Home → "Agendar exame" → completa 4 passos → confirma → notificacao agendada para 24h antes
4. **Cancelar agendamento** → Agenda → "Cancelar" no card → POST DELETE pro json-server
5. **Pull to refresh** em Home, Agenda, Resultados, Unidades → re-fetch da API
6. **Offline** → derruba o json-server → telas mostram erro com "Tentar novamente"
7. **Notificacoes** → Perfil → toggle "Notificacoes" → mostra notificacao instantanea de teste

## Notas sobre push notifications

Este projeto usa **notificacoes locais** (`flutter_local_notifications`) que rodam no dispositivo sem servidor — perfeito pra estudo de UX de lembretes. Para notificacoes **remotas** (push push), seria necessario adicionar Firebase Cloud Messaging:

```yaml
# pubspec.yaml
firebase_core: ^3.x.x
firebase_messaging: ^15.x.x
```

E configurar projeto Firebase + `google-services.json`. Fica como proximo passo.

## Proximos passos sugeridos

- Trocar identidade visual (logo, nome, cores) por uma propria
- Adicionar FCM para push notifications reais
- Implementar visualizador de PDF para resultados (`syncfusion_flutter_pdfviewer`)
- Adicionar testes de widget e integration tests
- Implementar code generation com `riverpod_generator` + `freezed` para reduzir boilerplate
- Adicionar cache local com `hive` ou `drift` para offline-first
