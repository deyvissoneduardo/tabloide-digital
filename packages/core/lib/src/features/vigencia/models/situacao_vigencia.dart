enum SituacaoVigencia {
  vigente('VIGENTE', 'Vigente'),

  agendado('AGENDADO', 'Agendado');

  const SituacaoVigencia(this.codigo, this.rotulo);

  final String codigo;

  final String rotulo;

  static SituacaoVigencia? doCodigo(String codigo) =>
      values.where((s) => s.codigo == codigo).firstOrNull;
}
