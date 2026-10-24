import 'package:tabloide_core/src/brand/brand_config.dart';
import 'package:tabloide_core/src/brand/brand_erros.dart';
import 'package:tabloide_core/src/brand/cnpj.dart';

final class BrandRegistry {
  final Map<String, BrandConfig> _marcas = {};

  static final _formatoId = RegExp(r'^[a-z][a-z0-9_]*$');

  void registrar(String id, BrandConfig marca) {
    if (!_formatoId.hasMatch(id)) {
      throw MarcaInvalida(id, 'id deve ser snake_case');
    }
    if (_marcas.containsKey(id)) throw MarcaDuplicada(id);
    _validar(id, marca);
    _marcas[id] = marca;
  }

  BrandConfig resolver(String id) =>
      _marcas[id] ?? (throw MarcaNaoRegistrada(id, ids));

  List<String> get ids => List.unmodifiable(_marcas.keys);

  void _validar(String id, BrandConfig marca) {
    if (marca.nome.trim().isEmpty) throw MarcaInvalida(id, 'nome vazio');
    if (!cnpjValido(marca.cnpj)) throw MarcaInvalida(id, 'CNPJ inválido');
    if (marca.corPrimaria.a < 1 || marca.corSecundaria.a < 1) {
      throw MarcaInvalida(id, 'cores da marca não podem ter transparência');
    }
  }
}
