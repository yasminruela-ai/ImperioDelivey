const { createClient } = require("@supabase/supabase-js");

let _supabase = null;
function getSupabase() {
  if (!_supabase) {
    _supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_KEY);
  }
  return _supabase;
}

async function enviarPedidoParaErp(deliveryPedidoId, itens) {
  try {
    const supabase = getSupabase();

    const { data: venda, error: vendaError } = await supabase
      .from("delivery_vendas")
      .insert({ delivery_pedido_id: deliveryPedidoId, status: "pendente" })
      .select("id")
      .single();

    if (vendaError) return { success: false, error: vendaError.message };

    const itensRows = itens.map((item) => ({
      venda_id: venda.id,
      nome: item.nome || "",
      quantidade: Number(item.quantidade) || 1,
      preco_unitario: Number(item.valor) || 0,
    }));

    const { error: itensError } = await supabase
      .from("delivery_itens")
      .insert(itensRows);

    if (itensError) return { success: false, error: itensError.message };

    return { success: true, erpVendaId: venda.id };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

async function atualizarStatusNoErp(erpVendaId, status) {
  try {
    const supabase = getSupabase();

    const { error } = await supabase
      .from("delivery_vendas")
      .update({ status, atualizado_em: new Date().toISOString() })
      .eq("id", erpVendaId);

    if (error) return { success: false, error: error.message };
    return { success: true };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

module.exports = { enviarPedidoParaErp, atualizarStatusNoErp };
