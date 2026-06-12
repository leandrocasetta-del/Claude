# Hcor App (Estudo de UI/UX)

App Android em Flutter que reproduz fielmente 3 telas do app oficial do Hcor (Associacao Beneficente Siria): **Login**, **Pos-login** e **Resultado de exames**. **Projeto exclusivamente para estudo de UI/UX** — todos os dados sao mock e o login eh validado localmente, sem servidor.

## Aviso legal

Este projeto NAO eh oficial nem afiliado ao Hcor. A marca "hcor", logos e identidade visual sao propriedade da Associacao Beneficente Siria / Hospital do Coracao. Use apenas para estudo pessoal — nao publique em loja nem distribua.

## Telas

| Tela | Funcionalidade |
|------|----------------|
| Splash | Logo Hcor + loading enquanto checa se ja esta logado |
| Login | CPF/e-mail + senha + 4 atalhos circulares (duvidas, fale conosco, Portal Medico, suporte tecnico) |
| Pos-login | Avatar, nome, prontuario, data de nascimento + cards de menu (Resultado de exames, Meus agendamentos, Vacinas, Extrato, Doe aqui, Acesso temporario) |
| Resultado de exames | Filtro por data + tipo + busca + cards de pedido com Laudo completo / Laudo evolutivo / Detalhar |

## Credenciais

- **CPF/e-mail**: `32843725801` (tambem aceita `328.437.258-01`)
- **Senha**: `Rinmueck45@`

## Stack

- Flutter 3.10+
- Riverpod 2 (gerenciamento de estado)
- local_auth (biometria opcional)
- flutter_local_notifications (notificacoes locais)
- shared_preferences (token de sessao)
- google_fonts (Inter)

## Como rodar

### Opcao 1: Baixar o APK pronto (recomendado)

1. Va em https://github.com/leandrocasetta-del/Claude/actions
2. Clique no workflow mais recente "Build Android APK"
3. Baixe o artefato `diagnosticos-app-debug`
4. Descompacte e instale o `.apk` no celular

### Opcao 2: Rodar local

Pre-requisitos: Flutter SDK + Android Studio.

```bash
cd diagnosticos_app
flutter create --project-name diagnosticos_app --platforms android .
flutter pub get
flutter run
```

## Estrutura

```
lib/
├── main.dart                       # ProviderScope + init notifications
├── theme/app_theme.dart            # Paleta Hcor (roxo + ciano + azul + verde)
├── services/
│   ├── auth_service.dart           # Login local + biometria
│   └── notification_service.dart   # Local notifications
├── providers/providers.dart        # Riverpod (auth, notifications, biometric)
├── widgets/wave_header.dart        # Curva roxa de fundo
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── home_screen.dart
    └── results_screen.dart
```
