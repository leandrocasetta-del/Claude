import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExamDetailScreen extends StatelessWidget {
  const ExamDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laudo cardiologico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: const [
          _Header(),
          SizedBox(height: 12),
          _PatientCard(),
          SizedBox(height: 12),
          _ClinicalIndicationCard(),
          SizedBox(height: 16),
          _Ecg12LeadsSection(),
          SizedBox(height: 12),
          _HolterSection(),
          SizedBox(height: 12),
          _EcoTransthoracicSection(),
          SizedBox(height: 12),
          _ErgometricSection(),
          SizedBox(height: 12),
          _BiomarkersSection(),
          SizedBox(height: 12),
          _EteSection(),
          SizedBox(height: 12),
          _AngioCtSection(),
          SizedBox(height: 12),
          _CardiacMrSection(),
          SizedBox(height: 12),
          _EpsSection(),
          SizedBox(height: 12),
          _DiagnosticSummaryCard(),
          SizedBox(height: 16),
          _FictionalNotice(),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'CardioImagem Diagnosticos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Centro de Cardiologia Diagnostica e Imagem Cardiovascular',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Unidade Sao Paulo (instituicao ficticia)',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          SizedBox(height: 12),
          Text(
            'RELATORIO CONSOLIDADO DE EXAMES CARDIOLOGICOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12),
          _HeaderLine(label: 'Protocolo', value: '2026-CIM-008471'),
          _HeaderLine(label: 'Emissao', value: '10/06/2026 18:42'),
        ],
      ),
    );
  }
}

class _HeaderLine extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FictionalNotice extends StatelessWidget {
  const _FictionalNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        border: Border.all(color: const Color(0xFFE30613).withOpacity(0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'DOCUMENTO FICTICIO GERADO PARA SIMULACAO / FINS DIDATICOS - NAO POSSUI '
        'VALIDADE CLINICA OU DIAGNOSTICA',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFB00010),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _KeyValueRow(
            left: _KV('Paciente', 'Leandro Casetta'),
            right: _KV('Prontuario', '21356284'),
          ),
          _KeyValueRow(
            left: _KV('Sexo', 'Masculino'),
            right: _KV('Idade', '43 anos'),
          ),
          _KeyValueRow(
            left: _KV('Nascimento', '11/04/1983'),
            right: _KV('Convenio', 'Bradesco Empresas'),
          ),
          SizedBox(height: 8),
          _KV('Medico solicitante', 'Dr. Ricardo Casalino - CRM/SP 04641'),
          SizedBox(height: 4),
          _KV('Resp. tecnico', 'Dr. C. Tanaka - CRM/SP 05433-8 / RQE Cardiologia'),
        ],
      ),
    );
  }
}

class _ClinicalIndicationCard extends StatelessWidget {
  const _ClinicalIndicationCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Indicacao clinica',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Fibrilacao atrial (CID-10 I48) recorrente, documentada em '
            'monitorizacao, em ritmo sinusal no momento do registro. '
            'Avaliacao estrutural, isquemica e anatomica do coracao.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          SizedBox(height: 8),
          Text(
            'Observacao metodologica: cenario modelado como FA estabelecida/'
            'paroxistica atualmente em ritmo sinusal, para manter coerencia '
            'com o ECG sinusal. Resultados representam coracao estruturalmente '
            'normal (FA isolada / "lone AF").',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _Ecg12LeadsSection extends StatelessWidget {
  const _Ecg12LeadsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '1',
      title: 'Eletrocardiograma de repouso (12 derivacoes)',
      tag: 'Realizado em 10/06/2026',
      technique:
          'ECG digital de 12 derivacoes simultaneas, 25 mm/s, 10 mm/mV, '
          'filtro 0,05-150 Hz. Paciente em repouso, decubito dorsal.',
      rows: const [
        _Row('Ritmo', 'Sinusal', 'Sinusal', '', _Flag.normal),
        _Row('Frequencia cardiaca', '64', '60-100', 'bpm', _Flag.normal),
        _Row('Onda P (duracao)', '102', '< 110', 'ms', _Flag.normal),
        _Row('Eixo da onda P', '+58', '0 a +75', 'graus', _Flag.normal),
        _Row('Intervalo PR', '158', '120-200', 'ms', _Flag.normal),
        _Row('Duracao do QRS', '92', '< 120', 'ms', _Flag.normal),
        _Row('Eixo do QRS', '+42', '-30 a +90', 'graus', _Flag.normal),
        _Row('QT / QTc (Bazett)', '386 / 408', 'QTc < 450 (H)', 'ms', _Flag.normal),
        _Row('Sokolow-Lyon (HVE)', '26', '< 35', 'mm', _Flag.normal),
      ],
      bullets: const [
        'Onda P de morfologia normal, sem sinais de sobrecarga atrial '
            'esquerda ou direita.',
        'Progressao de onda R normal nas precordiais; ausencia de ondas Q '
            'patologicas.',
        'Segmento ST isoeletrico; ondas T de polaridade e amplitude normais. '
            'Sem alteracoes de repolarizacao.',
        'Sem bloqueios de ramo, sem pre-excitacao (ausencia de onda delta), '
            'sem extrassistoles no tracado.',
      ],
      impression:
          'ECG dentro dos limites da normalidade. Ritmo sinusal regular. '
          'Sem criterios de hipertrofia, isquemia ou disturbio de conducao. '
          '(FA nao presente neste registro pontual.)',
    );
  }
}

class _HolterSection extends StatelessWidget {
  const _HolterSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '2',
      title: 'Holter de 24 horas',
      tag: '24h05min - sinusal predominante',
      technique:
          'Sistema de 3 canais, 24h05min de registro valido (98,7% analisavel). '
          'Diario de atividades correlacionado.',
      rows: const [
        _Row('Ritmo de base predominante', 'Sinusal', 'Sinusal', '', _Flag.normal),
        _Row('FC minima (sono)', '49', '> 40', 'bpm', _Flag.normal),
        _Row('FC media (24h)', '67', '60-100', 'bpm', _Flag.normal),
        _Row('FC maxima (esforco)', '141', '< FCMP', 'bpm', _Flag.normal),
        _Row('Episodios de FA paroxistica', '2', 'Achado', 'n', _Flag.achado),
        _Row('Duracao do maior episodio de FA', '2h41min', '-', '', _Flag.achado),
        _Row(
            'Resposta ventricular media na FA', '98', '< 110 (controlada)', 'bpm', _Flag.controlada),
        _Row('Pausas > 3,0 s', '0', '0', 'n', _Flag.normal),
        _Row('BAV de 2o / 3o grau', 'Ausente', 'Ausente', '', _Flag.normal),
        _Row('Extrassistoles supraventriculares', '412 (0,4%)', '< 1% do total', 'n/24h', _Flag.normal),
        _Row('Extrassistoles ventriculares', '38 (<0,1%)', '< 1% do total', 'n/24h', _Flag.normal),
        _Row('TV nao sustentada', 'Ausente', 'Ausente', '', _Flag.normal),
      ],
      bullets: const [
        'Ritmo sinusal predominante, interrompido por 2 episodios autolimitados '
            'de FA paroxistica, com resposta ventricular controlada e sem '
            'sintomas correlacionados graves no diario.',
        'Extrassistolia supraventricular e ventricular de baixa densidade, '
            'isolada, monomorfica; sem formas repetitivas complexas.',
        'Sem pausas significativas e sem disturbio de conducao de alto grau.',
      ],
      impression:
          'Ritmo sinusal predominante com episodios de fibrilacao atrial '
          'paroxistica de resposta ventricular controlada (documenta o '
          'diagnostico de FA). Sem pausas, bloqueios ou arritmia ventricular '
          'complexa.',
    );
  }
}

class _EcoTransthoracicSection extends StatelessWidget {
  const _EcoTransthoracicSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '3',
      title: 'Ecocardiograma transtoracico com Doppler',
      tag: 'Em ritmo sinusal durante o exame',
      technique:
          'Transtoracico bidimensional, modo-M, Doppler colorido, pulsado, '
          'continuo e tecidual. Janelas adequadas. Medidas em ritmo sinusal.',
      subgroups: const [
        _SubGroup(
          label: 'ATRIOS E AORTA',
          rows: [
            _Row('Atrio esquerdo (diametro)', '36', '< 40', 'mm', _Flag.normal),
            _Row('AE (volume indexado)', '28', '< 34', 'mL/m2', _Flag.normal),
            _Row('Raiz da aorta', '31', '< 40', 'mm', _Flag.normal),
          ],
        ),
        _SubGroup(
          label: 'VENTRICULO ESQUERDO',
          rows: [
            _Row('Diametro diastolico (DDVE)', '50', '42-58', 'mm', _Flag.normal),
            _Row('Diametro sistolico (DSVE)', '32', '25-40', 'mm', _Flag.normal),
            _Row('Septo interventricular', '9', '6-11', 'mm', _Flag.normal),
            _Row('Parede posterior', '9', '6-11', 'mm', _Flag.normal),
            _Row('Massa de VE indexada', '84', '< 115', 'g/m2', _Flag.normal),
            _Row('FE (Simpson biplano)', '62', '>= 52', '%', _Flag.normal),
            _Row('Contratilidade segmentar', 'Preservada', 'Sem deficit', '', _Flag.normal),
          ],
        ),
        _SubGroup(
          label: 'FUNCAO DIASTOLICA E CAMARAS DIREITAS',
          rows: [
            _Row('Relacao E/A', '1,2', '0,8-2,0', '', _Flag.normal),
            _Row("Relacao E/e' media", '7', '< 14', '', _Flag.normal),
            _Row('TAPSE (funcao de VD)', '23', '> 17', 'mm', _Flag.normal),
            _Row('PSAP estimada', '24', '< 35', 'mmHg', _Flag.normal),
            _Row('Veia cava inferior', 'Normal, colaba >50%', '< 21 mm', '', _Flag.normal),
          ],
        ),
      ],
      bullets: const [
        'Valvas: mitral, aortica, tricuspide e pulmonar de morfologia e '
            'mobilidade normais. Sem estenoses; refluxos ausentes ou triviais. '
            'Caracteriza FA nao valvar.',
        'Pericardio: sem derrame; espessura normal. Massas/trombos: nao '
            'visualizados (metodo pouco sensivel para apendice atrial esquerdo).',
        'Funcao diastolica normal; pressoes de enchimento normais.',
      ],
      impression:
          'Ecocardiograma dentro da normalidade. Camaras de dimensoes normais, '
          'funcao sistolica biventricular preservada, funcao diastolica normal '
          'e valvas sem disfuncao significativa. Sem sinais de cardiopatia '
          'estrutural.',
    );
  }
}

class _ErgometricSection extends StatelessWidget {
  const _ErgometricSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '4',
      title: 'Teste ergometrico (esteira)',
      tag: 'Protocolo de Bruce',
      technique:
          'Esteira rolante, protocolo de Bruce, monitorizacao continua de 12 '
          'derivacoes e PA. Criterio de interrupcao: fadiga fisica (meta atingida).',
      rows: const [
        _Row('Estagio / tempo', 'IV / 12min06s', 'Adequado p/ idade', '', _Flag.normal),
        _Row('Capacidade funcional', '12,1', '> 10 (boa)', 'METs', _Flag.normal),
        _Row('FC maxima atingida', '178 (95% FCMP)', '>= 85% FCMP', 'bpm', _Flag.normal),
        _Row('Resposta cronotropica', 'Normal', 'Normal', '', _Flag.normal),
        _Row('PA repouso / pico', '120/78 -> 182/80', 'Resposta fisiologica', 'mmHg', _Flag.normal),
        _Row('Resposta do segmento ST', 'Sem infra >=1 mm', 'Sem isquemia', '', _Flag.normal),
        _Row('Arritmias ao esforco', 'Ausentes', 'Ausentes', '', _Flag.normal),
        _Row('Sintomas (angina)', 'Ausentes', 'Ausentes', '', _Flag.normal),
      ],
      bullets: const [
        'Sem deflagracao de FA durante o esforco; controle de frequencia '
            'mantido em todas as fases.',
        'Recuperacao da FC normal no 1o minuto; sem ectopia ventricular '
            'complexa na recuperacao.',
      ],
      impression:
          'Teste ergometrico sem evidencia de isquemia miocardica induzida '
          'pelo esforco. Capacidade funcional preservada, respostas '
          'cronotropica e pressorica normais.',
    );
  }
}

class _BiomarkersSection extends StatelessWidget {
  const _BiomarkersSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '5',
      title: 'Biomarcadores cardiacos (sangue)',
      tag: 'Imunoensaio / Quimioluminescencia',
      technique:
          'Material: soro/plasma. Metodos: imunoensaio de alta sensibilidade '
          '(troponina), quimioluminescencia (NT-proBNP).',
      rows: const [
        _Row('Troponina I (alta sens.)', '3', '< 34 (homens, P99)', 'ng/L', _Flag.normal),
        _Row('CK-MB massa', '1,6', '< 5,0', 'ng/mL', _Flag.normal),
        _Row('NT-proBNP', '68', '< 125 (< 75 anos)', 'pg/mL', _Flag.normal),
      ],
      bullets: const [
        'Nuance honesta: a propria FA eleva o NT-proBNP. Como o paciente esta '
            'em ritmo sinusal e sem doenca estrutural, o valor esta normal; '
            'durante um episodio de FA este marcador pode elevar-se '
            'transitoriamente mesmo com coracao normal.',
        'Troponina normal: ausencia de injuria miocardica.',
      ],
      impression:
          'Marcadores de injuria miocardica e de sobrecarga ventricular '
          'dentro da normalidade.',
    );
  }
}

class _EteSection extends StatelessWidget {
  const _EteSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '6',
      title: 'Ecocardiograma transesofagico (ETE)',
      tag: 'Pesquisa de trombo pre-procedimento',
      technique:
          'Sonda transesofagica multiplanar, sedacao consciente. Indicacao: '
          'avaliacao do apendice atrial esquerdo antes de cardioversao/ablacao.',
      rows: const [
        _Row('Trombo em apendice atrial esq. (AAE)', 'Ausente', 'Ausente', '', _Flag.normal),
        _Row('Contraste espontaneo ("smoke")', 'Ausente', 'Ausente', '', _Flag.normal),
        _Row('Velocidade de esvaziamento do AAE', '58', '> 40 (baixo risco)', 'cm/s', _Flag.normal),
        _Row('Septo interatrial', 'Integro', 'Sem FOP/CIA', '', _Flag.normal),
        _Row('Aorta toracica (ateroma)', 'Grau I (minimo)', 'Sem placa complexa', '', _Flag.normal),
      ],
      impression:
          'Ausencia de trombo no apendice atrial esquerdo; velocidades de '
          'esvaziamento preservadas. Baixo risco tromboembolico estrutural.',
    );
  }
}

class _AngioCtSection extends StatelessWidget {
  const _AngioCtSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '7',
      title: 'Angiotomografia de arterias coronarias (Angio-TC)',
      tag: 'Escore de calcio e mapeamento atrial',
      technique:
          'TC de 256 canais, aquisicao prospectiva gatilhada pelo ECG, em '
          'ritmo sinusal e FC controlada (~58 bpm). Nitrato sublingual para '
          'vasodilatacao coronaria. Contraste iodado 65 mL EV. '
          'Dose: DLP 95 mGy*cm (baixa). Qualidade: otima.',
      subgroups: const [
        _SubGroup(
          label: '7.1 ESCORE DE CALCIO (AGATSTON)',
          rows: [
            _Row('TCE', '0', 'Sem calcio', '', _Flag.normal),
            _Row('DA', '0', 'Sem calcio', '', _Flag.normal),
            _Row('CX', '0', 'Sem calcio', '', _Flag.normal),
            _Row('CD', '0', 'Sem calcio', '', _Flag.normal),
            _Row('Escore total', '0', 'Risco muito baixo', '', _Flag.normal),
          ],
        ),
        _SubGroup(
          label: '7.2 ANALISE DAS CORONARIAS (SCCT 18 SEGMENTOS, DOMINANCIA DIREITA)',
          rows: [
            _Row('TCE', 'Sem placa', '0%', '', _Flag.normal),
            _Row('DA prox/medio/distal', 'Sem placa', '0%', '', _Flag.normal),
            _Row('Diagonais (D1, D2)', 'Sem placa', '0%', '', _Flag.normal),
            _Row('CX prox/distal', 'Sem placa', '0%', '', _Flag.normal),
            _Row('Marginais (Mg)', 'Sem placa', '0%', '', _Flag.normal),
            _Row('CD prox/medio/distal', 'Sem placa', '0%', '', _Flag.normal),
            _Row('DP / VP', 'Sem placa', '0% (dominancia D)', '', _Flag.normal),
          ],
        ),
        _SubGroup(
          label: '7.3 CAD-RADS 2.0',
          rows: [
            _Row('CAD-RADS', '0', 'Ausencia de DAC', '', _Flag.normal),
            _Row('Modificadores', 'Nenhum', '-', '', _Flag.normal),
          ],
        ),
        _SubGroup(
          label: '7.4 AVALIACAO ESPECIFICA PARA FA',
          rows: [
            _Row('Atrio esquerdo (volume)', 'Normal', 'Nao aumentado', '', _Flag.normal),
            _Row('Trombo em AAE', 'Ausente', 'Ausente', '', _Flag.normal),
            _Row('Veias pulmonares', 'Tipico (4 veias)', '4 ostios', '', _Flag.normal),
            _Row('Ostios VPSD/VPID', '19 / 17', '~14-21', 'mm', _Flag.normal),
            _Row('Ostios VPSE/VPIE', '18 / 16', '~14-21', 'mm', _Flag.normal),
            _Row('Tronco comum / acessoria', 'Ausente', 'Variante', '', _Flag.normal),
            _Row('Morfologia do AAE', '"Chicken wing"', 'Variante de menor risco', '', _Flag.favoravel),
          ],
        ),
      ],
      bullets: const [
        'Origem e trajeto: ostios em posicao habitual nos seios de Valsalva. '
            'Sem anomalias de origem ou trajeto interarterial.',
        'Ponte miocardica: ausente.',
        'Placa aterosclerotica: nao detectada (calcificada, nao calcificada '
            'ou mista) em nenhum segmento.',
        'Aorta e grandes vasos: raiz e aorta ascendente de calibre normal; '
            'sem disseccao ou aneurisma.',
        'Estruturas extracardiacas: sem achados incidentais.',
      ],
      impression:
          'Escore de calcio total = 0; risco cardiovascular muito baixo. '
          'CAD-RADS 0: ausencia de doenca arterial coronariana. Anatomia '
          'coronaria normal. Anatomia de veias pulmonares tipica e AAE sem '
          'trombo (morfologia "chicken wing", favoravel): condicoes '
          'anatomicas adequadas para eventual isolamento de veias pulmonares.',
    );
  }
}

class _CardiacMrSection extends StatelessWidget {
  const _CardiacMrSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '8',
      title: 'Ressonancia magnetica cardiaca',
      tag: 'Caracterizacao tecidual e fibrose atrial',
      technique:
          'RM 1,5T, cine-SSFP, realce tardio com gadolinio (LGE), mapas T1 '
          'nativo, T2 e ECV; protocolo de fibrose atrial (Utah).',
      rows: const [
        _Row('FE do VE', '60', '>= 55', '%', _Flag.normal),
        _Row('FE do VD', '56', '>= 50', '%', _Flag.normal),
        _Row('Volumes ventriculares indexados', 'Normais', 'Dentro da faixa', 'mL/m2', _Flag.normal),
        _Row('Realce tardio (LGE)', 'Ausente', 'Ausente', '', _Flag.normal),
        _Row('Mapa T1 nativo / ECV', 'Normais', 'Sem expansao', '', _Flag.normal),
        _Row('Mapa T2 (edema)', 'Normal', 'Sem edema', '', _Flag.normal),
        _Row('Fibrose do AE (Utah)', 'Estagio I (<10%)', 'Estagio I', '', _Flag.favoravel),
      ],
      impression:
          'Sem cardiopatia estrutural; ausencia de fibrose/cicatriz miocardica '
          'e de infiltracao. Fibrose atrial minima (favoravel para ablacao).',
    );
  }
}

class _EpsSection extends StatelessWidget {
  const _EpsSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      number: '9',
      title: 'Estudo eletrofisiologico invasivo (EEF)',
      tag: 'Em contexto de mapeamento/ablacao',
      technique:
          'Cateteres multipolares, avaliacao da conducao AV/His-Purkinje e '
          'protocolo de estimulacao programada.',
      rows: const [
        _Row('Intervalo AH', '78', '50-120', 'ms', _Flag.normal),
        _Row('Intervalo HV', '45', '35-55', 'ms', _Flag.normal),
        _Row('Via acessoria', 'Ausente', 'Ausente', '', _Flag.normal),
        _Row('Dupla via nodal / TRN', 'Ausente', 'Ausente', '', _Flag.normal),
        _Row('Gatilho de FA', 'Focos em veias pulmonares', 'Substrato tipico', '', _Flag.achado),
        _Row('Outra taquicardia induzivel', 'Ausente', 'Ausente', '', _Flag.normal),
      ],
      impression:
          'Sistema de conducao normal. Substrato compativel com FA focal de '
          'veias pulmonares, sem outra arritmia induzivel. Candidato a '
          'isolamento de veias pulmonares.',
    );
  }
}

class _DiagnosticSummaryCard extends StatelessWidget {
  const _DiagnosticSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'SINTESE DIAGNOSTICA',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Coracao estruturalmente normal',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: 12),
          _SummaryBullet(
            label: 'Unico achado alterado: ',
            text: 'o ritmo (FA paroxistica documentada no Holter; ECG de '
                'repouso em ritmo sinusal).',
          ),
          _SummaryBullet(
            label: 'Estrutura e funcao (ECO, RM): ',
            text: 'normais. Funcao sistolica e diastolica preservadas, sem '
                'cardiopatia estrutural.',
          ),
          _SummaryBullet(
            label: 'Isquemia (ergometrico, Angio-TC): ',
            text: 'ausente. Escore de calcio 0, CAD-RADS 0, sem isquemia '
                'ao esforco.',
          ),
          _SummaryBullet(
            label: 'Tromboembolismo estrutural (ETE, Angio-TC): ',
            text: 'sem trombo em AAE; baixo risco. Anatomia favoravel para '
                'ablacao.',
          ),
          _SummaryBullet(
            label: 'Biomarcadores: ',
            text: 'normais (NT-proBNP pode elevar-se durante episodios de FA, '
                'mesmo com coracao normal).',
          ),
          SizedBox(height: 12),
          Text(
            'Conclusao do quadro: fibrilacao atrial isolada ("lone AF") em '
            'coracao estruturalmente normal. Esta condicao e mais coerente '
            'com FA paroxistica/recente; FA permanente de longa data '
            'tipicamente cursaria com aumento do atrio esquerdo (nao modelado '
            'aqui, por premissa de "coracao perfeito").',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBullet extends StatelessWidget {
  final String label;
  final String text;
  const _SummaryBullet({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: '- ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            TextSpan(
              text: text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final String number;
  final String title;
  final String tag;
  final String technique;
  final List<_Row> rows;
  final List<_SubGroup> subgroups;
  final List<String> bullets;
  final String impression;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.tag,
    required this.technique,
    this.rows = const [],
    this.subgroups = const [],
    this.bullets = const [],
    required this.impression,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(11),
                  bottom: _expanded ? Radius.zero : const Radius.circular(11),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.number,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.tag,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabeledText(label: 'Tecnica', text: widget.technique),
                  const SizedBox(height: 12),
                  if (widget.rows.isNotEmpty) _ParamTable(rows: widget.rows),
                  for (final sg in widget.subgroups) ...[
                    if (sg != widget.subgroups.first)
                      const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      color: AppColors.primary.withOpacity(0.08),
                      child: Text(
                        sg.label,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    _ParamTable(rows: sg.rows),
                  ],
                  if (widget.bullets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...widget.bullets.map(
                      (b) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 13)),
                            Expanded(
                              child: Text(
                                b,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Impressao',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.impression,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ParamTable extends StatelessWidget {
  final List<_Row> rows;
  const _ParamTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: AppColors.background,
          child: const _HeaderRow(),
        ),
        ...rows.map((r) => _DataRow(row: r)),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppColors.secondary,
      letterSpacing: 0.5,
    );
    return Row(
      children: const [
        Expanded(flex: 4, child: Text('PARAMETRO', style: style)),
        Expanded(flex: 3, child: Text('RESULTADO', style: style)),
        Expanded(flex: 3, child: Text('REF.', style: style)),
        Expanded(flex: 2, child: Text('FLAG', style: style, textAlign: TextAlign.right)),
      ],
    );
  }
}

class _DataRow extends StatelessWidget {
  final _Row row;
  const _DataRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              row.param,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              row.value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.reference,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (row.unit.isNotEmpty)
                  Text(
                    row.unit,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _FlagChip(flag: row.flag),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Flag { normal, achado, controlada, favoravel }

class _FlagChip extends StatelessWidget {
  final _Flag flag;
  const _FlagChip({required this.flag});

  ({String label, Color color}) get _data {
    switch (flag) {
      case _Flag.normal:
        return (label: 'Normal', color: AppColors.success);
      case _Flag.achado:
        return (label: 'Achado', color: AppColors.warning);
      case _Flag.controlada:
        return (label: 'Controlada', color: AppColors.secondary);
      case _Flag.favoravel:
        return (label: 'Favoravel', color: AppColors.cyanDark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: d.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        d.label,
        style: TextStyle(
          color: d.color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Row {
  final String param;
  final String value;
  final String reference;
  final String unit;
  final _Flag flag;
  const _Row(this.param, this.value, this.reference, this.unit, this.flag);
}

class _SubGroup {
  final String label;
  final List<_Row> rows;
  const _SubGroup({required this.label, required this.rows});
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  final _KV left;
  final _KV right;
  const _KeyValueRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: left),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  const _KV(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.secondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _LabeledText extends StatelessWidget {
  final String label;
  final String text;
  const _LabeledText({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.secondary,
            ),
          ),
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
