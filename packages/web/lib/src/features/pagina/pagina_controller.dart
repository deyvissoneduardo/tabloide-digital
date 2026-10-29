import 'package:flutter/foundation.dart';
import 'package:tabloide_web/src/features/pagina/edicao_aparencia.dart';
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

ProdutoEstruturaResponse _daEstrutura(ProdutoResponse produto) =>
    ProdutoEstruturaResponse(
      id: produto.id,
      nome: produto.nome,
      quantidade: produto.quantidade,
      descricao: produto.descricao,
      observacao: produto.observacao,
      precoPromocionalCentavos: produto.precoPromocionalCentavos,
      precoOriginalCentavos: produto.precoOriginalCentavos,
      urlFoto: produto.urlFoto,
      vigencia: produto.vigencia,
    );

/// T9: troca o produto no lugar; se mudou de categoria, sai da antiga e vai
/// para o fim da nova.
List<CategoriaEstruturaResponse> _comProduto(
  List<CategoriaEstruturaResponse> categorias,
  ProdutoResponse editado,
) {
  final produto = _daEstrutura(editado);
  final destino = editado.categoria.id;
  final mesmaCategoria = categorias.any(
    (c) => c.id == destino && c.produtos.any((p) => p.id == produto.id),
  );
  return List.unmodifiable([
    for (final categoria in categorias)
      if (mesmaCategoria && categoria.id == destino)
        categoria.comProdutos([
          for (final p in categoria.produtos) p.id == produto.id ? produto : p,
        ])
      else if (!mesmaCategoria && categoria.id == destino)
        categoria.comProdutos([
          for (final p in categoria.produtos)
            if (p.id != produto.id) p,
          produto,
        ])
      else if (categoria.produtos.any((p) => p.id == produto.id))
        categoria.comProdutos([
          for (final p in categoria.produtos)
            if (p.id != produto.id) p,
        ])
      else
        categoria,
  ]);
}

/// Página da filial em uso: ordem (RN45) e aparência (RN46–RN48). `emEdicao`
/// e `aparenciaEmEdicao` são o que a tela e a prévia mostram; `salvo` e
/// `aparenciaSalva` são o que a API tem (D10). Um único "Publicar" envia as
/// duas (T7).
class PaginaController extends ChangeNotifier {
  PaginaController(this._service);

  final PaginaServiceWeb _service;

  String? _filialId;
  PaginaEstado _estado = const PaginaCarregando();
  List<CategoriaEstruturaResponse> _salvo = const [];
  List<CategoriaEstruturaResponse> _emEdicao = const [];
  ConfiguracaoPaginaResponse _aparenciaSalva =
      ConfiguracaoPaginaResponse.padrao;
  EdicaoAparencia _aparenciaEmEdicao = EdicaoAparencia.de(
    ConfiguracaoPaginaResponse.padrao,
  );
  int _revisaoAparencia = 0;
  bool _publicando = false;
  bool _bloqueado = false;

  String? get filialId => _filialId;

  PaginaEstado get estado => _estado;

  List<CategoriaEstruturaResponse> get salvo => _salvo;

  List<CategoriaEstruturaResponse> get emEdicao => _emEdicao;

  ConfiguracaoPaginaResponse get aparenciaSalva => _aparenciaSalva;

  EdicaoAparencia get aparenciaEmEdicao => _aparenciaEmEdicao;

  /// Muda quando a aparência em edição é trocada por inteiro (carregar ou
  /// descartar): os campos da aba Aparência se preenchem de novo.
  int get revisaoAparencia => _revisaoAparencia;

  bool get ordemMudou => !_mesmaOrdem(_salvo, _emEdicao);

  bool get aparenciaMudou => _aparenciaEmEdicao.mudouDesde(_aparenciaSalva);

  bool get temMudancas => ordemMudou || aparenciaMudou;

  bool get publicando => _publicando;

  /// `true` depois de um 403 `LOJISTA_DESATIVADO`: desliga a edição.
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
        _aparenciaSalva = valor.configuracao;
        _aparenciaEmEdicao = EdicaoAparencia.de(valor.configuracao);
        _revisaoAparencia++;
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

  /// Troca a aparência em edição (sem salvar): a prévia acompanha ao vivo.
  void editarAparencia(EdicaoAparencia Function(EdicaoAparencia atual) editar) {
    if (_bloqueado || _publicando) return;
    _aparenciaEmEdicao = editar(_aparenciaEmEdicao);
    notifyListeners();
  }

  /// Produto salvo pelo formulário aberto no editor (U17, T9): atualiza o
  /// item em `emEdicao` e em `salvo` sem publicar nada.
  void produtoEditado(ProdutoResponse produto) {
    _salvo = _comProduto(_salvo, produto);
    _emEdicao = _comProduto(_emEdicao, produto);
    if (_estado case PaginaCarregada(:final dados)) {
      _estado = PaginaCarregada(
        dados.copiar(estrutura: EstruturaResponse(categorias: _salvo)),
      );
    }
    notifyListeners();
  }

  void descartar() {
    if (!temMudancas) return;
    _emEdicao = _salvo;
    _aparenciaEmEdicao = EdicaoAparencia.de(_aparenciaSalva);
    _revisaoAparencia++;
    notifyListeners();
  }

  /// T7: uploads/remoções do banner → `PATCH` da aparência → `PUT` da ordem,
  /// parando na primeira falha. O que gravou vira salvo; o resto continua
  /// pendente.
  Future<Either<Falha, Nada>> publicar() async {
    final filialId = _filialId;
    if (filialId == null || _publicando) {
      return const Failure(FalhaInesperada('Nenhuma filial carregada'));
    }
    _publicando = true;
    notifyListeners();
    final resultado = await _publicarAparencia();
    final Either<Falha, Nada> fim;
    if (resultado case Failure()) {
      fim = resultado;
    } else if (ordemMudou) {
      fim = await _publicarOrdem(filialId);
    } else {
      fim = const Success(Nada());
    }
    _publicando = false;
    switch (fim) {
      case Failure(falha: FalhaApi(codigo: 'LOJISTA_DESATIVADO')):
        _bloqueado = true;
      case Failure(falha: FalhaApi(codigo: 'ESTRUTURA_INVALIDA')):
        notifyListeners();
        await carregar(filialId);
        return fim;
      case _:
        break;
    }
    notifyListeners();
    return fim;
  }

  Future<Either<Falha, Nada>> _publicarAparencia() async {
    final edicao = _aparenciaEmEdicao;
    if (edicao.logo case final logo?) {
      final r = await _service.enviarLogoBanner(
        bytes: logo.bytes,
        nomeArquivo: logo.nomeArquivo,
      );
      if (r case Failure(:final falha)) return Failure(falha);
      _aparenciaSalvaPor(r, (e, c) => e.comLogoEnviado(c.banner.urlLogo));
    } else if (edicao.removeLogo(_aparenciaSalva)) {
      final r = await _service.removerLogoBanner();
      if (r case Failure(:final falha)) return Failure(falha);
      _aparenciaSalvaPor(r, (e, _) => e);
    }
    if (_aparenciaEmEdicao.enviaFoto) {
      final foto = _aparenciaEmEdicao.foto!;
      final r = await _service.enviarFotoBanner(
        bytes: foto.bytes,
        nomeArquivo: foto.nomeArquivo,
      );
      if (r case Failure(:final falha)) return Failure(falha);
      _aparenciaSalvaPor(
        r,
        (e, c) => e.comFotoEnviada(switch (c.banner.campanha) {
          CampanhaFoto(:final urlFoto) => urlFoto,
          _ => null,
        }),
      );
    } else if (_aparenciaEmEdicao.removeFoto(_aparenciaSalva)) {
      final r = await _service.removerFotoBanner();
      if (r case Failure(:final falha)) return Failure(falha);
      _aparenciaSalvaPor(r, (e, _) => e);
    }
    final pedido = _aparenciaEmEdicao.pedido(_aparenciaSalva);
    if (!pedido.vazio) {
      final r = await _service.editarAparencia(pedido);
      if (r case Failure(:final falha)) return Failure(falha);
      _aparenciaSalvaPor(r, (e, _) => e);
    }
    if (!_aparenciaEmEdicao.mudouDesde(_aparenciaSalva)) {
      _aparenciaEmEdicao = EdicaoAparencia.de(_aparenciaSalva);
    }
    return const Success(Nada());
  }

  void _aparenciaSalvaPor(
    Either<Falha, ConfiguracaoPaginaResponse> resultado,
    EdicaoAparencia Function(EdicaoAparencia, ConfiguracaoPaginaResponse)
    ajustar,
  ) {
    if (resultado case Success(valor: final configuracao)) {
      _aparenciaSalva = configuracao;
      _aparenciaEmEdicao = ajustar(_aparenciaEmEdicao, configuracao);
      if (_estado case PaginaCarregada(:final dados)) {
        _estado = PaginaCarregada(dados.copiar(configuracao: configuracao));
      }
      notifyListeners();
    }
  }

  Future<Either<Falha, Nada>> _publicarOrdem(String filialId) async {
    final resultado = await _service.publicar(
      filialId,
      EstruturaRequest.daEstrutura(_emEdicao),
    );
    if (resultado case Success(:final valor)) {
      _salvo = _emEdicao = List.unmodifiable(valor.categorias);
      if (_estado case PaginaCarregada(:final dados)) {
        _estado = PaginaCarregada(dados.copiar(estrutura: valor));
      }
    }
    return resultado.map((_) => const Nada());
  }
}
