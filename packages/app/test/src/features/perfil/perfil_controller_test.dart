import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

import '../../../helpers/montar.dart';

const _desativado = FalhaApi(
  codigo: 'LOJISTA_DESATIVADO',
  mensagem:
      'Sua conta está desativada. O painel está disponível só para consulta.',
);

void main() {
  group('Funcionalidade: controller de perfil no app', () {
    late LojistaRepositoryFake lojista;
    late IdentidadeRepositoryFake identidade;
    late PerfilController controller;

    setUp(() {
      lojista = LojistaRepositoryFake();
      identidade = IdentidadeRepositoryFake();
      controller = perfilControllerDeTeste(
        lojista: lojista,
        identidade: identidade,
      );
    });

    Future<Either<Falha, Nada>> salvar() => controller.salvar(
      nomeFantasia: '  Mercado Novo ',
      nomeResponsavel: ' Bia ',
      whatsapp: '(11) 91234-5678',
      cnpj: '11.222.333/0001-81',
      corPrimaria: '#00ff00',
      corSecundaria: '',
      sePanfleto: true,
    );

    test('Cenário: Dado as duas APIs respondendo, quando carrego, então tenho lojista e identidade', () async {
      final estados = <PerfilEstado>[];
      controller.addListener(() => estados.add(controller.estado));

      await controller.carregar();

      expect(estados.first, isA<PerfilCarregando>());
      final carregado = controller.estado as PerfilCarregado;
      expect(carregado.lojista, lojistaFake);
      expect(carregado.identidade, identidadeFake);
    });

    for (final (qual, falhar) in [
      (
        'do lojista',
        (LojistaRepositoryFake l, IdentidadeRepositoryFake _) =>
            l.falhaSimulada = const FalhaSemConexao(),
      ),
      (
        'da identidade',
        (LojistaRepositoryFake _, IdentidadeRepositoryFake i) =>
            i.falhaSimulada = const FalhaSemConexao(),
      ),
    ]) {
      test(
        'Cenário: Dado a API $qual fora do ar, quando carrego, então fico com a falha',
        () async {
          falhar(lojista, identidade);

          await controller.carregar();

          expect(
            (controller.estado as PerfilComFalha).falha,
            const FalhaSemConexao(),
          );
        },
      );
    }

    test('Cenário: Dado o formulário com máscaras, quando salvo, então atualizo o lojista e a identidade com o mesmo nome fantasia', () async {
      await controller.carregar();

      final resultado = await salvar();

      expect(resultado, const Success<Falha, Nada>(Nada()));
      expect(
        lojista.pedidos.single,
        const LojistaRequest(
          nomeFantasia: 'Mercado Novo',
          nomeResponsavel: 'Bia',
          whatsapp: '11912345678',
          cnpj: '11222333000181',
        ),
      );
      expect(
        identidade.pedidos.single,
        const IdentidadeRequest(
          nomeFantasia: 'Mercado Novo',
          corPrimaria: '#00FF00',
          sePanfleto: true,
        ),
      );
      final carregado = controller.estado as PerfilCarregado;
      expect(carregado.lojista.nomeFantasia, 'Mercado Novo');
      expect(carregado.identidade.nomeFantasia, 'Mercado Novo');
      expect(controller.salvando, isFalse);
    });

    test('Cenário: Dado a conta desativada, quando salvo, então devolvo a falha e não atualizo a identidade', () async {
      await controller.carregar();
      lojista.falhaSimulada = _desativado;

      final resultado = await salvar();

      expect(resultado, const Failure<Falha, Nada>(_desativado));
      expect(identidade.pedidos, isEmpty);
      expect(controller.estado, isA<PerfilCarregado>());
    });

    test('Cenário: Dado um WhatsApp recusado pela API, quando salvo, então o erro vai para o campo e some quando edito', () async {
      await controller.carregar();
      lojista.falhaSimulada = const FalhaApi(
        codigo: 'VALIDACAO_INVALIDA',
        mensagem: 'Dados inválidos.',
        campos: {
          'whatsapp': ['Informe um WhatsApp válido com DDD.'],
        },
      );

      await salvar();

      expect(
        controller.erroDoCampo('whatsapp'),
        'Informe um WhatsApp válido com DDD.',
      );
      controller.limparErroDoCampo('whatsapp');
      expect(controller.erroDoCampo('whatsapp'), isNull);
    });

    test('Cenário: Dado uma cor recusada pela API da identidade, quando salvo, então o erro vai para o campo da cor', () async {
      await controller.carregar();
      identidade.falhaSimulada = const FalhaApi(
        codigo: 'VALIDACAO_INVALIDA',
        mensagem: 'Dados inválidos.',
        campos: {
          'corPrimaria': ['Informe a cor no formato #RRGGBB.'],
        },
      );

      final resultado = await salvar();

      expect(resultado.isFailure, isTrue);
      expect(
        controller.erroDoCampo('corPrimaria'),
        'Informe a cor no formato #RRGGBB.',
      );
    });

    test('Cenário: Dado uma imagem válida, quando envio o logo, então a identidade passa a ter o novo logo e o lojista continua', () async {
      await controller.carregar();

      final resultado = await controller.enviarLogo(
        bytes: [1, 2, 3],
        nomeArquivo: 'novo.png',
      );

      expect(resultado.isSuccess, isTrue);
      expect(controller.enviandoLogo, isFalse);
      final carregado = controller.estado as PerfilCarregado;
      expect(carregado.identidade.urlLogo, 'https://midia.fake/logo/novo.png');
      expect(carregado.lojista, lojistaFake);
    });

    test('Cenário: Dado uma imagem maior que 10 MB, quando envio o logo, então recuso sem chamar a API', () async {
      await controller.carregar();

      final resultado = await controller.enviarLogo(
        bytes: List.filled(maxBytesLogo + 1, 0),
        nomeArquivo: 'grande.png',
      );

      expect(
        (resultado as Failure<Falha, IdentidadeResponse>).falha,
        isA<FalhaApi>().having(
          (f) => f.codigo,
          'codigo',
          'IMAGEM_MUITO_GRANDE',
        ),
      );
      expect(identidade.logosEnviados, isEmpty);
    });

    test('Cenário: Dado a API recusando a imagem, quando envio o logo, então devolvo a falha e mantenho o logo atual', () async {
      await controller.carregar();
      identidade.falhaSimulada = const FalhaApi(
        codigo: 'IMAGEM_INVALIDA',
        mensagem: 'Envie uma imagem JPEG, PNG ou WebP válida.',
      );

      final resultado = await controller.enviarLogo(
        bytes: [1],
        nomeArquivo: 'a.gif',
      );

      expect(resultado.isFailure, isTrue);
      expect(
        (controller.estado as PerfilCarregado).identidade.urlLogo,
        identidadeFake.urlLogo,
      );
    });
  });
}
