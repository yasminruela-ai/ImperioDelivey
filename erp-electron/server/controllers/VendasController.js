import {
  listarVendasComItens,
  buscarVendaPorId,
  excluirVenda,
} from "../models/Vendas.js";

import { canUser } from "./PermissoesController.js";

const tabela = "pedidos";

export async function listarTodasVendas() {
  if (!canUser(tabela, "select")) {
    return { success: false, message: "Permissão negada para listar vendas." };
  }

  try {
    const vendas = await listarVendasComItens();
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

export async function deletarVenda(id) {
  if (!canUser(tabela, "delete")) {
    return { success: false, message: "Permissão negada para excluir venda." };
  }

  try {
    const removido = await excluirVenda(id);

    if (!removido) {
      return { success: false, message: "Venda não encontrada." };
    }

    return { success: true, message: "Venda removida com sucesso." };
  } catch (err) {
    console.error("Erro ao remover venda:", err);
    return { success: false, message: "Erro ao remover venda." };
  }
}
