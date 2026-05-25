import { useEffect, useState } from "react";

export default function useProdutos(tela) {
  const [dados, setDados] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [form, setForm] = useState({
    id: null,
    nome: "",
    preco: "",
    categoriaId: "",
  });
  const [editando, setEditando] = useState(false);

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

  return {
    dados,
    categorias,
    form,
    editando,
    setForm,
    handleSubmit,
    handleEditar,
    handleRemover,
    limparFormulario,
  };
}
