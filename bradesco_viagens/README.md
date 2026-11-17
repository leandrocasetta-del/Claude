# Viagens BPB – Gerenciador de viagens corporativas (protótipo)

PWA (`www/`) empacotado como APK Android via Capacitor.

- **Editar dados:** `www/data.js` (perfil, viagens, política, contatos).
- **Trocar o logo:** substitua `www/assets/logo.svg` (ou use PNG e ajuste `index.html`).
- **Rodar no navegador:** `cd www && python3 -m http.server 8080`
- **Gerar APK:** `npm ci && npx cap sync android && cd android && ./gradlew assembleDebug`
  (requer JDK 17 e Android SDK). APK pronto em `dist/viagens-bpb-debug.apk`.
