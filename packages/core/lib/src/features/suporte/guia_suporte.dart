import 'package:flutter/material.dart';

final class TopicoSuporte {
  const TopicoSuporte({
    required this.titulo,
    required this.icone,
    required this.resumo,
    required this.passos,
    this.dicas = const [],
  });

  final String titulo;

  final IconData icone;

  final String resumo;

  final List<String> passos;

  final List<String> dicas;
}

const guiaSuporte = <TopicoSuporte>[
  TopicoSuporte(
    titulo: 'Conta e acesso',
    icone: Icons.lock_open_outlined,
    resumo: 'Crie sua conta uma vez e entre no painel com e-mail e senha.',
    passos: [
      'Na tela "Entre no painel", toque em "Cadastre-se".',
      'Preencha nome fantasia, nome do responsável, WhatsApp com DDD, CNPJ, e-mail e senha.',
      'Toque em "Cadastrar". Depois, entre com o mesmo e-mail e senha.',
    ],
    dicas: [
      'A senha precisa ter de 8 a 128 caracteres, com ao menos uma letra e um número.',
      'O nome fantasia é o nome que seus clientes vão ver na página. Use o nome da fachada da loja.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Perfil e identidade',
    icone: Icons.person_outline,
    resumo:
        'Dados da loja, nome e logo. Valem para todas as filiais e aparecem em todas as páginas.',
    passos: [
      'Toque em "Perfil", no topo do painel (na web em tela larga, no fim do menu lateral).',
      'Confira nome fantasia, responsável, WhatsApp e CNPJ.',
      'Toque em "Trocar logo" e escolha a imagem da sua marca.',
      'Toque em "Salvar".',
    ],
    dicas: [
      'Logo em JPEG, PNG ou WebP de até 10 MB. Prefira uma imagem quadrada e com fundo liso.',
      'As cores da página não ficam aqui: elas ficam em Página, aba Aparência.',
      'Para sair da sua conta, use "Sair do painel", no fim do Perfil.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Filiais',
    icone: Icons.storefront_outlined,
    resumo:
        'Cada filial tem a própria página, com panfleto e produtos próprios.',
    passos: [
      'Na aba Filiais, toque em "Nova filial".',
      'Informe o nome da filial e o CEP: o endereço é preenchido sozinho.',
      'Confira rua, número, bairro, cidade e UF e toque em "Salvar filial".',
      'No menu da filial, toque em "Usar esta filial". Ela ganha a marca "Em uso".',
    ],
    dicas: [
      'Panfletos, produtos e a página sempre mostram a filial "Em uso". Antes de cadastrar, confira qual está em uso.',
      'Se a busca do CEP falhar, preencha o endereço à mão.',
      '"Mostrar só o panfleto na página" vale só para aquela filial. Sem panfleto vigente, a página mostra os produtos.',
      'Excluir uma filial apaga também o panfleto, as categorias e os produtos dela. A loja precisa manter ao menos uma filial.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Categorias',
    icone: Icons.category_outlined,
    resumo:
        'Agrupam os produtos na página, como "Mercearia", "Bebidas" ou "Hortifrúti".',
    passos: [
      'Na aba Produtos, toque em "Categorias".',
      'Toque em "Nova categoria", dê um nome e toque em "Salvar categoria".',
      'Para mudar o nome, abra o menu da categoria e toque em "Renomear".',
    ],
    dicas: [
      'Crie as categorias antes dos produtos: todo produto precisa de uma.',
      'Use nomes curtos (até 80 caracteres). Eles aparecem como título na página.',
      'Uma categoria com produtos ativos não pode ser excluída. Ao excluir, os produtos vencidos dela também saem.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Produtos',
    icone: Icons.sell_outlined,
    resumo: 'As ofertas da filial em uso, com foto, preço e validade.',
    passos: [
      'Na aba Produtos, toque em "Novo produto".',
      'Informe nome, categoria e preço promocional.',
      'Se quiser, adicione o preço original, quantidade (ex.: "1 kg"), descrição, observação e uma foto (da galeria ou tirada com a câmera).',
      'Escolha as datas de início e limite, se precisar, e toque em "Publicar produto".',
    ],
    dicas: [
      'Com o preço original, a página mostra "de R\$ X por R\$ Y" e o selo de desconto. Ele precisa ser maior que o promocional.',
      'Sem data de início, o produto entra no ar na hora. Sem data limite, ele fica até ser excluído.',
      'Use a data de início para agendar a oferta do fim de semana com antecedência.',
      'Depois que o produto está vigente, a data de início não muda mais.',
      'Excluir tira o produto da página na hora.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Panfletos',
    icone: Icons.photo_library_outlined,
    resumo:
        'O folheto pronto da filial em uso, como imagem ou PDF, para mostrar na página.',
    passos: [
      'Na aba Panfletos, toque em "Novo panfleto".',
      'Escolha a imagem ou o PDF do panfleto.',
      'Defina as datas de início e limite, se precisar, e toque em "Publicar panfleto".',
    ],
    dicas: [
      'Imagem em JPEG, PNG ou WebP de até 10 MB, ou PDF de 1 página de até 2 MB.',
      'O PDF passou de 2 MB? Exporte de novo com a opção "otimizado para web".',
      'Para agendar o próximo panfleto, defina antes a data limite do atual: os períodos não podem se sobrepor.',
      'Quer que a página mostre só o folheto? Ligue "Mostrar só o panfleto na página" no cadastro da filial.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Página',
    icone: Icons.web_outlined,
    resumo:
        'Monte a página da filial em uso, ajuste a aparência e publique.',
    passos: [
      'Na aba Página, use "Montar" para arrastar as categorias e os produtos na ordem em que devem aparecer. Toque em um produto para editá-lo.',
      'Em "Aparência", ligue o banner (cor, logo, nome e campanha com foto ou descrição) e escolha as cores da página.',
      'Confira tudo na "Prévia" (na web em tela larga, ela fica ao lado).',
      'Toque em "Publicar". A página atualiza em até 1 minuto.',
    ],
    dicas: [
      'Nada muda para os clientes até você tocar em "Publicar". Se sair da aba com mudanças, o painel pergunta se quer descartar.',
      'As cores são usadas exatamente como você escolher. Confira na Prévia se o texto fica legível.',
      'Desligue "Mostrar nome da categoria" para mostrar todos os produtos numa grade única.',
      'Com a filial mostrando só o panfleto, a ordem e o banner só valem quando não houver panfleto vigente.',
      'Só aparecem as categorias que têm produtos vigentes ou agendados.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Divulgar a página',
    icone: Icons.share_outlined,
    resumo:
        'Leve os clientes até a página pública de cada filial.',
    passos: [
      'Na aba Início, vá até "Suas páginas".',
      'Confira o status da filial: "No ar: panfleto", "No ar: N produtos" ou "Nada no ar".',
      'Use "Abrir página" para ver como o cliente vê, "Copiar link" ou "Compartilhar link".',
      'Mostre o QR Code no caixa, na vitrine ou no próprio panfleto impresso.',
    ],
    dicas: [
      '"Nada no ar" significa que a filial não tem panfleto nem produtos vigentes: publique algo antes de divulgar.',
      'Depois de publicar ofertas novas, use o mesmo link: a página da filial mostra sempre o que está no ar.',
      'Compartilhe o link nos grupos e no status do WhatsApp sempre que publicar ofertas novas.',
    ],
  ),
  TopicoSuporte(
    titulo: 'Problemas comuns',
    icone: Icons.help_outline,
    resumo: 'O que fazer quando algo não sai como esperado.',
    passos: [
      '"Sua página está fora do ar até a conta ser ativada": a conta ainda não foi ativada. Até a ativação, a página fica fora do ar e não pode ser alterada.',
      '"Não conseguimos abrir a câmera" ou "suas imagens": libere a permissão nas configurações do aparelho ou do navegador e tente de novo.',
      '"A imagem passa de 10 MB": diminua a imagem ou exporte com qualidade menor.',
      'Não acho o produto ou o panfleto: confira se a filial "Em uso" é a certa, na aba Filiais.',
      'Publiquei e a página não mudou: espere até 1 minuto e recarregue a página.',
    ],
  ),
];
