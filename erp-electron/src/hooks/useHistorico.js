import { useEffect, useState } from "react";

export default function useHistorico(permissoes) {
  const podeVisualizar = permissoes?.select || false;

  const [filtros, setFiltros] = useState({
    usuarioSistema: "",
    operacao: "",
    dataInicio: "",
    dataFim: "",
  });

  const [logs, setLogs] = useState([]);

  async function carregarLogs() {
    if (!podeVisualizar) return;

    try {
      const res = await window.ipc.historico.listar(filtros);
      setLogs(res?.success && Array.isArray(res.data) ? res.data : []);
    } catch (err) {
      console.error(err);
      setLogs([]);
    }
  }

  useEffect(() => {
    carregarLogs();
  }, []);

  function atualizarFiltro(key, value) {
    setFiltros((prev) => ({ ...prev, [key]: value }));
  }

  async function limparFiltros() {
    setFiltros({
      usuarioSistema: "",
      operacao: "",
      dataInicio: "",
      dataFim: "",
    });
    await carregarLogs();
  }

  async function aplicarFiltros(e) {
    e.preventDefault();
    await carregarLogs();
  }

  return {
    filtros,
    logs,
    podeVisualizar,
    atualizarFiltro,
    limparFiltros,
    aplicarFiltros,
  };
}
