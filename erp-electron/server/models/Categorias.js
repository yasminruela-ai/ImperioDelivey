import { getDb } from "../db.js";

export async function listarCategorias() {
  const { data, error } = await getDb()
    .from("categorias")
    .select("*")
    .eq("ativo", true);
  if (error) throw new Error(error.message);
  return data;
}

export async function buscarCategoriaPorId(id) {
  const { data, error } = await getDb()
    .from("categorias")
    .select("*")
    .eq("id", id)
    .single();
  if (error) throw new Error(error.message);
  return data;
}

export async function adicionarCategoria(nome) {
  const { data, error } = await getDb()
    .from("categorias")
    .insert({ nome, ativo: true })
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  return data.id;
}

export async function atualizarCategoria(id, nome) {
  const { data, error } = await getDb()
    .from("categorias")
    .update({ nome })
    .eq("id", id)
    .select("id");
  if (error) throw new Error(error.message);
  return data.length > 0;
}

export async function desativarCategoria(id) {
  const { data, error } = await getDb()
    .from("categorias")
    .update({ ativo: false })
    .eq("id", id)
    .select("id");
  if (error) throw new Error(error.message);
  return data.length > 0;
}
