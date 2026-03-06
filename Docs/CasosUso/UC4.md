Caso de Uso: Visualizar Produto
Ator: Usuário
Objetivo: Permitir que o usuário visualize detalhes de um produto disponível no catálogo.

Pré-condições:
- O usuário deve estar autenticado no sistema.
- O sistema deve possuir produtos cadastrados.

Pós-condições:
- O usuário visualiza as informações detalhadas do produto.

Fluxo Principal:
1) Usuário acessa o catálogo de produtos.
2) Sistema exibe os produtos organizados por categorias.
3) Usuário seleciona um produto.
4) Sistema exibe os detalhes do produto (nome, preço, descrição e imagem).

Fluxos Alternativos:
A1) Caso não existam produtos disponíveis, o sistema informa que não há produtos cadastrados.

Regras de Negócio:
- RN07 As recomendações devem considerar histórico de pedidos e frequência de consumo.

Requisitos Relacionados:
- RF06 O sistema deve exibir um catálogo de produtos organizado por categorias.
- RF07 O sistema deve permitir visualizar detalhes do produto.
- RNF01 O aplicativo deve possuir interface simples, intuitiva e responsiva.
