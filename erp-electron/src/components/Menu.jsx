import React from "react";

const Menu = ({ tabelas = [], selecionado, setSelecionado, temaEscuro }) => {
  const baseClasses = temaEscuro
    ? "bg-[#3b240f] text-yellow-200"
    : "bg-gradient-to-r from-yellow-400 to-red-500 text-white";

  const botaoBase =
    "flex-shrink-0 px-4 py-2 rounded font-semibold transition-all duration-200";

  // Função para calcular estilo do botão
  const estilo = (nome) =>
    selecionado === nome
      ? temaEscuro
        ? "bg-yellow-500 text-black shadow-md"
        : "bg-red-700 text-white shadow-md"
      : temaEscuro
      ? "bg-[#5a3515] text-yellow-200 hover:bg-[#70421c]"
      : "bg-yellow-200 text-red-800 hover:bg-yellow-300";

  return (
    <nav className={`flex overflow-x-auto gap-2 p-2 ${baseClasses}`}>
      <button
        onClick={() => setSelecionado("dashboards")}
        className={`${botaoBase} ${estilo("dashboards")}`}
      >
        Dashboards
      </button>

      <button
        onClick={() => setSelecionado("delivery")}
        className={`${botaoBase} ${estilo("delivery")}`}
      >
        Delivery
      </button>

      {tabelas.length === 0 ? (
        <p className="px-4 py-2 italic opacity-75">Carregando menu...</p>
      ) : (
        tabelas.map((tabela) => {
          const nome =
            typeof tabela === "string"
              ? tabela
              : tabela.nome || tabela.tabela || "";

          return (
            <button
              key={nome}
              onClick={() => setSelecionado(nome.toLowerCase())}
              className={`${botaoBase} ${estilo(nome)}`}
            >
              {nome.charAt(0).toUpperCase() + nome.slice(1)}
            </button>
          );
        })
      )}
    </nav>
  );
};

export default Menu;
