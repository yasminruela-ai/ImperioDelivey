import React, { useState } from "react";
import useDeliveryOrders from "../../hooks/useDeliveryOrders";

const STATUS_CORES = {
  pendente: { bg: "#FEF3C7", text: "#92400E", border: "#F59E0B" },
  aceito: { bg: "#DBEAFE", text: "#1E40AF", border: "#3B82F6" },
  em_preparo: { bg: "#FEE2E2", text: "#991B1B", border: "#EF4444" },
  saiu_para_entrega: { bg: "#D1FAE5", text: "#065F46", border: "#10B981" },
  entregue: { bg: "#F3F4F6", text: "#374151", border: "#9CA3AF" },
  cancelado: { bg: "#F3F4F6", text: "#6B7280", border: "#D1D5DB" },
};

function BadgeStatus({ status, labels }) {
  const cores = STATUS_CORES[status] ?? STATUS_CORES.pendente;
  return (
    <span
      className="px-2 py-1 rounded-full text-xs font-bold border"
      style={{ backgroundColor: cores.bg, color: cores.text, borderColor: cores.border }}
    >
      {labels[status] ?? status}
    </span>
  );
}

function PedidoDeliveryCard({ pedido, temaEscuro, alterarStatus, formatarData, formatarPreco, PROXIMOS_STATUS, STATUS_LABELS }) {
  const [expandido, setExpandido] = useState(false);

  const proximos = PROXIMOS_STATUS[pedido.status] ?? [];
  const itens = pedido.delivery_itens ?? [];
  const total = itens.reduce((s, i) => s + i.quantidade * i.preco_unitario, 0);
  const idCurto = String(pedido.delivery_pedido_id).slice(-8).toUpperCase();

  return (
    <div
      className={`rounded-lg border p-4 transition-colors space-y-3 ${
        temaEscuro
          ? "bg-[#3b240f] border-yellow-900"
          : pedido.status === "pendente"
          ? "bg-amber-50 border-amber-300"
          : "bg-gray-50 border-gray-200"
      }`}
    >
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <span className={`font-bold text-lg ${temaEscuro ? "text-yellow-200" : ""}`}>
              #{idCurto}
            </span>
            <BadgeStatus status={pedido.status} labels={STATUS_LABELS} />
          </div>
          <div className={`text-sm ${temaEscuro ? "text-yellow-600" : "text-gray-500"}`}>
            {formatarData(pedido.criado_em)} — {itens.length} {itens.length === 1 ? "item" : "itens"} — {formatarPreco(total)}
          </div>
        </div>

        <div className="flex flex-wrap gap-2 items-center">
          {proximos.length > 0 && (
            <select
              defaultValue=""
              onChange={(e) => {
                if (e.target.value) alterarStatus(pedido.id, e.target.value);
                e.target.value = "";
              }}
              className={`p-2 rounded-lg text-sm outline-none transition ${
                temaEscuro
                  ? "bg-[#1C1C1C] border border-gray-700 text-gray-100"
                  : "border border-gray-300"
              }`}
            >
              <option value="" disabled>Avançar status</option>
              {proximos.map((s) => (
                <option key={s} value={s}>{STATUS_LABELS[s] ?? s}</option>
              ))}
            </select>
          )}

          <button
            onClick={() => setExpandido((v) => !v)}
            className="px-3 py-2 rounded-lg text-sm font-semibold text-black hover:opacity-90 transition"
            style={{ backgroundColor: "#F4B400" }}
          >
            {expandido ? "Fechar" : "Ver itens"}
          </button>
        </div>
      </div>

      {expandido && (
        <div className={`rounded-lg p-3 space-y-1 text-sm ${temaEscuro ? "bg-[#2b1a0c]" : "bg-white border border-gray-100"}`}>
          {itens.length === 0 ? (
            <span className="text-gray-400 italic">Sem itens registrados.</span>
          ) : (
            itens.map((item) => (
              <div key={item.id} className="flex justify-between">
                <span className={temaEscuro ? "text-yellow-200" : ""}>
                  {item.nome} × {item.quantidade}
                </span>
                <span className={temaEscuro ? "text-yellow-400" : "text-gray-600"}>
                  {formatarPreco(item.preco_unitario * item.quantidade)}
                </span>
              </div>
            ))
          )}
          <div className={`pt-2 border-t flex justify-between font-bold ${temaEscuro ? "border-yellow-900 text-yellow-300" : "border-gray-200"}`}>
            <span>Total</span>
            <span>{formatarPreco(total)}</span>
          </div>
        </div>
      )}
    </div>
  );
}

export default function DeliveryOrders({ temaEscuro }) {
  const {
    pedidos,
    loading,
    erro,
    carregar,
    alterarStatus,
    formatarData,
    formatarPreco,
    pendentes,
    PROXIMOS_STATUS,
    STATUS_LABELS,
  } = useDeliveryOrders();

  const [filtro, setFiltro] = useState("ativos");

  const pedidosFiltrados = pedidos.filter((p) => {
    if (filtro === "ativos") return p.status !== "entregue" && p.status !== "cancelado";
    if (filtro === "concluidos") return p.status === "entregue";
    if (filtro === "cancelados") return p.status === "cancelado";
    return true;
  });

  return (
    <div
      className={`p-6 space-y-6 min-h-screen transition-colors ${
        temaEscuro ? "bg-[#1b1208] text-yellow-300" : "bg-gray-100 text-gray-800"
      }`}
    >
      <div className="flex items-center justify-between flex-wrap gap-3">
        <div className="flex items-center gap-3">
          <h2 className={`text-3xl font-bold ${temaEscuro ? "text-yellow-400" : "text-[#C62828]"}`}>
            Delivery
          </h2>
          {pendentes > 0 && (
            <span className="px-3 py-1 rounded-full text-sm font-bold text-white" style={{ backgroundColor: "#C62828" }}>
              {pendentes} novo{pendentes > 1 ? "s" : ""}
            </span>
          )}
        </div>

        <button
          onClick={carregar}
          className={`px-4 py-2 rounded-lg text-sm font-semibold transition ${
            temaEscuro
              ? "bg-yellow-800 text-yellow-200 hover:bg-yellow-700"
              : "bg-white border border-gray-300 hover:bg-gray-50"
          }`}
        >
          Atualizar
        </button>
      </div>

      <div
        className={`rounded-lg shadow-xl p-6 space-y-4 transition-colors ${
          temaEscuro ? "bg-[#2b1a0c] border border-yellow-900" : "bg-white"
        }`}
      >
        <div className="flex gap-2 flex-wrap">
          {[
            { key: "ativos", label: "Em andamento" },
            { key: "concluidos", label: "Entregues" },
            { key: "cancelados", label: "Cancelados" },
            { key: "todos", label: "Todos" },
          ].map((f) => (
            <button
              key={f.key}
              onClick={() => setFiltro(f.key)}
              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                filtro === f.key
                  ? "text-white shadow"
                  : temaEscuro
                  ? "bg-[#3b240f] text-yellow-200 hover:bg-[#4d2b0e]"
                  : "bg-gray-100 hover:bg-gray-200"
              }`}
              style={filtro === f.key ? { backgroundColor: "#C62828" } : {}}
            >
              {f.label}
            </button>
          ))}
        </div>

        {loading && (
          <div className={`text-center py-8 ${temaEscuro ? "text-yellow-600" : "text-gray-400"}`}>
            Carregando...
          </div>
        )}

        {erro && (
          <div className="p-3 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm">
            {erro}
          </div>
        )}

        {!loading && !erro && pedidosFiltrados.length === 0 && (
          <div className={`text-center py-8 italic ${temaEscuro ? "text-yellow-700" : "text-gray-400"}`}>
            Nenhum pedido encontrado.
          </div>
        )}

        <div className="space-y-3">
          {pedidosFiltrados.map((p) => (
            <PedidoDeliveryCard
              key={p.id}
              pedido={p}
              temaEscuro={temaEscuro}
              alterarStatus={alterarStatus}
              formatarData={formatarData}
              formatarPreco={formatarPreco}
              PROXIMOS_STATUS={PROXIMOS_STATUS}
              STATUS_LABELS={STATUS_LABELS}
            />
          ))}
        </div>
      </div>
    </div>
  );
}
