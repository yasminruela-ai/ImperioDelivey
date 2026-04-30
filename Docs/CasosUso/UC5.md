Caso de Uso: Receber Notificação de Pedido
Ator: Usuário
Objetivo: Informar o usuário sobre atualizações no status do pedido.

Pré-condições:
- O usuário deve ter realizado um pedido.
- O sistema deve possuir um pedido registrado.

Pós-condições:
- O usuário recebe uma notificação informando a atualização do pedido.

Fluxo Principal:
1) O sistema atualiza o status do pedido.
2) O sistema gera uma notificação.
3) O usuário recebe a notificação no aplicativo.
4) O usuário pode acessar o pedido para visualizar os detalhes.

Fluxos Alternativos:
A1) Caso o dispositivo esteja offline, a notificação será exibida quando o usuário voltar a se conectar.

Regras de Negócio:
- RN04 O pedido deve seguir a sequência de status: Recebido → Em preparo → Saiu para entrega → Entregue.
- RN06 Toda alteração no status do pedido deve gerar uma notificação para o usuário.

Requisitos Relacionados:
- RF12 O sistema deve permitir acompanhar o status do pedido.
- RF14 O sistema deve enviar notificações push sobre atualizações de pedidos.
- RNF03 O sistema deve estar disponível 24 horas por dia.
