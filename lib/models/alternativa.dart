class Alternativa {
 
  String _texto;
  bool _isCorreta; 

Alternativa({
  required String texto,
  required bool isCorreta,
})     : _texto = texto,
      _isCorreta = isCorreta;

    String get texto => _texto;
    bool get isCorreta => _isCorreta;


}
