import React from "react";
import useHistorico from "../../hooks/useHistorico";
import FiltroHistorico from "./FiltroHistorico";
import TabelaHistorico from "./TabelaHistorico";

export default function Historico({ permissoes, temaEscuro }) {
  const {
    filtros,
    logs,
    atualizarFiltro,
    aplicarFiltros,
    limparFiltros,
  } = useHistorico(permissoes);

  return (
    <div
      className={`min-h-screen p-6 transition-colors duration-300 ${
        temaEscuro ? "bg-[#1b1208] text-yellow-300" : "bg-gray-50 text-gray-900"
      }`}
    >
      <h2 className="text-3xl font-bold mb-6 tracking-tight">
        Histórico de Operações
      </h2>

      <FiltroHistorico
        filtros={filtros}
        temaEscuro={temaEscuro}
        atualizarFiltro={atualizarFiltro}
        aplicarFiltros={aplicarFiltros}
        limparFiltros={limparFiltros}
      />

      <TabelaHistorico logs={logs} temaEscuro={temaEscuro} />
    </div>
  );
}
