import { getDb, getIdUser } from "../db.js";

export async function criarVenda(nome, itens) {
  const db = getDb();
  const usuarioId = getIdUser();

  if (!usuarioId) {
    throw new Error("Usuario nao identificado. Faca login novamente.");
  }

  const { data: venda, error: errV } = await db
    .from("vendas")
    .insert({ nome, data_venda: new Date().toISOString(), status: "pendente", usuario_id: usuarioId })
    .select("id")
    .single();

  if (errV) throw new Error(errV.message);

  const vendaId = venda.id;

  for (const item of itens) {
    const { data: prod, error: errP } = await db
      .from("produtos")
      .select("id, preco")
      .eq("id", item.produtoId)
      .eq("ativo", true)
      .single();

    if (errP || !prod) {
      await db.from("vendas").delete().eq("id", vendaId);
      throw new Error(`Produto invalido ou inativo (id ${item.produtoId})`);
    }

    const { error: errI } = await db.from("itens_vendas").insert({
      quantidade: item.quantidade,
      preco_unitario: prod.preco,
      venda_id: vendaId,
      produto_id: item.produtoId,
    });

    if (errI) {
      await db.from("vendas").delete().eq("id", vendaId);
      throw new Error(errI.message);
    }
  }

  return vendaId;
}

export async function listarVendas() {
  const { data, error } = await getDb()
    .from("vendas")
    .select("*, usuarios(nome)")
    .order("data_venda", { ascending: false });

  if (error) throw new Error(error.message);

  return data.map((v) => ({
    ...v,
    usuario_nome: v.usuarios?.nome ?? null,
    usuarios: undefined,
  }));
}

export async function buscarVendaPorId(id) {
  const { data, error } = await getDb()
    .from("vendas")
    .select("*, usuarios(nome), itens_vendas(*, produtos(nome))")
    .eq("id", id)
    .single();

  if (error) return null;

  return {
    ...data,
    usuario_nome: data.usuarios?.nome ?? null,
    itens: (data.itens_vendas || []).map((i) => ({
      ...i,
      produto_nome: i.produtos?.nome ?? null,
    })),
  };
}

export async function atualizarStatusVenda(id, status) {
  const { data, error } = await getDb()
    .from("vendas")
    .update({ status })
    .eq("id", id)
    .select("id");

  if (error) throw new Error(error.message);
  return data.length > 0;
}
