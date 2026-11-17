/* =========================================================
   DADOS DO APP — EDITE AQUI.
   Tudo abaixo é PROVISÓRIO/FICTÍCIO até você enviar as viagens reais.
   Valores em BRL. Datas no formato AAAA-MM-DD.
   ========================================================= */
window.PROFILE = {
  nome: "Leandro Casetta",          // << confirmar nome completo
  funcional: "I414962",
  cargo: "Private Bank",            // << ajustar cargo/área
  centroCusto: "CC 4410 – Private Bank",
  gestor: "Gestor Imediato (a definir)",
  alcadaDiaria: 1800,               // limite de diária de hotel (política)
  cartaoCorporativo: "Bradesco Corporate •••• 4821"
};

window.POLICY = [
  "Solicitações devem ser feitas com no mínimo 7 dias de antecedência (viagens nacionais) e 14 dias (internacionais).",
  "Classe econômica para voos até 6h; executiva permitida acima de 6h mediante aprovação da diretoria.",
  "Limite de diária de hotel: R$ 1.800 (nacional) e US$ 450 (internacional).",
  "Despesas devem ser prestadas contas em até 5 dias úteis após o retorno.",
  "Viagens internacionais exigem aprovação de Compliance e checagem de países de risco.",
  "Reservas fora da política exigem justificativa e aprovação adicional."
];

window.CONTACTS = [
  { nome: "Agência Corporativa de Viagens", fone: "+55 11 4000-0000", obs: "24h – emissão e remarcação" },
  { nome: "Assistência ao Viajante", fone: "+55 11 4000-0001", obs: "Seguro viagem e emergências" },
  { nome: "Segurança Corporativa", fone: "+55 11 4000-0002", obs: "Alertas de risco por destino" }
];

/* status da viagem: solicitada | aprovada | bookada | andamento | concluida | cancelada
   status do item de custo: estimado | reservado | pago | reembolsado */
window.TRIPS = [
  {
    id: "V-2026-0187", destino: "Nova York, EUA", origem: "São Paulo (GRU)", tipo: "Internacional",
    motivo: "Private Bank Wealth Summit", inicio: "2026-12-08", fim: "2026-12-13",
    status: "bookada", orcamento: 38000, centro: "CC 4410",
    voos: [
      { cia: "American Airlines", num: "AA 904", de: "GRU", para: "JFK", saida: "2026-12-08 22:10", chegada: "2026-12-09 06:15", classe: "Executiva", loc: "QWX7LP", assento: "3A", valor: 14800, status: "reservado" },
      { cia: "American Airlines", num: "AA 905", de: "JFK", para: "GRU", saida: "2026-12-13 21:40", chegada: "2026-12-14 08:55", classe: "Executiva", loc: "QWX7LP", assento: "3A", valor: 0, status: "reservado" }
    ],
    hoteis: [
      { nome: "The Westin New York Grand Central", cidade: "Nova York", checkin: "2026-12-09", checkout: "2026-12-13", diaria: 2350, noites: 4, loc: "HTL-88213", valor: 9400, status: "reservado", cancelamento: "Grátis até 05/12" }
    ],
    extras: [
      { desc: "Seguro viagem internacional", valor: 420, status: "pago" },
      { desc: "Traslado (estimado)", valor: 900, status: "estimado" },
      { desc: "Alimentação – diárias (estimado)", valor: 3200, status: "estimado" }
    ],
    aprovacoes: [
      { etapa: "Solicitante", quem: "Você", status: "ok", data: "2026-10-28", obs: "Solicitação enviada" },
      { etapa: "Gestor imediato", quem: "Gestor", status: "ok", data: "2026-10-29", obs: "Aprovado" },
      { etapa: "Diretoria", quem: "Diretoria Private", status: "ok", data: "2026-10-31", obs: "Classe executiva autorizada (voo > 6h)" },
      { etapa: "Compliance", quem: "Compliance", status: "ok", data: "2026-11-03", obs: "Destino sem restrições" },
      { etapa: "Agência / Emissão", quem: "Agência", status: "ok", data: "2026-11-05", obs: "Bilhetes emitidos" }
    ],
    documentos: ["Passaporte válido até 2031 ✔", "Visto/ESTA ✔ (ESTA válido até 2028)", "Seguro viagem ✔", "Cartão de embarque (disponível 24h antes)"]
  },
  {
    id: "V-2026-0201", destino: "Brasília, DF", origem: "São Paulo (CGH)", tipo: "Nacional",
    motivo: "Reunião institucional – Banco Central", inicio: "2026-11-24", fim: "2026-11-25",
    status: "bookada", orcamento: 5200, centro: "CC 4410",
    voos: [
      { cia: "LATAM", num: "LA 3314", de: "CGH", para: "BSB", saida: "2026-11-24 07:05", chegada: "2026-11-24 08:55", classe: "Econômica", loc: "MNB4TR", assento: "12C", valor: 1180, status: "reservado" },
      { cia: "LATAM", num: "LA 3329", de: "BSB", para: "CGH", saida: "2026-11-25 19:30", chegada: "2026-11-25 21:20", classe: "Econômica", loc: "MNB4TR", assento: "14A", valor: 960, status: "reservado" }
    ],
    hoteis: [
      { nome: "Brasil 21 Suites", cidade: "Brasília", checkin: "2026-11-24", checkout: "2026-11-25", diaria: 690, noites: 1, loc: "HTL-55120", valor: 690, status: "reservado", cancelamento: "Grátis até 23/11" }
    ],
    extras: [
      { desc: "Táxi/App (estimado)", valor: 300, status: "estimado" },
      { desc: "Alimentação (estimado)", valor: 400, status: "estimado" }
    ],
    aprovacoes: [
      { etapa: "Solicitante", quem: "Você", status: "ok", data: "2026-11-05", obs: "Solicitação enviada" },
      { etapa: "Gestor imediato", quem: "Gestor", status: "ok", data: "2026-11-06", obs: "Aprovado" },
      { etapa: "Agência / Emissão", quem: "Agência", status: "ok", data: "2026-11-07", obs: "Bilhetes emitidos" }
    ],
    documentos: ["Documento com foto ✔", "Cartão de embarque (check-in abre 24h antes)"]
  },
  {
    id: "V-2026-0209", destino: "Rio de Janeiro, RJ", origem: "São Paulo (CGH)", tipo: "Nacional",
    motivo: "Visita a clientes Private", inicio: "2026-11-16", fim: "2026-11-18",
    status: "andamento", orcamento: 5600, centro: "CC 4410",
    voos: [
      { cia: "GOL", num: "G3 1832", de: "CGH", para: "SDU", saida: "2026-11-16 06:50", chegada: "2026-11-16 07:50", classe: "Econômica", loc: "ZKT9AB", assento: "9D", valor: 740, status: "pago" },
      { cia: "GOL", num: "G3 1851", de: "SDU", para: "CGH", saida: "2026-11-18 20:15", chegada: "2026-11-18 21:15", classe: "Econômica", loc: "ZKT9AB", assento: "9D", valor: 690, status: "pago" }
    ],
    hoteis: [
      { nome: "Hotel Fasano Rio (corporativo)", cidade: "Rio de Janeiro", checkin: "2026-11-16", checkout: "2026-11-18", diaria: 1650, noites: 2, loc: "HTL-70331", valor: 3300, status: "pago", cancelamento: "Não reembolsável" }
    ],
    extras: [
      { desc: "Táxi/App", valor: 210, status: "pago" },
      { desc: "Almoço com clientes", valor: 480, status: "pago" }
    ],
    aprovacoes: [
      { etapa: "Solicitante", quem: "Você", status: "ok", data: "2026-11-02", obs: "Solicitação enviada" },
      { etapa: "Gestor imediato", quem: "Gestor", status: "ok", data: "2026-11-03", obs: "Aprovado" },
      { etapa: "Agência / Emissão", quem: "Agência", status: "ok", data: "2026-11-04", obs: "Bilhetes emitidos" }
    ],
    documentos: ["Documento com foto ✔"]
  },
  {
    id: "V-2027-0012", destino: "Lisboa, Portugal", origem: "São Paulo (GRU)", tipo: "Internacional",
    motivo: "Reunião com parceiros europeus", inicio: "2027-02-09", fim: "2027-02-13",
    status: "solicitada", orcamento: 29500, centro: "CC 4410",
    voos: [
      { cia: "TAP Air Portugal", num: "TP 82", de: "GRU", para: "LIS", saida: "2027-02-09 22:30", chegada: "2027-02-10 11:20", classe: "Executiva", loc: "— (cotação)", assento: "—", valor: 13600, status: "estimado" },
      { cia: "TAP Air Portugal", num: "TP 83", de: "LIS", para: "GRU", saida: "2027-02-13 12:50", chegada: "2027-02-13 19:00", classe: "Executiva", loc: "— (cotação)", assento: "—", valor: 0, status: "estimado" }
    ],
    hoteis: [
      { nome: "Hotel Avenida Palace", cidade: "Lisboa", checkin: "2027-02-10", checkout: "2027-02-13", diaria: 2100, noites: 3, loc: "— (cotação)", valor: 6300, status: "estimado", cancelamento: "Grátis até 05/02" }
    ],
    extras: [
      { desc: "Seguro viagem", valor: 380, status: "estimado" },
      { desc: "Alimentação/traslados (estimado)", valor: 2800, status: "estimado" }
    ],
    aprovacoes: [
      { etapa: "Solicitante", quem: "Você", status: "ok", data: "2026-11-14", obs: "Solicitação enviada" },
      { etapa: "Gestor imediato", quem: "Gestor", status: "pendente", data: "", obs: "Aguardando análise" },
      { etapa: "Diretoria", quem: "Diretoria Private", status: "aguardando", data: "", obs: "Classe executiva requer aprovação" },
      { etapa: "Compliance", quem: "Compliance", status: "aguardando", data: "", obs: "" },
      { etapa: "Agência / Emissão", quem: "Agência", status: "aguardando", data: "", obs: "" }
    ],
    documentos: ["Passaporte válido ✔", "Seguro viagem (pendente)"],
    alertas: ["Acima do orçamento sugerido para classe executiva — justificativa enviada"]
  },
  {
    id: "V-2026-0164", destino: "Miami, EUA", origem: "São Paulo (GRU)", tipo: "Internacional",
    motivo: "Conferência de Wealth Management", inicio: "2026-10-05", fim: "2026-10-09",
    status: "concluida", orcamento: 26000, centro: "CC 4410", prestacao: "pendente",
    voos: [
      { cia: "LATAM", num: "LA 8084", de: "GRU", para: "MIA", saida: "2026-10-05 23:00", chegada: "2026-10-06 05:50", classe: "Executiva", loc: "RTY2KD", assento: "2K", valor: 12900, status: "pago" },
      { cia: "LATAM", num: "LA 8085", de: "MIA", para: "GRU", saida: "2026-10-09 22:20", chegada: "2026-10-10 08:10", classe: "Executiva", loc: "RTY2KD", assento: "2K", valor: 0, status: "pago" }
    ],
    hoteis: [
      { nome: "JW Marriott Marquis Miami", cidade: "Miami", checkin: "2026-10-06", checkout: "2026-10-09", diaria: 2200, noites: 3, loc: "HTL-41987", valor: 6600, status: "pago", cancelamento: "—" }
    ],
    extras: [
      { desc: "Uber (3 corridas)", valor: 520, status: "pago" },
      { desc: "Jantar com clientes", valor: 1850, status: "pago" },
      { desc: "Seguro viagem", valor: 410, status: "pago" }
    ],
    aprovacoes: [
      { etapa: "Solicitante", quem: "Você", status: "ok", data: "2026-09-10", obs: "" },
      { etapa: "Gestor imediato", quem: "Gestor", status: "ok", data: "2026-09-11", obs: "" },
      { etapa: "Diretoria", quem: "Diretoria Private", status: "ok", data: "2026-09-12", obs: "" },
      { etapa: "Compliance", quem: "Compliance", status: "ok", data: "2026-09-15", obs: "" },
      { etapa: "Agência / Emissão", quem: "Agência", status: "ok", data: "2026-09-16", obs: "" }
    ],
    documentos: ["Comprovantes enviados (parcial)", "Nota do jantar — pendente"]
  },
  {
    id: "V-2026-0150", destino: "Zurique, Suíça", origem: "São Paulo (GRU)", tipo: "Internacional",
    motivo: "Reunião com banco correspondente", inicio: "2026-09-21", fim: "2026-09-25",
    status: "cancelada", orcamento: 34000, centro: "CC 4410",
    voos: [], hoteis: [], extras: [],
    aprovacoes: [
      { etapa: "Solicitante", quem: "Você", status: "ok", data: "2026-08-20", obs: "" },
      { etapa: "Gestor imediato", quem: "Gestor", status: "ok", data: "2026-08-21", obs: "" },
      { etapa: "Diretoria", quem: "Diretoria Private", status: "negado", data: "2026-08-25", obs: "Reunião realizada por videoconferência" }
    ],
    documentos: []
  }
];

window.USD_BRL = 5.45; // cotação de referência (provisória)
