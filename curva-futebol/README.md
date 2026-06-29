# Curva: Futebol Arcade

Jogo de futebol arcade para Android. Diferencial: **chute em curva por swipe** — a curva
do seu gesto vira a curva da bola no ar. O jogo inteiro é um arquivo único em
`www/index.html` (HTML5 + Canvas + JS puro, sem build).

## Testar local (sem empacotar)
Abra `www/index.html` no Chrome em modo mobile/retrato. Não precisa de servidor.

## Empacotar para Android (Capacitor)
Pré-requisitos: Node LTS, Android Studio (SDK + JDK 17).
```bash
npm install
npm run add:android   # cap add android
npm run sync          # cap sync
npm run open:android  # abre no Android Studio
```
Trave a orientação em retrato, configure o ícone adaptativo
(foreground = `assets/icon_foreground_1024.png`, background = `#06121F`) e gere o
**Android App Bundle (.aab)** assinado. Passo a passo em `docs/kit-lancamento.md`.

## Gerar o AAB pelo CI
O workflow `.github/workflows/android-aab.yml` roda `cap add android` + Gradle e gera um
`.aab` **assinado** quando os secrets do keystore estão configurados
(`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`). Sem eles, gera um
`.aab` de debug como artefato. Dispare em **Actions > Build Android AAB > Run workflow**.

## Conteúdo
100% original. Sem marcas, times, jogadores, escudos ou uniformes reais; sem
"FIFA"/"World Cup"/"Copa do Mundo". Ver alerta jurídico em `docs/kit-lancamento.md`.

## Estrutura
```
www/index.html        # o jogo (fonte única)
www/manifest.json     # PWA / TWA
www/icons/            # ícones do app
assets/               # ícones master (loja + adaptativo)
tools/genicons.py     # regenera os ícones (pure Python)
docs/kit-lancamento.md
capacitor.config.json
```
