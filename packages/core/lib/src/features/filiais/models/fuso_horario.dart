enum FusoHorario {
  saoPaulo('America/Sao_Paulo', 'São Paulo (UTC−3)'),

  bahia('America/Bahia', 'Salvador (UTC−3)'),

  fortaleza('America/Fortaleza', 'Fortaleza (UTC−3)'),

  recife('America/Recife', 'Recife (UTC−3)'),

  maceio('America/Maceio', 'Maceió (UTC−3)'),

  belem('America/Belem', 'Belém (UTC−3)'),

  santarem('America/Santarem', 'Santarém (UTC−3)'),

  araguaina('America/Araguaina', 'Araguaína (UTC−3)'),

  noronha('America/Noronha', 'Fernando de Noronha (UTC−2)'),

  manaus('America/Manaus', 'Manaus (UTC−4)'),

  cuiaba('America/Cuiaba', 'Cuiabá (UTC−4)'),

  campoGrande('America/Campo_Grande', 'Campo Grande (UTC−4)'),

  portoVelho('America/Porto_Velho', 'Porto Velho (UTC−4)'),

  boaVista('America/Boa_Vista', 'Boa Vista (UTC−4)'),

  rioBranco('America/Rio_Branco', 'Rio Branco (UTC−5)'),

  eirunepe('America/Eirunepe', 'Eirunepé (UTC−5)');

  const FusoHorario(this.id, this.rotulo);

  final String id;

  final String rotulo;

  static FusoHorario? doId(String id) =>
      values.where((fuso) => fuso.id == id).firstOrNull;
}
