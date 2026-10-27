import 'package:flutter/foundation.dart';
import 'package:tabloide_web/src/features/pagina/pagina_estado.dart';
import 'package:tabloide_web/src/features/pagina/services/pagina_service_web.dart';
import 'package:tabloide_core/tabloide_core.dart';

bool _mesmaOrdem(
  List<CategoriaEstruturaResponse> a,
  List<CategoriaEstruturaResponse> b,
) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].id != b[i].id) return false;
    final pa = a[i].produtos;
    final pb = b[i].produtos;
    if (pa.length != pb.length) return false;
    for (var j = 0; j < pa.length; j++) {
      if (pa[j].id != pb[j].id) return false;
    }
  }
  return true;
}

List<T> _mover<T>(List<T> lista, int de, int para) {
  if (de < 0 || de >= lista.length || para < 0 || para >= lista.length) {
    return lista;
  }
  if (de == para) return lista;
  final nova = [...lista];
  nova.insert(para, nova.removeAt(de));
  return List.unmodifiable(nova);
}

/// Ordem da página da filial em uso (RN45). `emEdicao` é o que a tela e a
/// prévia mostram; `salvo` é o que a API tem (D10).
class PaginaController extends ChangeNotifier {
  PaginaController(this._service);

  final PaginaServiceWeb _service;

  String? _filialId;
  PaginaEstado _estado = const PaginaCarregando();
  List<CategoriaEstruturaResponse> _salvo = const [];
  List<CategoriaEstruturaResponse> _emEdicao = const [];
  bool _publicando = false;
  bool _bloqueado = false;

  String? get filialId => _filialId;

  PaginaEstado get estado => _estado;

  List<CategoriaEstruturaResponse> get salvo => _salvo;

  List<CategoriaEstruturaResponse> get emEdicao => _emEdicao;

  bool get temMudancas => !_mesmaOrdem(_salvo, _emEdicao);

  bool get publicando => _publicando;

  /// `true` depois de um 403 `LOJISTA_DESATIVADO`: desliga o arrastar.
  bool get bloqueado => _bloqueado;

  Future<void> carregar(String filialId) async {
    _filialId = filialId;
    _estado = const PaginaCarregando();
    notifyListeners();
    final resultado = await _service.carregar(filialId);
    if (filialId != _filialId) return;
    switch (resultado) {
      case Success(:final valor):
        _estado = PaginaCarregada(valor);
        _salvo = _emEdicao = List.unmodifiable(valor.estrutura.categorias);
      case Failure(:final falha):
        _estado = PaginaComFalha(falha);
    }
    notifyListeners();
  }

  /// Índices do `onReorderItem` do `ReorderableListView` (`para` já é a
  /// posição final).
  void moverCategoria(int de, int para) {
    if (_bloqueado || _publicando) return;
    final nova = _mover(_emEdicao, de, para);
    if (identical(nova, _emEdicao)) return;
    _emEdicao = nova;
    notifyListeners();
  }

  void moverProduto(String categoriaId, int de, int para) {
    if (_bloqueado || _publicando) return;
    final i = _emEdicao.indexWhere((c) => c.id == categoriaId);
    if (i < 0) return;
    final categoria = _emEdicao[i];
    final produtos = _mover(categoria.produtos, de, para);
    if (identical(produtos, categoria.produtos)) return;
    _emEdicao = List.unmodifiable([
      for (final (j, c) in _emEdicao.indexed)
        j == i ? categoria.comProdutos(produtos) : c,
    ]);
    notifyListeners();
  }

  void subir(int indice) => moverCategoria(indice, indice - 1);

  void descer(int indice) => moverCategoria(indice, indice + 1);

  void esquerda(String categoriaId, int indice) =>
      moverProduto(categoriaId, indice, indice - 1);

  void direita(String categoriaId, int indice) =>
      moverProduto(categoriaId, indice, indice + 1);

  void descartar() {
    if (!temMudancas) return;
    _emEdicao = _salvo;
    notifyListeners();
  }

  Future<Either<Falha, Nada>> publicar() async {
    final filialId = _filialId;
    if (filialId == null || _publicando) {
      return const Failure(FalhaInesperada('Nenhuma filial carregada'));
    }
    _publicando = true;
    notifyListeners();
    final resultado = await _service.publicar(
      filialId,
      EstruturaRequest.daEstrutura(_emEdicao),
    );
    _publicando = false;
    switch (resultado) {
      case Success(:final valor):
        _salvo = _emEdicao = List.unmodifiable(valor.categorias);
        if (_estado case PaginaCarregada(:final dados)) {
          _estado = PaginaCarregada(
            DadosPagina(
              identidade: dados.identidade,
              estrutura: valor,
              panfletoVigente: dados.panfletoVigente,
            ),
          );
        }
      case Failure(falha: FalhaApi(codigo: 'LOJISTA_DESATIVADO')):
        _bloqueado = true;
      case Failure(falha: FalhaApi(codigo: 'ESTRUTURA_INVALIDA')):
        notifyListeners();
        await carregar(filialId);
        return resultado.map((_) => const Nada());
      case Failure():
        break;
    }
    notifyListeners();
    return resultado.map((_) => const Nada());
  }
}
