# CLAUDE.md

## Visão do Projeto
Painel do lojista do Tabloide Digital (filiais, panfletos, produtos), white-label: um código Flutter para app (Android/iOS) e web, marca escolhida no build (`--dart-define-from-file=config/marcas/<marca>.json`). Otimiza: reuso entre app e web e troca de marca sem tocar em tela.

## Stack
- Flutter, Dart `^3.13.0`, Pub Workspace (`packages/core`, `brands`, `app`, `web`) + melos via `dart run melos`.
- Estado: `provider` + `ChangeNotifier`. HTTP: `dio` atrás de `RestClient`. Testes: `flutter_test`, `mocktail`, `alchemist` (goldens).
- NÃO usar sem aprovação: outro state management (Riverpod, Bloc, GetX, MobX…), `package:http` ou `Dio` direto fora de `DioRestClient`, codegen (`build_runner`, `freezed`, `json_serializable`).

## Como rodar
- Install: `flutter pub get` (na raiz)
- Dev: `flutter run -d chrome --dart-define-from-file=config/marcas/tabloide.json`
- Lint: `dart run melos run analyze`
- Testes: `dart run melos run test` (pacotes) **e** `flutter test` (raiz — o melos não roda o `test/` da raiz)
- Goldens: `dart run melos run golden:atualizar` · navegador: `dart run melos run test:browser`

## Regras de comportamento (não negocie)
1. **Incerteza → leia o arquivo ou rode `grep`. Nunca chute.** Se não achou (função, campo, API, arquivo), diga que não achou.
2. **Menor delta possível.** Resolva só o pedido. Oportunidade de melhoria fora do escopo → reporte separado, não execute sem pedir.
3. **Não toque em código fora do escopo sem autorização explícita.** Viu algo errado → sinalize, não conserte por conta própria.
4. **"Funciona" só com evidência.** Ao afirmar que algo funciona, mostre o output do comando/teste. Não rodou → diga "não rodei".
5. **Ações destrutivas exigem confirmação prévia.** Migração de schema, delete em massa, mudança de CI/auth → confirme antes de executar.

Mudança que toca 2+ pacotes ou um contrato do core (`BrandConfig`, `RestClient`, `*Service`, `*Repository`) → mostre o plano (arquivos/pacotes afetados) e espere OK.

## Arquitetura
- Dependências permitidas: `core` → nenhum pacote do workspace; `brands`, `app`, `web` → só `core`. Verificado por `packages/core/test/arquitetura/dependencias_test.dart`.
- Camadas: `RestClient` → `*Repository` → `*Service` (por plataforma) → `*Controller`. Ordem de registro em `providersCore` (`packages/core/lib/src/di/providers_core.dart`).
- Contrato do service e controller ficam no core; implementações em `HomeServiceApp`/`HomeServiceWeb` registradas em `providersApp()`/`providersWeb()`.
- Repositories e services NÃO lançam exceção: retornam `Either<Falha, T>`, envolvendo a chamada em `tentar(...)`. Trate `Falha` (sealed) com `switch` exaustivo.
- Código por plataforma via import condicional (`if (dart.library.io)` / `if (dart.library.js_interop)`, ver `lib/bootstrap/bootstrap.dart`). NÃO use `kIsWeb` nem `dart:html`.

## Convenções
- Imports sempre `package:` (lint `always_use_package_imports`); trailing commas obrigatórias.
- Todo membro público do `core` tem doc comment `///` (lint `public_member_api_docs`).
- Nomes de domínio em pt-BR (`Falha`, `buscarResumo`, `SecaoPainel`); sufixos técnicos em inglês (`Controller`, `Service`, `Repository`).
- Testes: `group('Funcionalidade: …')`, casos `'Cenário: Dado …, quando …, então …'`.
- Fakes para outros pacotes saem de `package:tabloide_core/testing.dart` e só são importados em `test/`.

## Onde coisas novas vão
- Regra/estado comum a app e web → `packages/core/lib/src/features/<feature>/` e exporte em `tabloide_core.dart`. NÃO duplique controller/regra em `app` e `web`.
- Tela/widget de plataforma → `packages/{app,web}/lib/src/features/<feature>/`.
- Marca nova → classe `BrandConfig` em `packages/brands/lib/src/<marca>/`, asset em `packages/brands/assets/<marca>/` (declarar no pubspec), registro em `registrar_marcas.dart`, config em `config/marcas/<marca>.json`.
- Diferença entre marcas vira campo no `BrandConfig`. NÃO faça `if`/`switch` por id de marca.

## UI / Design System
- Cores: `Theme.of(context).colorScheme` (derivado da marca) ou `AppCores` (status/neutros). NÃO use `Color(0x…)` em telas.
- Espaços: `AppEspacamentos` (xs 4, sm 8, md 16, lg 24, xl 32). NÃO use números soltos em `EdgeInsets`/`SizedBox`.
- Marca na tela só via `MarcaLogo`/`MarcaNome`/`context.read<BrandConfig>()`.

## Testing & Quality Bar
"Feito" = `dart run melos run analyze` limpo + `dart run melos run test` e `flutter test` (raiz) verdes. Mudou tela → regenere goldens e versione só `goldens/ci/`.

<!-- Itere este arquivo: erro que estava neste contrato → fortaleça a regra existente;
     erro que NÃO estava → adicione uma regra nova. O arquivo cresce com o uso, não de uma vez. -->
