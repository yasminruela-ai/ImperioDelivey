export default function ListaItensVenda({ venda, temaEscuro }) {
  return (
    <div
      className={`mt-4 border-l-4 pl-3 ${
        temaEscuro ? "border-yellow-500" : "border-red-500"
      }`}
    >
      {venda.itens?.length > 0 ? (
        venda.itens.map((item, i) => (
          <div
            key={i}
            className="text-sm flex justify-between mb-1"
          >
            <span>
              {item.nome} — {item.quantidade}x
            </span>
            <span>
              R${" "}
              {(Number(item.preco) * Number(item.quantidade)).toFixed(2)}
            </span>
          </div>
        ))
      ) : (
        <p className="italic opacity-70 text-sm">
          Nenhum item listado
        </p>
      )}
    </div>
  );
}
