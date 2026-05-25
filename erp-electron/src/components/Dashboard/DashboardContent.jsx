import React from "react";
import GraficoBarra from "../Charts/ChartBar";
import GraficoPizza from "../Charts/ChartPie";
import GraficoLinha from "../Charts/ChartLine";
import Card from "./Card";

export default function DashboardContent({ temaEscuro, graficoSelecionado, dados }) {
  const meses = dados.vendasMes?.map((v) => v.mesAno) ?? [];
  const vendasMensais = dados.vendasMes?.map((v) => v.valorTotalVendido) ?? [];

  const categoriasLabels = dados.categorias?.map((v) => v.categoria) ?? [];
  const categoriasQtd = dados.categorias?.map((v) => v.quantidadeVendida) ?? [];

  const usuariosLabels = dados.vendasUsuario?.map((v) => v.usuario) ?? [];
  const usuariosQtd =
    dados.vendasUsuario?.map((v) => v.quantidadeVendida) ?? [];

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      {(graficoSelecionado === "geral" ||
        graficoSelecionado === "categorias") && (
        <Card titulo="Categorias mais vendidas" temaEscuro={temaEscuro}>
          {categoriasLabels.length ? (
            <GraficoPizza
              labels={categoriasLabels}
              valores={categoriasQtd}
              titulo="Categorias"
              nomeDataset="Vendas"
            />
          ) : (
            <p className="text-center">Sem dados.</p>
          )}
        </Card>
      )}

      {(graficoSelecionado === "geral" ||
        graficoSelecionado === "usuarios") && (
        <Card titulo="Vendas por Usuário" temaEscuro={temaEscuro}>
          {usuariosLabels.length ? (
            <GraficoBarra
              labels={usuariosLabels}
              valores={usuariosQtd}
              titulo="Usuários"
              nomeDataset="Quantidade"
            />
          ) : (
            <p className="text-center">Sem dados.</p>
          )}
        </Card>
      )}

      <Card
        titulo="Evolução das Vendas"
        temaEscuro={temaEscuro}
        className="col-span-1 md:col-span-2 xl:col-span-3"
      >
        {meses.length ? (
          <GraficoLinha
            labels={meses}
            valores={vendasMensais}
            titulo="Vendas Mensais"
            nomeDataset="R$"
          />
        ) : (
          <p className="text-center">Sem dados.</p>
        )}
      </Card>
    </div>
  );
}
