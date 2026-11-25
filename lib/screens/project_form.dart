import 'package:http/http.dart' show ClientException;
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _techStack = '';
  String _projectUrl = '';
  String _projectImageUrl = '';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final form = _formKey.currentState!;
    if (_isSubmitting || !form.validate()) return;
    form.save();

    final newProject = Project(
      title: _title,
      description: _description,
      techStack: _techStack,
      projectUrl: _projectUrl,
      projectImageUrl: _projectImageUrl,
    );
    final auth = context.read<AuthState>();
    final api = context.read<ApiClient>();
    String? token;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      if (!await ensureLoggedIn(context) || !mounted) return;
      token = auth.token;
      if (token == null) return;

      final created = await api.createProject(newProject, token: token);
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: Text(created.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) form.reset();
    } on ApiException catch (error) {
      if (error.statusCode != 401) {
        _showMessage('Gagal menyimpan proyek (${error.statusCode}).');
        return;
      }

      if (token != null && auth.token == token) await auth.logout();
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (!await ensureLoggedIn(context)) {
        _showMessage('Sesi berakhir. Login lagi untuk menyimpan proyek.');
      }
    } on ClientException {
      _showMessage('Gagal terhubung ke server. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateRequired(String? value) {
    return (value ?? '').trim().isEmpty ? 'Kolom ini wajib diisi.' : null;
  }

  String? _validateUrl(String? value, {bool optional = false}) {
    final url = (value ?? '').trim();
    if (url.isEmpty) return optional ? null : 'URL proyek wajib diisi.';

    final uri = Uri.tryParse(url);
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty ||
        RegExp(r'\s').hasMatch(url)) {
      return 'Masukkan URL HTTP atau HTTPS yang valid.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: border,
                ),
                validator: _validateRequired,
                onSaved: (value) => _title = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: border,
                ),
                maxLines: 5,
                validator: _validateRequired,
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Tech Stack',
                  border: border,
                ),
                validator: _validateRequired,
                onSaved: (value) => _techStack = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Project URL',
                  border: border,
                ),
                keyboardType: TextInputType.url,
                validator: _validateUrl,
                onSaved: (value) => _projectUrl = value!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Project Image URL (Optional)',
                  border: border,
                ),
                keyboardType: TextInputType.url,
                validator: (value) => _validateUrl(value, optional: true),
                onSaved: (value) => _projectImageUrl = value?.trim() ?? '',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: Text(_isSubmitting ? 'Saving...' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
