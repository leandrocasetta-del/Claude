# Centro de Diagnosticos - App (Estudo de UI/UX)

App Android em Flutter que reproduz o padrao visual e de navegacao de um app de centro de diagnosticos medicos (inspirado no app do Hcor Centro de Diagnosticos). **Projeto exclusivamente para estudo de UI/UX** — todos os dados sao mock.

## Aviso legal

Este projeto NAO eh oficial nem afiliado ao Hcor (Hospital do Coracao). A marca "Hcor", logos, identidade visual oficial e nome sao propriedade do Hospital do Coracao. Antes de qualquer uso publico (publicacao em loja, divulgacao em portfolio publico, etc), troque cores/nome/icones por uma identidade visual propria para evitar problemas de marca/copyright.

## Telas implementadas

- **Splash** — tela de abertura com logo
- **Login** — autenticacao por CPF e senha (mock — qualquer valor entra)
- **Home** — saudacao, proximo agendamento, grid de servicos, destaques
- **Agendamentos** — abas "Proximos" e "Historico" com cards de exames
- **Resultados** — lista de laudos com badge "NOVO" e bottom sheet de acoes
- **Unidades** — lista de unidades com endereco, telefone, horarios
- **Perfil** — dados pessoais, configuracoes, sair
- **Agendar exame** — fluxo de 4 passos: categoria → exame → unidade → data/hora
- **Preparos** — instrucoes de preparo por tipo de exame (ExpansionTile)

## Stack

- Flutter 3.10+ / Dart 3+
- Material 3
- google_fonts (Inter)
- intl + flutter_localizations (pt_BR)

## Como rodar

```bash
# 1. Entre na pasta
cd diagnosticos_app

# 2. Gere a estrutura nativa (android/, ios/) se ainda nao existir
flutter create --project-name diagnosticos_app .

# 3. Instale dependencias
flutter pub get

# 4. Rode num emulador ou dispositivo
flutter run
```

Se voce ja tem o projeto Android conectado, basta:

```bash
flutter pub get
flutter run
```

## Estrutura

```
lib/
├── main.dart                # Entry point
├── theme/
│   └── app_theme.dart       # Cores, fontes, ThemeData
├── models/
│   └── models.dart          # ExamType, Appointment, ExamResult, Unit, UserProfile
├── data/
│   └── mock_data.dart       # Dados ficticios
├── widgets/
│   ├── service_card.dart    # Card de servico do grid da home
│   └── section_header.dart  # Header de secao com acao
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── home_shell.dart       # Scaffold com bottom nav
    ├── home_screen.dart
    ├── appointments_screen.dart
    ├── results_screen.dart
    ├── units_screen.dart
    ├── profile_screen.dart
    ├── schedule_exam_screen.dart
    └── preparation_screen.dart
```

## Proximos passos sugeridos

- Trocar identidade visual (logo, nome, cores) por uma propria
- Adicionar gerenciamento de estado (Provider, Riverpod ou Bloc)
- Plugar backend mock (json_server, fastapi, etc) ou Firebase
- Adicionar autenticacao biometrica (local_auth)
- Adicionar push notifications (firebase_messaging)
- Implementar visualizador de PDF para resultados
- Adicionar testes de widget
