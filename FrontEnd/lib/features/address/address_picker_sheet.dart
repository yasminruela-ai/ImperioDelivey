import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';

class AddressPickerSheet extends StatefulWidget {
  const AddressPickerSheet({super.key});

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
  bool _loading = true;
  List<Map<String, dynamic>> _enderecos = [];
  int _selectedIndex = 0;
  bool _showForm = false;

  final _cepCtrl = TextEditingController();
  final _numeroCtrl = TextEditingController();
  final _complementoCtrl = TextEditingController();
  String _rua = '';
  String _bairro = '';
  String _cidade = '';
  String _estado = '';
  bool _cepLoading = false;
  bool _saveAddress = true;
  String _label = 'Casa';
  bool _savingNew = false;

  static const _labels = ['Casa', 'Trabalho', 'Outro'];
  static const _labelIcons = {
    'Casa': Icons.home_rounded,
    'Trabalho': Icons.work_rounded,
    'Outro': Icons.location_on_rounded,
  };
  static const _labelColors = {
    'Casa': Color(0xFF2979FF),
    'Trabalho': Color(0xFFFF6D00),
    'Outro': Color(0xFF9E9E9E),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _cepCtrl.addListener(_onCepChanged);
  }

  @override
  void dispose() {
    _cepCtrl.removeListener(_onCepChanged);
    _cepCtrl.dispose();
    _numeroCtrl.dispose();
    _complementoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final enderecos = await AuthService.getEnderecos();
    final idx = await AuthService.getEnderecoSelecionadoIndex();
    if (mounted) {
      setState(() {
        _enderecos = enderecos;
        _selectedIndex = enderecos.isEmpty ? 0 : idx.clamp(0, enderecos.length - 1);
        _loading = false;
        if (enderecos.isEmpty) _showForm = true;
      });
    }
  }

  void _onCepChanged() async {
    final cep = _cepCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;
    setState(() => _cepLoading = true);
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['erro'] == null) {
          setState(() {
            _rua    = data['logradouro'] as String? ?? '';
            _bairro = data['bairro']     as String? ?? '';
            _cidade = data['localidade'] as String? ?? '';
            _estado = data['uf']         as String? ?? '';
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _cepLoading = false);
  }

  Future<void> _confirmSelection() async {
    if (_enderecos.isEmpty) return;
    await AuthService.setEnderecoSelecionadoIndex(_selectedIndex);
    if (mounted) Navigator.pop(context, _enderecos[_selectedIndex]);
  }

  Future<void> _addAddress() async {
    final cep    = _cepCtrl.text.replaceAll(RegExp(r'\D'), '');
    final numero = _numeroCtrl.text.trim();

    if (cep.length != 8 || _rua.isEmpty || numero.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Preencha o CEP e o número'),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    setState(() => _savingNew = true);

    final newAddr = <String, dynamic>{
      'label'  : _label,
      'rua'    : _rua,
      'numero' : numero,
      'bairro' : _bairro,
      'cidade' : _cidade,
      'estado' : _estado,
      'cep'    : cep,
      if (_complementoCtrl.text.trim().isNotEmpty)
        'complemento': _complementoCtrl.text.trim(),
    };

    if (_saveAddress) {
      final list = [..._enderecos, newAddr];
      await AuthService.saveEnderecosList(list);
      if (mounted) {
        setState(() {
          _enderecos     = list;
          _selectedIndex = list.length - 1;
          _savingNew     = false;
          _showForm      = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _savingNew = false);
        Navigator.pop(context, newAddr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (_showForm && _enderecos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _showForm = false),
                      child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                    ),
                  ),
                Expanded(
                  child: Text(
                    _showForm ? 'Novo endereço' : 'Escolha o endereço',
                    style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary, letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5),
            )
          else if (_showForm)
            _buildForm()
          else
            _buildList(),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_enderecos.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _enderecos.length,
            itemBuilder: (_, i) => _AddressTile(
              address: _enderecos[i],
              selected: _selectedIndex == i,
              onTap: () => setState(() => _selectedIndex = i),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextButton.icon(
            onPressed: () => setState(() => _showForm = true),
            icon: const Icon(Icons.add_rounded, color: AppTheme.primary, size: 20),
            label: const Text(
              'Adicionar novo endereço',
              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 20),
          child: SizedBox(
            width: double.infinity, height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: _enderecos.isEmpty ? null : AppTheme.brandGradient,
                color: _enderecos.isEmpty ? AppTheme.surfaceAlt : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: _enderecos.isEmpty ? null : _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Usar este endereço',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FormField(
            label: 'CEP',
            child: TextField(
              controller: _cepCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
              ],
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: '00000000',
                suffixIcon: _cepLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          if (_rua.isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(label: 'Rua',    value: _rua),
            _InfoRow(label: 'Bairro', value: _bairro),
            _InfoRow(label: 'Cidade', value: '$_cidade/$_estado'),
          ],
          const SizedBox(height: 12),
          _FormField(
            label: 'Número',
            child: TextField(
              controller: _numeroCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: '123'),
            ),
          ),
          const SizedBox(height: 12),
          _FormField(
            label: 'Complemento (opcional)',
            child: TextField(
              controller: _complementoCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(hintText: 'Apto, bloco, referência...'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Identificar como',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: _labels.map((l) {
              final selected = _label == l;
              final color    = _labelColors[l]!;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _label = l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.12) : AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selected ? color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_labelIcons[l]!, size: 14, color: selected ? color : AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          l,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected ? color : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _saveAddress = !_saveAddress),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: _saveAddress ? AppTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _saveAddress ? AppTheme.primary : AppTheme.textHint,
                      width: 2,
                    ),
                  ),
                  child: _saveAddress
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Salvar para próximas vezes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: _savingNew ? null : _addAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _savingNew
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        _saveAddress ? 'Salvar e usar' : 'Usar uma vez',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _AddressTile extends StatelessWidget {
  final Map<String, dynamic> address;
  final bool selected;
  final VoidCallback onTap;
  const _AddressTile({required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label  = address['label']  as String? ?? 'Endereço';
    final rua    = address['rua']    as String? ?? '';
    final numero = address['numero'] as String? ?? '';
    final bairro = address['bairro'] as String? ?? '';
    final cidade = address['cidade'] as String? ?? '';
    final estado = address['estado'] as String? ?? '';

    const colorMap = {'Casa': Color(0xFF2979FF), 'Trabalho': Color(0xFFFF6D00)};
    const iconMap  = {'Casa': Icons.home_rounded, 'Trabalho': Icons.work_rounded};
    final color = colorMap[label] ?? const Color(0xFF9E9E9E);
    final icon  = iconMap[label]  ?? Icons.location_on_rounded;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.06) : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700,
                      color: selected ? color : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$rua, $numero — $bairro, $cidade/$estado',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : AppTheme.textHint,
                  width: 2,
                ),
                color: selected ? color : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
