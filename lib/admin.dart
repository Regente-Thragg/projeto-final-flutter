import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  double _avaliacao = 4.5;
  bool _salvando = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _sinopseController.dispose();
    _imagemController.dispose();
    _comentarioController.dispose();
    super.dispose();
  }

  bool _ehSvg(String url) {
    final limpo = url.trim().toLowerCase().split('?').first;
    return limpo.endsWith('.svg') || url.trim().startsWith('data:image/svg+xml');
  }

  void _preencherExemploTeste() {
    setState(() {
      _tituloController.text = 'Interestelar';
      _sinopseController.text =
          'Uma equipe de exploradores viaja através de um buraco de minhoca no espaço na tentativa de garantir a sobrevivência da humanidade.';
      _avaliacao = 5.0;
      _imagemController.text =
          'https://upload.wikimedia.org/wikipedia/commons/6/69/IMDB_Logo_2016.svg';
      _comentarioController.text =
          'Trilha sonora impecável do Hans Zimmer e ficção científica emocionante do início ao fim.';
    });
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
      setState(() => _avaliacao = 4.5);

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

  Widget _buildPreviewImagem(String url) {
    final link = url.trim();
    if (link.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 240,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: _ehSvg(link)
          ? SvgPicture.network(
              link,
              fit: BoxFit.contain,
              placeholderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __, ___) => const Center(
                child: Text('Não foi possível carregar esse SVG'),
              ),
            )
          : Image.network(
              link,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('Não foi possível pré-visualizar essa URL'),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin — Nova Dica de Filme'),
        actions: [
          TextButton.icon(
            onPressed: _preencherExemploTeste,
            icon: const Icon(Icons.auto_fix_high),
            label: const Text('Exemplo SVG'),
          ),
        ],
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
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'URL da imagem (SVG, PNG ou JPG)',
                  hintText: 'https://exemplo.com/poster.svg',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o link da imagem'
                    : null,
              ),
              _buildPreviewImagem(_imagemController.text),
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