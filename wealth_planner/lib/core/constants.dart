import 'package:intl/intl.dart';

abstract class AppConstants {
  static const String appName = 'WealthPlanner';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String profilesBox = 'profiles';
  static const String assetsBox = 'assets';
  static const String successionBox = 'succession';

  // Risk profiles
  static const List<Map<String, dynamic>> riskProfiles = [
    {
      'id': 'conservative',
      'name': 'Conservador',
      'description': 'Prioriza preservação do capital. Aceita retornos menores em troca de segurança.',
      'expectedReturn': '8-10% a.a.',
      'volatility': 'Baixa',
      'icon': '🛡️',
    },
    {
      'id': 'moderate',
      'name': 'Moderado',
      'description': 'Equilibra crescimento e segurança. Aceita oscilações moderadas em busca de bons retornos.',
      'expectedReturn': '12-15% a.a.',
      'volatility': 'Média',
      'icon': '⚖️',
    },
    {
      'id': 'aggressive',
      'name': 'Arrojado',
      'description': 'Busca maximizar retornos. Aceita alta volatilidade e maior risco no curto prazo.',
      'expectedReturn': '18-25% a.a.',
      'volatility': 'Alta',
      'icon': '🚀',
    },
  ];

  // Asset categories
  static const List<Map<String, dynamic>> assetCategories = [
    {'id': 'fixedIncome', 'name': 'Renda Fixa', 'icon': '🏦'},
    {'id': 'stocks', 'name': 'Ações BR', 'icon': '📈'},
    {'id': 'fiis', 'name': 'FIIs', 'icon': '🏢'},
    {'id': 'internationalEquity', 'name': 'Ações Internacionais', 'icon': '🌍'},
    {'id': 'crypto', 'name': 'Criptomoedas', 'icon': '₿'},
    {'id': 'realEstate', 'name': 'Imóveis', 'icon': '🏠'},
    {'id': 'cash', 'name': 'Caixa', 'icon': '💵'},
    {'id': 'others', 'name': 'Outros', 'icon': '📦'},
  ];

  // Jurisdictions
  static const List<String> jurisdictions = [
    'Brasil',
    'Estados Unidos',
    'Europa',
    'Reino Unido',
    'Ilhas Cayman',
    'Ilhas Virgens Britânicas (BVI)',
    'Dubai (EAU)',
    'Luxemburgo',
    'Suíça',
    'Singapura',
    'Malta',
    'Outros',
  ];

  // Offshore structures
  static const List<Map<String, dynamic>> offshoreStructureTypes = [
    {'id': 'holdingBVI', 'name': 'Holding BVI'},
    {'id': 'holdingCayman', 'name': 'Holding Cayman'},
    {'id': 'holdingDubai', 'name': 'Holding Dubai'},
    {'id': 'bankAccount', 'name': 'Conta Bancária Internacional'},
    {'id': 'trust', 'name': 'Trust'},
    {'id': 'foundation', 'name': 'Fundação'},
  ];

  // Marital statuses
  static const List<String> maritalStatuses = [
    'Solteiro(a)',
    'Casado(a)',
    'União Estável',
    'Divorciado(a)',
    'Viúvo(a)',
  ];

  // Investment objectives
  static const List<String> investmentObjectives = [
    'Preservação de patrimônio',
    'Crescimento acelerado',
    'Renda passiva',
    'Proteção cambial',
    'Sucessão familiar',
    'Proteção contra inflação',
    'Diversificação geográfica',
    'Redução de carga tributária',
  ];

  // Brazilian states for ITCMD
  static const List<Map<String, dynamic>> brazilianStates = [
    {'uf': 'SP', 'name': 'São Paulo', 'itcmdRate': 0.04},
    {'uf': 'RJ', 'name': 'Rio de Janeiro', 'itcmdRate': 0.08},
    {'uf': 'MG', 'name': 'Minas Gerais', 'itcmdRate': 0.05},
    {'uf': 'RS', 'name': 'Rio Grande do Sul', 'itcmdRate': 0.06},
    {'uf': 'PR', 'name': 'Paraná', 'itcmdRate': 0.04},
    {'uf': 'SC', 'name': 'Santa Catarina', 'itcmdRate': 0.08},
    {'uf': 'BA', 'name': 'Bahia', 'itcmdRate': 0.08},
    {'uf': 'GO', 'name': 'Goiás', 'itcmdRate': 0.04},
    {'uf': 'DF', 'name': 'Distrito Federal', 'itcmdRate': 0.06},
    {'uf': 'PE', 'name': 'Pernambuco', 'itcmdRate': 0.08},
    {'uf': 'CE', 'name': 'Ceará', 'itcmdRate': 0.08},
    {'uf': 'PA', 'name': 'Pará', 'itcmdRate': 0.04},
    {'uf': 'AM', 'name': 'Amazonas', 'itcmdRate': 0.02},
    {'uf': 'MT', 'name': 'Mato Grosso', 'itcmdRate': 0.04},
    {'uf': 'MS', 'name': 'Mato Grosso do Sul', 'itcmdRate': 0.06},
    {'uf': 'ES', 'name': 'Espírito Santo', 'itcmdRate': 0.04},
    {'uf': 'Outros', 'name': 'Outros Estados', 'itcmdRate': 0.08},
  ];

  // Currencies
  static const List<String> currencies = ['BRL', 'USD', 'EUR', 'GBP', 'CHF'];

  // Countries
  static const List<String> countries = [
    'Brasil',
    'Estados Unidos',
    'Portugal',
    'Espanha',
    'França',
    'Alemanha',
    'Reino Unido',
    'Itália',
    'Suíça',
    'Emirados Árabes Unidos',
    'Singapura',
    'Outros',
  ];
}

abstract class AppFormatters {
  static final NumberFormat brlFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final NumberFormat usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'US\$',
    decimalDigits: 2,
  );

  static final NumberFormat percentFormat = NumberFormat.percentPattern('pt_BR');

  static final NumberFormat compactBrlFormat = NumberFormat.compactCurrency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 1,
  );

  static String formatCurrency(double value, {String currency = 'BRL'}) {
    switch (currency) {
      case 'USD':
        return usdFormat.format(value);
      case 'EUR':
        return NumberFormat.currency(
          locale: 'pt_BR',
          symbol: '€',
          decimalDigits: 2,
        ).format(value);
      default:
        return brlFormat.format(value);
    }
  }

  static String formatBRL(double value) => brlFormat.format(value);

  static String formatCompactBRL(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(0)}K';
    }
    return brlFormat.format(value);
  }

  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String formatCPF(String cpf) {
    final digits = cpf.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return cpf;
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'pt_BR').format(date);
  }
}
