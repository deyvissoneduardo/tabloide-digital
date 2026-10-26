# Design System — Tabloide Digital (painel do lojista)

> Gerado por `agent-spec-design-system-bootstrap` em 23/10/2026 (modo BOOTSTRAP); atualizado em 23/10/2026 com a tela de login e a regra de telas por plataforma. Atualize via a mesma skill (enriquecimento) ou via promoções da `agent-spec-generate-design`.
> Fonte canônica da identidade visual do painel. **Todo pacote, tela, page, screen e widget de `packages/app`, `packages/web` e `lib/` segue este documento**; as regras verificáveis estão em `packages/core/test/arquitetura/design_system_test.dart` e quebram o `melos run test`.

## 1. Identificação

- **Produto**: Tabloide Digital — painel do lojista, com identidade única (nome, logo e cores do Tabloide Digital).
- **Frente(s)**: ambas — app (Android/iOS) e web, com o mesmo painel. **Mobile first**: o layout base é o do celular; telas largas só acrescentam.
- **Stack de UI**: Flutter (Dart `^3.13.0`), Material 3 (`useMaterial3: true`).
- **Biblioteca de UI base**: widgets Material puros, estilizados só pelo `ThemeData` (`AppTheme.claro`). Não há kit de componentes próprio; o core só oferece os padrões de feedback que o Material não tem (seção 5).
- **Fontes desta consolidação**: codebase (`packages/core/lib/src/theme/`, `packages/core/lib/src/widgets/`, telas `home` e `login`); docs `Tabloide Digital — Regras de Front-end (MVP).md` e `Regras de Negócio e Requisitos Não Funcionais (MVP).md`; questionário com o usuário em 23/10/2026. Sem Figma.

---

## 2. Fundações (tokens)

Todos os tokens moram em `packages/core/lib/src/theme/` e saem pelo barrel `package:tabloide_core/tabloide_core.dart`.

### 2.1 Cores

A cor é a do **Tabloide Digital**: o esquema é derivado de `AppCores.primaria` (`#1565C0`) e `AppCores.secundaria` (`#FFB300`) com `ColorScheme.fromSeed(dynamicSchemeVariant: fidelity)`. A cor exata é usada sempre que tiver contraste ≥ 4.5 com branco ou preto; senão fica o tom calculado.

| Token | Valor | Uso | Origem |
|---|---|---|---|
| `colorScheme.primary` / `onPrimary` | `AppCores.primaria` (`#1565C0`) | botão principal, ícones de destaque, foco de campo | [derivado] `app_theme.dart` |
| `colorScheme.secondary` / `secondaryContainer` | `AppCores.secundaria` (`#FFB300`) | indicador da navegação, destaques secundários | [derivado] `app_theme.dart` |
| `colorScheme.surface` / `onSurface` | do esquema | fundo de tela, card, AppBar, dialog | [derivado] `app_theme.dart` |
| `colorScheme.onSurfaceVariant` | do esquema | texto de apoio (mensagens, legendas, "Em breve") | [derivado] |
| `colorScheme.outlineVariant` | do esquema | borda de card, divisórias, borda inferior da AppBar | [usuário] forma "suave e plana" |
| `colorScheme.outline` | do esquema | borda de campo de texto | [usuário] |
| `colorScheme.surfaceContainerHighest` | do esquema | bloco de skeleton | [usuário] loading |
| `AppCores.erro` (= `colorScheme.error`) | `#B3261E` | erro de validação, falha, ação destrutiva | [derivado] `app_cores.dart` |
| `AppCores.sucesso` | `#2E7D32` | confirmação | [derivado] |
| `AppCores.alerta` | `#ED6C02` | aviso (ex.: lojista desativado, só consulta) | [derivado] |
| `AppCores.info` | `#0277BD` | aviso informativo (separado da primária, para o aviso não se confundir com ação) | [derivado] |
| `AppCores.neutroClaro` | `#F5F5F5` | fundo neutro | [derivado] |

**Regra**: tela nunca declara cor. Use `Theme.of(context).colorScheme.*` ou `AppCores.*`. Proibido `Color(0x…)`, `Color.fromARGB/RGBO` e `Colors.*` (exceto `Colors.transparent`).

**Identidade**: `AppMarca.nome` (`'Tabloide Digital'`) e `AppMarca.logo` (`packages/core/assets/logo.png`, com 2.0x/3.0x) em `app_marca.dart`. Na tela, use `MarcaLogo`/`MarcaNome`.

### 2.2 Tipografia

Fonte do sistema: Roboto (Android/web) e SF (iOS), sem dependência nem download. Isso ajuda no RNF02 (3 s no 4G fraco). Escala do Material 3 com os ajustes de peso de `AppTipografia`.

| Estilo | Peso | Uso | Origem |
|---|---|---|---|
| `headlineSmall` | 400 | números de resumo (ex.: total de produtos no ar) | [derivado] |
| `titleLarge` | **700** | nome do produto, título de tela/dialog | [derivado] `app_tipografia.dart` |
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
| `ClasseTamanho.expandido` | ≥ 840 | `NavigationRail` estendido (`AppLayout.larguraMenuLateral` = 220) com logo e nome | centralizado, máx. `AppLayout.larguraMaximaConteudo` (1200) |

- Formulários (filial, panfleto, produto, cadastro, login) ficam limitados a `AppLayout.larguraMaximaFormulario` (600) em qualquer classe.
- Obter a classe: `ClasseTamanho.de(context)`. Proibido comparar largura com número solto (`largura < 600`) e usar `MediaQuery.of(context).size`.
- Referências implementadas: `packages/web/lib/src/features/home/home_screen.dart` (navegação por classe) e `packages/web/lib/src/features/login/login_screen.dart` (formulário centralizado, igual ao do app em qualquer classe, limitado a `larguraMaximaFormulario`).

### 3.2 Classes de tamanho e adaptação (mobile)

- **Orientações**: retrato é o caso principal; paisagem segue as mesmas classes.
- **Tablet**: no app, hoje só a home usa a navegação compacta. **Débito**: levar o `NavigationRail` das classes médio/expandido para o app.
- **iOS / Android**: mesmo tema Material nos dois; a fonte muda pelo sistema.

### 3.3 Densidade

- Confortável (`VisualDensity` padrão), alvo de toque mínimo `AppLayout.alvoMinimo` (48) e `MaterialTapTargetSize.padded`. Público é lojista não técnico usando o celular (RNF09).

---

## 4. Tema

- **Modos suportados**: **só claro**. `MaterialApp` usa `title: AppMarca.nome`, `theme: AppTheme.claro()` e `themeMode: ThemeMode.light`. O tema escuro foi removido do código; proibidos `darkTheme:`, `ThemeMode.dark/system` e `AppTheme.escuro`.
- **Estratégia de theming**: um `ThemeData` central (`AppTheme.claro`) gerado das cores do Tabloide, com tema configurado para cada componente Material. Tela usa o widget Material puro (`FilledButton`, `TextField`, `Card`…) sem `style:` próprio.
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
| `AppBotaoPrincipal` | `packages/core/lib/src/widgets/app_botao_principal.dart` | `carregando`, `rotuloCarregando` | ação principal da tela ("Entrar", "Cadastrar"): `ElevatedButton` em `primary`, raio `bordaMd`, texto `titleMedium` em `onPrimary`; carregando = desabilitado com spinner em `secondary` |
| `AppBotaoTexto` | `packages/core/lib/src/widgets/app_botao_texto.dart` | — | ação de navegação secundária ("Cadastre-se"), texto `titleMedium` em `primary` |
| `AppCampoTexto` | `packages/core/lib/src/widgets/app_campo_texto.dart` | `validador`, `erro` (da API), `teclado`, `acao`, `autofill`, `autocorrecao`, `habilitado`, `inputFormatters` (máscara `brasil_fields`, vinda de `app`/`web`), `somenteLeitura` + `aoTocar` (campo que abre seletor), `sufixo` (ex.: spinner de busca) | todo campo de texto com rótulo e ícone |
| `AppCampoSenha` | `packages/core/lib/src/widgets/app_campo_senha.dart` | mesmos do campo de texto | senha, com mostrar/ocultar (estado de visibilidade no próprio widget) |
| `AppCampoSelecao<T>` | `packages/core/lib/src/widgets/app_campo_selecao.dart` | `valor`, `opcoes`, `rotuloDe`, `validador`, `erro` (da API), `habilitado` | campo de escolha com rótulo e ícone (`DropdownButtonFormField`): UF da filial na web |
| `AppCartaoFilial` | `packages/core/lib/src/widgets/app_cartao_filial.dart` | `emUso` (chip "Em uso"), `aoTocar`, `aoEscolherAcao` (menu Usar/Editar/Excluir), `podeExcluir` | item de filial na seção Filiais e na escolha de filial; com `podeExcluir: false` o "Excluir" fica desabilitado com o motivo |
| `AppCartaoPanfleto` | `packages/core/lib/src/widgets/app_cartao_panfleto.dart` | `aoTocar`, `aoEscolherAcao` (menu Editar/Excluir; "Editar" só se `editavel`, RN26) | item de panfleto: miniatura (`Image.network`, `cover`, texto alternativo "Panfleto <situação> de dd/mm/aaaa"), título "Vigente desde dd/mm/aaaa" / "Agendado para dd/mm/aaaa", subtítulo "Válido até dd/mm" ou "Sem data limite"; golden `panfleto_componentes` |
| `AppCampoImagem` | `packages/core/lib/src/widgets/app_campo_imagem.dart` | `bytes` (escolhida, ainda não enviada) ou `url`, `aoEscolher`, `aoRemover` (opcional), `carregando`, `erro`, `ajuda`, `proporcao` | imagem de panfleto e foto de produto: prévia `contain` limitada a `AppLayout.alturaPreviaImagem` (320), botão "Escolher imagem"/"Trocar imagem" com spinner quando `carregando`, "Remover imagem" (`TextButton`) só com imagem e `aoRemover`, erro abaixo no `colorScheme.error` (RNF05). Quem escolhe a imagem é a tela (`image_picker`) |
| `AppCartaoCategoria` | `packages/core/lib/src/widgets/app_cartao_categoria.dart` | `aoTocar`, `aoEscolherAcao` (menu Renomear/Excluir) | item de categoria: ícone `category_outlined` na primária, nome e contagens "12 vigentes · 3 agendados · 7 vencidos" (só as não zeradas; sem produtos → "Nenhum produto"). Sem `podeExcluir` (RN20), "Excluir" fica desabilitado com o motivo; golden `produto_componentes` |
| `AppCartaoProduto` | `packages/core/lib/src/widgets/app_cartao_produto.dart` | `aoTocar`, `aoEscolherAcao` (menu Editar/Excluir; "Editar" só se `editavel`, RN26) | item de produto: foto 48 (`cover`, texto alternativo "Foto de <nome>", sem foto → `sell_outlined`), título "<nome> · <quantidade>", preço `R$ 9,90` ou "de R$ X por R$ Y" (RN32, `Centavos.formatar`) e "Vigente"/"Agendado para dd/mm/aaaa" · "válido até dd/mm"/"sem data limite"; golden `produto_componentes` |
| `AppCampoData` | `packages/core/lib/src/widgets/app_campo_data.dart` | `valor`, `primeiraData`/`ultimaData` (limites do calendário, RN42), `aoMudar`, `aoLimpar` (opcional), `validador`, `erro`, `dica`, `habilitado` | data só de dia (RN24): campo só leitura em `dd/mm/aaaa` que abre o `showDatePicker` só calendário; vigência de panfleto e produto |
| `AppSeletorCor` | `packages/core/lib/src/widgets/app_seletor_cor.dart` | `validador`, `erro` (da API), `habilitado`, `aoMudar` | cor em `#RRGGBB`: campo com máscara hex (maiúsculas, 6 dígitos), amostra da cor à esquerda e botão de paleta que abre o `ColorPicker` (`flutter_colorpicker`) em diálogo "Cancelar"/"Usar cor"; golden `identidade_componentes` |
| `AppLogoIdentidade` | `packages/core/lib/src/widgets/app_logo_identidade.dart` | `url` (nula = sem logo), `nome`, `tamanho` | logo do lojista (`Image.network`, `contain`) em quadro `surfaceContainerHighest` com raio `bordaMd`; sem logo → ícone de adicionar imagem; falha → ícone de imagem quebrada |
| `AppFormulario` | `packages/core/lib/src/widgets/app_formulario.dart` | `chave` (`GlobalKey<FormState>`) | corpo de tela de formulário: `SafeArea`, rolagem, padding `md`, largura máx. `larguraMaximaFormulario`, coluna esticada |
| `AppMarcaDestaque` | `packages/core/lib/src/widgets/app_marca_destaque.dart` | — | logo grande (`AppIcones.destaque`) e nome do produto centralizados (login) |
| `AppMarcaCabecalho` | `packages/core/lib/src/widgets/app_marca_cabecalho.dart` | — | logo pequena + nome em linha (título da `AppBar`, menu lateral) |
| `AppConteudoSecao` | `packages/core/lib/src/widgets/app_conteudo_secao.dart` | `secao` | seção do painel ainda não implementada ("Em breve") |
| `MarcaLogo` | `packages/core/lib/src/widgets/marca_logo.dart` | `altura` | logo do Tabloide (`AppMarca.logo`, asset em `packages/core/assets/`; iniciais se a imagem falhar) |
| `MarcaNome` | `packages/core/lib/src/widgets/marca_nome.dart` | `estilo` | nome do produto (`AppMarca.nome`), 1 linha com reticências |
| `Esqueleto` / `EsqueletoLista` | `packages/core/lib/src/widgets/esqueleto.dart` | `altura`, `largura` / `quantidade`, `altura` | carregamento de lista e card |
| `EstadoVazio` | `packages/core/lib/src/widgets/estado_vazio.dart` | com ou sem ação | lista/seção sem itens |
| `EstadoFalha` | `packages/core/lib/src/widgets/estado_vazio.dart` | `icone` | falha ao carregar, com "Tentar de novo" |
| `confirmarExclusao(...)` | `packages/core/lib/src/widgets/feedback.dart` | — | toda exclusão (RN12, RN20) |
| `confirmar(...)` | `packages/core/lib/src/widgets/feedback.dart` | — | confirmação de ação não destrutiva (ex.: "Sair do painel?"), botão de confirmar no tema |
| `mostrarAviso(...)` | `packages/core/lib/src/widgets/feedback.dart` | `TipoAviso.sucesso` / `erro` / `alerta` / `info`; opcionais `titulo`, `icone`, `duracao`, `rotuloAcao` + `aoAgir` | retorno de ação em SnackBar amigável: fundo `surfaceContainerLowest`, borda e ícone na cor do status, título amigável padrão ("Tudo certo!", "Ops, algo deu errado", "Atenção", "Para sua informação") e a mensagem |
| `AppAviso` | `packages/core/lib/src/widgets/app_aviso.dart` | `tipo`, `titulo`, `icone` | conteúdo do aviso (ícone + título + mensagem), usado pelo `mostrarAviso`; golden `avisos` |

> **Contrato de reuso**: cada plataforma implementa as próprias telas, com service, controller e validação em `packages/{app,web}/lib/src/features/<feature>/`. Toda `*_screen.dart` tem um único widget (Stateless ou Stateful com seu State) e nenhuma função retorna `Widget` (fora o `build`); widget auxiliar vai para arquivo próprio (verificado por `widgets_test.dart`). Widget que se repete ou tem o mesmo comportamento no app e na web vai para `packages/core/lib/src/widgets/` com prefixo `App` (com teste de widget + golden `componentes_app`) e entra nesta tabela; app e web sempre usam esse widget. Ele não carrega validação de formulário (recebe o `validador` por parâmetro) nem estado de tela. Identidade na tela só via `MarcaLogo`/`MarcaNome` e `AppMarca`.

---

## 6. Padrões de Feedback Canônicos

| Estado | Padrão canônico | Componente | Origem |
|---|---|---|---|
| Loading de lista/card | skeleton estático no formato do conteúdo (sem animação, para goldens estáveis); nunca spinner de tela inteira | `EsqueletoLista` / `Esqueleto` | [usuário] |
| Loading de ação | spinner dentro do botão que disparou (`CircularProgressIndicator` no `child`), botão com `onPressed: null` até terminar, sem duplo envio | `FilledButton` | [usuário] |
| Erro ao carregar | ícone na cor de erro, mensagem da `Falha` e botão "Tentar de novo" | `EstadoFalha` | [derivado] `resumo_inicio.dart` |
| Erro de validação | no próprio campo (`validator`/`errorText`), nunca em SnackBar; texto diz o que fazer ("Precisa ser maior que o promocional"). Validadores com `validatorless` e máscaras (telefone, CNPJ…) com `brasil_fields`, só em `app`/`web` (nunca no core) | `TextFormField` | [usuário] |
| Erro de envio (back-end recusou) | aviso de erro (`mostrarAviso`, borda e ícone vermelhos, título "Ops, algo deu errado") com a mensagem da `Falha`; quando a API manda o erro (`FalhaApi`), a mensagem é a da própria API (ex.: "E-mail ou senha incorretos.") | `mostrarAviso(tipo: TipoAviso.erro)` | [usuário] |
| Vazio | ícone na primária, título do que falta, orientação e ação principal ("Cadastrar filial") | `EstadoVazio` | [usuário] |
| Sucesso | aviso de sucesso (título "Tudo certo!") com mensagem curta ("Produto salvo"); salvar já publica (RN40), então não existe "rascunho salvo" | `mostrarAviso()` | [usuário] |
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
| Login | marca (`MarcaLogo` em `AppIcones.destaque` + `MarcaNome`), título "Entre no painel", campos E-mail (teclado de e-mail) e Senha (mínimo de 6 caracteres, botão mostrar/ocultar, "Entrar" no teclado envia). Ação principal é o `AppBotaoPrincipal` "Entrar" (exceção ao `FilledButton` pílula, decidida pelo usuário em 24/10/2026); spinner em `colorScheme.secondary` enquanto envia, com campos desabilitados. Abaixo, `TextButton` "Cadastre-se" alinhado à direita, em `primary`. Largura máx. `larguraMaximaFormulario` |
| Cadastro | aberto pelo "Cadastre-se" do login (push, `AppBar` "Crie sua conta" com voltar). Campos na ordem: Nome fantasia e Nome do responsável (obrigatórios, mínimo 2), E-mail, WhatsApp (com DDD) e CNPJ (obrigatórios, sem máscara), Senha (8 a 128 caracteres, com letra e número — mesma regra da API) e Confirmar senha. Botão "Cadastrar" no mesmo visual do "Entrar". Erros da API (`FalhaApi.campos`, 409 de e-mail no campo E-mail) aparecem embaixo do campo e somem quando o lojista edita o campo, com a mensagem geral em `mostrarAviso` vermelho. Sucesso abre a home e limpa a pilha. Largura máx. `larguraMaximaFormulario` |
| Filial | campos na ordem: Nome da filial (mínimo 2), CEP (máscara `00000-000`, 8 números), Rua ou avenida, Número, Complemento (opcional), Bairro, Cidade e UF. Ao completar o CEP, busca no ViaCEP (spinner no campo) e preenche rua, bairro, cidade e UF (nunca o complemento; campo vazio no ViaCEP não sobrescreve). CEP inexistente → erro no campo CEP; ViaCEP fora do ar → aviso `alerta` "CEP indisponível" para preencher à mão. Sem campo de fuso: o fuso vem da UF (`Uf.fuso`); erro de fuso da API aparece no campo UF. UF no app abre bottom sheet (`SeletorUf`, "SP · São Paulo"); na web, `AppCampoSelecao`. Botão "Salvar filial" (`AppBotaoPrincipal`). Erros da API no campo (`endereco.*` vira o campo do endereço) e mensagem geral em aviso de erro (ex.: 409 limite do plano) |
| Entrada no painel (sessão e filial) | `InicioSessaoScreen` é a raiz: restaura a sessão do cache (sem sessão → login), lista as filiais com skeleton e decide: 0 → "Cadastre sua filial" sem voltar; 1 → home com ela em uso; 2+ → "Escolha a filial". Falha → `EstadoFalha`; 401 → encerra a sessão e volta ao login |
| Seção Filiais | lista de `AppCartaoFilial` com "Nova filial" no topo; "Usar esta filial" troca a filial em uso; excluir pede `confirmarExclusao` (RN12) e a única filial não pode ser excluída; excluir a filial em uso com 2+ restantes leva à escolha de filial |
| Seção Início | app e web: três `Card` com número em `headlineSmall` — Filiais (tamanho da lista do `FiliaisController`), Panfletos no ar e Produtos no ar (soma dos vigentes de todas as filiais, lida do `total` de `GET .../panfletos` e `GET .../produtos` com `situacao=VIGENTE&porPagina=1`, 2 requisições por filial). Recarrega a cada vez que a seção abre e quando a lista de filiais muda; enquanto as filiais carregam → `EsqueletoLista`; falha → `EstadoFalha` |
| Seção Panfletos | panfletos vigentes e agendados da filial em uso (`AppCartaoPanfleto`, por data de início) com "Novo panfleto" no topo; sem panfletos → `EstadoVazio` com a ação "Novo panfleto"; vigente sem data limite → texto orientando definir a data antes de agendar (RN17); excluir pede `confirmarExclusao` "Excluir este panfleto?" |
| Formulário de panfleto | `AppCampoImagem` (obrigatória no cadastro; > 10 MB recusada no campo) + Data de início e Data limite (`AppCampoData`, opcionais; sem início começa hoje, sem limite vale até ser excluído). Vigente: início bloqueado com dica (RN26). Data limite já salva não pode ser removida. Cadastro = `POST` multipart (imagem + datas); edição = `PATCH` só das datas alteradas e `PUT /imagem` se trocou a imagem. Erros com campo da API no próprio campo; `PANFLETO_PERIODO_SOBREPOSTO` (RN16) em aviso de erro com o período do panfleto em conflito ("Ele conflita com o panfleto de dd/mm/aaaa a dd/mm/aaaa.", vindo de `FalhaApi.detalhes`); `PANFLETO_ATUAL_SEM_DATA_LIMITE` (RN17) em aviso de alerta "Defina a data limite". Se as datas salvarem e a troca de imagem falhar, a lista já recebe as datas novas e o formulário fica aberto com o aviso de erro. Calendário em pt-BR (`flutter_localizations`) |
| Seção Produtos | produtos vigentes e agendados da filial em uso (todas as páginas de 100), agrupados por categoria com o nome da categoria em `titleMedium`; categorias e produtos em ordem alfabética (RN30). No topo, "Novo produto" (`AppBotaoPrincipal`) e "Categorias" (`OutlinedButton.icon`), que abre a tela de categorias e, ao voltar, recarrega os produtos. Sem categorias → `EstadoVazio` "Crie a primeira categoria" com "Nova categoria" (RN19); com categorias e sem produtos → "Categorias" no topo + `EstadoVazio` com "Novo produto". Excluir produto pede `confirmarExclusao` "Excluir <nome>?" |
| Categorias | tela própria (push, `AppBar` "Categorias") com `AppCartaoCategoria` e "Nova categoria" no topo; vazia → `EstadoVazio` com "Nova categoria". Formulário com um campo "Nome da categoria" (até 80) e "Salvar categoria"; serve para criar e renomear. Nome repetido (`CATEGORIA_JA_EXISTE`, RN43) aparece no campo. Excluir pede `confirmarExclusao` "Excluir a categoria <nome>?" com o aviso dos vencidos (RN20) quando houver; recusa da API vira aviso de erro |
| Formulário de produto | campos na ordem: Nome (até 120), Categoria (`AppCampoSelecao`), Preço promocional (obrigatório, > 0), Preço original (opcional, maior que o promocional → erro no campo, RN21), Quantidade (até 40), Descrição (até 500), Observação (até 200), Foto (`AppCampoImagem` quadrada, opcional, > 10 MB recusada no campo, com "Remover imagem"), Data de início e Data limite (`AppCampoData`, como no panfleto; a data limite pode ser removida). Preços com `CentavosInputFormatter(moeda: true)` do `brasil_fields`, enviados em centavos. Cadastro = `POST` JSON (sem foto) ou multipart (com foto no campo `foto`); edição = `PATCH` só dos campos alterados (opcional apagado vai como `null`), depois `PUT /foto` se trocou ou `DELETE /foto` se removeu. Vigente: início bloqueado com dica (RN26). Erros da API no próprio campo (`PRECO_ORIGINAL_INVALIDO`, `DATA_*`, `IMAGEM_*` e `campos`); demais (ex.: `LIMITE_DO_PLANO_ATINGIDO`) em aviso de erro. Se o `PATCH` salvar e a foto falhar, a lista já recebe o produto atualizado |
| Perfil | aberto pelo ícone `person_outline` "Perfil" (`AppBar` da home no app e na web compacta; rodapé do menu lateral na web). Carrega `GET /painel/lojista` e `GET /painel/lojista/identidade` juntos (falha em qualquer um → `EstadoFalha`). **Dados da loja** primeiro: E-mail (só leitura, desabilitado), Nome fantasia (2 a 120, vem do lojista), Nome do responsável (2 a 120), WhatsApp (máscara de celular; a API devolve `+55…`, exibido sem o DDI e enviado só com dígitos) e CNPJ (obrigatório, nunca nulo, máscara alfanumérica do cadastro). Depois **Identidade visual** (vale para todas as filiais): `AppLogoIdentidade` + "Trocar logo" (`image_picker`, galeria; spinner dentro do botão desabilitado; > 10 MB recusada antes do envio; 413/422 em aviso de erro) e Cor primária/secundária (`AppSeletorCor`, opcionais; vazia remove a cor). Um único "Salvar" (`AppBotaoPrincipal`) faz `PATCH /painel/lojista` e, se der certo, `PATCH /painel/lojista/identidade` com o mesmo nome fantasia e as cores. Erros de campo da API no próprio campo; demais (ex.: 403 `LOJISTA_DESATIVADO`) em aviso de erro. No fim, separado por `Divider`, "Sair do painel" (`TextButton.icon`) com `confirmar` "Sair do painel?" |
| Status "desativado" | banner fixo no topo com `AppCores.alerta` ("Conta desativada: somente consulta") e ações de criar/editar/excluir desabilitadas (não escondidas) |
| RN12 / RN20 | textos de confirmação: filial → "Panfleto, categorias e produtos desta filial também serão excluídos."; categoria com vencidos → "Os produtos vencidos desta categoria também serão excluídos." |
| RNF05 | imagem: tipo e tamanho conferidos antes do envio, com erro no campo |
| Valores | preço em pt-BR (`R$ 9,90`); datas `dd/mm/aaaa` no painel, "válido até dd/mm" na listagem |

---

## 7. Acessibilidade Visual (RNF10)

- **Contraste mínimo**: WCAG AA 4.5:1. Garantido por `AppTheme.contraste` para primária, secundária, erro e superfície (testado em `app_theme_test.dart`).
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
| 1 · Fundações — tipografia | fonte do sistema | Inter como asset; Poppins como asset; fonte por marca (white-label, removido em 26/10/2026) | [usuário] |
| 1 · Fundações — forma | suave e plana (raio 12, pílula, sem sombra) | bem arredondado; reto e denso; padrão M3 | [usuário] |
| 1 · Fundações — cores e espaço | cores fixas do Tabloide em `AppCores` (`primaria`/`secundaria` + status); escala 4 pt | cores por marca no build (white-label, removido em 26/10/2026 a pedido do usuário) | [derivado] |
| 2 · Biblioteca de componentes | só tema no `ThemeData` (Material puro) + padrões de feedback no core | kit `Ds*` obrigatório; híbrido; pacote `tabloide_ui` | [usuário] |
| 3 · Layout | classes do Material 3 (600 / 840) | corte único em 1024; coluna única; 5 breakpoints | [usuário] |
| 4 · Tema | só claro, escuro removido | manter sem usar; escuro como débito; seguir o SO | [usuário] |
| 5 · Feedback — loading | skeleton em lista, spinner em ação | spinner centralizado; barra linear; skeleton em tudo | [usuário] |
| 5 · Feedback — ações | dialog para confirmar, SnackBar para retorno, erro no campo | bottom sheet; dialog + banner; desfazer | [usuário] |
| Reuso entre plataformas | cada plataforma tem as próprias telas (mesmo parecidas); core só guarda widgets de padrões entre features diferentes | formulário compartilhado no core; widget de formulário sem validação no core | [usuário] 23/10/2026 |
| Garantia | teste de conformidade + CLAUDE.md + goldens | só documentação; `custom_lint`; teste + golden por componente | [usuário] |
