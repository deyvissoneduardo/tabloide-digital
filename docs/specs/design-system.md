# Design System — Tabloide Digital (painel do lojista)

> Gerado por `agent-spec-design-system-bootstrap` em 23/10/2026 (modo BOOTSTRAP); atualizado em 23/10/2026 com a tela de login e a regra de telas por plataforma. Atualize via a mesma skill (enriquecimento) ou via promoções da `agent-spec-generate-design`.
> Fonte canônica da identidade visual do painel. **Todo pacote, tela, page, screen e widget de `packages/app`, `packages/web` e `lib/` segue este documento**; as regras verificáveis estão em `packages/core/test/arquitetura/design_system_test.dart` e quebram o `melos run test`.

## 1. Identificação

- **Produto**: Tabloide Digital — painel do lojista, white-label (marca escolhida no build).
- **Frente(s)**: ambas — app (Android/iOS) e web, com o mesmo painel. **Mobile first**: o layout base é o do celular; telas largas só acrescentam.
- **Stack de UI**: Flutter (Dart `^3.13.0`), Material 3 (`useMaterial3: true`).
- **Biblioteca de UI base**: widgets Material puros, estilizados só pelo `ThemeData` (`AppTheme.claro`). Não há kit de componentes próprio; o core só oferece os padrões de feedback que o Material não tem (seção 5).
- **Fontes desta consolidação**: codebase (`packages/core/lib/src/theme/`, `packages/core/lib/src/widgets/`, telas `home` e `login`); docs `Tabloide Digital — Regras de Front-end (MVP).md` e `Regras de Negócio e Requisitos Não Funcionais (MVP).md`; questionário com o usuário em 23/10/2026. Sem Figma.

---

## 2. Fundações (tokens)

Todos os tokens moram em `packages/core/lib/src/theme/` e saem pelo barrel `package:tabloide_core/tabloide_core.dart`.

### 2.1 Cores

A cor é da **marca** (white-label): o esquema é derivado de `BrandConfig.corPrimaria`/`corSecundaria` com `ColorScheme.fromSeed(dynamicSchemeVariant: fidelity)`. A cor exata do cliente é usada sempre que tiver contraste ≥ 4.5 com branco ou preto; senão fica o tom calculado.

| Token | Valor | Uso | Origem |
|---|---|---|---|
| `colorScheme.primary` / `onPrimary` | cor primária da marca | botão principal, ícones de destaque, foco de campo | [derivado] `app_theme.dart` |
| `colorScheme.secondary` / `secondaryContainer` | cor secundária da marca | indicador da navegação, destaques secundários | [derivado] `app_theme.dart` |
| `colorScheme.surface` / `onSurface` | do esquema | fundo de tela, card, AppBar, dialog | [derivado] `app_theme.dart` |
| `colorScheme.onSurfaceVariant` | do esquema | texto de apoio (mensagens, legendas, "Em breve") | [derivado] |
| `colorScheme.outlineVariant` | do esquema | borda de card, divisórias, borda inferior da AppBar | [usuário] forma "suave e plana" |
| `colorScheme.outline` | do esquema | borda de campo de texto | [usuário] |
| `colorScheme.surfaceContainerHighest` | do esquema | bloco de skeleton | [usuário] loading |
| `AppCores.erro` (= `colorScheme.error`) | `#B3261E` | erro de validação, falha, ação destrutiva | [derivado] `app_cores.dart` |
| `AppCores.sucesso` | `#2E7D32` | confirmação | [derivado] |
| `AppCores.alerta` | `#ED6C02` | aviso (ex.: lojista desativado, só consulta) | [derivado] |
| `AppCores.neutroClaro` | `#F5F5F5` | fundo neutro | [derivado] |

**Regra**: tela nunca declara cor. Use `Theme.of(context).colorScheme.*` ou `AppCores.*`. Proibido `Color(0x…)`, `Color.fromARGB/RGBO` e `Colors.*` (exceto `Colors.transparent`).

### 2.2 Tipografia

Fonte do sistema: Roboto (Android/web) e SF (iOS), sem dependência nem download. Isso ajuda no RNF02 (3 s no 4G fraco). Escala do Material 3 com os ajustes de peso de `AppTipografia`.

| Estilo | Peso | Uso | Origem |
|---|---|---|---|
| `headlineSmall` | 400 | números de resumo (ex.: total de produtos no ar) | [derivado] |
| `titleLarge` | **700** | nome da marca, título de tela/dialog | [derivado] `app_tipografia.dart` |
| `titleMedium` | **600** | título de card, de estado vazio, de seção | [derivado] |
| `bodyLarge` | 400 | mensagem de falha, texto principal | [usuário] |
| `bodyMedium` | 400 | texto corrido, mensagens de apoio | [derivado] |
| `labelLarge` | **600** | rótulo de botão | [derivado] |

**Regra**: estilo de texto sai sempre de `Theme.of(context).textTheme.*`, ajustado só com `copyWith(color: colorScheme.*)`. Proibidos `TextStyle(`, `fontSize:` e `fontFamily:` em tela.

### 2.3 Espaçamento

- **Escala**: 4 pt.

| Token | Valor | Uso típico | Origem |
|---|---|---|---|
| `AppEspacamentos.xs` | 4 | entre ícone e texto colados | [derivado] `app_espacamentos.dart` |
| `AppEspacamentos.sm` | 8 | entre itens de lista, entre logo e nome | [derivado] |
| `AppEspacamentos.md` | 16 | margem de tela no celular, padding de card e campo | [derivado] |
| `AppEspacamentos.lg` | 24 | entre blocos, padding de estados vazio/falha | [derivado] |
| `AppEspacamentos.xl` | 32 | separação de seções em telas largas | [derivado] |

**Regra**: proibido número solto em `EdgeInsets.*` e `SizedBox(width/height:)`.

### 2.4 Raios e sombras

Forma "suave e plana": nada tem sombra, a separação vem de borda fina.

| Token | Valor | Uso | Origem |
|---|---|---|---|
| `AppRaios.sm` / `bordaSm` | 8 | chip, SnackBar | [usuário] |
| `AppRaios.md` / `bordaMd` | 12 | card, campo de texto, skeleton | [usuário] |
| `AppRaios.lg` / `bordaLg` | 16 | dialog, bottom sheet (topo), FAB | [usuário] |
| `AppRaios.pilula` / `bordaPilula` | 999 | todos os botões | [usuário] |
| Elevação | 0 | card, FAB, NavigationBar, AppBar ao rolar | [usuário] |

**Regra**: proibidos `BorderRadius.circular(<número>)`, `Radius.circular(<número>)` e `elevation: <número>` em tela; o tema já define.

### 2.5 Iconografia

- **Biblioteca**: Material Symbols via `Icons.*` (já incluído no Flutter). Contorno (`*_outlined`) para estado normal e preenchido para selecionado (ver `SecaoPainel.icone`/`iconeSelecionado`).
- **Tamanhos canônicos** (`AppIcones`): `pequeno` 20 (dentro de botão/campo), `padrao` 24 (navegação, listas), `destaque` 48 (estado vazio/falha, logo no menu lateral).
- **Regra**: proibido `size: <número>`.

---

## 3. Layout

Classes de tamanho do Material 3, em `AppLayout` + `ClasseTamanho` (`app_layout.dart`). Mobile first: projete primeiro o compacto.

### 3.1 Breakpoints (web e app)

| Classe | Largura | Navegação | Conteúdo |
|---|---|---|---|
| `ClasseTamanho.compacto` | < 600 | `AppBar` com `MarcaLogo` + `MarcaNome` e `NavigationBar` embaixo | coluna única, margem `md` |
| `ClasseTamanho.medio` | 600 – 839 | `NavigationRail` recolhido (só logo, rótulos sob os ícones) | coluna única |
| `ClasseTamanho.expandido` | ≥ 840 | `NavigationRail` estendido (`AppLayout.larguraMenuLateral` = 220) com marca | centralizado, máx. `AppLayout.larguraMaximaConteudo` (1200) |

- Formulários (filial, panfleto, produto, cadastro, login) ficam limitados a `AppLayout.larguraMaximaFormulario` (600) em qualquer classe.
- Obter a classe: `ClasseTamanho.de(context)`. Proibido comparar largura com número solto (`largura < 600`) e usar `MediaQuery.of(context).size`.
- Referências implementadas: `packages/web/lib/src/features/home/home_screen.dart` (navegação por classe) e `packages/web/lib/src/features/login/login_screen.dart` (formulário: no compacto ocupa a tela; a partir do médio fica num `Card` centralizado com padding `lg`).

### 3.2 Classes de tamanho e adaptação (mobile)

- **Orientações**: retrato é o caso principal; paisagem segue as mesmas classes.
- **Tablet**: no app, hoje só a home usa a navegação compacta. **Débito**: levar o `NavigationRail` das classes médio/expandido para o app.
- **iOS / Android**: mesmo tema Material nos dois; a fonte muda pelo sistema.

### 3.3 Densidade

- Confortável (`VisualDensity` padrão), alvo de toque mínimo `AppLayout.alvoMinimo` (48) e `MaterialTapTargetSize.padded`. Público é lojista não técnico usando o celular (RNF09).

---

## 4. Tema

- **Modos suportados**: **só claro**. `MaterialApp` usa `theme: AppTheme.claro(marca)` e `themeMode: ThemeMode.light`. O tema escuro foi removido do código; proibidos `darkTheme:`, `ThemeMode.dark/system` e `AppTheme.escuro`.
- **Estratégia de theming**: um `ThemeData` central (`AppTheme.claro`) gerado da marca, com tema configurado para cada componente Material. Tela usa o widget Material puro (`FilledButton`, `TextField`, `Card`…) sem `style:` próprio.
- **Tokens semânticos**: os papéis do `ColorScheme` (`primary`, `surface`, `outlineVariant`, `error`…) mais `AppCores` para status.

---

## 5. Biblioteca de Componentes

Os widgets Material são os componentes; o visual vem do tema:

| Componente Material | Como o tema deixa | Uso canônico |
|---|---|---|
| `FilledButton` | pílula, altura mín. 48, `labelLarge` | ação principal da tela (1 por tela): "Salvar", "Cadastrar filial" |
| `OutlinedButton` | idem, com contorno | ação secundária |
| `TextButton` | idem, sem fundo | ação terciária, "Cancelar" em dialog |
| `TextField` / `TextFormField` | contorno, raio 12, preenchido com `surface`, foco 2 px na primária, erro na cor de erro | todo campo de formulário |
| `Card` | plano, borda `outlineVariant`, raio 12, margem inferior `sm` | item de lista (filial, panfleto, produto) |
| `ListTile` | padding horizontal `md` | conteúdo de card e listas |
| `Chip` | raio 8 | categoria, status de vigência |
| `AlertDialog` | raio 16, sem tint | confirmação (via `confirmarExclusao`) |
| `SnackBar` | flutuante, raio 8 | retorno de ação (via `mostrarAviso`) |
| `NavigationBar` / `NavigationRail` | sem elevação, indicador `secondaryContainer` | navegação principal |
| `AppBar` | `surface`, borda inferior, sem sombra ao rolar | topo da tela no compacto |

Componentes próprios do core (contrato de reuso: importe pelo barrel `package:tabloide_core/tabloide_core.dart`, nunca recrie):

| Componente | Referência | Variantes | Uso canônico |
|---|---|---|---|
| `MarcaLogo` | `packages/core/lib/src/widgets/marca_logo.dart` | `altura` | logo da marca (com iniciais se a imagem falhar) |
| `MarcaNome` | `packages/core/lib/src/widgets/marca_nome.dart` | `estilo` | nome da marca, 1 linha com reticências |
| `Esqueleto` / `EsqueletoLista` | `packages/core/lib/src/widgets/esqueleto.dart` | `altura`, `largura` / `quantidade`, `altura` | carregamento de lista e card |
| `EstadoVazio` | `packages/core/lib/src/widgets/estado_vazio.dart` | com ou sem ação | lista/seção sem itens |
| `EstadoFalha` | `packages/core/lib/src/widgets/estado_vazio.dart` | `icone` | falha ao carregar, com "Tentar de novo" |
| `confirmarExclusao(...)` | `packages/core/lib/src/widgets/feedback.dart` | — | toda exclusão (RN12, RN20) |
| `mostrarAviso(...)` | `packages/core/lib/src/widgets/feedback.dart` | `TipoAviso.sucesso` / `erro` | retorno de salvar/excluir |

> **Contrato de reuso**: cada plataforma implementa as próprias telas, com service, controller e validação em `packages/{app,web}/lib/src/features/<feature>/`. A mesma tela em `app` e `web` (ex.: `LoginScreen`) é escrita nos dois pacotes, mesmo parecida, e isso não conta como repetição. Padrão visual que se repete entre telas ou features **diferentes** vai para `packages/core/lib/src/widgets/` (com teste de widget + golden) e entra nesta tabela; esse widget não carrega validação de formulário nem estado de tela. Marca na tela só via `MarcaLogo`/`MarcaNome`/`context.read<BrandConfig>()`.

---

## 6. Padrões de Feedback Canônicos

| Estado | Padrão canônico | Componente | Origem |
|---|---|---|---|
| Loading de lista/card | skeleton estático no formato do conteúdo (sem animação, para goldens estáveis); nunca spinner de tela inteira | `EsqueletoLista` / `Esqueleto` | [usuário] |
| Loading de ação | spinner dentro do botão que disparou (`CircularProgressIndicator` no `child`), botão com `onPressed: null` até terminar, sem duplo envio | `FilledButton` | [usuário] |
| Erro ao carregar | ícone na cor de erro, mensagem da `Falha` e botão "Tentar de novo" | `EstadoFalha` | [derivado] `resumo_inicio.dart` |
| Erro de validação | no próprio campo (`validator`/`errorText`), nunca em SnackBar; texto diz o que fazer ("Precisa ser maior que o promocional"). Validadores com `validatorless` e máscaras (telefone, CNPJ…) com `brasil_fields`, só em `app`/`web` (nunca no core) | `TextFormField` | [usuário] |
| Erro de envio (back-end recusou) | SnackBar vermelho com a mensagem da `Falha`; quando a API manda o erro (`FalhaApi`), a mensagem é a da própria API (ex.: "E-mail ou senha incorretos.") | `mostrarAviso(tipo: TipoAviso.erro)` | [usuário] |
| Vazio | ícone na primária, título do que falta, orientação e ação principal ("Cadastrar filial") | `EstadoVazio` | [usuário] |
| Sucesso | SnackBar curto ("Produto salvo"); salvar já publica (RN40), então não existe "rascunho salvo" | `mostrarAviso()` | [usuário] |
| Ação destrutiva | `AlertDialog` com título em pergunta, impacto descrito e botão vermelho que repete a ação ("Excluir filial"), mais "Cancelar". Nunca "desfazer" no lugar de confirmar | `confirmarExclusao` | [usuário] RN12/RN20 |

### 6.1 Padrões de formulário (derivados das regras de negócio)

| Regra | Padrão visual |
|---|---|
| RN09 (RNF09: produto em < 1 min) | campos obrigatórios primeiro (Nome, Categoria, Preço promocional), opcionais depois; teclado numérico em preço; foco segue para o próximo campo |
| RN21 | preço original ≤ promocional → erro no campo "Preço original" |
| RN24 / RN42 | data só com dia (`showDatePicker`, sem hora). `firstDate` = hoje no fuso da filial; data limite com `firstDate` = max(hoje, data de início) |
| RN26 | item vigente: campo "Data de início" desabilitado com texto de apoio explicando. Item vencido/excluído: tela só leitura, sem botões de editar |
| RN40 | botão principal diz "Publicar"/"Salvar" (salvar = publicar); sem "Salvar rascunho" |
| RN16 / RN17 | conflito de período e "defina a data limite do atual" aparecem como erro no campo de data, com a orientação |
| RN37 / RN43 | e-mail ou categoria repetidos → erro no próprio campo |
| RN36 | tela de login com texto de apoio "Esqueceu a senha? Fale com o suporte.", sem link de recuperação |
| Login | marca (`MarcaLogo` em `AppIcones.destaque` + `MarcaNome`), título "Entre no painel", campos E-mail (teclado de e-mail, autofill) e Senha (botão mostrar/ocultar, "Entrar" no teclado envia), `FilledButton` "Entrar" com spinner enquanto envia e campos desabilitados; largura máx. `larguraMaximaFormulario` |
| Status "desativado" | banner fixo no topo com `AppCores.alerta` ("Conta desativada: somente consulta") e ações de criar/editar/excluir desabilitadas (não escondidas) |
| RN12 / RN20 | textos de confirmação: filial → "Panfleto, categorias e produtos desta filial também serão excluídos."; categoria com vencidos → "Os produtos vencidos desta categoria também serão excluídos." |
| RNF05 | imagem: tipo e tamanho conferidos antes do envio, com erro no campo |
| Valores | preço em pt-BR (`R$ 9,90`); datas `dd/mm/aaaa` no painel, "válido até dd/mm" na listagem |

---

## 7. Acessibilidade Visual (RNF10)

- **Contraste mínimo**: WCAG AA 4.5:1. Garantido por `AppTheme.contraste` para primária, secundária, erro e superfície (testado em `app_theme_test.dart` com marcas escura, média e clara).
- **Texto alternativo**: toda imagem tem `semanticLabel` (logo, foto de produto, panfleto). Skeleton anuncia "Carregando".
- **Foco visível**: borda de 2 px na primária em campos; foco padrão do Material nos botões.
- **Touch targets**: mínimo 48×48 (`AppLayout.alvoMinimo`).
- **Cor nunca sozinha**: erro tem ícone ou texto além da cor.
- **Reduced motion**: sem animações decorativas; skeleton é estático.

---

## 8. Governança

- **Verificação automática** (`packages/core/test/arquitetura/design_system_test.dart`, roda no `melos run test`). Varre `packages/app/lib`, `packages/web/lib` e `lib/` e reprova:
  - cor literal;
  - número solto em `EdgeInsets`, `SizedBox`, raio, `elevation:` e `size:`;
  - `TextStyle(`, `fontSize:` e `fontFamily:`;
  - tema escuro;
  - breakpoint literal;
  - `MediaQuery.of(...).size`.
- **Goldens**: todo padrão do core tem golden (`componentes_tema`, `padroes_feedback`, `marca_logo_nome`). Tela nova tem golden por classe de tamanho relevante. Versione só `goldens/ci/`.
- **Promover token/componente novo ao global**: via `/agent-spec-generate-design` ou enriquecimento desta skill; token novo entra em `packages/core/lib/src/theme/` + esta seção 2 + regra no teste, se proibir um literal.
- **Decisões transversais com trade-off real**: candidatas a ADR (tag `ui`) via `/agent-spec-adr-create`.
- **Débitos aceitos**:
  - app no tablet ainda sem `NavigationRail` (ver 3.2);
  - `MarcaLogo(altura:)` recebe número, então use `AppIcones.*`.

---

## 9. Decisões (árvore — auditável)

| Eixo | Escolha | Alternativas consideradas | Origem |
|---|---|---|---|
| 1 · Fundações — tipografia | fonte do sistema | Inter como asset; Poppins como asset; fonte por marca no `BrandConfig` | [usuário] |
| 1 · Fundações — forma | suave e plana (raio 12, pílula, sem sombra) | bem arredondado; reto e denso; padrão M3 | [usuário] |
| 1 · Fundações — cores e espaço | cores da marca + `AppCores`; escala 4 pt | — | [derivado] |
| 2 · Biblioteca de componentes | só tema no `ThemeData` (Material puro) + padrões de feedback no core | kit `Ds*` obrigatório; híbrido; pacote `tabloide_ui` | [usuário] |
| 3 · Layout | classes do Material 3 (600 / 840) | corte único em 1024; coluna única; 5 breakpoints | [usuário] |
| 4 · Tema | só claro, escuro removido | manter sem usar; escuro como débito; seguir o SO | [usuário] |
| 5 · Feedback — loading | skeleton em lista, spinner em ação | spinner centralizado; barra linear; skeleton em tudo | [usuário] |
| 5 · Feedback — ações | dialog para confirmar, SnackBar para retorno, erro no campo | bottom sheet; dialog + banner; desfazer | [usuário] |
| Reuso entre plataformas | cada plataforma tem as próprias telas (mesmo parecidas); core só guarda widgets de padrões entre features diferentes | formulário compartilhado no core; widget de formulário sem validação no core | [usuário] 23/10/2026 |
| Garantia | teste de conformidade + CLAUDE.md + goldens | só documentação; `custom_lint`; teste + golden por componente | [usuário] |
