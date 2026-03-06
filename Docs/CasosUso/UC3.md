Caso de Uso: Acompanhar Pedido
Ator: Usuário
Objetivo: Permitir que o usuário acompanhe o status de um pedido realizado.

Pré-condições:
- O usuário deve estar autenticado.
- O usuário deve ter realizado pelo menos um pedido.

Pós-condições:
- O usuário visualiza o status atual do pedido.

Fluxo Principal:
1) Usuário acessa a área de pedidos.
2) Sistema exibe o histórico de pedidos.
3) Usuário seleciona um pedido.
4) Sistema exibe o status atual do pedido.

Fluxos Alternativos:
A1) Caso o usuário não possua pedidos, o sistema informa que não há pedidos registrados.

Regras de Negócio:
- RN04 O pedido deve seguir a sequência de status: Recebido → Em preparo → Saiu para entrega → Entregue.
- RN06 Toda alteração no status do pedido deve gerar uma notificação para o usuário.

Requisitos Relacionados:
- RF12 O sistema deve permitir acompanhar o status do pedido.
- RF13 O sistema deve exibir o histórico de pedidos do usuário.
- RF14 O sistema deve enviar notificações push sobre atualizações de pedidos.
- RNF01 O aplicativo deve possuir interface simples, intuitiva e responsiva.
