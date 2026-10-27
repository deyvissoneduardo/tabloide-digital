import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabloide_app/tabloide_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Funcionalidade: link da página pública no app (D16)', () {
    test(
      'Cenário: Dado uma url, quando abro, então o launcher recebe a mesma url',
      () async {
        final abertas = <Uri>[];
        final service = LinkServiceApp(
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
        final service = LinkServiceApp(
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

      await LinkServiceApp(
        abrirUrl: (_) async => true,
        compartilharNoSistema: (_) async => ShareResult.unavailable,
      ).copiar('https://tabloide.app/f/k7Qm2xPa');

      expect(copiado, ['https://tabloide.app/f/k7Qm2xPa']);
    });

    test('Cenário: Dado "Compartilhar link", quando compartilho, então share_plus recebe o texto com a url', () async {
      final pedidos = <ShareParams>[];
      final service = LinkServiceApp(
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
    });
  });
}
