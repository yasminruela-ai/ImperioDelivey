import { getDb } from "../db.js";

export async function listarProdutos() {
  const { data, error } = await getDb()
    .from("produtos")
    .select("*, categorias(nome)")
    .eq("ativo", true);
  if (error) throw new Error(error.message);
  return data.map((p) => ({
    ...p,
    categoria_nome: p.categorias?.nome ?? null,
    categorias: undefined,
  }));
}

export async function buscarProdutoPorId(id) {
  const { data, error } = await getDb()
    .from("produtos")
    .select("*, categorias(nome)")
    .eq("id", id)
    .eq("ativo", true)
    .single();
  if (error) throw new Error(error.message);
  return { ...data, categoria_nome: data.categorias?.nome ?? null, categorias: undefined };
}

export async function adicionarProduto(nome, preco, categoriaId) {
  const { data, error } = await getDb()
    .from("produtos")
    .insert({ nome, preco, ativo: true, categoria_id: categoriaId })
    .select("id")
    .single();
  if (error) throw new Error(error.message);
  return data.id;
}

export async function atualizarProduto(id, nome, preco, categoriaId) {
  const { data, error } = await getDb()
    .from("produtos")
    .update({ nome, preco, categoria_id: categoriaId })
    .eq("id", id)
    .select("id");
  if (error) throw new Error(error.message);
  return data.length > 0;
}

export async function desativarProduto(id) {
  const { data, error } = await getDb()
    .from("produtos")
    .update({ ativo: false })
    .eq("id", id)
    .select("id");
  if (error) throw new Error(error.message);
  return data.length > 0;
}
