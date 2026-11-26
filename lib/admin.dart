import 'package:flutter/material.dart';
import 'models/filme.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarSupabase();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin - Dicas de Filme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CadastroFilmePage(),
    );
  }
}

class CadastroFilmePage extends StatefulWidget {
  const CadastroFilmePage({super.key});

  @override
  State<CadastroFilmePage> createState() => _CadastroFilmePageState();
}

class _CadastroFilmePageState extends State<CadastroFilmePage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _sinopseController = TextEditingController();
  final _imagemController = TextEditingController();
  final _comentarioController = TextEditingController();

  double _avaliacao = 4.0;
  bool _salvando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _sinopseController.dispose();
    _imagemController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _salvarFilme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final novoFilme = Filme(
        titulo: _tituloController.text.trim(),
        sinopse: _sinopseController.text.trim(),
        avaliacao: _avaliacao,
        imagemUrl: _imagemController.text.trim(),
        comentario: _comentarioController.text.trim(),
      );

      await supabase.from('filmes').insert(novoFilme.toInsertMap());

      if (!mounted) return;
      _formKey.currentState!.reset();
      _tituloController.clear();
      _sinopseController.clear();
      _imagemController.clear();
      _comentarioController.clear();
      setState(() => _avaliacao = 4.0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Filme publicado na timeline com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar filme: $e')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin — Nova Dica de Filme'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título do filme',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o título' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sinopseController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Sinopse',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a sinopse' : null,
              ),
              const SizedBox(height: 12),
              Text('Avaliação: ${_avaliacao.toStringAsFixed(1)} / 5.0'),
              Slider(
                value: _avaliacao,
                min: 0,
                max: 5,
                divisions: 10,
                label: _avaliacao.toStringAsFixed(1),
                onChanged: (valor) => setState(() => _avaliacao = valor),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imagemController,
                decoration: const InputDecoration(
                  labelText: 'URL da imagem (pôster/capa)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o link da imagem'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _comentarioController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Comentário / Recomendação',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Escreva um comentário'
                    : null,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvarFilme,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_salvando ? 'Publicando...' : 'Publicar Filme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}