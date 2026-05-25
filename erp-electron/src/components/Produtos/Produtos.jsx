import React, { useState, useEffect } from "react";

export default function Gerenciamento({ permissoes, temaEscuro }) {
  const [tela, setTela] = useState("categorias");
  const [dados, setDados] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [form, setForm] = useState({
    id: null,
    nome: "",
    preco: "",
    categoriaId: "",
  });
  const [editando, setEditando] = useState(false);

  const podeCriar = permissoes?.insert || false;
  const podeEditar = permissoes?.update || false;
  const podeRemover = permissoes?.delete || false;

  // 🔥 Paleta escura/clara
  const estilo = {
    fundo: temaEscuro ? "bg-[#0d0703] text-yellow-200" : "bg-white text-black",
    card: temaEscuro
      ? "bg-[#1a0f06] border border-yellow-700"
      : "bg-white border border-gray-300",
    botaoAtivo: temaEscuro
      ? "bg-yellow-600 text-black"
      : "bg-blue-600 text-white",
    botaoInativo: temaEscuro
      ? "bg-[#2b1a0b] text-yellow-300"
      : "bg-gray-200 text-black",
    tabelaHeader: temaEscuro ? "bg-[#2c1808] text-yellow-300" : "bg-gray-100",
    tabelaBorda: temaEscuro ? "border-yellow-600" : "border-gray-300",
    input: temaEscuro
      ? "bg-[#130a05] text-white border-yellow-700"
      : "bg-white border-gray-400",
    titulo: temaEscuro ? "text-yellow-300" : "text-black",
  };

  // ==============================
  //        CARREGAR DADOS
  // ==============================
  useEffect(() => {
    carregarDados();
  }, [tela]);

  async function carregarDados() {
    try {
      if (tela === "categorias") {
        const res = await window.ipc.categorias.listar();
        setDados(res?.success && Array.isArray(res.data) ? res.data : []);
      } else {
        const prods = await window.ipc.produtos.listar();
        const cats = await window.ipc.categorias.listar();

        setCategorias(
          cats?.success && Array.isArray(cats.data) ? cats.data : []
        );
        setDados(prods?.success && Array.isArray(prods.data) ? prods.data : []);
      }
    } catch {
      setDados([]);
    }
    limparFormulario();
  }

  function limparFormulario() {
    setForm({ id: null, nome: "", preco: "", categoriaId: "" });
    setEditando(false);
  }

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      if (tela === "categorias") {
        if (editando) await window.ipc.categorias.editar(form.id, form.nome);
        else await window.ipc.categorias.criar(form.nome);
      } else {
        if (editando)
          await window.ipc.produtos.editar(
            form.id,
            form.nome,
            form.preco,
            form.categoriaId
          );
        else
          await window.ipc.produtos.criar(
            form.nome,
            form.preco,
            form.categoriaId
          );
      }
      await carregarDados();
    } catch {}
  }

  function handleEditar(item) {
    setEditando(true);
    if (tela === "categorias")
      setForm({ id: item.idCategorias, nome: item.nome });
    else
      setForm({
        id: item.idProdutos,
        nome: item.nome,
        preco: item.preco,
        categoriaId: item.categorias_idCategorias,
      });
  }

  async function handleRemover(id) {
    try {
      if (tela === "categorias") await window.ipc.categorias.remover(id);
      else await window.ipc.produtos.remover(id);
      await carregarDados();
    } catch {}
  }

  return (
    <div className={`p-6 space-y-6 min-h-screen ${estilo.fundo}`}>
      {/* ==============================
            MENU DE ALTERNÂNCIA
      ============================== */}
      <div className="flex gap-2">
        <button
          className={`px-4 py-2 rounded transition ${
            tela === "categorias" ? estilo.botaoAtivo : estilo.botaoInativo
          }`}
          onClick={() => setTela("categorias")}
        >
          Categorias
        </button>

        <button
          className={`px-4 py-2 rounded transition ${
            tela === "produtos" ? estilo.botaoAtivo : estilo.botaoInativo
          }`}
          onClick={() => setTela("produtos")}
        >
          Produtos
        </button>
      </div>

      {/* ==============================
            LISTAGEM
      ============================== */}
      <div className={`shadow-md rounded p-4 ${estilo.card}`}>
        <h2 className={`text-xl font-bold mb-4 ${estilo.titulo}`}>
          Lista de {tela === "categorias" ? "Categorias" : "Produtos"}
        </h2>

        <table className="w-full border-collapse">
          <thead>
            <tr className={`${estilo.tabelaHeader}`}>
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

      {/* ==============================
            FORMULÁRIO
      ============================== */}
      {(podeCriar || editando) && (
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
                  onChange={(e) =>
                    setForm({ ...form, categoriaId: e.target.value })
                  }
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
      )}
    </div>
  );
}
