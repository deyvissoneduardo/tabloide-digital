# Tabloide Digital — Painel do Lojista

> Painel do lojista do Tabloide Digital — um único código Flutter, white-label, para app mobile e web.

![Home do painel nas marcas Tabloide e Mercado Exemplo](packages/app/test/src/features/home/goldens/ci/home_screen_app_light.png)

*Golden de CI da home mobile: a mesma tela nas duas marcas cadastradas (texto renderizado como blocos).*

## Sobre

O painel é onde o lojista acompanha filiais, panfletos e produtos vigentes. Um mesmo código atende vários clientes: cada marca (nome, cores, logo e CNPJ) é escolhida no build, sem fork do projeto.

O repositório é um [Pub Workspace](https://dart.dev/tools/pub/workspaces) com quatro pacotes, e o app raiz (`lib/`) só faz o bootstrap da plataforma certa:

| Pacote | Papel | Depende de |
|---|---|---|
| [`packages/core`](packages/core) (`tabloide_core`) | Contrato de marca, tema, HTTP (Dio), `Either`/`Falha`, controllers e repositórios | — |
| [`packages/brands`](packages/brands) (`tabloide_brands`) | Uma classe `BrandConfig` + assets por cliente | core |
| [`packages/app`](packages/app) (`tabloide_app`) | Telas do painel mobile (Android/iOS) | core |
| [`packages/web`](packages/web) (`tabloide_web`) | Telas do painel web | core |

Essas dependências são verificadas por teste (`packages/core/test/arquitetura/dependencias_test.dart`).

## Features

- Home com navegação entre **Início**, **Filiais**, **Panfletos** e **Produtos**.
- Resumo de início com filiais, panfletos vigentes e produtos vigentes.
- Marca e URL da API definidas no build via `--dart-define`.
- Tema claro e escuro derivado das cores da marca.

> Os dados do resumo ainda vêm de `HomeRepositoryFake` (em memória); a integração com a API ainda não existe.

## Pré-requisitos

- Flutter com Dart SDK `^3.13.0` (testado com Flutter 3.47.3, canal stable)
- Chrome, para rodar a versão web e os testes de navegador
- Xcode / Android SDK, para rodar no iOS / Android

## Como rodar

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=config/marcas/tabloide.json
```

Para outra marca ou outro dispositivo, troque o arquivo de config e o `-d`:

```bash
flutter run --dart-define-from-file=config/marcas/mercado_exemplo.json
```

## Configuração

Os valores são lidos com `String.fromEnvironment` em `lib/main.dart`. Já existe um arquivo pronto por marca em [`config/marcas/`](config/marcas).

| Variável | Default | Descrição |
|---|---|---|
| `MARCA` | `tabloide` | Id da marca registrada em `registrarMarcas`. Se o id não existir, o app não sobe (`MarcaNaoRegistrada`). |
| `API_URL` | `http://localhost:3000/v1` | URL base da API do Tabloide. |

### Adicionando uma marca

1. Crie `packages/brands/lib/src/<marca>/<marca>_brand.dart` implementando `BrandConfig`.
2. Coloque o logo em `packages/brands/assets/<marca>/` e declare a pasta em `flutter.assets` no `packages/brands/pubspec.yaml`.
3. Registre a marca em `packages/brands/lib/src/registrar_marcas.dart`.
4. Crie `config/marcas/<marca>.json` com `MARCA` e `API_URL`.

Use `MercadoExemploBrand` como referência.

## Build

```bash
flutter build web --dart-define-from-file=config/marcas/tabloide.json
flutter build apk --dart-define-from-file=config/marcas/tabloide.json
flutter build ios --dart-define-from-file=config/marcas/tabloide.json
```

## Testes

Os scripts ficam no `pubspec.yaml` raiz (seção `melos`) e rodam em todos os pacotes. Não é preciso instalar o Melos globalmente:

```bash
dart run melos run analyze          # flutter analyze em cada pacote
dart run melos run test             # todos os testes, exceto os de navegador
dart run melos run test:golden      # só os goldens
dart run melos run golden:atualizar # regenera os goldens
dart run melos run test:browser     # testes do core no Chrome
flutter test                        # testes da raiz (test/) — o melos não roda esta pasta
```

Só os goldens de `goldens/ci/` vão para o git. Os de plataforma (`macos/`, `linux/`, `windows/`) servem apenas para conferência local.

## Contribuindo

1. Crie uma branch a partir da `main`.
2. Rode `dart run melos run analyze`, `dart run melos run test` e `flutter test` (na raiz) antes de abrir o PR.
3. Se mudou alguma tela, regenere os goldens com `dart run melos run golden:atualizar` e mande as imagens novas no PR.
