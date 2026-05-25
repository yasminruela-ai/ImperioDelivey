import { getDb } from "../db.js";

export async function listarCategoriaVenda() {
  const { data, error } = await getDb().from("vw_categoria_venda").select("*");
  if (error) throw new Error(error.message);
  return data;
}

export async function listarQuantidadeVenda() {
  const { data, error } = await getDb().from("vw_quantidade_venda").select("*");
  if (error) throw new Error(error.message);
  return data;
}

export async function listarVendaMes() {
  const { data, error } = await getDb().from("vw_venda_mes").select("*");
  if (error) throw new Error(error.message);
  return data;
}

export async function listarVendaUsuario() {
  const { data, error } = await getDb().from("vw_venda_usuario").select("*");
  if (error) throw new Error(error.message);
  return data;
}

export async function listarVendaUsuarioPorMes(mesAno) {
  const { data, error } = await getDb()
    .from("vw_venda_usuario")
    .select("*")
    .eq("mes_ano", mesAno);
  if (error) throw new Error(error.message);
  return data;
}
