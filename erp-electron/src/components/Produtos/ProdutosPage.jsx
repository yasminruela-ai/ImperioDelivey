import React, { useState } from "react";
import useProdutos from "../../hooks/useProdutos";
import ProdutosHeader from "./ProdutosHeader";
import ProdutosTable from "./ProdutosTable";
import ProdutosForm from "./ProdutosForm";
import temaEstilos from "../../utils/temaEstilos";

export default function ProdutosPage({ permissoes, temaEscuro }) {
  const [tela, setTela] = useState("categorias");
  const {
    dados,
    categorias,
    form,
    editando,
    setForm,
    handleSubmit,
    handleEditar,
    handleRemover,
    limparFormulario,
  } = useProdutos(tela);

  const estilo = temaEstilos(temaEscuro);

  const podeCriar = permissoes?.insert || false;
  const podeEditar = permissoes?.update || false;
  const podeRemover = permissoes?.delete || false;

  return (
    <div className={`p-6 space-y-6 min-h-screen ${estilo.fundo}`}>
      <ProdutosHeader tela={tela} setTela={setTela} estilo={estilo} />

      <ProdutosTable
        tela={tela}
        dados={dados}
        categorias={categorias}
        podeEditar={podeEditar}
        podeRemover={podeRemover}
        handleEditar={handleEditar}
        handleRemover={handleRemover}
        estilo={estilo}
      />

      <ProdutosForm
        tela={tela}
        form={form}
        categorias={categorias}
        editando={editando}
        setForm={setForm}
        handleSubmit={handleSubmit}
        limparFormulario={limparFormulario}
        podeCriar={podeCriar}
        estilo={estilo}
      />
    </div>
  );
}
