# Roteiro — Apresentação (3 min)

## 1. Abertura (20s)
> "O Imperios Burger é um app de delivery completo, com frontend mobile em Flutter e infraestrutura real em produção."

## 2. Frontend — Flutter (1min)
- Mostrar o app rodando no celular
- Login com Google ou email/senha
- Catálogo de produtos com filtro por categoria
- Adicionar item ao carrinho → animação voando pro ícone
- Finalizar pedido: endereço + forma de pagamento
- Tela de rastreamento com timeline de status

> "Todo o estado do carrinho é salvo localmente e sincronizado com o backend ao logar."

## 3. Infraestrutura (1min)
- "A API roda 24/7 em uma VPS Debian, dentro de um container Docker"
- "O domínio `imp.vititraining.com.br` tem HTTPS via Certbot + Nginx como proxy reverso"
- Mostrar: `curl -I https://imp.vititraining.com.br` retornando 200 OK
- "Zero dependência de máquina local — qualquer dispositivo acessa"

## 4. Fechamento (20s)
> "O app está em produção, conectado a Firebase para autenticação e notificações push, e Supabase para os pedidos do ERP. Qualquer pedido feito no app chega em tempo real no sistema interno."

---

**Dica:** Deixa o app aberto no celular e o terminal com o `curl` pronto antes de começar.
