import {
  criarVenda,
  listarVendas,
  buscarVendaPorId,
  atualizarStatusVenda,
} from "../models/Pedidos.js";

import { canUser } from "./PermissoesController.js";

const tabela = "vendas";

export async function registrarVenda(nome, itens) {
  if (!canUser(tabela, "insert")) {
    return {
      success: false,
      message: "Permissão negada para registrar venda.",
    };
  }

  try {
    const id = await criarVenda(nome, itens);
    return { success: true, message: "Venda registrada com sucesso.", id };
  } catch (err) {
    console.error("Erro ao registrar venda:", err);
    return {
      success: false,
      message: err.message || "Erro ao registrar venda.",
    };
  }
}

export async function listarTodasVendas() {
  if (!canUser(tabela, "select")) {
    return { success: false, message: "Permissão negada para listar vendas." };
  }

  try {
    const vendas = await listarVendas();
    return { success: true, data: vendas };
  } catch (err) {
    console.error("Erro ao listar vendas:", err);
    return { success: false, message: "Erro ao listar vendas." };
  }
}

export async function obterVenda(id) {
  if (!canUser(tabela, "select")) {
    return {
      success: false,
      message: "Permissão negada para consultar venda.",
    };
  }

  try {
    const venda = await buscarVendaPorId(id);
    if (!venda) {
      return { success: false, message: "Venda não encontrada." };
    }
    return { success: true, data: venda };
  } catch (err) {
    console.error("Erro ao buscar venda:", err);
    return { success: false, message: "Erro ao buscar venda." };
  }
}

export async function alterarStatus(id, status) {
  if (!canUser(tabela, "update")) {
    return {
      success: false,
      message: "Permissão negada para atualizar venda.",
    };
  }

  try {
    const atualizado = await atualizarStatusVenda(id, status);
    if (!atualizado) {
      return {
        success: false,
        message: "Venda não encontrada ou não atualizada.",
      };
    }
    return { success: true, message: "Status atualizado com sucesso." };
  } catch (err) {
    console.error("Erro ao atualizar status:", err);
    return { success: false, message: "Erro ao atualizar status da venda." };
  }
}
