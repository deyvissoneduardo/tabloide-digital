import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

import '../../helpers/montar.dart';

class _Componentes extends StatelessWidget {
  const _Componentes();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppEspacamentos.md),
    children: [
      Wrap(
        spacing: AppEspacamentos.sm,
        runSpacing: AppEspacamentos.sm,
        children: [
          FilledButton(onPressed: () {}, child: const Text('Salvar')),
          OutlinedButton(onPressed: () {}, child: const Text('Cancelar')),
          TextButton(onPressed: () {}, child: const Text('Voltar')),
          const FilledButton(onPressed: null, child: Text('Desabilitado')),
        ],
      ),
      const SizedBox(height: AppEspacamentos.md),
      const TextField(
        decoration: InputDecoration(labelText: 'Nome do produto'),
      ),
      const SizedBox(height: AppEspacamentos.md),
      const TextField(
        decoration: InputDecoration(
          labelText: 'Preço original',
          errorText: 'Precisa ser maior que o promocional',
        ),
      ),
      const SizedBox(height: AppEspacamentos.md),
      const Card(
        child: ListTile(
          leading: Icon(Icons.sell),
          title: Text('Arroz 5 kg'),
          subtitle: Text('válido até 31/10'),
        ),
      ),
      const Wrap(
        spacing: AppEspacamentos.sm,
        children: [
          Chip(label: Text('Mercearia')),
          Chip(label: Text('Bebidas')),
        ],
      ),
    ],
  );
}

const _marcas = {
  'azul': MarcaFake(nome: 'Marca Azul'),
  'vermelha': MarcaFake(
    nome: 'Marca Vermelha',
    corPrimaria: Color(0xFFC62828),
    corSecundaria: Color(0xFF2E7D32),
  ),
};

const _celular = BoxConstraints.tightFor(width: 360, height: 480);

void main() {
  goldenTest(
    'Cenário: Dado duas marcas, então os componentes Material seguem o tema do painel',
    fileName: 'componentes_tema',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in _marcas.entries)
          GoldenTestScenario(
            name: 'Marca $nome',
            constraints: _celular,
            child: montarComMarca(
              const SizedBox.expand(child: _Componentes()),
              marca: marca,
            ),
          ),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado os padrões de feedback, então skeleton, vazio e falha seguem o tema',
    fileName: 'padroes_feedback',
    builder: () => GoldenTestGroup(
      columns: 3,
      children: [
        GoldenTestScenario(
          name: 'Carregando (skeleton)',
          constraints: _celular,
          child: montarComMarca(const SizedBox.expand(child: EsqueletoLista())),
        ),
        GoldenTestScenario(
          name: 'Vazio',
          constraints: _celular,
          child: montarComMarca(
            EstadoVazio(
              icone: Icons.storefront,
              titulo: 'Nenhuma filial cadastrada',
              mensagem: 'Cadastre a primeira para gerar o QR Code.',
              rotuloAcao: 'Cadastrar filial',
              aoAgir: () {},
            ),
          ),
        ),
        GoldenTestScenario(
          name: 'Falha',
          constraints: _celular,
          child: montarComMarca(
            EstadoFalha(
              mensagem: 'Sem conexão com a internet.',
              aoTentarDeNovo: () {},
            ),
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'Cenário: Dado os quatro tipos de aviso, então cada um tem título amigável, ícone e borda na cor do status',
    fileName: 'avisos',
    builder: () => GoldenTestGroup(
      columns: 2,
      children: [
        for (final MapEntry(key: nome, value: marca) in _marcas.entries)
          GoldenTestScenario(
            name: 'Marca $nome',
            constraints: const BoxConstraints.tightFor(width: 360, height: 420),
            child: montarComMarca(
              SizedBox.expand(
                child: ListView(
                  padding: const EdgeInsets.all(AppEspacamentos.md),
                  children: [
                    for (final tipo in TipoAviso.values)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppEspacamentos.md),
                          child: AppAviso(
                            tipo: tipo,
                            mensagem:
                                'Mensagem de ${tipo.name} para o lojista.',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              marca: marca,
            ),
          ),
      ],
    ),
  );
}
