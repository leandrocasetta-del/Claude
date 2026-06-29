# Kit de Lançamento — Curva: Futebol Arcade

## 1. Alerta jurídico (leia primeiro)
Use **somente conteúdo original**. Não inclua marcas, nomes de times, jogadores,
escudos, uniformes ou estádios reais. Evite os termos "FIFA", "World Cup", "Copa do
Mundo" e qualquer logotipo de federação. Eles são marcas protegidas e bloqueiam a
publicação (ou geram takedown) na Play Store. A marca "Curva", a paleta navy/verde/ciano
e os ícones deste repositório são próprios.

## 2. Marca
- Nome: **Curva: Futebol Arcade** (short name: Curva).
- Conceito: a curva do swipe = a curva da bola.
- Cores: fundo `#06121F`, acento verde `#2ee6a6` → ciano `#29c2ff`.
- Tipografia: sans-serif pesada (system stack no app).
- Ícone: bola branca + swoosh em curva verde→ciano (`assets/icon_master_1024.png`).

## 3. ASO (App Store Optimization)
- **Título (até 30):** Curva: Futebol Arcade
- **Subtítulo curto (até 30):** Chute em curva no swipe
- **Descrição curta (até 80):** Arraste, curve o gesto e a bola curva no ar. Marque do impossível.
- **Palavras-chave:** futebol, arcade, chute, curva, falta, gol, swipe, casual, offline.
- **Descrição longa:** foco no diferencial (curva por gesto), modo offline, partidas rápidas
  de 10 chutes, dificuldade crescente, sem necessidade de conta.

## 4. Screenshots (Play exige 2–8)
Capture no Chrome em modo retrato (ex.: 1080×1920):
1. Tela de chute com a barreira e o goleiro.
2. Trilha de mira em curva durante o arraste.
3. Momento "GOL!" com o placar e o streak 🔥.
4. Tela de fim com pontuação.
Roteiro: DevTools > Toggle device toolbar > 1080×1920 > screenshot de página inteira.

## 5. Soft launch
Publique primeiro em **teste interno** (até 100 testadores por e-mail) ou **teste fechado**.
Valide crash-free, retenção D1 e tempo de sessão antes de promover para produção.

## 6. A/B (Play Console > Experimentos da ficha)
Teste variações de ícone (com/sem swoosh), primeira screenshot e descrição curta.
Rode cada experimento por pelo menos 7 dias com significância antes de aplicar.

## 7. Empacotamento e assinatura

### Rota recomendada: Capacitor
```bash
npm install
npm run add:android      # cap add android  (cria a pasta android/)
npm run sync             # cap sync
npm run open:android     # abre no Android Studio
```
No Android Studio:
- `applicationId = com.curva.futebol`, defina `versionCode`/`versionName`.
- Orientação retrato: no `android/app/src/main/AndroidManifest.xml`, na `<activity>`,
  adicione `android:screenOrientation="portrait"`.
- Ícone adaptativo (Image Asset Studio): foreground = `assets/icon_foreground_1024.png`,
  background = cor `#06121F`.
- `Build > Generate Signed Bundle/APK > Android App Bundle (.aab)`.

### Keystore (gerar uma vez, guardar com segurança)
```bash
keytool -genkeypair -v -keystore curva-release.jks \
  -alias curva -keyalg RSA -keysize 2048 -validity 10000
```
Guarde o `.jks` e as senhas fora do repositório. Ative o **Play App Signing** na Console
(o Google passa a gerenciar a chave de assinatura; sua chave de upload assina os envios).

### Rota alternativa: TWA (Trusted Web Activity)
Use Bubblewrap quando quiser empacotar o PWA diretamente:
```bash
npm i -g @bubblewrap/cli
bubblewrap init --manifest https://SEU_DOMINIO/manifest.json
bubblewrap build
```
Exige hospedar `www/` em HTTPS e configurar o Digital Asset Links.

### Build automatizado no CI
`.github/workflows/android-aab.yml` roda `cap add android` + Gradle e gera um `.aab`
**assinado** quando os secrets do keystore estão configurados (veja seção 8). Sem os
secrets, ele ainda gera um `.aab` de debug como artefato para inspeção.

## 8. Secrets do CI (Settings > Secrets and variables > Actions)
- `KEYSTORE_BASE64` — `base64 -w0 curva-release.jks`
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS` (ex.: `curva`)
- `KEY_PASSWORD`

## 9. Monetização (sugestões)
- **Rewarded ads:** assistir vídeo para ganhar +3 chutes ao perder.
- **Intersticial:** a cada 3 partidas, com frequência baixa.
- **Remoção de anúncios:** compra única (IAP).
- **Cosméticos:** trilhas de chute / bolas alternativas (cosmético, sem afetar gameplay).
Mantenha o jogo jogável e divertido offline antes de adicionar SDKs de anúncio.

## 10. Checklist de submissão
- [ ] AAB assinado com a chave de upload.
- [ ] Ícone 512×512 e feature graphic 1024×500.
- [ ] 2–8 screenshots retrato.
- [ ] Política de privacidade (URL) se houver anúncios/IAP.
- [ ] Classificação indicativa (questionário IARC).
- [ ] Data Safety preenchido.
