import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tabloide_core/src/features/pagina/models/tipo_campanha.dart';
import 'package:tabloide_core/src/theme/app_espacamentos.dart';
import 'package:tabloide_core/src/theme/app_layout.dart';
import 'package:tabloide_core/src/widgets/app_campo_imagem.dart';

/// Máximo de caracteres da descrição da campanha (U6).
const maxDescricaoCampanha = 280;

/// Campanha do banner (U5): segmentado **Foto | Descrição | Nenhuma** e, abaixo,
/// o campo de imagem 16:9 ou o texto multilinha com contador. Quem escolhe a
/// imagem é a tela; a validação da descrição vem por [validadorDescricao].
class AppCampoCampanha extends StatelessWidget {
  const AppCampoCampanha({
    super.key,
    required this.tipo,
    required this.descricao,
    this.aoMudarTipo,
    this.bytesFoto,
    this.urlFoto,
    this.aoEscolherFoto,
    this.aoRemoverFoto,
    this.erroFoto,
    this.aoMudarDescricao,
    this.validadorDescricao,
    this.habilitado = true,
  });

  final TipoCampanha tipo;

  final TextEditingController descricao;

  final ValueChanged<TipoCampanha>? aoMudarTipo;

  final Uint8List? bytesFoto;

  final String? urlFoto;

  final VoidCallback? aoEscolherFoto;

  final VoidCallback? aoRemoverFoto;

  final String? erroFoto;

  final ValueChanged<String>? aoMudarDescricao;

  final FormFieldValidator<String>? validadorDescricao;

  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final aoMudarTipo = this.aoMudarTipo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppEspacamentos.md,
      children: [
        Text('Campanha', style: tema.textTheme.titleSmall),
        SegmentedButton<TipoCampanha>(
          segments: const [
            ButtonSegment(
              value: TipoCampanha.foto,
              label: Text('Foto'),
              icon: Icon(Icons.image_outlined),
            ),
            ButtonSegment(
              value: TipoCampanha.descricao,
              label: Text('Descrição'),
              icon: Icon(Icons.notes_outlined),
            ),
            ButtonSegment(
              value: TipoCampanha.nenhuma,
              label: Text('Nenhuma'),
              icon: Icon(Icons.block_outlined),
            ),
          ],
          selected: {tipo},
          showSelectedIcon: false,
          onSelectionChanged: habilitado && aoMudarTipo != null
              ? (selecao) => aoMudarTipo(selecao.first)
              : null,
        ),
        switch (tipo) {
          TipoCampanha.foto => AppCampoImagem(
            rotulo: 'Foto da campanha',
            descricao: 'Foto da campanha',
            bytes: bytesFoto,
            url: urlFoto,
            proporcao: AppLayout.proporcaoFotoBanner,
            aoEscolher: habilitado ? aoEscolherFoto : null,
            aoRemover: habilitado ? aoRemoverFoto : null,
            erro: erroFoto,
            ajuda: 'Exibida em 16:9. JPEG, PNG ou WebP de até 10 MB.',
          ),
          TipoCampanha.descricao => TextFormField(
            controller: descricao,
            enabled: habilitado,
            decoration: const InputDecoration(
              labelText: 'Descrição da campanha',
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 6,
            maxLength: maxDescricaoCampanha,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onChanged: aoMudarDescricao,
            validator: validadorDescricao,
          ),
          TipoCampanha.nenhuma => Text(
            'O banner fica sem foto e sem descrição.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
            ),
          ),
        },
      ],
    );
  }
}
