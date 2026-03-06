Caso de Uso: Realizar Pedido
Ator: Usuário
Objetivo: Permitir que o usuário selecione produtos e finalize um pedido.

Pré-condições:
- O usuário deve estar autenticado no sistema.
- O usuário deve estar dentro da área de entrega.

Pós-condições:
- O pedido é registrado no sistema.

Fluxo Principal:
1) Usuário acessa o catálogo de produtos.
2) Usuário seleciona um produto.
3) Usuário adiciona o produto ao carrinho.
4) Usuário confirma o pedido.
5) Sistema calcula o valor total.
6) Sistema registra o pedido no banco de dados.

Fluxos Alternativos:
A1) Caso o carrinho esteja vazio, o sistema impede a finalização do pedido.
A2) Caso o endereço esteja fora da área de entrega, o sistema informa que não é possível realizar o pedido.

Regras de Negócio:
- RN01 Pedidos só podem ser realizados se o endereço estiver dentro da área de entrega.
- RN02 Apenas usuários autenticados podem realizar pedidos.
- RN03 Não é permitido finalizar um pedido com o carrinho vazio.

Requisitos Relacionados:
- RF06 O sistema deve exibir um catálogo de produtos organizado por categorias.
- RF08 O sistema deve permitir adicionar, remover e alterar itens no carrinho.
- RF09 O sistema deve calcular automaticamente o valor total do pedido.
- RF10 O sistema deve permitir a confirmação e envio de pedidos.
- RF11 O sistema deve registrar pedidos no banco de dados.
- RNF02 O tempo de resposta das operações principais deve ser inferior a 3 segundos.
