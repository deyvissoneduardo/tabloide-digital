String urlAbertaPeloPainel(String urlPublica) {
  final uri = Uri.parse(urlPublica);
  return uri
      .replace(queryParameters: {...uri.queryParameters, 'origem': 'painel'})
      .toString();
}
