class Aluno {
  final String id;  // mantido como String possível código serial como identificar
  final String nome;
  final String email;
  final bool isAtivo;

  Aluno({
    required this.id,
    required this.nome,
    required this.email,
    required this.isAtivo,
  });
}
