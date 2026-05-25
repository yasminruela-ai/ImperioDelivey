import {
  listarCategorias,
  buscarCategoriaPorId,
  adicionarCategoria,
  atualizarCategoria,
  desativarCategoria,
} from "../models/Categorias.js";

import { canUser } from "../controllers/PermissoesController.js";

const tabela = "produtos";

export async function listarTodasCategorias() {
  if (!canUser(tabela, "select")) {
    return {
      success: false,
      message: "Permissão negada para listar categorias.",
    };
  }

  try {
    const categorias = await listarCategorias();
    return { success: true, data: categorias };
  } catch (err) {
    console.error("Erro ao listar categorias:", err);
    return { success: false, message: "Erro ao listar categorias." };
  }
}

export async function obterCategoriaPorId(id) {
  if (!canUser(tabela, "select")) {
    return {
      success: false,
      message: "Permissão negada para visualizar categoria.",
    };
  }

  try {
    const categoria = await buscarCategoriaPorId(id);
    if (!categoria) {
      return { success: false, message: "Categoria não encontrada." };
    }
    return { success: true, data: categoria };
  } catch (err) {
    console.error("Erro ao buscar categoria:", err);
    return { success: false, message: "Erro ao buscar categoria." };
  }
}

export async function criarCategoria(nome) {
  if (!canUser(tabela, "insert")) {
    return {
      success: false,
      message: "Permissão negada para adicionar categoria.",
    };
  }

  try {
    const id = await adicionarCategoria(nome);
    return { success: true, message: "Categoria adicionada com sucesso.", id };
  } catch (err) {
    console.error("Erro ao adicionar categoria:", err);
    return { success: false, message: "Erro ao adicionar categoria." };
  }
}

export async function editarCategoria(id, nome) {
  if (!canUser(tabela, "update")) {
    return {
      success: false,
      message: "Permissão negada para atualizar categoria.",
    };
  }

  try {
    const atualizado = await atualizarCategoria(id, nome);
    if (!atualizado) {
      return {
        success: false,
        message: "Categoria não encontrada ou não atualizada.",
      };
    }
    return { success: true, message: "Categoria atualizada com sucesso." };
  } catch (err) {
    console.error("Erro ao atualizar categoria:", err);
    return { success: false, message: "Erro ao atualizar categoria." };
  }
}

export async function removerCategoria(id) {
  if (!canUser(tabela, "delete")) {
    return {
      success: false,
      message: "Permissão negada para desativar categoria.",
    };
  }

  try {
    const desativado = await desativarCategoria(id);
    if (!desativado) {
      return {
        success: false,
        message: "Categoria não encontrada ou já desativada.",
      };
    }
    return { success: true, message: "Categoria desativada com sucesso." };
  } catch (err) {
    console.error("Erro ao desativar categoria:", err);
    return { success: false, message: "Erro ao desativar categoria." };
  }
}
