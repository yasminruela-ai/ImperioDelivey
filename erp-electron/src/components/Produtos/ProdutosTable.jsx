export default function ProdutosTable({
  tela,
  dados,
  categorias,
  podeEditar,
  podeRemover,
  handleEditar,
  handleRemover,
  estilo,
}) {
  return (
    <div className={`shadow-md rounded p-4 ${estilo.card}`}>
      <h2 className={`text-xl font-bold mb-4 ${estilo.titulo}`}>
        Lista de {tela === "categorias" ? "Categorias" : "Produtos"}
      </h2>

      <table className="w-full border-collapse">
        <thead>
          <tr className={estilo.tabelaHeader}>
            <th className={`p-2 text-left border ${estilo.tabelaBorda}`}>
              Nome
            </th>

            {tela === "produtos" && (
              <>
                <th className={`p-2 text-left border ${estilo.tabelaBorda}`}>
                  Preço
                </th>
                <th className={`p-2 text-left border ${estilo.tabelaBorda}`}>
                  Categoria
                </th>
              </>
            )}

            {(podeEditar || podeRemover) && (
              <th className={`p-2 text-center border ${estilo.tabelaBorda}`}>
                Ações
              </th>
            )}
          </tr>
        </thead>

        <tbody>
          {dados.length > 0 ? (
            dados.map((item) => (
              <tr
                key={
                  tela === "categorias" ? item.idCategorias : item.idProdutos
                }
                className={`border-b ${estilo.tabelaBorda}`}
              >
                <td className="p-2">{item.nome}</td>

                {tela === "produtos" && (
                  <>
                    <td className="p-2">R$ {item.preco}</td>
                    <td className="p-2">
                      {categorias.find(
                        (c) => c.idCategorias === item.categorias_idCategorias
                      )?.nome || "-"}
                    </td>
                  </>
                )}

                {(podeEditar || podeRemover) && (
                  <td className="p-2 text-center flex gap-2 justify-center">
                    {podeEditar && (
                      <button
                        onClick={() => handleEditar(item)}
                        className="bg-yellow-500 text-black px-3 py-1 rounded"
                      >
                        Editar
                      </button>
                    )}
                    {podeRemover && (
                      <button
                        onClick={() =>
                          handleRemover(
                            tela === "categorias"
                              ? item.idCategorias
                              : item.idProdutos
                          )
                        }
                        className="bg-red-600 text-white px-3 py-1 rounded"
                      >
                        Deletar
                      </button>
                    )}
                  </td>
                )}
              </tr>
            ))
          ) : (
            <tr>
              <td
                colSpan={tela === "produtos" ? 4 : 2}
                className="text-center p-4 italic opacity-60"
              >
                Nenhum registro encontrado.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
