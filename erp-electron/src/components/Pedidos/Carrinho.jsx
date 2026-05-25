import React from "react";

export default function Carrinho({
  carrinho,
  removerItem,
  formatPrice,
  total,
  temaEscuro,
}) {
  return (
    <div
      className={`rounded-lg shadow-xl p-4 transition-colors ${
        temaEscuro ? "bg-[#2b1a0c] border border-yellow-900" : "bg-white"
      }`}
    >
      <h3 className="font-bold text-lg mb-3">Comanda</h3>

      {carrinho.length === 0 ? (
        <div className="text-gray-500 italic">Sem itens</div>
      ) : (
        <div className="space-y-3">
          {carrinho.map((it) => (
            <div
              key={it.produtoId}
              className={`p-3 flex justify-between items-center rounded-lg transition-colors ${
                temaEscuro
                  ? "bg-[#3b240f] border border-yellow-900"
                  : "bg-gray-100"
              }`}
            >
              <div>
                <div className="font-semibold">{it.nome}</div>
                <div className="text-sm">
                  {formatPrice(it.preco)} x {it.quantidade}
                </div>
              </div>

              <div className="flex flex-col gap-1 text-right">
                <div className="font-semibold">{formatPrice(it.subtotal)}</div>
                <button
                  onClick={() => removerItem(it.produtoId)}
                  className="px-3 py-1 rounded-lg text-white hover:opacity-90 transition text-sm"
                  style={{ backgroundColor: "#C62828" }}
                >
                  Remover
                </button>
              </div>
            </div>
          ))}

          <div className="border-t pt-3 flex font-bold justify-between">
            <span>Total:</span>
            <span>{formatPrice(total)}</span>
          </div>
        </div>
      )}
    </div>
  );
}
