import React from "react";
import usePedidos from "../../hooks/usePedidos";
import ProdutoCard from "./ProdutoCard";
import PedidoCard from "./PedidoCard";
import Carrinho from "./Carrinho";

export default function Pedidos({ permissoes, temaEscuro }) {
  const {
    categorias,
    categoriaAtiva,
    setCategoriaAtiva,
    cliente,
    setCliente,
    carrinho,
    pedidos,
    loading,
    visivelQtd,
    qtdInputs,
    STATUSES,
    abrirQuantidade,
    alterarInputQtd,
    adicionarAoCarrinho,
    removerItem,
    confirmarPedido,
    alterarStatus,
    verItens,
    formatPrice,
    total,
    produtosFiltrados,
    podeRemover,
  } = usePedidos(permissoes);

  return (
    <div
      className={`p-6 space-y-6 min-h-screen transition-colors ${
        temaEscuro
          ? "bg-[#1b1208] text-yellow-300"
          : "bg-gray-100 text-gray-800"
      }`}
    >
      <h2
        className={`text-3xl font-bold ${
          temaEscuro ? "text-yellow-400" : "text-[#C62828]"
        }`}
      >
        Pedidos
      </h2>

      <div
        className={`rounded-lg shadow-xl p-6 transition-colors ${
          temaEscuro ? "bg-[#2b1a0c] border border-yellow-900" : "bg-white"
        }`}
      >
        <div className="flex flex-col md:flex-row gap-3 mb-6">
          <input
            className={`p-3 rounded-lg flex-1 outline-none transition-colors ${
              temaEscuro
                ? "bg-[#3b240f] border border-yellow-900 text-yellow-200 placeholder-yellow-700"
                : "bg-white border border-gray-300"
            }`}
            placeholder="Nome do cliente"
            value={cliente}
            onChange={(e) => setCliente(e.target.value)}
          />

          <button
            onClick={confirmarPedido}
            className="px-6 py-3 rounded-lg font-bold text-white shadow-md transition-colors"
            style={{ backgroundColor: "#2ECC71" }}
          >
            Concluir Pedido ({formatPrice(total)})
          </button>
        </div>

        <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
          <div className="xl:col-span-2 space-y-4">
            <div className="flex gap-2 overflow-x-auto pb-1">
              {categorias.map((c) => (
                <button
                  key={c.idCategorias}
                  onClick={() => setCategoriaAtiva(c.idCategorias)}
                  className={`px-4 py-2 rounded-lg font-medium whitespace-nowrap transition-colors ${
                    categoriaAtiva === c.idCategorias
                      ? "text-white shadow"
                      : temaEscuro
                      ? "bg-[#3b240f] text-yellow-200 hover:bg-[#4d2b0e]"
                      : "bg-gray-200"
                  }`}
                  style={
                    categoriaAtiva === c.idCategorias
                      ? { backgroundColor: "#C62828" }
                      : {}
                  }
                >
                  {c.nome}
                </button>
              ))}
            </div>

            <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {loading ? (
                <div>Carregando...</div>
              ) : produtosFiltrados.length ? (
                produtosFiltrados.map((p) => (
                  <ProdutoCard
                    key={p.idProdutos}
                    p={p}
                    temaEscuro={temaEscuro}
                    visivelQtd={visivelQtd}
                    qtdInputs={qtdInputs}
                    abrirQuantidade={abrirQuantidade}
                    alterarInputQtd={alterarInputQtd}
                    adicionarAoCarrinho={adicionarAoCarrinho}
                    formatPrice={formatPrice}
                  />
                ))
              ) : (
                <div className="col-span-full text-gray-500 italic">
                  Nenhum produto nesta categoria.
                </div>
              )}
            </div>
          </div>

          <Carrinho
            carrinho={carrinho}
            removerItem={removerItem}
            formatPrice={formatPrice}
            total={total}
            temaEscuro={temaEscuro}
          />
        </div>
      </div>

      <div
        className={`rounded-lg shadow-xl p-6 transition-colors ${
          temaEscuro ? "bg-[#2b1a0c] border border-yellow-900" : "bg-white"
        }`}
      >
        <h3
          className={`text-xl font-bold mb-4 ${
            temaEscuro ? "text-yellow-400" : "text-[#C62828]"
          }`}
        >
          Pedidos
        </h3>

        <div className="space-y-3">
          {pedidos.filter((p) => {
            const status = (p.status ?? "").toLowerCase();
            return status !== "pago" && status !== "cancelado";
          }).length === 0 ? (
        <div className="text-gray-500 italic">Nenhum pedido.</div>
          ) : (
            pedidos
            .filter((p) => {
              const status = (p.status ?? "").toLowerCase();
              return status !== "pago" && status !== "cancelado";
            })
          .map((p) => (
            <PedidoCard
              key={p.idVendas ?? p.id ?? p.idVenda}
              p={p}
              STATUSES={STATUSES}
              temaEscuro={temaEscuro}
              alterarStatus={alterarStatus}
              verItens={verItens}
              podeRemover={podeRemover}
            />
          ))
        )}
        </div>
      </div>
    </div>
  );
}
