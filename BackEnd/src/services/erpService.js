const ERP_API_URL = process.env.ERP_API_URL;
const ERP_API_KEY = process.env.ERP_API_KEY;

function erpHeaders() {
  return {
    "Content-Type": "application/json",
    Authorization: `Bearer ${ERP_API_KEY}`,
  };
}

async function verificarErpOnline() {
  try {
    const res = await fetch(`${ERP_API_URL}/integracao/health`, { signal: AbortSignal.timeout(3000) });
    return res.ok;
  } catch {
    return false;
  }
}

async function enviarPedidoParaErp(deliveryPedidoId, itens) {
  try {
    const res = await fetch(`${ERP_API_URL}/integracao/pedido`, {
      method: "POST",
      headers: erpHeaders(),
      body: JSON.stringify({ deliveryPedidoId, itens }),
    });
    const data = await res.json();
    if (res.ok && data.success) {
      return { success: true, erpVendaId: data.erpVendaId };
    }
    return { success: false, error: data.message || `HTTP ${res.status}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

async function atualizarStatusNoErp(erpVendaId, status) {
  try {
    const res = await fetch(`${ERP_API_URL}/integracao/pedido/${erpVendaId}/status`, {
      method: "PUT",
      headers: erpHeaders(),
      body: JSON.stringify({ status }),
    });
    const data = await res.json();
    if (res.ok && data.success) return { success: true };
    return { success: false, error: data.message || `HTTP ${res.status}` };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

module.exports = { verificarErpOnline, enviarPedidoParaErp, atualizarStatusNoErp };
