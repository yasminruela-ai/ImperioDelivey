import { useEffect, useState } from "react";

export default function usePedidos(permissoes) {
  const [categorias, setCategorias] = useState([]);
  const [produtos, setProdutos] = useState([]);
  const [categoriaAtiva, setCategoriaAtiva] = useState(null);
  const [cliente, setCliente] = useState("");
  const [carrinho, setCarrinho] = useState([]);
  const [pedidos, setPedidos] = useState([]);
  const [loading, setLoading] = useState(false);
  const [visivelQtd, setVisivelQtd] = useState({});
  const [qtdInputs, setQtdInputs] = useState({});

  const podeCriar = permissoes?.insert ?? true;
  const podeEditar = permissoes?.update ?? true;
  const podeRemover = permissoes?.delete ?? true;

  const STATUSES = ["pendente", "pronto", "entregue", "pago", "cancelado"];

  useEffect(() => {
    carregar();
    carregarPedidos();
  }, []);

  async function carregar() {
    setLoading(true);
    try {
      const cats = await window.ipc.categorias.listar();
      const prods = await window.ipc.produtos.listar();

      setCategorias(
        cats?.success && Array.isArray(cats.data)
          ? cats.data
          : Array.isArray(cats)
          ? cats
          : []
      );

      setProdutos(
        prods?.success && Array.isArray(prods.data)
          ? prods.data
          : Array.isArray(prods)
          ? prods
          : []
      );

      setCategoriaAtiva(
        cats?.success && cats.data?.[0]?.idCategorias ||
          cats?.[0]?.idCategorias ||
          null
      );
    } finally {
      setLoading(false);
    }
  }

  async function carregarPedidos() {
    try {
      const res = await window.ipc.vendas.listar();
      if (res?.success && Array.isArray(res.data)) setPedidos(res.data);
      else if (Array.isArray(res)) setPedidos(res);
    } catch {
      setPedidos([]);
    }
  }

  function abrirQuantidade(prod) {
    setVisivelQtd((s) => ({ ...s, [prod.idProdutos]: !s[prod.idProdutos] }));
    setQtdInputs((s) => ({ ...s, [prod.idProdutos]: s[prod.idProdutos] ?? 1 }));
  }

  function alterarInputQtd(prodId, val) {
    const v = Number(val);
    if (!Number.isFinite(v) || v < 1) return;
    setQtdInputs((s) => ({ ...s, [prodId]: Math.floor(v) }));
  }

  function adicionarAoCarrinho(prod) {
    const qtd = Number(qtdInputs[prod.idProdutos] ?? 1);
    if (!qtd || qtd <= 0) return;

    setCarrinho((old) => {
      const idx = old.findIndex((i) => i.produtoId === prod.idProdutos);

      if (idx >= 0) {
        const copia = [...old];
        copia[idx].quantidade = Number(copia[idx].quantidade) + qtd;
        copia[idx].subtotal = copia[idx].quantidade * copia[idx].preco;
        return copia;
      }

      return [
        ...old,
        {
          produtoId: prod.idProdutos,
          nome: prod.nome,
          preco: Number(prod.preco),
          quantidade: qtd,
          subtotal: Number(prod.preco) * qtd,
        },
      ];
    });

    setVisivelQtd((s) => ({ ...s, [prod.idProdutos]: false }));
  }

  function removerItem(produtoId) {
    setCarrinho((old) => old.filter((i) => i.produtoId !== produtoId));
  }

  function mudarQtd(produtoId) {
    const item = carrinho.find((i) => i.produtoId === produtoId);
    if (!item) return;

    const nova = prompt("Nova quantidade:", String(item.quantidade));
    if (nova === null) return;

    const qtd = Number(nova);
    if (!qtd || qtd <= 0) return;

    setCarrinho((old) =>
      old.map((i) =>
        i.produtoId === produtoId
          ? { ...i, quantidade: qtd, subtotal: qtd * i.preco }
          : i
      )
    );
  }

  const total = carrinho.reduce((s, it) => s + Number(it.subtotal), 0);

  async function confirmarPedido() {
    if (!podeCriar) return alert("Sem permissão para criar pedidos.");
    if (!cliente.trim()) return alert("Informe o nome do cliente.");
    if (!carrinho.length) return alert("Adicione itens ao pedido.");

    const itens = carrinho.map((i) => ({
      produtoId: i.produtoId,
      quantidade: i.quantidade,
    }));

    try {
      const res = await window.ipc.vendas.registrar(cliente.trim(), null, itens);

      if (res?.success) {
        setCliente("");
        setCarrinho([]);
      }

      carregarPedidos();
    } catch {
      alert("Erro ao criar pedido.");
    }
  }

  async function alterarStatus(id, novoStatus) {
    if (!podeEditar) return alert("Sem permissão.");

    try {
      const res = await window.ipc.vendas.atualizarStatus(id, novoStatus);
      if (res?.success) carregarPedidos();
    } catch {}
  }

  async function verItens(p) {
    try {
      const id = p.idVendas ?? p.id ?? p.idVenda;
      const res = await window.ipc.vendas.buscarPorId(id);
      const itens = res?.success ? res?.data?.itens ?? [] : [];

      const txt = itens
        .map(
          (it) =>
            `${it.produto_nome ?? "Produto"} — qtd:${it.quantidade} — R$ ${(
              Number(it.precoUnitario) ||
              Number(it.preco) ||
              0
            ).toFixed(2)}`
        )
        .join("\n");

      alert(txt || "Sem itens.");
    } catch {
      alert("Erro ao obter itens");
    }
  }

  function formatPrice(v) {
    return `R$ ${Number(v).toFixed(2)}`;
  }

  return {
    categorias,
    produtos,
    categoriaAtiva,
    setCategoriaAtiva,
    cliente,
    setCliente,
    carrinho,
    pedidos,
    loading,
    visivelQtd,
    qtdInputs,
    podeCriar,
    podeEditar,
    podeRemover,
    STATUSES,
    abrirQuantidade,
    alterarInputQtd,
    adicionarAoCarrinho,
    removerItem,
    mudarQtd,
    confirmarPedido,
    alterarStatus,
    verItens,
    formatPrice,
    total,
    produtosFiltrados: produtos.filter(
      (p) => p.categorias_idCategorias === categoriaAtiva
    ),
  };
}
