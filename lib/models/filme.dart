class Filme {
  final String? id;
  final String titulo;
  final String sinopse;
  final double avaliacao;
  final String imagemUrl;
  final String comentario;
  final DateTime? createdAt;

  Filme({
    this.id,
    required this.titulo,
    required this.sinopse,
    required this.avaliacao,
    required this.imagemUrl,
    required this.comentario,
    this.createdAt,
  });

  factory Filme.fromMap(Map<String, dynamic> map) {
    return Filme(
      id: map['id']?.toString(),
      titulo: map['titulo'] ?? '',
      sinopse: map['sinopse'] ?? '',
      avaliacao: (map['avaliacao'] is num)
          ? (map['avaliacao'] as num).toDouble()
          : double.tryParse(map['avaliacao']?.toString() ?? '0') ?? 0.0,
      imagemUrl: map['imagem_url'] ?? '',
      comentario: map['comentario'] ?? '',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'titulo': titulo,
      'sinopse': sinopse,
      'avaliacao': avaliacao,
      'imagem_url': imagemUrl,
      'comentario': comentario,
    };
  }
}