import React from "react";

export default function FiltroHistorico({
  filtros,
  temaEscuro,
  atualizarFiltro,
  aplicarFiltros,
  limparFiltros,
}) {
  function handleFiltroChange(e) {
    atualizarFiltro(e.target.name, e.target.value);
  }

  const baseInput = `p-3 rounded-lg border w-full outline-none transition-colors`;

  const estiloInput = temaEscuro
    ? "bg-[#3b240f] border-yellow-800 text-yellow-200"
    : "bg-white border-gray-300";

  return (
    <form
      onSubmit={aplicarFiltros}
      className={`p-5 rounded-2xl shadow-xl grid gap-4 md:grid-cols-2 xl:grid-cols-4 transition-colors duration-300 ${
        temaEscuro ? "bg-[#2b1a0c]" : "bg-white"
      }`}
    >
      <input
        type="text"
        placeholder="Usuário"
        name="usuarioSistema"
        value={filtros.usuarioSistema}
        onChange={handleFiltroChange}
        className={`${baseInput} ${estiloInput}`}
      />

      <input
        type="text"
        placeholder="Operação"
        name="operacao"
        value={filtros.operacao}
        onChange={handleFiltroChange}
        className={`${baseInput} ${estiloInput}`}
      />

      <input
        type="date"
        name="dataInicio"
        value={filtros.dataInicio}
        onChange={handleFiltroChange}
        className={`${baseInput} ${estiloInput}`}
      />

      <input
        type="date"
        name="dataFim"
        value={filtros.dataFim}
        onChange={handleFiltroChange}
        className={`${baseInput} ${estiloInput}`}
      />

      <div className="flex gap-3 col-span-full flex-wrap">
        <button
          type="submit"
          className={`px-5 py-2 rounded-xl font-semibold shadow-md transition-all ${
            temaEscuro
              ? "bg-yellow-500 hover:bg-yellow-400 text-black"
              : "bg-red-600 hover:bg-red-700 text-white"
          }`}
        >
          Aplicar
        </button>

        <button
          type="button"
          onClick={limparFiltros}
          className={`px-5 py-2 rounded-xl font-semibold shadow-md transition-all ${
            temaEscuro
              ? "bg-red-600 hover:bg-red-500 text-white"
              : "bg-gray-400 hover:bg-gray-500 text-white"
          }`}
        >
          Limpar
        </button>
      </div>
    </form>
  );
}
