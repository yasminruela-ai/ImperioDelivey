import React from "react";

export default function ProdutoCard({
  p,
  temaEscuro,
  visivelQtd,
  qtdInputs,
  formatPrice,
  abrirQuantidade,
  alterarInputQtd,
  adicionarAoCarrinho,
}) {
  return (
    <div
      className={`p-4 rounded shadow flex flex-col transition-colors ${
        temaEscuro
          ? "bg-[#3b240f] border border-yellow-900"
          : "bg-gray-50"
      }`}
    >
      <div className="font-semibold">{p.nome}</div>
      <div className="text-sm mb-2">{formatPrice(p.preco)}</div>

      <button
        onClick={() => abrirQuantidade(p)}
        className="mt-auto px-3 py-2 rounded-lg text-black font-semibold hover:opacity-90 transition"
        style={{ backgroundColor: "#F4B400" }}
      >
        Adicionar
      </button>

      {visivelQtd[p.idProdutos] && (
        <div className="mt-2 flex gap-2 items-center">
          <input
            type="number"
            min="1"
            value={qtdInputs[p.idProdutos] ?? 1}
            onChange={(e) =>
              alterarInputQtd(p.idProdutos, e.target.value)
            }
            className={`p-2 rounded w-full outline-none transition ${
              temaEscuro
                ? "bg-[#2b1a0c] border border-yellow-900 text-yellow-200"
                : "border"
            }`}
          />
          <button
            onClick={() => adicionarAoCarrinho(p)}
            className="px-3 py-2 rounded-lg text-white hover:opacity-90 transition font-semibold"
            style={{ backgroundColor: "#2ECC71" }}
          >
            OK
          </button>
        </div>
      )}
    </div>
  );
}
