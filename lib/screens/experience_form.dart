import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _experienceName = "";
  String _description = "";
  String _category = "Full-Time";
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  final List<String> _categories = [
    "Full-Time",
    "Part-Time",
    "Internship",
    "Volunteer",
    "Research",
  ];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _pickDate({required bool isStart}) async {
    FocusScope.of(context).unfocus();
    final date = await showDatePicker(
      context: context,
      initialDate:
          (isStart ? _startDate : _endDate) ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (!mounted || date == null) return;
    setState(() {
      if (isStart) {
        _startDate = date;
        _startDateController.text = _formatDate(date);
      } else {
        _endDate = date;
        _endDateController.text = _formatDate(date);
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Pengalaman'),
        scrollable: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Nama Pengalaman: $_experienceName'),
            Text('Deskripsi: $_description'),
            Text('Kategori: $_category'),
            Text('Tanggal Mulai: ${_formatDate(_startDate!)}'),
            Text(
              'Tanggal Selesai: ${_isOngoing ? 'Masih berlangsung (Ongoing)' : _formatDate(_endDate!)}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengalaman'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nama Pengalaman',
                    hintText: 'Contoh: Software Engineer di Mana',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: 100,
                  validator: (value) {
                    final name = value?.trim() ?? '';
                    if (name.isEmpty) return 'Nama pengalaman wajib diisi.';
                    if (name.length > 100) {
                      return 'Nama pengalaman maksimal 100 karakter.';
                    }
                    return null;
                  },
                  onSaved: (value) => _experienceName = value!.trim(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Ceritakan detail pengalamanmu',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  maxLength: 1000,
                  validator: (value) {
                    final description = value?.trim() ?? '';
                    if (description.isEmpty) return 'Deskripsi wajib diisi.';
                    if (description.length > 1000) {
                      return 'Deskripsi maksimal 1000 karakter.';
                    }
                    return null;
                  },
                  onSaved: (value) => _description = value!.trim(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                  validator: (value) => _categories.contains(value)
                      ? null
                      : 'Pilih kategori pengalaman yang valid.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai',
                    hintText: 'Pilih tanggal mulai',
                    suffixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) =>
                      _startDate == null ? 'Tanggal mulai wajib diisi.' : null,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Masih berlangsung (Ongoing)'),
                  value: _isOngoing,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _isOngoing = value ?? false;
                      if (_isOngoing) {
                        _endDate = null;
                        _endDateController.clear();
                      }
                    });
                  },
                ),
                if (!_isOngoing)
                  TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Selesai',
                      hintText: 'Pilih tanggal selesai',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    onTap: () => _pickDate(isStart: false),
                    validator: (_) {
                      if (_endDate == null) {
                        return 'Tanggal selesai wajib diisi.';
                      }
                      if (_startDate != null &&
                          _endDate!.isBefore(_startDate!)) {
                        return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  onPressed: _save,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
