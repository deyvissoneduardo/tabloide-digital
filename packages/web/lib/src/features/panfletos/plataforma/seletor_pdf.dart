import 'package:file_picker/file_picker.dart';
import 'package:tabloide_web/src/features/panfletos/panfleto_form_controller.dart';

/// Abre o seletor de arquivos do sistema só com PDF. Fica atrás de um provider
/// para os testes trocarem por um falso (o `FilePicker` só tem métodos
/// estáticos).
class SeletorPdf {
  const SeletorPdf();

  /// `null` quando o lojista cancela.
  Future<ArquivoEscolhido?> escolher() async {
    final arquivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (arquivo == null) return null;
    return (bytes: await arquivo.readAsBytes(), nome: arquivo.name);
  }
}
