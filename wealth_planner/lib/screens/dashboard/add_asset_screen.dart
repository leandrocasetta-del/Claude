import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../models/asset.dart';
import '../../providers/assets_provider.dart';

class AddAssetScreen extends ConsumerStatefulWidget {
  final Asset? existingAsset;

  const AddAssetScreen({super.key, this.existingAsset});

  @override
  ConsumerState<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends ConsumerState<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _acquisitionValueController = TextEditingController();
  final _brokerController = TextEditingController();
  final _notesController = TextEditingController();

  AssetCategory _category = AssetCategory.fixedIncome;
  String _currency = 'BRL';
  String _jurisdiction = 'Brasil';
  DateTime _acquisitionDate = DateTime.now();
  bool _isOffshore = false;
  bool _isSaving = false;

  bool get _isEditing => widget.existingAsset != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.existingAsset!;
      _nameController.text = a.name;
      _subcategoryController.text = a.subcategory;
      _currentValueController.text = a.currentValue.toStringAsFixed(2);
      _acquisitionValueController.text = a.acquisitionValue.toStringAsFixed(2);
      _brokerController.text = a.broker;
      _notesController.text = a.notes;
      _category = a.category;
      _currency = a.currency;
      _jurisdiction = a.jurisdiction;
      _acquisitionDate = a.acquisitionDate;
      _isOffshore = a.isOffshore;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subcategoryController.dispose();
    _currentValueController.dispose();
    _acquisitionValueController.dispose();
    _brokerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double _parseValue(String text) {
    final cleaned = text
        .replaceAll('R\$', '')
        .replaceAll('US\$', '')
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _acquisitionDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _acquisitionDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final asset = Asset(
        id: _isEditing ? widget.existingAsset!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _category,
        subcategory: _subcategoryController.text.trim(),
        currency: _currency,
        currentValue: _parseValue(_currentValueController.text),
        acquisitionValue: _parseValue(_acquisitionValueController.text),
        acquisitionDate: _acquisitionDate,
        jurisdiction: _jurisdiction,
        broker: _brokerController.text.trim(),
        isOffshore: _isOffshore,
        notes: _notesController.text.trim(),
      );

      if (_isEditing) {
        await ref.read(assetsProvider.notifier).updateAsset(asset);
      } else {
        await ref.read(assetsProvider.notifier).addAsset(asset);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Ativo atualizado com sucesso!'
                : 'Ativo adicionado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Ativo' : 'Novo Ativo'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Identificação'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do ativo *',
                  hintText: 'Ex: Tesouro IPCA+ 2035',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AssetCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                dropdownColor: AppColors.surface,
                items: AssetCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Text(c.icon),
                        const SizedBox(width: 8),
                        Text(c.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _category = v;
                      _isOffshore = v == AssetCategory.internationalEquity;
                      if (_isOffshore && _jurisdiction == 'Brasil') {
                        _jurisdiction = 'Estados Unidos';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subcategoryController,
                decoration: const InputDecoration(
                  labelText: 'Subcategoria',
                  hintText: 'Ex: ETF, CDB, Ações, etc.',
                  prefixIcon: Icon(Icons.subdirectory_arrow_right),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Valores'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _currentValueController,
                      decoration: const InputDecoration(
                        labelText: 'Valor Atual *',
                        hintText: '0,00',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Obrigatório';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: const InputDecoration(labelText: 'Moeda'),
                      dropdownColor: AppColors.surface,
                      items: AppConstants.currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _acquisitionValueController,
                decoration: const InputDecoration(
                  labelText: 'Valor de Aquisição',
                  hintText: '0,00',
                  prefixIcon: Icon(Icons.price_change_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppColors.textMuted),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data de Aquisição',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            '${_acquisitionDate.day.toString().padLeft(2, '0')}/${_acquisitionDate.month.toString().padLeft(2, '0')}/${_acquisitionDate.year}',
                            style: const TextStyle(
                                fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Localização & Custódia'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _jurisdiction,
                decoration: const InputDecoration(
                  labelText: 'Jurisdição',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                dropdownColor: AppColors.surface,
                items: AppConstants.jurisdictions
                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _jurisdiction = v;
                      _isOffshore = v != 'Brasil';
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brokerController,
                decoration: const InputDecoration(
                  labelText: 'Corretora / Custodiante',
                  hintText: 'Ex: XP, BTG, Interactive Brokers',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: AppColors.secondary),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ativo Offshore',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Ativo mantido fora do Brasil',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOffshore,
                      onChanged: (v) => setState(() => _isOffshore = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Observações'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  hintText: 'Informações adicionais sobre este ativo...',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.background),
                        )
                      : Text(
                          _isEditing ? 'Salvar Alterações' : 'Adicionar Ativo',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
