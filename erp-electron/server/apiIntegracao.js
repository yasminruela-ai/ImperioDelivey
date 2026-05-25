import express from "express";
import { config } from "dotenv";
import {
  criarVendaDelivery,
  atualizarStatusVendaDelivery,
  listarProdutosAtivos,
} from "./models/PedidosService.js";

config();

const app = express();
app.use(express.json());

// ── Autenticação por API Key ──────────────────────────────────────────────────

function autenticar(req, res, next) {
  const apiKey = process.env.INTEGRACAO_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ success: false, message: "INTEGRACAO_API_KEY não configurada." });
  }

  const auth = req.headers["authorization"] ?? "";
  const token = auth.startsWith("Bearer ") ? auth.slice(7) : "";

  if (token !== apiKey) {
    return res.status(401).json({ success: false, message: "Não autorizado." });
  }

  next();
}

// ── Rotas ─────────────────────────────────────────────────────────────────────

app.get("/integracao/health", (_req, res) => {
  res.json({ success: true, message: "ERP online." });
});

app.post("/integracao/pedido", autenticar, async (req, res) => {
  const { deliveryPedidoId, itens } = req.body;

  if (!deliveryPedidoId || !Array.isArray(itens) || itens.length === 0) {
    return res.status(400).json({ success: false, message: "deliveryPedidoId e itens[] são obrigatórios." });
  }

  try {
    const erpVendaId = await criarVendaDelivery(deliveryPedidoId, itens);
    return res.status(201).json({ success: true, erpVendaId });
  } catch (err) {
    console.error("[ERP] Erro ao criar venda delivery:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.put("/integracao/pedido/:erpVendaId/status", autenticar, async (req, res) => {
  const erpVendaId = Number(req.params.erpVendaId);
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ success: false, message: "Campo 'status' é obrigatório." });
  }

  try {
    const atualizado = await atualizarStatusVendaDelivery(erpVendaId, status);
    if (!atualizado) {
      return res.status(404).json({ success: false, message: "Venda não encontrada ou não é de delivery." });
    }
    return res.status(200).json({ success: true });
  } catch (err) {
    console.error("[ERP] Erro ao atualizar status:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

app.get("/integracao/produtos", autenticar, async (_req, res) => {
  try {
    const data = await listarProdutosAtivos();
    return res.status(200).json({ success: true, data });
  } catch (err) {
    console.error("[ERP] Erro ao listar produtos:", err.message);
    return res.status(500).json({ success: false, message: err.message });
  }
});

// ── Inicialização ─────────────────────────────────────────────────────────────

export async function iniciarApiIntegracao() {
  const porta = Number(process.env.INTEGRACAO_PORT) || 4000;
  app.listen(porta, () => {
    console.log(`[ERP] API de integração rodando na porta ${porta}`);
  });
}
