# Imperios Burger — Delivery com IA

Aplicativo mobile de delivery para hamburgueria com assistente de inteligência artificial, acompanhamento de pedidos em tempo real e notificações push.

---

## Funcionalidades

- **Cardápio digital** com filtro por categorias e imagens dos produtos
- **Assistente IA** (Gemini 2.5 Flash) — conversa em linguagem natural, sugere itens e adiciona ao carrinho automaticamente
- **Carrinho** sincronizado com o backend, persistido localmente
- **Checkout** com escolha de forma de pagamento
- **Acompanhamento de pedido** em tempo real com atualização automática a cada 10 segundos
- **Notificações push** (FCM) disparadas a cada mudança de status do pedido
- **Painel do gerente** — visualiza todos os pedidos e avança o status com validação de transição

---

## Fluxo de Status do Pedido

```
pendente → aceito → em_preparo → saiu_para_entrega → entregue
             ↓           ↓                ↓
          cancelado   cancelado        (não permitido)
```

Cada transição registra o timestamp correspondente e dispara uma notificação push para o cliente.

---

## Stack

| Camada | Tecnologia |
|---|---|
| Mobile | Flutter 3.x (Dart 3.10+) |
| State management | Provider |
| Backend | Node.js + Express 5 |
| Banco de dados | Firebase Firestore |
| Autenticação | Firebase Auth + Google Sign-In |
| IA | Google Gemini 2.5 Flash (`@google/generative-ai`) |
| Imagens | Cloudinary + Multer |
| Push notifications | Firebase Cloud Messaging (FCM) |
| Notificações locais | flutter_local_notifications |

---

## Estrutura do Projeto

```
ImperioDelivey-IA/
├── BackEnd/
│   └── src/
│       ├── api.js
│       ├── ia.js                  # Chat com Gemini (multi-turn, JSON schema)
│       ├── notifications.js       # Envio de FCM via Firebase Admin
│       ├── config/
│       │   ├── firebase.js
│       │   └── cloudinary.js
│       ├── Controllers/
│       │   ├── userController.js
│       │   ├── produtosController.js
│       │   ├── carrinhoController.js
│       │   └── pedidoController.js
│       ├── Models/
│       │   ├── User.js
│       │   ├── Produto.js
│       │   ├── Carrinho.js
│       │   └── Pedido.js
│       ├── middleware/
│       │   ├── authMiddleware.js
│       │   └── isManager.js
│       └── routers/routers.js
│
├── FrontEnd/
│   └── lib/
│       ├── main.dart
│       ├── core/
│       │   ├── services/
│       │   │   ├── auth_service.dart
│       │   │   ├── product_service.dart
│       │   │   ├── order_service.dart
│       │   │   └── notification_service.dart
│       │   ├── theme/app_theme.dart
│       │   └── constants.dart
│       └── modules/
│           ├── auth/
│           ├── home/
│           ├── chat/              # Assistente IA
│           ├── cart/
│           └── checkout/
│               ├── checkout_page.dart
│               ├── order_success_page.dart  # Timeline de acompanhamento
│               └── models/order_model.dart
│
└── Docs/                          # Requisitos, casos de uso, backlog
```

---

## Rotas da API

### Autenticação e Usuários
| Método | Rota | Auth | Descrição |
|---|---|---|---|
| POST | `/register` | — | Cadastro de cliente |
| POST | `/funcionario` | gerente | Cadastro de funcionário |
| POST | `/login` | — | Login |
| PUT | `/user` | ✓ | Atualizar perfil |
| DELETE | `/user` | ✓ | Deletar conta |
| POST | `/user/fcm-token` | ✓ | Salvar token FCM do dispositivo |

### Produtos
| Método | Rota | Auth | Descrição |
|---|---|---|---|
| GET | `/produto` | — | Listar produtos |
| GET | `/produto/:id` | — | Detalhes |
| POST | `/produto` | gerente | Criar (com imagem) |
| PUT | `/produto/:id` | gerente | Atualizar |
| DELETE | `/produto/:id` | gerente | Deletar |

### Carrinho
| Método | Rota | Auth | Descrição |
|---|---|---|---|
| GET | `/carrinho` | ✓ | Obter carrinho |
| POST | `/carrinho` | ✓ | Salvar carrinho completo |
| POST | `/carrinho/item` | ✓ | Adicionar item |
| DELETE | `/carrinho/item/:id` | ✓ | Remover item |
| DELETE | `/carrinho` | ✓ | Limpar carrinho |

### Pedidos
| Método | Rota | Auth | Descrição |
|---|---|---|---|
| POST | `/pedido` | ✓ | Finalizar pedido (usa carrinho) |
| GET | `/pedido/me` | ✓ | Meus pedidos |
| GET | `/pedido/:id` | ✓ | Detalhes do pedido |
| GET | `/pedidos` | gerente | Todos os pedidos |
| PUT | `/pedido/:id/status` | gerente | Atualizar status |

### IA
| Método | Rota | Auth | Descrição |
|---|---|---|---|
| POST | `/chat` | — | Mensagem para o assistente |

---

## Como rodar

### Pré-requisitos
- Node.js 18+
- Flutter 3.x
- Conta Firebase com Firestore e Authentication habilitados
- Conta Cloudinary
- Chave de API do Google Gemini

### Backend

```bash
cd BackEnd
npm install
```

Crie o arquivo `.env`:

```env
PORT=3000
FIREBASE_API_KEY=sua_chave
GEMINI_API_KEY=sua_chave
CLOUDINARY_NAME=seu_cloud
CLOUDINARY_KEY=sua_chave
CLOUDINARY_SECRET=seu_secret
```

Coloque o arquivo `firebase-key.json` (Service Account) em `src/config/`.

```bash
npm run dev
```

### Frontend

```bash
cd FrontEnd
flutter pub get
```

Em `lib/core/constants.dart`, configure a URL do backend:

```dart
// Emulador Android
const String kBaseUrl = 'http://10.0.2.2:3000';

// Dispositivo físico (substitua pelo IP da sua máquina)
const String kBaseUrl = 'http://192.168.x.x:3000';
```

Coloque o `google-services.json` do Firebase em `android/app/`.

```bash
flutter run
```

---

## Notificações Push

O app usa Firebase Cloud Messaging. Ao fazer login, o token FCM do dispositivo é enviado ao backend via `POST /user/fcm-token`. Quando um gerente atualiza o status de um pedido, o backend dispara automaticamente uma notificação para o cliente.

Notificações em foreground são exibidas como notificação local. Ao tocar, o app navega diretamente para a tela de acompanhamento do pedido.

---

## Documentação

A pasta `Docs/` contém:
- `Requisitos/RF.md` — Requisitos funcionais
- `Requisitos/RN.md` — Regras de negócio
- `Requisitos/RNF.md` — Requisitos não funcionais
- `CasosUso/` — Casos de uso detalhados e diagramas
- `Backlog/BACKLOG.md` — Backlog do projeto
- `Arquitetura/Visao_Produto.pdf` — Visão do produto
