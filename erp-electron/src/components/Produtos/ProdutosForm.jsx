export default function ProdutosForm({
  tela,
  form,
  categorias,
  editando,
  setForm,
  handleSubmit,
  limparFormulario,
  podeCriar,
  estilo,
}) {
  if (!podeCriar && !editando) return null;

  return (
    <div className={`shadow-md rounded p-4 ${estilo.card}`}>
      <h2 className={`text-xl font-bold mb-4 ${estilo.titulo}`}>
        {editando ? "Editar" : "Novo"}{" "}
        {tela === "categorias" ? "Categoria" : "Produto"}
      </h2>

      <form onSubmit={handleSubmit} className="flex flex-col gap-3">
        <input
          type="text"
          placeholder="Nome"
          value={form.nome}
          onChange={(e) => setForm({ ...form, nome: e.target.value })}
          required
          className={`rounded p-2 border ${estilo.input}`}
        />

        {tela === "produtos" && (
          <>
            <input
              type="number"
              placeholder="Preço"
              value={form.preco}
              onChange={(e) => setForm({ ...form, preco: e.target.value })}
              required
              className={`rounded p-2 border ${estilo.input}`}
            />

            <select
              value={form.categoriaId}
              onChange={(e) => setForm({ ...form, categoriaId: e.target.value })}
              required
              className={`rounded p-2 border ${estilo.input}`}
            >
              <option value="">Selecione uma categoria</option>
              {categorias.map((c) => (
                <option key={c.idCategorias} value={c.idCategorias}>
                  {c.nome}
                </option>
              ))}
            </select>
          </>
        )}

        <div className="flex gap-2">
          <button
            type="submit"
            className="bg-green-600 text-white px-4 py-2 rounded"
          >
            {editando ? "Atualizar" : "Criar"}
          </button>

          {editando && (
            <button
              type="button"
              onClick={limparFormulario}
              className="bg-gray-500 text-white px-4 py-2 rounded"
            >
              Cancelar
            </button>
          )}
        </div>
      </form>
    </div>
  );
}
