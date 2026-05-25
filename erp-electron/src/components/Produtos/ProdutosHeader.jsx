export default function ProdutosHeader({ tela, setTela, estilo }) {
  return (
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
  );
}
