import { supabase } from "../database/dbService.js";

export async function criarVendaDelivery(deliveryPedidoId, itens) {
  const { data: venda, error: vendaError } = await supabase
    .from("delivery_vendas")
    .insert({ delivery_pedido_id: deliveryPedidoId, status: "pendente" })
    .select("id")
    .single();

  if (vendaError) throw new Error(vendaError.message);

  const itensRows = itens.map((item) => ({
    venda_id: venda.id,
    nome: item.nome || "",
    quantidade: Number(item.quantidade) || 1,
    preco_unitario: Number(item.valor) || 0,
  }));

  const { error: itensError } = await supabase
    .from("delivery_itens")
    .insert(itensRows);

  if (itensError) throw new Error(itensError.message);

  return venda.id;
}

export async function atualizarStatusVendaDelivery(vendaId, status) {
  const { data, error } = await supabase
    .from("delivery_vendas")
    .update({ status, atualizado_em: new Date().toISOString() })
    .eq("id", vendaId)
    .select("id")
    .single();

  if (error) throw new Error(error.message);
  return !!data;
}

export async function listarPedidosDelivery() {
  const { data, error } = await supabase
    .from("delivery_vendas")
    .select("*, delivery_itens(*)")
    .order("criado_em", { ascending: false });

  if (error) throw new Error(error.message);
  return data || [];
}

export async function buscarPedidoDelivery(id) {
  const { data, error } = await supabase
    .from("delivery_vendas")
    .select("*, delivery_itens(*)")
    .eq("id", id)
    .single();

  if (error) return null;
  return data;
}

export async function listarProdutosAtivos() {
  const { data, error } = await supabase
    .from("produtos")
    .select("id, nome, preco, categorias(nome)")
    .eq("ativo", true);

  if (error) throw new Error(error.message);

  return (data || []).map((p) => ({
    id: p.id,
    nome: p.nome,
    preco: p.preco,
    categoria: p.categorias?.nome ?? null,
  }));
}
