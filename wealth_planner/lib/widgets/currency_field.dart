import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyField extends StatefulWidget {
  final String label;
  final String? hint;
  final String currency;
  final double? initialValue;
  final ValueChanged<double>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextEditingController? controller;
  final bool enabled;

  const CurrencyField({
    super.key,
    required this.label,
    this.hint,
    this.currency = 'BRL',
    this.initialValue,
    this.onChanged,
    this.validator,
    this.controller,
    this.enabled = true,
  });

  @override
  State<CurrencyField> createState() => _CurrencyFieldState();
}

class _CurrencyFieldState extends State<CurrencyField> {
  late TextEditingController _controller;
  late NumberFormat _format;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _updateFormat();
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValue != null && widget.initialValue! > 0) {
      _controller.text = _formatValue(widget.initialValue!);
    }
    _controller.addListener(_onTextChanged);
  }

  void _updateFormat() {
    switch (widget.currency) {
      case 'USD':
        _format = NumberFormat.currency(
            locale: 'en_US', symbol: 'US\$ ', decimalDigits: 2);
        break;
      case 'EUR':
        _format = NumberFormat.currency(
            locale: 'pt_BR', symbol: '€ ', decimalDigits: 2);
        break;
      default:
        _format = NumberFormat.currency(
            locale: 'pt_BR', symbol: 'R\$ ', decimalDigits: 2);
    }
  }

  String _formatValue(double value) {
    return _format.format(value);
  }

  double _parseValue(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^\d,.]'), '');
    if (cleaned.isEmpty) return 0;

    String normalized = cleaned;
    if (widget.currency == 'BRL') {
      normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      normalized = cleaned.replaceAll(',', '');
    }

    return double.tryParse(normalized) ?? 0;
  }

  void _onTextChanged() {
    if (_isUpdating) return;
    final value = _parseValue(_controller.text);
    widget.onChanged?.call(value);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
      ],
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint ?? _formatValue(0),
        prefixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Text(
            _getCurrencySymbol(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC9A84C),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0),
      ),
      validator: widget.validator,
      onEditingComplete: () {
        _isUpdating = true;
        final value = _parseValue(_controller.text);
        if (value > 0) {
          _controller.text = _formatValue(value);
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
        _isUpdating = false;
      },
    );
  }

  String _getCurrencySymbol() {
    switch (widget.currency) {
      case 'USD':
        return 'US\$';
      case 'EUR':
        return '€';
      default:
        return 'R\$';
    }
  }
}

class SimpleCurrencyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final String currency;
  final bool enabled;

  const SimpleCurrencyField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.currency = 'BRL',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: currency == 'BRL' ? 'R\$ 0,00' : 'US\$ 0.00',
      ),
      validator: validator,
    );
  }
}
