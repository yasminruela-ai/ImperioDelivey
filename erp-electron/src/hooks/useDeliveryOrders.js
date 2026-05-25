import { useEffect, useState, useCallback } from "react";

const PROXIMOS_STATUS = {
  pendente: ["aceito", "cancelado"],
  aceito: ["em_preparo", "cancelado"],
  em_preparo: ["saiu_para_entrega", "cancelado"],
  saiu_para_entrega: ["entregue"],
  entregue: [],
  cancelado: [],
};

const STATUS_LABELS = {
  pendente: "Pendente",
  aceito: "Aceito",
  em_preparo: "Em preparo",
  saiu_para_entrega: "Saiu para entrega",
  entregue: "Entregue",
  cancelado: "Cancelado",
};

export default function useDeliveryOrders() {
  const [pedidos, setPedidos] = useState([]);
  const [loading, setLoading] = useState(false);
  const [erro, setErro] = useState(null);

  const carregar = useCallback(async () => {
    setLoading(true);
    setErro(null);
    try {
      const res = await window.ipc.delivery.listar();
      if (res?.success && Array.isArray(res.data)) {
        setPedidos(res.data);
      } else {
        setErro(res?.message ?? "Erro ao carregar pedidos.");
      }
    } catch (e) {
      setErro(e.message);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    carregar();
    const intervalo = setInterval(carregar, 15000);
    return () => clearInterval(intervalo);
  }, [carregar]);

  async function alterarStatus(id, status) {
    try {
      const res = await window.ipc.delivery.atualizarStatus(id, status);
      if (res?.success) carregar();
    } catch {}
  }

  function formatarData(iso) {
    if (!iso) return "—";
    return new Date(iso).toLocaleString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  }

  function formatarPreco(v) {
    return `R$ ${Number(v).toFixed(2)}`;
  }

  const pendentes = pedidos.filter((p) => p.status === "pendente").length;

  return {
    pedidos,
    loading,
    erro,
    carregar,
    alterarStatus,
    formatarData,
    formatarPreco,
    pendentes,
    PROXIMOS_STATUS,
    STATUS_LABELS,
  };
}
