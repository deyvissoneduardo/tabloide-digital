enum TipoArquivoPanfleto {
  imagem('IMAGEM'),

  pdf('PDF');

  const TipoArquivoPanfleto(this.codigo);

  final String codigo;

  static TipoArquivoPanfleto? doCodigo(String codigo) =>
      values.where((t) => t.codigo == codigo).firstOrNull;
}
