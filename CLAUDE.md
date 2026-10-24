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

Mudança que toca 2+ pacotes ou um contrato do core (`BrandConfig`, `RestClient`, `Falha`, `*Repository`) → mostre o plano (arquivos/pacotes afetados) e espere OK.

## Arquitetura
- Dependências permitidas: `core` → nenhum pacote do workspace; `brands`, `app`, `web` → só `core`. Verificado por `packages/core/test/arquitetura/dependencias_test.dart`.
- Camadas: `RestClient` → `*Repository` → `*Service` (por plataforma) → `*Controller`. Ordem de registro em `providersCore` (`packages/core/lib/src/di/providers_core.dart`).
- Core guarda `requests/`, `responses/` e `*Repository` (contrato + implementação). Service, controller (e estado) e screen ficam em cada plataforma (`packages/{app,web}/lib/src/features/<feature>/`), registrados em `providersApp()`/`providersWeb()`. Ex.: login (`AuthServiceApp`/`AuthServiceWeb` + `LoginController`). A home (`HomeController`/`HomeService` no core) é anterior a esta regra.
- Validação de formulário fica fora do core: `validatorless` em `app`/`web`; máscaras (telefone, CNPJ…) com `brasil_fields`.
- Repositories e services NÃO lançam exceção: retornam `Either<Falha, T>`, envolvendo a chamada em `tentar(...)`. Trate `Falha` (sealed) com `switch` exaustivo.
- Código por plataforma via import condicional (`if (dart.library.io)` / `if (dart.library.js_interop)`, ver `lib/bootstrap/bootstrap.dart`). NÃO use `kIsWeb` nem `dart:html`.

## Convenções
- Imports sempre `package:` (lint `always_use_package_imports`); trailing commas obrigatórias.
- NUNCA use `unawaited()`. Se parecer necessário, pare e consulte o usuário explicando o motivo antes de usar. Para satisfazer a lint `unawaited_futures`, prefira `await` ou devolver o `Future`.
- Nomes de domínio em pt-BR (`Falha`, `buscarResumo`, `SecaoPainel`); sufixos técnicos em inglês (`Controller`, `Service`, `Repository`).
- Testes: `group('Funcionalidade: …')`, casos `'Cenário: Dado …, quando …, então …'`.
- Fakes para outros pacotes saem de `package:tabloide_core/testing.dart` e só são importados em `test/`.

## Onde coisas novas vão
- Request/response/repository → `packages/core/lib/src/{requests,responses}/` e `packages/core/lib/src/features/<feature>/repositories/`, exportados em `tabloide_core.dart`.
- Service/controller/tela de plataforma → `packages/{app,web}/lib/src/features/<feature>/` (um em cada plataforma).
- Marca nova → classe `BrandConfig` em `packages/brands/lib/src/<marca>/`, asset em `packages/brands/assets/<marca>/` (declarar no pubspec), registro em `registrar_marcas.dart`, config em `config/marcas/<marca>.json`.
- Diferença entre marcas vira campo no `BrandConfig`. NÃO faça `if`/`switch` por id de marca.

## UI / Design System
Fonte canônica: `docs/specs/design-system.md`. Leia antes de criar ou alterar qualquer tela/widget. Mobile first, **só tema claro**, Material 3 puro estilizado por `AppTheme.claro`. As regras abaixo são verificadas por `packages/core/test/arquitetura/design_system_test.dart` (varre `packages/app/lib`, `packages/web/lib` e `lib/`).
- Cores: `Theme.of(context).colorScheme` (derivado da marca) ou `AppCores` (status). NÃO use `Color(0x…)`, `Color.fromARGB` nem `Colors.*` (só `Colors.transparent`).
- Espaços: `AppEspacamentos` (xs 4, sm 8, md 16, lg 24, xl 32). NÃO use números soltos em `EdgeInsets`/`SizedBox`.
- Raios: `AppRaios` (sm 8, md 12, lg 16, pílula). Ícones: `AppIcones` (20/24/48). NÃO use números em `BorderRadius.circular`, `elevation:`, `size:`.
- Texto: só `Theme.of(context).textTheme.*` (+ `copyWith(color:)`). NÃO use `TextStyle(`, `fontSize:`, `fontFamily:`.
- Widgets Material sem `style:` próprio: o visual vem do tema. Ação principal = `AppBotaoPrincipal` (1 por tela); campos = `AppCampoTexto`/`AppCampoSenha`.
- Layout: `ClasseTamanho.de(context)` (compacto < 600, médio < 840, expandido) e `AppLayout` (larguras máximas). NÃO compare largura com número nem use `MediaQuery.of(context).size`.
- Tema: `theme: AppTheme.claro(marca)` + `themeMode: ThemeMode.light`. NÃO use `darkTheme:` nem `ThemeMode.dark/system`.
- Feedback: lista carregando → `EsqueletoLista`/`Esqueleto` (não spinner de tela); ação → spinner dentro do botão desabilitado; falha → `EstadoFalha`; vazio → `EstadoVazio`; exclusão → `confirmarExclusao`; retorno → `mostrarAviso`; erro de validação → no próprio campo.
- Marca na tela só via `MarcaLogo`/`MarcaNome`/`context.read<BrandConfig>()`.
- Toda `*_screen.dart` tem UM ÚNICO widget (StatelessWidget OU StatefulWidget com seu State), nunca dois. Widget auxiliar vai para arquivo próprio.
- NUNCA crie função ou método que retorne `Widget` (fora o `build`): crie um widget em arquivo próprio. Verificado por `packages/core/test/arquitetura/widgets_test.dart`.
- A tela em si é implementada em cada plataforma (`app` e `web`). Widget que se repete ou tem o mesmo comportamento no app e na web vai para `packages/core/lib/src/widgets/` com prefixo `App` (ex.: `AppBotaoPrincipal`, `AppCampoTexto`), com teste + golden e registro no `design-system.md`; app e web sempre usam esse widget. Validação de formulário não vai para o core: o widget recebe o `validador` por parâmetro. Token novo → `packages/core/lib/src/theme/` + doc + regra no teste.

## Testing & Quality Bar
"Feito" = `dart run melos run analyze` limpo + `dart run melos run test` e `flutter test` (raiz) verdes. Mudou tela → regenere goldens e versione só `goldens/ci/`.

<!-- Itere este arquivo: erro que estava neste contrato → fortaleça a regra existente;
     erro que NÃO estava → adicione uma regra nova. O arquivo cresce com o uso, não de uma vez. -->
