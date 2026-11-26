import 'package:flutter/material.dart';
import 'models/filme.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await inicializarSupabase();
  runApp(const TimelineFilmesApp());
}

class TimelineFilmesApp extends StatelessWidget {
  const TimelineFilmesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dicas de Filme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TimelineFilmesPage(),
    );
  }
}

class TimelineFilmesPage extends StatefulWidget {
  const TimelineFilmesPage({super.key});

  @override
  State<TimelineFilmesPage> createState() => _TimelineFilmesPageState();
}

class _TimelineFilmesPageState extends State<TimelineFilmesPage> {
  late Future<List<Filme>> _filmesFuture;

  @override
  void initState() {
    super.initState();
    _filmesFuture = _buscarFilmes();
  }

  Future<List<Filme>> _buscarFilmes() async {
    final resposta = await supabase
        .from('filmes')
        .select()
        .order('created_at', ascending: false);

    return (resposta as List<dynamic>)
        .map((item) => Filme.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> _atualizarTimeline() async {
    setState(() {
      _filmesFuture = _buscarFilmes();
    });
    await _filmesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dicas de Filme'),
        actions: [
          IconButton(
            onPressed: _atualizarTimeline,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar timeline',
          ),
        ],
      ),
      body: FutureBuilder<List<Filme>>(
        future: _filmesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Não foi possível carregar os filmes:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _atualizarTimeline,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filmes = snapshot.data ?? [];
          if (filmes.isEmpty) {
            return RefreshIndicator(
              onRefresh: _atualizarTimeline,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Center(
                    child: Text(
                      'Nenhuma dica de filme cadastrada ainda.\nPublique uma pelo admin.dart!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _atualizarTimeline,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filmes.length,
              itemBuilder: (context, index) {
                return _FilmeCard(filme: filmes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _FilmeCard extends StatelessWidget {
  final Filme filme;

  const _FilmeCard({required this.filme});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filme.imagemUrl.trim().isNotEmpty)
            SizedBox(
              height: 210,
              width: double.infinity,
              child: Image.network(
                filme.imagemUrl.trim(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, size: 40),
                      SizedBox(height: 6),
                      Text('Imagem indisponível'),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        filme.titulo,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      avatar: const Icon(Icons.star, size: 18, color: Colors.amber),
                      label: Text(filme.avaliacao.toStringAsFixed(1)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Sinopse',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(filme.sinopse),
                if (filme.comentario.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Comentário: "${filme.comentario}"',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}