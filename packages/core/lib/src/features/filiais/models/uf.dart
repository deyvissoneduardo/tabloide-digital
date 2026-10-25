import 'package:tabloide_core/src/features/filiais/models/fuso_horario.dart';

enum Uf {
  ac('AC', 'Acre', FusoHorario.rioBranco),

  al('AL', 'Alagoas', FusoHorario.maceio),

  ap('AP', 'Amapá', FusoHorario.belem),

  am('AM', 'Amazonas', FusoHorario.manaus),

  ba('BA', 'Bahia', FusoHorario.bahia),

  ce('CE', 'Ceará', FusoHorario.fortaleza),

  df('DF', 'Distrito Federal', FusoHorario.saoPaulo),

  es('ES', 'Espírito Santo', FusoHorario.saoPaulo),

  go('GO', 'Goiás', FusoHorario.saoPaulo),

  ma('MA', 'Maranhão', FusoHorario.fortaleza),

  mt('MT', 'Mato Grosso', FusoHorario.cuiaba),

  ms('MS', 'Mato Grosso do Sul', FusoHorario.campoGrande),

  mg('MG', 'Minas Gerais', FusoHorario.saoPaulo),

  pa('PA', 'Pará', FusoHorario.belem),

  pb('PB', 'Paraíba', FusoHorario.fortaleza),

  pr('PR', 'Paraná', FusoHorario.saoPaulo),

  pe('PE', 'Pernambuco', FusoHorario.recife),

  pi('PI', 'Piauí', FusoHorario.fortaleza),

  rj('RJ', 'Rio de Janeiro', FusoHorario.saoPaulo),

  rn('RN', 'Rio Grande do Norte', FusoHorario.fortaleza),

  rs('RS', 'Rio Grande do Sul', FusoHorario.saoPaulo),

  ro('RO', 'Rondônia', FusoHorario.portoVelho),

  rr('RR', 'Roraima', FusoHorario.boaVista),

  sc('SC', 'Santa Catarina', FusoHorario.saoPaulo),

  sp('SP', 'São Paulo', FusoHorario.saoPaulo),

  se('SE', 'Sergipe', FusoHorario.maceio),

  to('TO', 'Tocantins', FusoHorario.araguaina);

  const Uf(this.sigla, this.nome, this.fuso);

  final String sigla;

  final String nome;

  final FusoHorario fuso;

  static Uf? daSigla(String sigla) =>
      values.where((uf) => uf.sigla == sigla.toUpperCase()).firstOrNull;
}
