# CLAUDE.md — Curva: Futebol Arcade

Contexto para o agente Claude Code trabalhando neste projeto.

## O que é
Jogo de futebol arcade para Android. Diferencial central: **chute em curva por swipe** —
o jogador arrasta o dedo e a curvatura do gesto vira a curvatura da bola no ar (efeito Magnus).
O jogo inteiro é um **arquivo único** em `www/index.html` (HTML5 + Canvas + JS puro, sem build, sem dependências em runtime).

## Estrutura
```
curva-futebol/
  www/
    index.html        # o jogo (fonte única)
    manifest.json     # PWA (também usado pela rota TWA)
    icons/            # icon-192, icon-512, icon-512-maskable
  assets/             # ícones master (loja + adaptativo)
    icon_master_1024.png
    icon_foreground_1024.png   # foreground do ícone adaptativo (fundo transparente)
  tools/genicons.py   # regenera os PNGs (pure Python, sem libs)
  docs/kit-lancamento.md
  .github/workflows/android-aab.yml  # CI: build do .aab assinado
  capacitor.config.json
  package.json
```

## Estado atual
- [x] Jogo jogável (mecânica de curva, goleiro com IA, barreira, placar, streak, 10 chutes).
- [x] PWA manifest + ícones gerados.
- [x] Capacitor configurado (`appId: com.curva.futebol`, `webDir: www`).
- [x] Workflow de CI que gera um `.aab` assinado (precisa dos secrets do keystore).
- [ ] `npm install && npm run add:android` precisa rodar em máquina com Android SDK (ou no CI).
- [ ] Keystore de release real + cadastro na Play Console.

## Testar local
Abra `www/index.html` no Chrome em modo mobile/retrato. Não precisa de servidor.

## Empacotar Android (Capacitor)
Pré-requisitos: Node LTS, Android Studio (SDK + JDK 17).
```bash
npm install
npm run add:android   # cap add android
npm run sync          # cap sync
npm run open:android  # abre no Android Studio
```
No Android Studio: trave orientação retrato, configure o ícone adaptativo
(foreground = `assets/icon_foreground_1024.png`, background = `#06121F`),
e gere o AAB assinado. Detalhes na `docs/kit-lancamento.md`.

## Regras de conteúdo (importante)
Conteúdo 100% original. **Não** usar marcas, times, jogadores, escudos ou uniformes reais,
nem "FIFA"/"World Cup"/"Copa do Mundo". Paleta e marca são próprias (navy `#06121F` + verde/ciano).

## Regenerar ícones
`python3 tools/genicons.py` — não depende de PIL/ImageMagick.
