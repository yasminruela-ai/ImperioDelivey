import {
  listarPedidosDelivery,
  buscarPedidoDelivery,
  atualizarStatusVendaDelivery,
} from "../models/PedidosService.js";
import { canUser } from "./PermissoesController.js";

const tabela = "vendas";

export async function listarDelivery() {
  try {
    const data = await listarPedidosDelivery();
    console.log(`[Delivery] ${data.length} pedido(s) encontrado(s).`);
    return { success: true, data };
  } catch (err) {
    console.error("[Delivery] Erro ao listar pedidos:", err);
    return { success: false, message: err.message };
  }
}

export async function obterDelivery(id) {
  try {
    const data = await buscarPedidoDelivery(id);
    if (!data) return { success: false, message: "Pedido nao encontrado." };
    return { success: true, data };
  } catch (err) {
    return { success: false, message: err.message };
  }
}

export async function alterarStatusDelivery(id, status) {
  try {
    await atualizarStatusVendaDelivery(id, status);
    return { success: true };
  } catch (err) {
    console.error("[Delivery] Erro ao atualizar status:", err);
    return { success: false, message: err.message };
  }
}
