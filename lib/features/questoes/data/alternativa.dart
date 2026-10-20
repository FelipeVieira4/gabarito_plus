class Alternativa {

  final String texto;
  final bool isCorreta;

Alternativa({
  required this.texto,
  required this.isCorreta,
  });

  factory Alternativa.fromMap(Map<String, dynamic> map) {
    return Alternativa(
      texto: map['texto'] ?? '',
      isCorreta: map['isCorreta'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'texto': texto,
        'isCorreta': isCorreta,
      };
}
