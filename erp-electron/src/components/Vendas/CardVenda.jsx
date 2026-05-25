import ListaItensVenda from "./ListaItensVenda";

export default function CardVenda({
  venda,
  temaEscuro,
  podeRemover,
  excluirVenda,
}) {
  const id = venda.idVendas ?? venda.id;

  function formatDate(d) {
    return d ? new Date(d).toLocaleString("pt-BR") : "Sem data";
  }

  return (
    <div
      className={`rounded-lg p-4 shadow-md border transition-all duration-200 hover:scale-[1.01] ${
        temaEscuro
          ? "bg-[#3b240f] border-yellow-800 text-yellow-200"
          : "bg-white border-gray-300"
      }`}
    >
      <div className="flex justify-between items-start">
        <div>
          <p className="font-bold text-lg">Venda #{id}</p>
          <p className="text-sm opacity-80">
            Cliente: <strong>{venda.nome ?? "Não informado"}</strong>
          </p>
          <p className="text-sm opacity-80">
            Data: {formatDate(venda.dataVenda)}
          </p>
        </div>

        {podeRemover && (
          <button
            onClick={() => excluirVenda(id)}
            className={`px-3 py-1 rounded-lg font-semibold transition-colors shadow-md ${
              temaEscuro
                ? "bg-red-600 hover:bg-red-500 text-white"
                : "bg-yellow-500 hover:bg-yellow-600 text-black"
            }`}
          >
            Excluir
          </button>
        )}
      </div>

      <ListaItensVenda venda={venda} temaEscuro={temaEscuro} />

      <p className="mt-4 font-bold text-lg">
        Total: R$ {(venda.totalVenda ?? 0).toFixed(2)}
      </p>
    </div>
  );
}
