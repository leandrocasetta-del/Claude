# Segundo Cérebro 🧠

App Android nativo (Kotlin + Jetpack Compose) que acompanha sua vida, conversa com você por texto e voz, e age como seu segundo cérebro — conectado ao Claude (Anthropic).

## O que ele faz

- **Chat com IA** — converse por texto ou voz (🎙️ reconhecimento de fala + leitura das respostas em voz alta)
- **Tarefas** — a IA cria, conclui e apaga tarefas durante a conversa ("anota aí: pagar o aluguel sexta")
- **Diário e humor** — registre o dia manualmente ou apenas desabafe no chat; a IA registra por você
- **Memória de longo prazo** — a IA guarda fatos duradouros sobre você (rotina, pessoas, objetivos) e usa esse contexto em toda conversa; você revisa e apaga o que quiser na aba Memória
- **Lembretes** — "me lembra amanhã às 9h de ligar pro médico" agenda uma notificação no celular

## Como a IA funciona

O app chama a Messages API da Anthropic diretamente do celular (modelo `claude-opus-4-8`), com *tool use*: o modelo tem ferramentas para criar tarefas, registrar diário, salvar memórias e agendar lembretes. A cada conversa, o app monta um contexto com suas memórias, tarefas abertas e últimas entradas do diário.

## Configuração

1. Crie uma chave de API em [console.anthropic.com](https://console.anthropic.com) → API Keys (uso é pago por consumo; conversas típicas custam centavos)
2. Instale o APK (gerado pelo GitHub Actions em cada push — artifact `SegundoCerebro-debug-*`)
3. Abra o app → aba **Ajustes** → cole a chave e salve

## Privacidade

- Todos os dados (tarefas, diário, memórias, conversa) ficam **apenas no aparelho**, em arquivos locais do app
- A chave de API é armazenada com criptografia (EncryptedSharedPreferences)
- O contexto relevante é enviado à API da Anthropic a cada mensagem para a IA te conhecer

## Build local

```bash
cd SecondBrain
gradle assembleDebug   # requer Android SDK + Gradle 8.7 / Java 17
```

O APK sai em `app/build/outputs/apk/debug/app-debug.apk`.
