# Mock Backend (json-server)

API REST mock para o app Flutter de centro de diagnosticos. Usa [json-server](https://github.com/typicode/json-server).

## Como rodar

```bash
cd mock_backend
npm install
npm start
```

Servidor sobe em `http://localhost:3000` (ou `http://10.0.2.2:3000` quando acessado pelo emulador Android).

## Endpoints

| Metodo | URL | Descricao |
|--------|-----|-----------|
| GET | `/api/me` | Dados do usuario logado |
| GET | `/api/exam-types` | Tipos de exame disponiveis |
| GET | `/api/appointments` | Lista de agendamentos |
| POST | `/api/appointments` | Cria novo agendamento |
| DELETE | `/api/appointments/:id` | Cancela agendamento |
| GET | `/api/results` | Lista de resultados de exames |
| GET | `/api/units` | Lista de unidades |
| GET | `/api/auth` | Dados de auth (mock - apenas para o app validar) |

## Como o app se conecta

- **Emulador Android**: usa `http://10.0.2.2:3000` (10.0.2.2 eh o alias para localhost do host no AVD).
- **Dispositivo fisico**: troque por `http://<ip-da-sua-maquina>:3000` em `lib/services/api_service.dart`.
- **iOS Simulator**: usa `http://localhost:3000`.

A URL base esta em `ApiService.baseUrl`.
