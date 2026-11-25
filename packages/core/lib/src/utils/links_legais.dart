/// Endereços dos documentos legais publicados na página pública (LGPD).
/// A base vem de `--dart-define=PAGINA_PUBLICA_URL=...`; sem ela, usa o domínio de produção.
abstract final class LinksLegais {
  static const _base = String.fromEnvironment(
    'PAGINA_PUBLICA_URL',
    defaultValue: 'https://tabloide-digital.vercel.app',
  );

  static const termos = '$_base/termos';

  static const privacidade = '$_base/privacidade';
}
