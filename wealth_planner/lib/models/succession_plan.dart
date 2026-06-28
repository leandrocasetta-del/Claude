import 'package:hive/hive.dart';

class SuccessionPlan {
  final String id;
  final bool hasWill;
  final String willJurisdiction;
  final bool holdingCompany;
  final String holdingCompanyName;
  final bool donationInLife;
  final double donationAmount;
  final double itcmdEstimate;
  final bool trustStructure;
  final bool lifeInsurance;
  final double lifeInsuranceValue;
  final List<String> beneficiaries;
  final String notes;
  final DateTime createdAt;

  const SuccessionPlan({
    required this.id,
    required this.hasWill,
    required this.willJurisdiction,
    required this.holdingCompany,
    required this.holdingCompanyName,
    required this.donationInLife,
    required this.donationAmount,
    required this.itcmdEstimate,
    required this.trustStructure,
    required this.lifeInsurance,
    required this.lifeInsuranceValue,
    required this.beneficiaries,
    required this.notes,
    required this.createdAt,
  });

  int get completionItems {
    int count = 0;
    if (hasWill) count++;
    if (holdingCompany) count++;
    if (donationInLife) count++;
    if (lifeInsurance) count++;
    if (trustStructure) count++;
    return count;
  }

  double get completionPercentage => completionItems / 5.0;

  double get estimatedTaxSavings {
    double savings = 0;
    if (holdingCompany) savings += itcmdEstimate * 0.40;
    if (donationInLife) savings += donationAmount * 0.04;
    if (trustStructure) savings += itcmdEstimate * 0.30;
    if (lifeInsurance) savings += lifeInsuranceValue * 0.08;
    return savings;
  }

  SuccessionPlan copyWith({
    String? id,
    bool? hasWill,
    String? willJurisdiction,
    bool? holdingCompany,
    String? holdingCompanyName,
    bool? donationInLife,
    double? donationAmount,
    double? itcmdEstimate,
    bool? trustStructure,
    bool? lifeInsurance,
    double? lifeInsuranceValue,
    List<String>? beneficiaries,
    String? notes,
    DateTime? createdAt,
  }) {
    return SuccessionPlan(
      id: id ?? this.id,
      hasWill: hasWill ?? this.hasWill,
      willJurisdiction: willJurisdiction ?? this.willJurisdiction,
      holdingCompany: holdingCompany ?? this.holdingCompany,
      holdingCompanyName: holdingCompanyName ?? this.holdingCompanyName,
      donationInLife: donationInLife ?? this.donationInLife,
      donationAmount: donationAmount ?? this.donationAmount,
      itcmdEstimate: itcmdEstimate ?? this.itcmdEstimate,
      trustStructure: trustStructure ?? this.trustStructure,
      lifeInsurance: lifeInsurance ?? this.lifeInsurance,
      lifeInsuranceValue: lifeInsuranceValue ?? this.lifeInsuranceValue,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hasWill': hasWill,
      'willJurisdiction': willJurisdiction,
      'holdingCompany': holdingCompany,
      'holdingCompanyName': holdingCompanyName,
      'donationInLife': donationInLife,
      'donationAmount': donationAmount,
      'itcmdEstimate': itcmdEstimate,
      'trustStructure': trustStructure,
      'lifeInsurance': lifeInsurance,
      'lifeInsuranceValue': lifeInsuranceValue,
      'beneficiaries': beneficiaries,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SuccessionPlan.fromMap(Map<dynamic, dynamic> map) {
    return SuccessionPlan(
      id: map['id'] as String,
      hasWill: map['hasWill'] as bool? ?? false,
      willJurisdiction: map['willJurisdiction'] as String? ?? 'Brasil',
      holdingCompany: map['holdingCompany'] as bool? ?? false,
      holdingCompanyName: map['holdingCompanyName'] as String? ?? '',
      donationInLife: map['donationInLife'] as bool? ?? false,
      donationAmount: (map['donationAmount'] as num?)?.toDouble() ?? 0,
      itcmdEstimate: (map['itcmdEstimate'] as num?)?.toDouble() ?? 0,
      trustStructure: map['trustStructure'] as bool? ?? false,
      lifeInsurance: map['lifeInsurance'] as bool? ?? false,
      lifeInsuranceValue: (map['lifeInsuranceValue'] as num?)?.toDouble() ?? 0,
      beneficiaries: List<String>.from(map['beneficiaries'] as List? ?? []),
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  factory SuccessionPlan.empty() {
    return SuccessionPlan(
      id: 'default',
      hasWill: false,
      willJurisdiction: 'Brasil',
      holdingCompany: false,
      holdingCompanyName: '',
      donationInLife: false,
      donationAmount: 0,
      itcmdEstimate: 0,
      trustStructure: false,
      lifeInsurance: false,
      lifeInsuranceValue: 0,
      beneficiaries: [],
      notes: '',
      createdAt: DateTime.now(),
    );
  }
}

class SuccessionPlanAdapter extends TypeAdapter<Map<dynamic, dynamic>> {
  @override
  final int typeId = 3;

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
