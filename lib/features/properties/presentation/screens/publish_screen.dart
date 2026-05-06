import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/property.dart';
import '../providers/property_provider.dart';

class PublishScreen extends ConsumerStatefulWidget {
  const PublishScreen({super.key});

  @override
  ConsumerState<PublishScreen> createState() => _PublishScreenState();
}

class _PublishScreenState extends ConsumerState<PublishScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();

  // Campos do formulário
  String _type = 'rent';
  String _propertyType = 'house';
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  int _bedrooms = 2;
  int _bathrooms = 1;
  double _area = 80;
  List<String> _imageUrls = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _addressCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Publicar Imóvel — Passo ${_step + 1}/4'),
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
      ),
      body: Column(
        children: [
          // Barra de progresso
          LinearProgressIndicator(
            value: (_step + 1) / 4,
            backgroundColor: AppTheme.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: [
                  _Step1TypeSelection(),
                  _Step2Details(),
                  _Step3Location(),
                  _Step4Contact(),
                ][_step],
              ),
            ),
          ),
          _buildNavButton(),
        ],
      ),
    );
  }

  // Passo 1: Tipo de anúncio
  Widget _Step1TypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Que tipo de anúncio?',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 24),
        _SelectorRow(
          label: 'Finalidade',
          options: const {'rent': 'Arrendamento', 'sell': 'Venda'},
          selected: _type,
          onSelect: (v) => setState(() => _type = v),
        ),
        const SizedBox(height: 20),
        _SelectorRow(
          label: 'Tipo de imóvel',
          options: const {
            'house': 'Casa',
            'apartment': 'Apartamento',
            'land': 'Terreno',
            'commercial': 'Comercial'
          },
          selected: _propertyType,
          onSelect: (v) => setState(() => _propertyType = v),
        ),
      ],
    );
  }

  // Passo 2: Detalhes
  Widget _Step2Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detalhes do imóvel',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 24),
        _label('Título do anúncio'),
        TextFormField(
          controller: _titleCtrl,
          decoration: const InputDecoration(hintText: 'Ex: Vivenda T3 no Talatona'),
          validator: (v) =>
              v == null || v.isEmpty ? 'Título obrigatório' : null,
        ),
        const SizedBox(height: 16),
        _label('Descrição'),
        TextFormField(
          controller: _descCtrl,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Descreve o imóvel...'),
          validator: (v) =>
              v == null || v.isEmpty ? 'Descrição obrigatória' : null,
        ),
        const SizedBox(height: 16),
        _label('Preço (Kz)'),
        TextFormField(
          controller: _priceCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              hintText: _type == 'rent' ? 'Ex: 150000 / mês' : 'Ex: 25000000'),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Preço obrigatório';
            if (double.tryParse(v) == null) return 'Valor inválido';
            return null;
          },
        ),
        if (_propertyType != 'land') ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Quartos'),
                    _CounterField(
                      value: _bedrooms,
                      min: 0,
                      max: 10,
                      onChange: (v) => setState(() => _bedrooms = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('WC'),
                    _CounterField(
                      value: _bathrooms,
                      min: 0,
                      max: 10,
                      onChange: (v) => setState(() => _bathrooms = v),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        _label('Área (m²)'),
        Slider(
          value: _area,
          min: 20,
          max: 2000,
          divisions: 198,
          activeColor: AppTheme.primary,
          label: '${_area.toStringAsFixed(0)}m²',
          onChanged: (v) => setState(() => _area = v),
        ),
        Center(
            child: Text('${_area.toStringAsFixed(0)} m²',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.primary))),
      ],
    );
  }

  // Passo 3: Localização
  Widget _Step3Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Localização',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 24),
        _label('Bairro / Zona'),
        TextFormField(
          controller: _neighborhoodCtrl,
          decoration:
              const InputDecoration(hintText: 'Ex: Talatona, Miramar, Maianga'),
          validator: (v) => v == null || v.isEmpty ? 'Bairro obrigatório' : null,
        ),
        const SizedBox(height: 16),
        _label('Endereço completo'),
        TextFormField(
          controller: _addressCtrl,
          decoration: const InputDecoration(
              hintText: 'Rua, número, referência...'),
          validator: (v) =>
              v == null || v.isEmpty ? 'Endereço obrigatório' : null,
        ),
      ],
    );
  }

  // Passo 4: Contacto
  Widget _Step4Contact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contacto',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        const Text(
            'Os interessados entrarão em contacto contigo por telefone ou WhatsApp.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const SizedBox(height: 24),
        _label('Número de telefone'),
        TextFormField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '+244 9XX XXX XXX'),
          validator: (v) =>
              v == null || v.isEmpty ? 'Telefone obrigatório' : null,
        ),
        const SizedBox(height: 24),
        const Text('Revisão do anúncio',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        _ReviewItem('Tipo', '${_type == 'rent' ? 'Arrendamento' : 'Venda'} — $_propertyType'),
        _ReviewItem('Título', _titleCtrl.text),
        _ReviewItem('Preço', '${_priceCtrl.text} Kz'),
        _ReviewItem('Bairro', _neighborhoodCtrl.text),
      ],
    );
  }

  Widget _buildNavButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _handleNext,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(_step < 3 ? 'Continuar' : 'Publicar Anúncio'),
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    if (_step < 3) {
      setState(() => _step++);
      return;
    }

    // Submeter
    setState(() => _isSubmitting = true);
    try {
      final useCase = await ref.read(publishPropertyUseCaseProvider.future);
      final property = Property(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        type: _type,
        propertyType: _propertyType,
        latitude: -8.8390,
        longitude: 13.2894,
        address: _addressCtrl.text.trim(),
        neighborhood: _neighborhoodCtrl.text.trim(),
        images: _imageUrls,
        bedrooms: _bedrooms,
        bathrooms: _bathrooms,
        area: _area,
        ownerId: '',
        ownerPhone: _phoneCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      final result = await useCase(property);
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(failure.message),
                backgroundColor: AppTheme.error),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anúncio publicado com sucesso!'),
              backgroundColor: AppTheme.primary,
            ),
          );
          ref.read(propertyListNotifierProvider.notifier).refresh();
          context.go('/');
        },
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppTheme.textPrimary)),
      );
}

// Widgets auxiliares

class _SelectorRow extends StatelessWidget {
  final String label;
  final Map<String, String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _SelectorRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 14,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.entries.map((e) {
            final isSelected = e.key == selected;
            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.border),
                ),
                child: Text(e.value,
                    style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CounterField extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChange;

  const _CounterField(
      {required this.value,
      required this.min,
      required this.max,
      required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
        color: AppTheme.surface,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: value > min ? () => onChange(value - 1) : null,
            color: AppTheme.primary,
          ),
          Expanded(
              child: Text('$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: value < max ? () => onChange(value + 1) : null,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      fontSize: 13))),
        ],
      ),
    );
  }
}
