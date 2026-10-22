import 'package:tabloide_core/src/brand/brand_config.dart';
import 'package:tabloide_core/src/brand/brand_erros.dart';
import 'package:tabloide_core/src/brand/cnpj.dart';

/// Registro das marcas white-label disponíveis no build.
///
/// É uma instância comum, não um singleton: o `main` cria, registra, resolve
/// a marca escolhida e descarta.
final class BrandRegistry {
  final Map<String, BrandConfig> _marcas = {};

  static final _formatoId = RegExp(r'^[a-z][a-z0-9_]*$');

  /// Registra [marca] sob [id], validando os dados na hora.
  ///
  /// Lança [MarcaInvalida] ou [MarcaDuplicada].
  void registrar(String id, BrandConfig marca) {
    if (!_formatoId.hasMatch(id)) {
      throw MarcaInvalida(id, 'id deve ser snake_case');
    }
    if (_marcas.containsKey(id)) throw MarcaDuplicada(id);
    _validar(id, marca);
    _marcas[id] = marca;
  }

  /// Devolve a marca registrada sob [id] ou lança [MarcaNaoRegistrada].
  BrandConfig resolver(String id) =>
      _marcas[id] ?? (throw MarcaNaoRegistrada(id, ids));

  /// Ids registrados, na ordem de registro.
  List<String> get ids => List.unmodifiable(_marcas.keys);

  void _validar(String id, BrandConfig marca) {
    if (marca.nome.trim().isEmpty) throw MarcaInvalida(id, 'nome vazio');
    if (!cnpjValido(marca.cnpj)) throw MarcaInvalida(id, 'CNPJ inválido');
    if (marca.corPrimaria.a < 1 || marca.corSecundaria.a < 1) {
      throw MarcaInvalida(id, 'cores da marca não podem ter transparência');
    }
  }
}
