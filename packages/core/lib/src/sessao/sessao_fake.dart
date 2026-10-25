import 'package:tabloide_core/src/sessao/armazenamento_local.dart';
import 'package:tabloide_core/src/sessao/armazenamento_memoria.dart';
import 'package:tabloide_core/src/sessao/sessao.dart';

final agoraDeTeste = DateTime.utc(2026, 10, 18, 14);

Sessao sessaoDeTeste({ArmazenamentoLocal? armazenamento}) =>
    Sessao(armazenamento ?? ArmazenamentoMemoria(), agora: () => agoraDeTeste);
