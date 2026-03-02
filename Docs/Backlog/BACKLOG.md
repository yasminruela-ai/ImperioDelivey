# Backlog do Projeto – App de Delivery de Hamburgueria

Projeto mobile desenvolvido em **Flutter** com backend em **Node.js + Express**, utilizando **Firebase** como infraestrutura em nuvem e recursos nativos como **GPS**, **notificações push** e **inteligência artificial** para recomendações personalizadas.

---

## Épico 1 – Estrutura e Infraestrutura

- Criação do projeto Flutter (Android e iOS)
- Criação do backend em Node.js + Express
- Configuração do Firebase (Auth, Firestore, FCM)
- Definição de arquitetura (Clean Architecture / MVC)
- Configuração de variáveis de ambiente
- Configuração de versionamento com Git
- Deploy inicial do backend em nuvem

---

## Épico 2 – Autenticação e Usuário

- Cadastro de usuário com e-mail e senha
- Login e logout
- Persistência de sessão
- Criação e edição de perfil do usuário
- Armazenamento seguro de credenciais

---

## Épico 3 – Localização (GPS)

- Solicitação de permissão de localização
- Captura da localização atual do usuário
- Conversão de coordenadas em endereço
- Validação da área de entrega
- Armazenamento do endereço no banco de dados

---

## Épico 4 – Catálogo de Produtos

- Listagem de categorias de produtos
- Listagem de produtos por categoria
- Visualização de detalhes do produto
- Exibição de imagens, preços e descrições
- Cache local do catálogo

---

## Épico 5 – Carrinho e Pedido

- Adicionar e remover produtos do carrinho
- Alterar quantidade de itens
- Cálculo automático do valor total
- Confirmação e envio do pedido
- Registro e atualização de status do pedido

---

## Épico 6 – Notificações Push

- Configuração do Firebase Cloud Messaging
- Envio de notificações de status do pedido
- Envio de notificações promocionais
- Registro do token do dispositivo

---

## Épico 7 – Histórico e Perfil

- Listagem de pedidos anteriores
- Visualização de detalhes do pedido
- Repetição de pedidos
- Gerenciamento de dados do perfil

---

## Épico 8 – Inteligência Artificial (MVP)

- Registro de eventos de uso do aplicativo
- Criação de perfil de consumo do usuário
- Geração de sugestões personalizadas
- Exibição de recomendações na tela inicial
- Envio de notificações personalizadas

---

## Épico 9 – Observabilidade e Qualidade

- Registro de logs de erro no backend
- Tratamento de falhas no aplicativo
- Mensagens de feedback para o usuário
- Monitoramento básico de uso
