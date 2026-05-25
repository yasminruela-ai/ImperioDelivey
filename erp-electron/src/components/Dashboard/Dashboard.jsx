import React, { useState } from "react";
import useDashboardData from "../../hooks/useDashboardData";
import DashboardContent from "./DashboardContent";
import DashButton from "./DashButton";

export default function Dashboard({ temaEscuro }) {
  const { carregando, dados } = useDashboardData();
  const [graficoSelecionado, setGraficoSelecionado] = useState("geral");

  return (
    <main
      className={`flex-1 p-6 transition-colors duration-300 ${
        temaEscuro ? "bg-[#2a1a10] text-yellow-200" : "bg-yellow-50"
      }`}
    >
      <h2 className="text-3xl font-bold mb-6 text-center">Dashboard</h2>

      {/* Botões */}
      <div className="flex flex-wrap justify-center gap-3 mb-6">
        <DashButton
          ativo={graficoSelecionado === "geral"}
          onClick={() => setGraficoSelecionado("geral")}
          temaEscuro={temaEscuro}
        >
          Geral
        </DashButton>

        <DashButton
          ativo={graficoSelecionado === "categorias"}
          onClick={() => setGraficoSelecionado("categorias")}
          temaEscuro={temaEscuro}
        >
          Categorias
        </DashButton>

        <DashButton
          ativo={graficoSelecionado === "usuarios"}
          onClick={() => setGraficoSelecionado("usuarios")}
          temaEscuro={temaEscuro}
        >
          Usuários
        </DashButton>
      </div>

      {carregando ? (
        <p className="text-center text-lg mt-10">Carregando dashboard...</p>
      ) : (
        <DashboardContent
          temaEscuro={temaEscuro}
          graficoSelecionado={graficoSelecionado}
          dados={dados}
        />
      )}
    </main>
  );
}
