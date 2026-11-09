import 'package:file_picker/file_picker.dart';
import 'package:tabloide_web/src/features/panfletos/panfleto_form_controller.dart';

class SeletorPdf {
  const SeletorPdf();

  Future<ArquivoEscolhido?> escolher() async {
    final arquivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (arquivo == null) return null;
    return (bytes: await arquivo.readAsBytes(), nome: arquivo.name);
  }
}
