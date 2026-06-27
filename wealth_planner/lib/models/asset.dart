import 'package:hive/hive.dart';

enum AssetCategory {
  stocks,
  fiis,
  fixedIncome,
  crypto,
  realEstate,
  internationalEquity,
  cash,
  others,
}

extension AssetCategoryExtension on AssetCategory {
  String get displayName {
    switch (this) {
      case AssetCategory.stocks:
        return 'Ações BR';
      case AssetCategory.fiis:
        return 'FIIs';
      case AssetCategory.fixedIncome:
        return 'Renda Fixa';
      case AssetCategory.crypto:
        return 'Criptomoedas';
      case AssetCategory.realEstate:
        return 'Imóveis';
      case AssetCategory.internationalEquity:
        return 'Ações Internacionais';
      case AssetCategory.cash:
        return 'Caixa';
      case AssetCategory.others:
        return 'Outros';
    }
  }

  String get icon {
    switch (this) {
      case AssetCategory.stocks:
        return '📈';
      case AssetCategory.fiis:
        return '🏢';
      case AssetCategory.fixedIncome:
        return '🏦';
      case AssetCategory.crypto:
        return '₿';
      case AssetCategory.realEstate:
        return '🏠';
      case AssetCategory.internationalEquity:
        return '🌍';
      case AssetCategory.cash:
        return '💵';
      case AssetCategory.others:
        return '📦';
    }
  }
}

class Asset {
  final String id;
  final String name;
  final AssetCategory category;
  final String subcategory;
  final String currency;
  final double currentValue;
  final double acquisitionValue;
  final DateTime acquisitionDate;
  final String jurisdiction;
  final String broker;
  final bool isOffshore;
  final String notes;

  const Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
    required this.currency,
    required this.currentValue,
    required this.acquisitionValue,
    required this.acquisitionDate,
    required this.jurisdiction,
    required this.broker,
    required this.isOffshore,
    required this.notes,
  });

  double get unrealizedGain => currentValue - acquisitionValue;

  double get unrealizedGainPercent {
    if (acquisitionValue == 0) return 0;
    return (unrealizedGain / acquisitionValue) * 100;
  }

  Asset copyWith({
    String? id,
    String? name,
    AssetCategory? category,
    String? subcategory,
    String? currency,
    double? currentValue,
    double? acquisitionValue,
    DateTime? acquisitionDate,
    String? jurisdiction,
    String? broker,
    bool? isOffshore,
    String? notes,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      currency: currency ?? this.currency,
      currentValue: currentValue ?? this.currentValue,
      acquisitionValue: acquisitionValue ?? this.acquisitionValue,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      broker: broker ?? this.broker,
      isOffshore: isOffshore ?? this.isOffshore,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.index,
      'subcategory': subcategory,
      'currency': currency,
      'currentValue': currentValue,
      'acquisitionValue': acquisitionValue,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'jurisdiction': jurisdiction,
      'broker': broker,
      'isOffshore': isOffshore,
      'notes': notes,
    };
  }

  factory Asset.fromMap(Map<dynamic, dynamic> map) {
    return Asset(
      id: map['id'] as String,
      name: map['name'] as String,
      category: AssetCategory.values[map['category'] as int],
      subcategory: map['subcategory'] as String? ?? '',
      currency: map['currency'] as String? ?? 'BRL',
      currentValue: (map['currentValue'] as num).toDouble(),
      acquisitionValue: (map['acquisitionValue'] as num).toDouble(),
      acquisitionDate: DateTime.parse(map['acquisitionDate'] as String),
      jurisdiction: map['jurisdiction'] as String? ?? 'Brasil',
      broker: map['broker'] as String? ?? '',
      isOffshore: map['isOffshore'] as bool? ?? false,
      notes: map['notes'] as String? ?? '',
    );
  }
}

class AssetAdapter extends TypeAdapter<Map<dynamic, dynamic>> {
  @override
  final int typeId = 1;

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
