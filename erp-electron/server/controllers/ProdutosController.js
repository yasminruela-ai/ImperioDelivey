import {
  listarProdutos,
  buscarProdutoPorId,
  adicionarProduto,
  atualizarProduto,
  desativarProduto,
} from "../models/Produtos.js";

import { canUser } from "../controllers/PermissoesController.js";

const tabela = "produtos";

export async function listarTodosProdutos() {
  if (!canUser(tabela, "select")) {
    return {
      success: false,
      message: "Permissão negada para listar produtos.",
    };
  }

  try {
    const produtos = await listarProdutos();
    return { success: true, data: produtos };
  } catch (err) {
    console.error("Erro ao listar produtos:", err);
    return { success: false, message: "Erro ao listar produtos." };
  }
}

export async function obterProdutoPorId(id) {
  if (!canUser(tabela, "select")) {
    return {
      success: false,
      message: "Permissão negada para visualizar produto.",
    };
  }

  try {
    const produto = await buscarProdutoPorId(id);
    if (!produto) {
      return { success: false, message: "Produto não encontrado." };
    }
    return { success: true, data: produto };
  } catch (err) {
    console.error("Erro ao buscar produto:", err);
    return { success: false, message: "Erro ao buscar produto." };
  }
}

export async function criarProduto(nome, preco, categoriaId) {
  if (!canUser(tabela, "insert")) {
    return {
      success: false,
      message: "Permissão negada para adicionar produto.",
    };
  }

  try {
    const id = await adicionarProduto(nome, preco, categoriaId);
    return { success: true, message: "Produto adicionado com sucesso.", id };
  } catch (err) {
    console.error("Erro ao adicionar produto:", err);
    return { success: false, message: "Erro ao adicionar produto." };
  }
}

export async function editarProduto(id, nome, preco, categoriaId) {
  if (!canUser(tabela, "update")) {
    return {
      success: false,
      message: "Permissão negada para atualizar produto.",
    };
  }

  try {
    const atualizado = await atualizarProduto(id, nome, preco, categoriaId);
    if (!atualizado) {
      return {
        success: false,
        message: "Produto não encontrado ou não atualizado.",
      };
    }
    return { success: true, message: "Produto atualizado com sucesso." };
  } catch (err) {
    console.error("Erro ao atualizar produto:", err);
    return { success: false, message: "Erro ao atualizar produto." };
  }
}

export async function removerProduto(id) {
  if (!canUser(tabela, "delete")) {
    return {
      success: false,
      message: "Permissão negada para desativar produto.",
    };
  }

  try {
    const desativado = await desativarProduto(id);
    if (!desativado) {
      return {
        success: false,
        message: "Produto não encontrado ou já desativado.",
      };
    }
    return { success: true, message: "Produto desativado com sucesso." };
  } catch (err) {
    console.error("Erro ao desativar produto:", err);
    return { success: false, message: "Erro ao desativar produto." };
  }
}
