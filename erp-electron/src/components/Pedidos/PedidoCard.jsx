import React from "react";

export default function PedidoCard({
  p,
  STATUSES,
  temaEscuro,
  alterarStatus,
  verItens,
  podeRemover,
}) {
  const id = p.idVendas ?? p.id ?? p.idVenda;
  const nomePedido = p.nome ?? p.nomeCliente ?? p.nome;
  const status = (p.status ?? "").toLowerCase();
  const data = p.dataVenda;

  return (
    <div
      className={`flex flex-col md:flex-row md:items-center md:justify-between gap-3 p-4 rounded-lg border transition-colors ${
        temaEscuro
          ? "bg-[#3b240f] border border-yellow-900"
          : "bg-gray-50"
      }`}
    >
      <div>
        <div className="font-bold text-lg">
          #{id} — {nomePedido}
        </div>
        <div className="text-sm text-gray-500">
          {data ? new Date(data).toLocaleString("pt-BR") : "Sem data"}
        </div>
      </div>

      <div className="flex gap-2">
        <select
          value={status}
          onChange={(e) => alterarStatus(id, e.target.value)}
          className={`p-2 rounded-lg outline-none transition ${
            temaEscuro
              ? "bg-[#1C1C1C] border border-gray-700 text-gray-100"
              : "border"
          }`}
        >
          {STATUSES.map((s) => (
            <option key={s} value={s}>
              {s}
            </option>
          ))}
        </select>

        <button
          onClick={() => verItens(p)}
          className="px-4 py-2 rounded-lg text-black font-semibold hover:opacity-90 transition"
          style={{ backgroundColor: "#F4B400" }}
        >
          Itens
        </button>

        {podeRemover && (
          <button
            onClick={() => {
              if (!confirm("Cancelar este pedido?")) return;
              alterarStatus(id, "cancelado");
            }}
            className="px-4 py-2 rounded-lg text-white hover:opacity-90 transition font-semibold"
            style={{ backgroundColor: "#C62828" }}
          >
            Cancelar
          </button>
        )}
      </div>
    </div>
  );
}
