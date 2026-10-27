import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabloide_web/tabloide_web.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Funcionalidade: link da página pública na web (D16)', () {
    test(
      'Cenário: Dado uma url, quando abro, então o launcher recebe a mesma url',
      () async {
        final abertas = <Uri>[];
        final service = LinkServiceWeb(
          abrirUrl: (url) async {
            abertas.add(url);
            return true;
          },
          compartilharNoSistema: (_) async => ShareResult.unavailable,
        );

        expect(await service.abrir('https://tabloide.app/f/k7Qm2xPa'), isTrue);
        expect(abertas, [Uri.parse('https://tabloide.app/f/k7Qm2xPa')]);
      },
    );

    test(
      'Cenário: Dado o launcher falhando, quando abro, então devolvo false',
      () async {
        final service = LinkServiceWeb(
          abrirUrl: (_) async => throw PlatformException(code: 'x'),
          compartilharNoSistema: (_) async => ShareResult.unavailable,
        );

        expect(await service.abrir('https://tabloide.app/f/x'), isFalse);
      },
    );

    test('Cenário: Dado "Copiar link", quando copio, então o Clipboard recebe a url', () async {
      final copiado = <Object?>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
            if (chamada.method == 'Clipboard.setData') {
              copiado.add((chamada.arguments as Map)['text']);
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await LinkServiceWeb(
        abrirUrl: (_) async => true,
        compartilharNoSistema: (_) async => ShareResult.unavailable,
      ).copiar('https://tabloide.app/f/k7Qm2xPa');

      expect(copiado, ['https://tabloide.app/f/k7Qm2xPa']);
    });

    test('Cenário: Dado navegador com Web Share, quando compartilho, então o texto vai sem fallback de e-mail e não copio', () async {
      final pedidos = <ShareParams>[];
      final service = LinkServiceWeb(
        abrirUrl: (_) async => true,
        compartilharNoSistema: (params) async {
          pedidos.add(params);
          return ShareResult.unavailable;
        },
      );

      final resultado = await service.compartilhar(
        'Confira as ofertas de Mercado Bom Preço - Centro: https://tabloide.app/f/k7Qm2xPa',
        'https://tabloide.app/f/k7Qm2xPa',
      );

      expect(resultado, ResultadoCompartilhar.compartilhado);
      expect(pedidos.single.text, contains('https://tabloide.app/f/k7Qm2xPa'));
      expect(pedidos.single.mailToFallbackEnabled, isFalse);
    });

    test('Cenário: Dado navegador sem Web Share (share_plus lança), quando compartilho, então copio o link e devolvo copiado', () async {
      final copiado = <Object?>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
            if (chamada.method == 'Clipboard.setData') {
              copiado.add((chamada.arguments as Map)['text']);
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final service = LinkServiceWeb(
        abrirUrl: (_) async => true,
        compartilharNoSistema: (_) async =>
            throw Exception('Navigator.canShare() is unavailable'),
      );

      final resultado = await service.compartilhar(
        'texto',
        'https://tabloide.app/f/k7Qm2xPa',
      );

      expect(resultado, ResultadoCompartilhar.copiado);
      expect(copiado, ['https://tabloide.app/f/k7Qm2xPa']);
    });
  });
}
