import { getDb } from "../db.js";

export async function listarVendasComItens() {
  const { data: vendas, error } = await getDb()
    .from("vendas")
    .select("id, data_venda, status, nome, usuarios(nome), itens_vendas(quantidade, preco_unitario, produtos(nome))")
    .eq("status", "pago")
    .order("data_venda", { ascending: false });

  if (error) throw new Error(error.message);

  return vendas.map((v) => ({
    idVendas: v.id,
    dataVenda: v.data_venda,
    status: v.status,
    nome: v.nome,
    usuario_nome: v.usuarios?.nome ?? null,
    totalVenda: (v.itens_vendas || []).reduce(
      (acc, i) => acc + i.quantidade * i.preco_unitario,
      0
    ),
    itens: (v.itens_vendas || []).map((i) => ({
      nome: i.produtos?.nome ?? null,
      quantidade: i.quantidade,
      preco: i.preco_unitario,
    })),
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

export async function excluirVenda(id) {
  const { error: errItens } = await getDb()
    .from("itens_vendas")
    .delete()
    .eq("venda_id", id);

  if (errItens) throw new Error(errItens.message);

  const { data, error } = await getDb()
    .from("vendas")
    .delete()
    .eq("id", id)
    .select("id");

  if (error) throw new Error(error.message);
  return data.length > 0;
}
