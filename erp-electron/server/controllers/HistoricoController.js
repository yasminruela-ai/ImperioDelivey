import { buscar, buscarPorId } from "../models/Historico.js";
import { canUser } from "../controllers/PermissoesController.js";

const tabela = "historico";

export async function listarHistorico(filtros = {}) {
  if (!canUser(tabela, "select")) {
    return {
      success: false,
      message: "Permissão negada para listar histórico.",
    };
  }

  try {
    const logs = await buscar(filtros);
    return { success: true, data: logs };
  } catch (err) {
    console.error("Erro ao listar histórico:", err);
    return { success: false, message: "Erro ao listar histórico." };
  }
}

export async function obterLogPorId(id) {
  if (!canUser(tabela, "select")) {
    return { success: false, message: "Permissão negada para visualizar log." };
  }

  try {
    const log = await buscarPorId(id);
    if (!log) {
      return { success: false, message: "Log não encontrado." };
    }
    return { success: true, data: log };
  } catch (err) {
    console.error("Erro ao buscar log:", err);
    return { success: false, message: "Erro ao buscar log." };
  }
}
