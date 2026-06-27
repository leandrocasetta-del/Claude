import 'package:hive/hive.dart';

enum OffshoreStructureType {
  holdingBVI,
  holdingCayman,
  holdingDubai,
  bankAccount,
  trust,
  foundation,
}

extension OffshoreStructureTypeExtension on OffshoreStructureType {
  String get displayName {
    switch (this) {
      case OffshoreStructureType.holdingBVI:
        return 'Holding BVI';
      case OffshoreStructureType.holdingCayman:
        return 'Holding Cayman';
      case OffshoreStructureType.holdingDubai:
        return 'Holding Dubai';
      case OffshoreStructureType.bankAccount:
        return 'Conta Bancária Internacional';
      case OffshoreStructureType.trust:
        return 'Trust';
      case OffshoreStructureType.foundation:
        return 'Fundação';
    }
  }
}

class OffshoreStructure {
  final String id;
  final String name;
  final OffshoreStructureType type;
  final String jurisdiction;
  final double estimatedSetupCost;
  final double annualMaintenanceCost;
  final List<String> taxBenefits;
  final List<String> requirements;
  final double recommendedMinAssets;
  final List<String> pros;
  final List<String> cons;
  final String flagEmoji;

  const OffshoreStructure({
    required this.id,
    required this.name,
    required this.type,
    required this.jurisdiction,
    required this.estimatedSetupCost,
    required this.annualMaintenanceCost,
    required this.taxBenefits,
    required this.requirements,
    required this.recommendedMinAssets,
    required this.pros,
    required this.cons,
    required this.flagEmoji,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'jurisdiction': jurisdiction,
      'estimatedSetupCost': estimatedSetupCost,
      'annualMaintenanceCost': annualMaintenanceCost,
      'taxBenefits': taxBenefits,
      'requirements': requirements,
      'recommendedMinAssets': recommendedMinAssets,
      'pros': pros,
      'cons': cons,
      'flagEmoji': flagEmoji,
    };
  }

  static List<OffshoreStructure> predefinedStructures() {
    return [
      const OffshoreStructure(
        id: 'bvi_holding',
        name: 'Holding nas Ilhas Virgens Britânicas',
        type: OffshoreStructureType.holdingBVI,
        jurisdiction: 'Ilhas Virgens Britânicas (BVI)',
        estimatedSetupCost: 15000,
        annualMaintenanceCost: 5000,
        flagEmoji: '🇻🇬',
        taxBenefits: [
          'Zero imposto sobre ganho de capital',
          'Zero imposto sobre dividendos',
          'Zero imposto sobre herança',
          'Sigilo societário elevado',
        ],
        requirements: [
          'Mínimo recomendado: US\$ 500K em ativos',
          'Abertura de conta bancária internacional',
          'Agente registrado local',
          'Declaração anual no BCB (DCBE)',
        ],
        recommendedMinAssets: 3000000,
        pros: [
          'Baixo custo de manutenção',
          'Alta flexibilidade societária',
          'Proteção patrimonial robusta',
          'Facilidade de abertura',
          'Planejamento sucessório eficiente',
        ],
        cons: [
          'Pressão regulatória crescente',
          'Algumas jurisdições veem com desconfiança',
          'Requer agente registrado',
        ],
      ),
      const OffshoreStructure(
        id: 'cayman_holding',
        name: 'Holding nas Ilhas Cayman',
        type: OffshoreStructureType.holdingCayman,
        jurisdiction: 'Ilhas Cayman',
        estimatedSetupCost: 25000,
        annualMaintenanceCost: 8000,
        flagEmoji: '🇰🇾',
        taxBenefits: [
          'Isenção total de impostos diretos',
          'Sem tributação de dividendos',
          'Sem imposto sobre renda',
          'Ideal para fundos de investimento',
        ],
        requirements: [
          'Mínimo recomendado: US\$ 1M em ativos',
          'Estrutura societária complexa',
          'Agente registrado e diretor local',
          'Relatório anual CIMA (para fundos)',
        ],
        recommendedMinAssets: 6000000,
        pros: [
          'Jurisdição mais respeitada globalmente',
          'Ideal para estruturas complexas',
          'Acesso a melhores gestores internacionais',
          'Excelente para fundos de PE/VC',
        ],
        cons: [
          'Custo de manutenção elevado',
          'Regulamentação mais rigorosa',
          'Complexidade estrutural maior',
        ],
      ),
      const OffshoreStructure(
        id: 'dubai_holding',
        name: 'Holding em Dubai (EAU)',
        type: OffshoreStructureType.holdingDubai,
        jurisdiction: 'Dubai (EAU)',
        estimatedSetupCost: 20000,
        annualMaintenanceCost: 6000,
        flagEmoji: '🇦🇪',
        taxBenefits: [
          'Imposto corporativo de apenas 9% (acima de US\$ 100K)',
          'Zero imposto pessoal sobre renda',
          'Facilidade de residência fiscal',
          'Acesso ao sistema bancário global',
        ],
        requirements: [
          'Escritório físico ou virtual em Dubai',
          'Licença de negócios local',
          'Conta bancária nos EAU',
          'Possibilidade de residência fiscal',
        ],
        recommendedMinAssets: 5000000,
        pros: [
          'Possibilidade de mudar residência fiscal',
          'Localização estratégica global',
          'Ambiente de negócios favorável',
          'Alta qualidade de vida',
          'Tratados fiscais vantajosos',
        ],
        cons: [
          'Exige presença física significativa',
          'Custo de vida elevado',
          'Mudança de residência é permanente',
        ],
      ),
      const OffshoreStructure(
        id: 'int_bank_account',
        name: 'Conta Bancária Internacional',
        type: OffshoreStructureType.bankAccount,
        jurisdiction: 'Estados Unidos / Europa',
        estimatedSetupCost: 500,
        annualMaintenanceCost: 500,
        flagEmoji: '🏦',
        taxBenefits: [
          'Proteção contra desvalorização do Real',
          'Diversificação de risco bancário',
          'Acesso a produtos financeiros internacionais',
        ],
        requirements: [
          'Documentação KYC completa',
          'Passaporte válido',
          'Comprovante de renda',
          'Declaração no BACEN (CBE) se > R\$ 1 milhão',
        ],
        recommendedMinAssets: 300000,
        pros: [
          'Baixo custo e simplicidade',
          'Acesso imediato a investimentos globais',
          'Proteção cambial direta',
          'Fácil abertura remota',
        ],
        cons: [
          'Sem benefício fiscal direto',
          'Reportagem obrigatória à Receita Federal',
          'Juros sobre ativos financeiros no exterior',
        ],
      ),
      const OffshoreStructure(
        id: 'trust_structure',
        name: 'Trust Offshore',
        type: OffshoreStructureType.trust,
        jurisdiction: 'Ilhas Cayman / BVI / Jersey',
        estimatedSetupCost: 50000,
        annualMaintenanceCost: 15000,
        flagEmoji: '⚖️',
        taxBenefits: [
          'Proteção patrimonial máxima',
          'Planejamento sucessório sem inventário',
          'Potencial economia de ITCMD',
          'Confidencialidade elevada',
        ],
        requirements: [
          'Mínimo US\$ 1M em ativos',
          'Trustee profissional',
          'Carta de desejos (Letter of Wishes)',
          'Beneficiários claramente definidos',
        ],
        recommendedMinAssets: 10000000,
        pros: [
          'Proteção contra credores',
          'Sucessão sem inventário',
          'Gestão profissional de ativos',
          'Controle pós-morte dos ativos',
          'Estrutura irrevogável',
        ],
        cons: [
          'Alto custo de estruturação',
          'Perda de controle direto dos ativos',
          'Complexidade jurídica elevada',
          'Requer advogados especializados',
        ],
      ),
      const OffshoreStructure(
        id: 'foundation_structure',
        name: 'Fundação Privada',
        type: OffshoreStructureType.foundation,
        jurisdiction: 'Liechtenstein / Panamá',
        estimatedSetupCost: 40000,
        annualMaintenanceCost: 12000,
        flagEmoji: '🏛️',
        taxBenefits: [
          'Planejamento de longo prazo',
          'Filantropia com benefícios fiscais',
          'Preservação patrimonial intergeracional',
          'Controle sobre distribuição de ativos',
        ],
        requirements: [
          'Mínimo US\$ 500K em ativos',
          'Conselho de administração',
          'Estatuto da fundação',
          'Beneficiários ou fins definidos',
        ],
        recommendedMinAssets: 8000000,
        pros: [
          'Controle sobre destino dos ativos',
          'Ideal para legado familiar',
          'Estrutura híbrida (trust + empresa)',
          'Flexibilidade de gestão',
        ],
        cons: [
          'Menos conhecida no Brasil',
          'Exige consultoria especializada',
          'Jurisdições menos acessíveis',
        ],
      ),
    ];
  }
}

class OffshoreStructureAdapter extends TypeAdapter<Map<dynamic, dynamic>> {
  @override
  final int typeId = 2;

  @override
  Map<dynamic, dynamic> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <dynamic, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.read();
      final value = reader.read();
      fields[key] = value;
    }
    return fields;
  }

  @override
  void write(BinaryWriter writer, Map<dynamic, dynamic> obj) {
    writer.writeByte(obj.length);
    for (final entry in obj.entries) {
      writer.write(entry.key);
      writer.write(entry.value);
    }
  }
}
