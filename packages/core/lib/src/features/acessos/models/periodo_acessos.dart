sealed class PeriodoAcessos {
  const PeriodoAcessos();

  static const padrao = PeriodoPredefinido(30);

  static const maximoDias = 366;

  static const diasPredefinidos = [1, 7, 15, 30];

  int get dias;
}

final class PeriodoPredefinido extends PeriodoAcessos {
  const PeriodoPredefinido(this.dias)
    : assert(dias == 1 || dias == 7 || dias == 15 || dias == 30);

  @override
  final int dias;

  @override
  bool operator ==(Object other) =>
      other is PeriodoPredefinido && other.dias == dias;

  @override
  int get hashCode => Object.hash(PeriodoPredefinido, dias);
}

final class PeriodoPersonalizado extends PeriodoAcessos {
  const PeriodoPersonalizado(this.inicio, this.fim);

  final DateTime inicio;

  final DateTime fim;

  @override
  int get dias =>
      DateTime.utc(
        fim.year,
        fim.month,
        fim.day,
      ).difference(DateTime.utc(inicio.year, inicio.month, inicio.day)).inDays +
      1;

  @override
  bool operator ==(Object other) =>
      other is PeriodoPersonalizado &&
      other.inicio == inicio &&
      other.fim == fim;

  @override
  int get hashCode => Object.hash(PeriodoPersonalizado, inicio, fim);
}
