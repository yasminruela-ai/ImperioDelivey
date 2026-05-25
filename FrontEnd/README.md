# Imperios Burger — Frontend

Aplicativo mobile de delivery desenvolvido em **Flutter**, com foco em Android. Integra autenticação Firebase, notificações push, assistente de IA, rastreamento de pedidos em tempo real e carrinho sincronizado com o backend.

---

## Tecnologias

| Tecnologia | Versão | Uso |
|---|---|---|
| Flutter / Dart | 3.x | Framework principal |
| Provider | 6.0.5 | Gerenciamento de estado (carrinho) |
| HTTP | 1.6.0 | Comunicação com a API |
| Firebase Core | 3.0.0 | Inicialização Firebase |
| Firebase Messaging | 15.0.0 | Push notifications |
| Flutter Local Notifications | 18.0.0 | Exibição de notificações locais |
| Google Sign-In | 6.2.1 | Autenticação OAuth |
| Shared Preferences | 2.2.2 | Persistência local |

---

## Estrutura do Projeto

```
lib/
├── main.dart                        # Entry point — Firebase, Provider, tema
├── core/
│   ├── constants.dart               # kBaseUrl e outras constantes globais
│   ├── theme/
│   │   └── app_theme.dart           # Cores, gradientes, tipografia (Material 3)
│   ├── services/
│   │   ├── auth_service.dart        # Login, registro, Google Auth, JWT
│   │   ├── product_service.dart     # Listagem de produtos
│   │   ├── order_service.dart       # Criação e rastreamento de pedidos
│   │   └── notification_service.dart # FCM + notificações locais
│   └── animations/
│       └── fly_to_cart.dart         # Animação produto voando para o carrinho
├── modules/
│   ├── splash/
│   │   └── splash_page.dart         # Splash screen com verificação de login
│   ├── auth/
│   │   ├── login_page.dart          # Login email/senha e Google
│   │   ├── register_page.dart       # Cadastro — etapa 1 (credenciais)
│   │   ├── register_complement_page.dart # Cadastro — etapa 2 (endereço)
│   │   └── widgets/
│   │       └── auth_text_field.dart # Campo de texto reutilizável
│   ├── home/
│   │   ├── home_page.dart           # Catálogo com filtros, banner, chat
│   │   ├── models/
│   │   │   └── product_model.dart   # Modelo de produto
│   │   └── widgets/
│   │       ├── product_card.dart    # Card horizontal de produto
│   │       ├── category_widget.dart # Pills de categorias horizontal
│   │       └── banner_widget.dart   # Carrossel de banners promocionais
│   ├── cart/
│   │   ├── cart_page.dart           # Tela do carrinho
│   │   ├── cart_controller.dart     # ChangeNotifier — estado do carrinho
│   │   └── models/
│   │       └── cart_item_model.dart # Modelo de item do carrinho
│   ├── checkout/
│   │   ├── checkout_page.dart       # Checkout legado (não usado no fluxo principal)
│   │   ├── order_success_page.dart  # Rastreamento do pedido (timeline)
│   │   └── models/
│   │       └── order_model.dart     # Modelo de pedido e itens
│   └── chat/
│       └── chat_page.dart           # Assistente de IA (multiturn)
├── features/
│   ├── checkout/
│   │   ├── checkout_bottom_sheet.dart # Checkout principal (endereço + pagamento)
│   │   └── order_confirmed_page.dart  # Tela de confirmação com confetti
│   └── address/
│       └── address_picker_sheet.dart  # Modal de seleção/criação de endereço
└── orders/
    └── orders_history_page.dart     # Histórico de pedidos do usuário
```

---

## Telas e Funcionalidades

### Splash
- Verifica token salvo localmente
- Registra token FCM no backend
- Redireciona para Home (logado) ou Login

### Autenticação
- Login com email/senha ou Google Sign-In
- Cadastro em 2 etapas: credenciais → endereço/telefone
- Auto-preenchimento de endereço via [ViaCEP](https://viacep.com.br)
- JWT armazenado em SharedPreferences

### Home / Catálogo
- Grid de produtos com filtro por categoria (Todos, Lanches, Pizzas, Porções, Bebidas, Sobremesas)
- Carrossel de banners promocionais com auto-scroll
- Badge animado com quantidade de itens no carrinho
- Botão de acesso ao assistente de IA

### Carrinho
- Local-first: persiste em SharedPreferences
- Sincroniza com o backend ao logar
- Controles de incremento/decremento por item
- Cálculo de subtotal, taxa de entrega e total

### Checkout
- Seleção ou criação de endereço de entrega (ViaCEP)
- Formas de pagamento: Pix, cartão de crédito, dinheiro
- Resumo do pedido antes de confirmar
- Tela de celebração com confetti após confirmação

### Rastreamento de Pedido
- Timeline com 5 etapas: Pendente → Aceito → Preparando → Saiu para entrega → Entregue
- Polling automático a cada 10 segundos
- Acessível via notificação push (deep link com ID do pedido)

### Assistente de IA
- Conversa multi-turn (histórico dos últimos 5 pares)
- Backend retorna recomendações de produtos (IDs)
- App localiza os produtos no catálogo e adiciona ao carrinho
- Sugestões rápidas de ação

### Histórico de Pedidos
- Lista todos os pedidos do usuário autenticado
- Badge de status com cor e ícone (pendente, em preparo, entregue, cancelado)
- Exibe endereço de entrega e forma de pagamento

### Notificações Push
- Registro do token FCM no login
- Foreground: notificação local com Flutter Local Notifications
- Background/fechado: deep link direto para a tela de rastreamento

---

## Endpoints da API

| Método | Rota | Descrição |
|---|---|---|
| POST | `/login` | Autenticação email/senha |
| POST | `/auth/google` | Login com Google |
| POST | `/auth/google-register` | Cadastro com Google |
| POST | `/register` | Cadastro com endereço |
| GET | `/produto` | Listagem de produtos |
| GET/POST/DELETE | `/carrinho` | Carrinho do usuário |
| POST | `/pedido` | Criar pedido |
| GET | `/pedido/{id}` | Status do pedido |
| GET | `/pedido/me` | Histórico de pedidos |
| GET | `/user/me` | Perfil e endereços |
| PUT | `/user/enderecos` | Salvar endereços |
| POST | `/user/fcm-token` | Registrar token de push |
| POST | `/chat` | Mensagem para o assistente de IA |

**Base URL:** definida em `lib/core/constants.dart`
```dart
const String kBaseUrl = 'https://imp.vititraining.com.br';
```

---

## Tema Visual

| Elemento | Valor |
|---|---|
| Cor primária | `#C62828` (vermelho) |
| Cor secundária | `#FF6D00` (laranja) |
| Gradiente principal | vermelho → vermelho escuro |
| Gradiente hero | vermelho → laranja |
| Design system | Material 3 |

---

## Animações

- **Splash**: logo + nome com fade
- **Auth**: entrada com fade + slide (700–900ms)
- **Product Card**: bounce no botão de adicionar, press com scale
- **Fly to Cart**: arco animado de 650ms do produto até o ícone do carrinho
- **Banner**: auto-scroll com efeito de escala
- **Badge do carrinho**: scale animado ao mudar quantidade
- **Order Confirmed**: círculo elástico + checkmark + confetti (2.2s)
- **Timeline do pedido**: etapas coloridas por estado (pendente / atual / concluído)

---

## Como Rodar

```bash
# Instalar dependências
flutter pub get

# Rodar em modo debug (emulador ou dispositivo)
flutter run

# Gerar APK release
flutter build apk --release
```

O APK gerado fica em:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Status do Projeto

Integrado com backend em produção em `https://imp.vititraining.com.br`.

---

## Autor

**Gustavo Viti** — Desenvolvimento completo (frontend, integração de API, UX)
