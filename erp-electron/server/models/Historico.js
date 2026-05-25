import { getDb } from "../db.js";

export async function buscar(filtros = {}) {
  let query = getDb()
    .from("logs")
    .select("*")
    .order("data_operacao", { ascending: false });

  if (filtros.usuarioSistema) {
    query = query.eq("usuario_sistema", filtros.usuarioSistema);
  }
  if (filtros.operacao) {
    query = query.eq("operacao", filtros.operacao);
  }
  if (filtros.dataInicio) {
    query = query.gte("data_operacao", filtros.dataInicio);
  }
  if (filtros.dataFim) {
    query = query.lte("data_operacao", filtros.dataFim);
  }

  const { data, error } = await query;
  if (error) throw new Error(error.message);
  return data;
}

export async function buscarPorId(idLog) {
  const { data, error } = await getDb()
    .from("logs")
    .select("*")
    .eq("id", idLog)
    .single();

  if (error) return null;
  return data;
}
